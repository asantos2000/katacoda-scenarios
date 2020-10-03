Istio is installed in two parts. The first part involves the CLI tooling that will be used to deploy and manage Istio backed services. The second part configures the Kubernetes cluster to support Istio.

## Install CLI tooling

The following command will install the Istio 0.7.1 release.

`export ISTIO_VERSION=1.7.3`{{execute}}

`export TARGET_ARCH=x86_64`{{execute}}

`curl -L https://istio.io/downloadIstio | sh -`{{execute}}

After it has successfully run, add the bin folder to your path.

`export PATH=$PWD/istio-$ISTIO_VERSION/bin:$PATH`{{execute}}

## Install Istio

The basic components of Istio, for more options see [Installation Configuration Profiles](https://istio.io/latest/docs/setup/additional-setup/config-profiles/).

`istioctl install --set profile=demo`{{execute}}

This will deploy Pilot, Mixer, Ingress-Controller, and Egress-Controller.

## Inject istio side car

Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later:

`kubectl label namespace default istio-injection=enabled`{{execute}}

## Check Status

All the services are deployed as Pods. Once they're running, Istio is correctly deployed.

`kubectl get pods -n istio-system`{{execute}}
