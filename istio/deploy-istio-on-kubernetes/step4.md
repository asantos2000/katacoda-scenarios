To showcase Istio, a BookInfo web application has been created. This sample deploys a simple application composed of four separate microservices which will be used to demonstrate various features of the Istio service mesh.

When deploying an application that will be extended via Istio, the Kubernetes YAML definitions are extended via _kube-inject_. This will configure the services proxy sidecar (Envoy), Mixers, Certificates and Init Containers.

`kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/platform/kube/bookinfo.yaml`{{execute}}

## Check Status

`kubectl get pods`{{execute}}

When the Pods are starting, you may see initiation steps happening as the container is created. This is configuring the Envoy sidebar for handling the traffic management and authentication for the application within the Istio service mesh.

And services

`kubectl get services` {{execute}}

Verify everything is working correctly 

`kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"`{{execute}}

### Open the application to outside traffic

Associate this application with the Istio gateway:

`kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/bookinfo-gateway.yaml`{{execute}}

Ensure that there are no issues with the configuration:

`istioctl analyze`{{execute}}

Once running the application can be accessed via the path _/productpage_.

The ingress routing information can be viewed using `kubectl describe ingress`{{execute}}

`export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')`{{execute}}

`export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')`{{execute}}

`export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')`{{execute}}

`echo http://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].[[KATACODA_DOMAIN]]/productpage`{{execute}}

The architecture of the application is described in the next step.
