Your goal is to apply a HPA declaration to instruct the HPA controller to scale your php-apache Pods.

Inspect the YAML manifest.

`ccat hpa.yaml`{{execute T1}}

Apply these HPA rules.

`kubectl apply -f hpa.yaml`{{execute T1}}

However, for this puzzler, something is wrong.

For this puzzler, try editing the hpa.yaml file with `edit` (vi, vim) and try to correct the syntax error.

`vi hpa.yaml`{{execute}}

In the vi editor type 'I' for insert, make you edit, and type `esc + :` then `wq` to save and exit. Once corrected, try again.

> Vi is my favorite text editor. I've been using it for years...I can't figure out how to exit. `¯\_(ツ)_/¯`

Try again.

`kubectl apply -f hpa.yaml`{{execute T1}}

Still getting an error, re-edit the YAML. If the command was successful inspect the new HPA object.

`kubectl get hpa -A`{{execute T1}}

Inspect the state of the HPA with the describe command.

`kubectl describe hpa -A`{{execute T1}}

If the HPA resource is not present, then something is still wrong. Once the HPA is successfully submitted, the Continue button will allow you to move to the next step.
