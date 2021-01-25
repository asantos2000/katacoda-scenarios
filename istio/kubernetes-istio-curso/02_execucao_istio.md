## Acessando o k8s

Primeiramente vamos verificar se estamos acessando o cluster de kubernetes.

Vamos verificar como estão os nós do nosso cluster:

`kubectl get nodes`{{execute}}

> [Opcional] Algumas instalações colocam o arquivo de configuração do kubernetes no caminho `~/.kube/config` e pode ser necessário configurar a variável de ambiente KUBECONFIG para apontar para este arquivo. Caso você obteve o arquivo de config de um cluster externo (AKS, EKS, GKE, etc), você deverá configurar esta variável `export KUBECONFIG=~/.kube/config`{{execute}}

No katacoda o ambiente já está configurado e não é necessário nenhuma configuração adicional.

> [Opcional] Se você tem mais de um cluster na configuração, verifique se está apontando para o correto. `kubectl config get-contexts`{{execute}}

## Instalando o Istio (linux ou mac)

Para instalar a última versão do Istio, neste momento 1.8.2, você pode ir até a página [Getting Started](https://istio.io/latest/docs/setup/getting-started/#download) ou seguir as instruções abaixo:

`curl -L https://istio.io/downloadIstio | sh -`{{execute}}

> Verifique qual foi a versão baixada e ajuste a variável ISTIO_VERSION, caso sejam diferentes.
> Se o download não iniciar, interrompa o comando com <kdb>ctrl</kbd>+<kdb>c</kbd> e execute novamente.

Para usar o comando `istioctl`, que está no diretório `bin` do download, coloque-o na variável `PATH` ou copie o arquivo `bin/istioctl` para um diretório no seu `PATH`

## Copiando o istioctl para o diretório de binários

`ISTIO_VERSION=1.8.2`{{execute}}

Verificar onde está o executável do Istio:

`ls istio-$ISTIO_VERSION/bin`{{execute}}

Copiar o arquivo para o diretório de binários:

`cp istio-$ISTIO_VERSION/bin/istioctl /usr/local/bin`{{execute}}

Teste

`istioctl version`{{execute}}

Ok, já temos o utilitário do Istio instalado no nosso sistema operacional, vamos seguir para instalação no cluster.

## Instalando o mínimo do Istio no k8s

Desde a versão 1.6 o Istio é composto de uma única entrega chamada `istiod` e ela pode ser instalada com o comando abaixo:

Isso deve demorar de 1 a 5 minutos, dependendo da capacidade do cluster.

`istioctl install --set profile=minimal --skip-confirmation`{{execute}}

Vamos verificar o que foi instalado

Obtendo os namespaces:

`kubectl get ns`{{execute}}

Um novo namespace foi criado, o istio-system, vamos ver o que foi instalado:

`kubectl get all -n istio-system`{{execute}}

Neste ponto já temos o Istio instalado.

## Istio CRDs

O Istio é uma aplicação que é executada no kubernetes e adiciona recursos personalizados ([CRD](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)) para sua configuração.

Você pode obter uma lista completa executando o comando abaixo:

`kubectl api-resources --api-group=networking.istio.io`{{execute}}

`kubectl api-resources --api-group=security.istio.io`{{execute}}

> Note que todos as configurações para recursos do Istio são aplicados para um _namespace_ (Namespaced=true), isso significa que a configuração terá efeito apenas em um _namespace_, porém, configurações que poderão ser aplicadas para toda a malha de serviços serão realizadas no _namespace_ do Istio, o `istio-system`.

Você verá muito disso no kubernetes, para uma lista completa de recursos e suas abreviações execute o mesmo comando acima, mas sem o filtro.

`kubectl api-resources`{{execute}}

Esses são os recursos adicionados e na segunda coluna o nome abreviado, você pode utilizar um ou outro, por exemplo:

Abreviado:

`kubectl get svc`{{execute}}

Que é equivalente a:

`kubectl get services`{{execute}}

## Ativando o Istio para um namespace

Um elemento chave do Istio é o _sidecar_ ou _proxy_, como veremos na discussão sobre arquitetura do Istio. Para que o Istio injete-o nos PODs da aplicação, é necessário marcar o _namespace_ da seguinte forma:

`kubectl label namespace default istio-injection=enabled`{{execute}}

Vamos verificar como ficou a configuração do namespace

`kubectl describe ns/default`{{execute}}

O `istiod` irá monitorar todos os _namespaces_ com o rótulo `istio-injection=enabled` e adicionar ao POD um _container_ de proxy, o _sidecar_.

Vamos fazer _deploy_ de uma aplicação exemplo para verificar esse comportamento.

## Criando uma aplicação demo

Vamos criar uma aplicação simples.

`mkdir -p simple-app`{{execute}}

Criando o arquivo de deployment:

```
cat <<EOT > simple-app/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-app
  labels:
    app: simple-app
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
        app: simple-app
        version: v1
  template:
    metadata:
      labels:
        app: simple-app
        version: v1
    spec:
      containers:
        - name: simple-app
          image: "nginx:stable"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
EOT
```{{execute}}

E o serviço:

```
cat <<EOT > simple-app/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: simple-app
  labels:
    app: simple-app
    version: v1
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: simple-app
    version: v1
EOT
```{{execute}}

Listando os arquivos criados:

`ls -la simple-app`{{execute}}

Criamos dois arquivos, o `simple-app/deployment.yaml`{{open}} e o `simple-app/service.yaml`{{open}} no diretório `simple-app`, agora vamos instala-la no _namespace_ default (quando omitido é onde os recursos serão criados).

Inspecione os arquivos e tente descobrir o que será instalado no cluster, uma dica, procure a pela imagem.

`kubectl apply -f simple-app`{{execute}}

Verificando a situação do POD.

`kubectl get pods`{{execute}}

> Repita o comando algumas vezes até que o POD esteja 2/2 _Running_.
> Para instalar a aplicação em um _namespace_ diferente adicione `--namesapce` ou `-n`ao comando. Exemplo: `kubectl apply -f assets/exemplos/simple-app -n test-app`

Vamos acessar nossa aplicação, ela foi configurada para o tipo de serviço `ClusterIP`, o que significa que o acesso é interno, apenas entre os PODs do cluster, mas podemos acessá-la utilizando o comando `kubectl port-forward`.

`kubectl port-forward svc/simple-app 8000:80 --address 0.0.0.0`{{execute T1}}

Vamos testar em um segundo terminal `curl localhost:8000`{{execute T2}}

Você também pode usar o link Apps na parte superior do terminal.

> Se o terminal for aberto pela primeira vez o comando pode ser ignorado, tente novamente com o terminal aberto.

Pronto, você tem acesso à sua aplicação como se estivesse sendo executada na sua máquina. Claro que o kubernetes pode estar na sua máquina, mas isso funcionará em qualquer kubernetes, local ou remoto.

Para interromper, no terminal tecle <kbd>CTRL</kbd>+<kbd>C</kbd>. Ou click em `echo " Pronto para ir. "`{{Execute interrupt T1}}

Verificando o que foi instalado.

`kubectl get --show-labels all`{{execute}}

Note que o pod/simple-app tem 2/2 na coluna pronto (Ready), isso significa que dois containers de dois estão ok, vamos verificar quem é o segundo container.

Usaremos um dos labels do pod para encontra-lo

`kubectl describe pod -l app=simple-app`{{execute}}

É uma grande quantidade de informação, vamos procurar uma seção chamada `Containers` e nela a nossa aplicação `simple-app`.

Como você pode ver, a imagem desse container é `nginx`, com a tag `stable`, mais abaixo tem um segundo container `istio-proxy`, com a imagem `docker.io/istio/proxyv2` e a _tag_ para a  versão `1.8.2`.

Esse container não faz parte do `simple-app/deployment.yaml`{{open}}, ele foi adicionado ao seu pod pelo `istiod`.

Caso você precise saber todos os _namespaces_ que tem a injeção do _envoy_ do Istio ativado, basta executar o comando:

`kubectl get ns -l istio-injection=enabled`{{execute}}

Até o momento, somente o namespace `default`, onde configuramos a marcação, foi encontrado.

## Conclusão

Neste ponto temos o mínimo do Istio em execução no nosso cluster, mas com exceção de um container extra isso não significa muito.

Na próxima parte iremos explorar os recursos que esta instalação mínima do Istio pode oferecer.
