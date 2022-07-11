[![actions](https://github.com/cbezmen/microservices/actions/workflows/maven.yml/badge.svg)](https://github.com/cbezmen/microservices/actions)
[![codecov](https://codecov.io/gh/cbezmen/microservices/branch/master/graph/badge.svg?token=FD1C9DADQA)](https://codecov.io/gh/cbezmen/microservices)

# Spring Kubernetes Example

Example Spring cloud kubernetes project. Run in local&kubernetes environment.

## Compile Projects

You can compile projects via:

### Local Development:

> You need docker up and running in local environment.

1. Before Running apps from you favorite IDE apply configs in local kube env
   ```shell
   $ bash build.sh apply-config-k8
   ```
   You can remove config via
   ```shell
   $ bash build.sh remove-config-k8
   ```
1. Check applications on local environment
    1. Address Endpoint
       ```shell
       $ curl http://localhost:8081/address/1
       ```
    1. User Endpoint which calls address domain
       ```shell
       $ curl http://localhost:8080/users/1
       ```
    1. Get environment configs
       ```shell
       $ curl http://localhost:8080/config
       ```

### Kubernetes:

> Please check ingress for kubernetes environment. [Check Adding Ingress](#add-ingress)

1. Compile project and build docker images
    ```shell
    $ bash build.sh compile
    ```
1. Start Kubernetes deployments, services and ingress
    ```shell
    $ bash build.sh start-k8
    ```
1. Scale Kubernetes deployments
    ```shell
    $ bash build.sh start-k8 scale=2
    ```
1. Stop Kubernetes deployments, services and ingress
    ```shell
    $ bash build.sh stop-k8
    ```
1. Check applications on kubernetes
    1. Address Endpoint
       ```shell
       $ curl http://localhost:31001/address/1
       ```
    1. User Endpoint which calls address domain
       ```shell
       $ curl http://localhost:31000/users/1
       ```
    1. Get environment configs
       ```shell
       $ curl http://localhost:31000/config
       ```
1. Access via Ingress
    1. Address Endpoint
       ```shell
       $ curl http://localhost/address-api/address/1
       ```
    1. User Endpoint which calls address domain
       ```shell
       $ curl http://localhost/user-api/users/1
       ```
    1. Get environment configs
       ```shell
       $ curl http://localhost/user-api/config
       ```
1. Update Configuration
    1. Update configuration file in user-docker config and refresh actuator via endpoint.
    ```shell
    $ curl -X POST http://localhost/user-api/actuator/refresh
    ```

### <a name="add-ingress"></a>Add Ingress

> Please read documentation for adding ingress if you are not using mac
https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac

This command add ingress to your docker desktop kubernetes.

```shell
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/cloud/deploy.yaml 
```

### Istio:

1. Install Istio
    ```shell
    $ export ISTIO_VERSION=1.13.3
    $ curl -L https://istio.io/downloadIstio | sh -
    $ export PATH="$PATH:/root/istio-${ISTIO_VERSION}/bin"
    $ istioctl install --set profile=demo -y
    $ kubectl get deployments,services -n istio-system
    $ istioctl version
    $ istioctl manifest generate --set profile=demo > $HOME/istio-generated-manifest.yaml
    $ istioctl verify-install -f $HOME/istio-generated-manifest.yaml
    ```
2. Install Istio Integrations
    ```shell
    $ SEMVER_REGEX='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    $ INTEGRATIONS_VERSION=$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\1#").$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\2#") && echo $INTEGRATIONS_VERSION
    $ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/prometheus.yaml
    $ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/grafana.yaml
    $ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/jaeger.yaml
    $ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/kiali.yaml
    ```
3. Envoy Injection
    ```shell
    $ kubectl label namespace default istio-injection=enabled
    ```
4. Add Addresses to /etc/hosts
    ```shell
    127.0.0.1 grafana.localhost
    127.0.0.1 prometheus.localhost
    127.0.0.1 kiali.localhost
    127.0.0.1 tracing.localhost
    ```
5. Compile project and build docker images
    ```shell
    $ bash build-istio.sh compile
    ```
6. Start Kubernetes deployments, services and ingress
    ```shell
    $ bash build-istio.sh start-k8
    ```
7. Scale Kubernetes deployments
    ```shell
    $ bash build-istio.sh start-k8 scale=2
    ```
8. Stop Kubernetes deployments, services and ingress
    ```shell
    $ bash build-istio.sh stop-k8
    ```
### Cli Versions

|            Cli            | Version |
| :-----------------------: | :-----: |
|          docker           | 20.10.5 |
| docker desktop kubernetes | v1.19.7 |
|            mvn            |  3.8.1  |

![Deadline gif](https://i.imgur.com/7ntFRIT.gif)
