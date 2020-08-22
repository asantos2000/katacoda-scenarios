This was tricky, you found a total of 4 problems all causing the HPA not to work.

- A syntax type error related to the CPU percentage setting
- Deployed to the wrong namespace
- `maxreplicas` should be larger than the `minreplicas`, such as `maxreplicas: 10`
- The name of the Pod and the target of the HPA was wrong, should not have been `pep-apache`, but rather `php-apache`.

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: apache-hpa
  namespace: default
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  targetCPUUtilizationPercentage: 40
```
These are all mistakes that anyone can make, especially if you are going to fast, not being careful, and not understanding how the declaration works.
