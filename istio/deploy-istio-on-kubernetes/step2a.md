The previous step deployed the Istio Pilot, Mixer, Ingress-Controller, and Egress-Controller, and the Istio CA (Certificate Authority).

* **Pilot** - Responsible for configuring the Envoy and Mixer at runtime.

* **Envoy** - Sidecar proxies per microservice to handle ingress/egress traffic between services in the cluster and from a service to external services. The proxies form a secure microservice mesh providing a rich set of functions like discovery, rich layer-7 routing, circuit breakers, policy enforcement and telemetry recording/reporting functions.

* **Mixer** - Create a portability layer on top of infrastructure backends. Enforce policies such as ACLs, rate limits, quotas, authentication, request tracing and telemetry collection at an infrastructure level.

* **Ingress/Egress** - Configure path based routing.

The overall architecture is shown below.

![Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/arch.svg)
Source: <https://istio.io>
