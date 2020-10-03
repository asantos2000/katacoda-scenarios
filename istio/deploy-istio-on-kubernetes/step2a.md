The previous step deployed the istiod, istio-ingressgateway, and istio-egressgateway.

[**istiod**](https://istio.io/latest/blog/2020/tradewinds-2020/#fewer-moving-parts) is the control plane, it provides service discovery, configuration and certificate management, and it's compose of:

[**Envoy**](https://istio.io/latest/docs/ops/deployment/architecture/) is part of data plane. Istio uses an extended version of the [Envoy](https://envoyproxy.github.io/envoy/) proxy. Envoy is a high-performance proxy developed in C++ to mediate all inbound and outbound traffic for all services in the service mesh. Envoy proxies are the only Istio components that interact with data plane traffic..

**Ingress/Egress** - They are Envoys deployed sololed and responsible for let data get in and out of the cluster.

The overall architecture is shown below.

![Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/arch.svg)
Source: <https://istio.io>
