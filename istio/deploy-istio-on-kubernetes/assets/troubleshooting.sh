kubectl get pods -l app=istio-ingressgateway -n istio-system

kubectl describe pod/istio-ingressgateway-66c76dfc5f-mxzbz -n istio-system

istioctl proxy-config route istio-ingressgateway-66c76dfc5f-mxzbz -n istio-system

istioctl proxy-config route istio-ingressgateway-66c76dfc5f-mxzbz.istio-system

istioctl proxy-config bootstrap k360api-deployment-7cbd8fcc4d-dg864.k360api

kubectl logs -f --all-containers -l app=istio-ingressgateway -n istio-system

kubectl logs -f -c istio-proxy -l app.kubernetes.io/name=whatsapp-kbot -n whatsapp