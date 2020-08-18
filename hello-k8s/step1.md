Vamos conhecer o seu cluster.

## Tarefas

Primeiro **comando** que você deve conhecer é como obter informações sobre o seu cluster.

`kubectl cluster-info`{{execute}}

Você pode verificar quais namespaces existem no seu cluster.

`kubectl get namespaces`{{execute}}

E acessar os recursos de um namespace.

`kubectl get pods -n kube-public`{{execute}}

Ou todos os recursos.

`kubectl get pods --all-namespaces`{{execute}}
