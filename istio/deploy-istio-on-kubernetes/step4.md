To showcase Istio, a BookInfo web application has been created. This sample deploys a simple application composed of four separate microservices which will be used to demonstrate various features of the Istio service mesh.

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/platform/kube/bookinfo.yaml`{{execute}}

## Check Status

`watch kubectl get pods`{{execute}}

> To continue hit <kbd>Ctrl</kbd>+<kbd>C</kbd> on terminal.`echo "Ready to go."`{{execute interrupt}}

When the Pods are starting, you may see initiation steps happening as the container is created. This is configuring the Envoy sidecar for handling the traffic management and authentication for the application within the Istio service mesh.

Those are the services configured for the application:

`kubectl get services`{{execute}}

And we can verify if everything is working correctly calling the product page:  

`kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"`{{execute}}

### Open the application to outside traffic

Associate this application with the Istio gateway configuring an ingress-gateway and a virtual service:

`kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/bookinfo-gateway.yaml`{{execute}}

Ensure that there are no issues with the configuration:

`istioctl analyze`{{execute}}

Once finished the application can be accessed via the path _/productpage_.

The ingress routing information can be viewed issuing the commands `kubectl describe gateway`{{execute}} and `kubectl describe virtualservice`{{execute}}

Let's define some environment variables:

The ingress gateway port:

`export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')`{{execute}}

The ingress gateway secure port:

`export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')`{{execute}}

Now we can access ther product page using one of this ports:

http://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].[[KATACODA_DOMAIN]]/productpage

https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].[[KATACODA_DOMAIN]]/productpage

The architecture of the application is described in the next step.
