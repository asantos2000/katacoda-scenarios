## Install add-ons and extras

Istio integrates with several different telemetry applications.

Use the following instructions to deploy the Kiali dashboard, along with Prometheus, Grafana, Zipkin, and Jaeger.

First install kiali CRD: `kubectl apply -f kiali-crds.yaml`{{execute}}

`kubectl apply -f $ISTIO_HOME/samples/addons`{{execute}}

`kubectl apply -f $ISTIO_HOME/samples/addons/extras/zipkin.yaml`{{execute}}

> We install kiali CRD becouse of error `unable to recognize "istio-1.7.3/samples/addons/kiali.yaml": no matches for kind "MonitoringDashboard" in version "monitoring.kiali.io/v1alpha1"`. Check if it's still necessary for future versions.

**Scope**

It's not part of Istio download package, but it can be deployed onto a Kubernetes cluster with the command `kubectl create -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml'`{{execute}}

Wait for it to be deployed by checking the status of the pods using `kubectl get pods -n weave`{{execute}}

## Check Status

As with Istio, these add-ons are deployed via Pods.

`watch kubectl get pods -n istio-system`{{execute}}

> Before continue hit <kbd>Ctrl</kbd>+<kbd>C</kbd> on terminal. `echo "Ready to go."`{{execute interrupt}}

With Istio's insight into how applications communicate, it can generate profound insights into how applications are working and performance metrics.

## Create services

To access services outside the cluster, we create services for each add-on.

`kubectl apply -f services-addons.yaml`{{execute}}

They are (-np):

`kubectl get svc -n istio-system`{{execute}}

> `NodePort` for those services is not the only option, but it's easier :). On cloud providers, you could use the type `LoadBalancer`.

## Generate Load

Make view the graphs, there first needs to be some traffic. Execute the command below to send requests to the application.

`
while true; do
  curl -s https://[[HOST_SUBDOMAIN]]-30446-[[KATACODA_HOST]].environments.katacoda.com/productpage > /dev/null
  echo -n .;
  sleep 0.2
done
`{{execute}}

## Access Dashboards

With the application responding to traffic the graphs will start highlighting what's happening under the covers.

## Grafana

[Grafana](https://grafana.com/grafana/) allows you to query, visualize, alert on and understand your metrics no matter where they are stored. Create, explore, and share dashboards with your team and foster a data driven culture:

https://[[HOST_SUBDOMAIN]]-30000-[[KATACODA_HOST]].environments.katacoda.com/dashboard/db/istio-dashboard

As Istio is managing the entire service-to-service communication, the dashboard will highlight the aggregated totals and the breakdown on an individual service level.

## Zipkin

[Zipkin](https://zipkin.io/) is a distributed tracing system. It helps gather timing data needed to troubleshoot latency problems in service architectures. Features include both the collection and lookup of this data.

http://[[HOST_SUBDOMAIN]]-30941-[[KATACODA_HOST]].environments.katacoda.com/zipkin/

Click on a span to view the details on an individual request and the HTTP calls made. This is an excellent way to identify issues and potential performance bottlenecks.

## Kiali

[Kiali](https://kiali.io/) is a management console for Istio-based service mesh. It provides dashboards, observability and lets you to operate your mesh with robust configuration and validation capabilities.

http://[[HOST_SUBDOMAIN]]-32001-[[KATACODA_HOST]].environments.katacoda.com/

## Jaeger

[Jaeger](https://www.jaegertracing.io/), inspired by Dapper and OpenZipkin, is a distributed tracing system released as open source by Uber Technologies. It is used for monitoring and troubleshooting microservices-based distributed systems.

http://[[HOST_SUBDOMAIN]]-30080-[[KATACODA_HOST]].environments.katacoda.com/

Before continuing, stop the traffic process with <kbd>Ctrl</kbd>+<kbd>C</kbd>. `echo "Ready to go."`{{execute interrupt}}

## Scope

View Scope on port 4040 at https://[[HOST_SUBDOMAIN]]-30404-[[KATACODA_HOST]].environments.katacoda.com/