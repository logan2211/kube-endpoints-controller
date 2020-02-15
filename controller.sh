#!/bin/bash

set -e

POLLING_INTERVAL="${POLLING_INTERVAL:-1}"

function start_watch() {
    exec 5< <(kubectl get endpoints -l "${ENDPOINT_SELECTOR}"  --watch-only)
}

function get_endpoints_json() {
    kubectl get endpoints -l "${ENDPOINT_SELECTOR}" -o json |\
    jq -c .items[].subsets |\
    jq -cs add
}

function update_endpoints() {
    local endpoint_name="${MANAGED_ENDPOINT}"
    local subsets=$(get_endpoints_json)

    echo "Endpoint update: ${subsets}"

    export endpoint_name subsets
    envsubst < endpoint.yaml.tmpl | kubectl apply -f -
}

: "${ENDPOINT_SELECTOR?An ENDPOINT_SELECTOR must be set}"
: "${MANAGED_ENDPOINT?A MANAGED_ENDPOINT must be set}"

while true; do
    if ! { <&5; } 2<> /dev/null; then
        # fd does not exist yet
        echo "Starting watch and performing initial update"
        start_watch
        update_endpoints
    fi

    # Read ALL output (until EOF)
    read -u5 -t "${POLLING_INTERVAL}" -d "$(echo -e '\004')" kubectl_output || CODE=$?

    if [ "$CODE" -eq 1 ]; then
        echo "Restarting watch"
        start_watch
    elif [ -n "${kubectl_output}" ]; then
        echo "Watch returned updated resources, updating endpoints"
        update_endpoints
    elif [ "$CODE" -eq 142 ]; then
        # Read timed out, no change
        sleep 1
        continue
    else
        echo $?
        echo "Unknown read exit code: $?"
        exit 1
    fi
done
