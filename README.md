# kube-endpoints-controller

Kubernetes controller used to combine the endpoints from multiple services with
a common label into a single service. This can be used used to expose multiple
services using different ports/pod combinations under a single loadbalancer.

## Installing

* Configure `ENDPOINT_SELECTOR` environment in the environment
  This is the common label that will be used to select endpoints to add to the
  consolidated service's endpoint
* Configure `MANAGED_ENDPOINT` to the name of the frontend service that will
  be the recipient of the selected endpoints. This service should not have a
  selector defined.

See the `example/` path for an example deployment.

## Authors

* **Logan V.** - [logan2211](https://github.com/logan2211)

See also the list of [contributors](https://github.com/logan2211/kube-endpoints-controller/contributors) who participated in this project.

## License

 [Apache2](LICENSE)
