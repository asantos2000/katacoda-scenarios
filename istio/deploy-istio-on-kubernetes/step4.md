To showcase Istio, a BookInfo web application has been created. This sample deploys a simple application composed of four separate microservices which will be used to demonstrate various features of the Istio service mesh.

Before that, let's check if Istio automatic sidecar injection is enable for the namespace:

`kubectl describe ns default`{{execute}}

And It's enabled, see the label `istio-injection=enabled` in the namespace, it's all we need, it will add an envoy sidecar to any deployment this namespace.

Now we can apply the configuration:

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/platform/kube/bookinfo.yaml`{{execute}}

## Check Status

`watch kubectl get pods`{{execute}}

Note that now our PODs have a second container, the `2/2` on the `READY` column means there are two containers and both are ready.

> To continue hit <kbd>Ctrl</kbd>+<kbd>C</kbd> on terminal.`echo "Ready to go."`{{execute interrupt}}

When the Pods are starting, you may see initiation steps happening as the container is created. This is configuring the Envoy sidecar for handling the traffic management and authentication for the application within the Istio service mesh.

Those are the services configured for the application:

`kubectl get services`{{execute}}

And we can verify if everything is working correctly calling the product page:  

`kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"`{{execute}}

### Open the application to outside traffic

At this point, there are no differences of any regular deployment besides the addition of sidecars, now it's time to start configuring them.

Associate this application with the Istio gateway configuring an ingress gateway and a virtual service:

`istio-1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml`{{open}}

`kubectl apply -f istio-1.7.3/samples/bookinfo/networking/bookinfo-gateway.yaml`{{execute}}

Ensure that there are no issues with the configuration:

`istioctl analyze`{{execute}}

Once finished the application can be accessed via the path _/productpage_.

The ingress routing information can be viewed issuing the commands `kubectl describe gateway`{{execute}} and `kubectl describe virtualservice`{{execute}}

Let's define some environment variables:

The ingress gateway port:

`export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')`{{execute}}

Now we can access ther product page using one of this ports:

`echo https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].[[KATACODA_DOMAIN]]/productpage`{{execute}}

And the api url is:

`echo https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].[[KATACODA_DOMAIN]]/api/v1/products`{{execute}}

The architecture of the application is described in the next step.
