Usando helm.

## Tarefa

### Instalar

Instalar um servidor de web usando [helm](https://helm.sh/docs/).

Adicionando um repositório externo (fora do docker.io)

`helm repo add bitnami https://charts.bitnami.com/bitnami`{{execute}}

Instalando a imagem com helm.

`/root/example/values.yaml`{{open}}

Iremos customizar o deploy com os seguintes valores:

<pre code class="yaml">
service:
  nodePorts:
    http: "30170"
    https: "30173"
  type: NodePort
</pre>

`helm install my-release -f /root/example/values.yaml bitnami/nginx`{{execute}}

Um parâmetro foi customizado, que indica que tipo de serviço será criado.

Você pode ver todos os parâmetros disponíveis para essa imagem no arquivo [values.yaml](https://github.com/bitnami/charts/blob/master/bitnami/nginx/values.yaml).

### Verificando

Listando os apps instalados.

`helm list`{{execute}}

Verificando o que foi criado:

`kubectl get deploy,svc`{{execute}}

Listando os valores que foram utilizados no `helm install`:

`helm get values my-release`{{execute}}

Listando todos os valores computados:

`helm get values my-release -a`{{execute}}

Acessando a aplicaçãp:

`curl http://localhost:30170`{{execute T2}}

Ou com um navegador:

`lynx http://localhost:30170`{{execute T2}}
