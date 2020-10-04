One of the main features of Istio is its traffic management. As a Microservice architectures scale, there is a requirement for more advanced service-to-service communication control.

## User Based Testing

One aspect of traffic management is controlling traffic routing based on the HTTP request, such as user agent strings, IP address or cookies.

The example below will send all traffic for the user "jason" to the reviews:v2, meaning they'll only see the black stars.

`$ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-jason-v2-v3.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-jason-v2-v3.yaml`{{execute}}

Visit the product page `echo https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].environments.katacoda.com/productpage`{{execute}} and signin as a user jason (password jason)

## Traffic Shaping for Canary Releases

The ability to split traffic for testing and rolling out changes is important. This allows for A/B variation testing or deploying canary releases.

The rule below ensures that 50% of the traffic goes to reviews:v1 (no stars), or reviews:v3 (red stars).

`$ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml`{{execute}}

_Note:_ The weighting is not round robin, multiple requests may go to the same service.

## New Releases

Given the above approach, if the canary release were successful then we'd want to move 100% of the traffic to reviews:v3.

`$ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-v3.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-v3.yaml`{{execute}}

## List All Routes

It's possible to get a list of all the rules applied using `istioctl proxy-status`{{execute}}

To see a route of particular pod run `istioctl proxy-config route $(kubectl get pods -l app=productpage -o jsonpath='{.items[*].metadata.name}').default`

