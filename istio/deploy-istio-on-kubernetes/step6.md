One of the main features of Istio is its traffic management. As a Microservice architectures scale, there is a requirement for more advanced service-to-service communication control.

## Route all to v1

In this case, the virtual services will route all traffic to `v1` of each microservice.

Open `istio-1.8.1/samples/bookinfo/networking/virtual-service-all-v1.yaml`{{open}} on editor.

Install on cluster with `kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-all-v1.yaml`{{execute}} command.

And show them with: `kubectl get destinationrules -o yaml`{{execute}}

Test it accessing the product page at `echo https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].environments.katacoda.com/productpage`{{execute}}

> Keep it open, you'll use it a lot in this step.

## Route based on user identity

One aspect of traffic management is controlling traffic routing based on the HTTP request, such as user agent strings, IP address or cookies.

The example below will send all traffic for the user "jason" to the reviews:v2, meaning they'll only see the black stars.

`istio-1.8.1/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml`{{execute}}

Visit the product page `echo https://[[HOST_SUBDOMAIN]]-$INGRESS_PORT-[[KATACODA_HOST]].environments.katacoda.com/productpage`{{execute}} and signin as a user jason (password any) to see the difference.

## Traffic Shaping for Canary Releases

The ability to split traffic for testing and rolling out changes is important. This allows for A/B variation testing or deploying canary releases.

The rule below ensures that 50% of the traffic goes to reviews:v1 (no stars), or reviews:v3 (red stars).

`istio-1.8.1/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml`{{execute}}

_Note:_ The weighting is not round robin, multiple requests may go to the same service.

Test it on product page.

## New Releases

Given the above approach, if the canary release were successful then we'd want to move 100% of the traffic to reviews:v3.

`istio-1.8.1/samples/bookinfo/networking/virtual-service-reviews-v3.yaml`{{open}}

`kubectl apply -f $ISTIO_HOME/samples/bookinfo/networking/virtual-service-reviews-v3.yaml`{{execute}}

Test it again on product page.

Did you realize that all changes have zero downtime?

## List All Routes

It's possible to get a list of all the rules applied using `istioctl proxy-status`{{execute}}

To see a route of particular pod run `istioctl proxy-config route $(kubectl get pods -l app=productpage -o jsonpath='{.items[*].metadata.name}').default`{{execute}}

## Cleanup

If you mess up or want to start over, there a script at `istio-1.8.1/samples/bookinfo/platform/kube/cleanup.sh`.Run it on the terminal and it'll restore the configuration back to the beginning of step 4.
