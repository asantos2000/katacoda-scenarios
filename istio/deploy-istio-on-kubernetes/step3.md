# View the dashboard

Istio integrates with several different telemetry applications.

Use the following instructions to deploy the Kiali dashboard, along with Prometheus, Grafana, and Jaeger.

`kubectl apply -f $ISTIO_HOME/samples/addons`{{execute)}

> if return `unable to recognize "istio-1.7.3/samples/addons/kiali.yaml": no matches for kind "MonitoringDashboard" in version "monitoring.kiali.io/v1alpha1"` try install kiali CRD first: `kubectl apply -f kiali-crds.yaml`{{execute}}.

Wait for kiali is ready:

`while ! kubectl wait --for=condition=available --timeout=600s deployment/kiali -n istio-system; do sleep 1; done`{{execute}}

## Check Status

As with Istio, these addons are deployed via Pods.

`watch kubectl get pods -n istio-system`{{execute}}

> CTRL + C on terminal to exit
