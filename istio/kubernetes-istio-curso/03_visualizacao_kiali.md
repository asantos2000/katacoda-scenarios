Discutiremos sobre muitas ferramentas durante este curso, mas o [Kiali](https://kiali.io/) é a a ferramenta que ajudará você a entender e administrar sua malha de serviços.

Até a versão 1.5, o Kiali e outras ferramentas faziam parte da distribuição do Istio, mas desde a versão 1.6 essas ferramentas devem ser instaladas.

Convenientemente o download do Istio, que fizemos na primeira parte, contém essas ferramentas.

### Instalando o kiali e dependências no cluster

Para instalar o Kiali iremos aplicar o arquivo [kiali.yaml](istio-1.7.4/samples/addons/kiali.yaml), mas antes vamos inspecioná-lo, clique no link para abri-lo.

O arquivo kiali é composto de alguns recursos, são eles:

* CDR
* ServiceAccount
* ConfigMap
* ClusterRole
* ClusterRoleBinding
* Deployment
* Service
* MonitoringDashboard

Com exceção do `MonitoringDashboard`, todos os demais recursos são do kubernetes e o CRD (Custom Resource Definition) é uma forma de criar novos recursos no kubernetes, neste caso, ele define o `MonitoringDashboard`. Mais sobre kuberntes você pode obter no nosso curso [Kubernetes avançado para iniciantes](TODO), onde abordamos esses temas e muitos outros.

Vamos instalar e conhecer o kiali antes de nos aprofundar neste CDR.

Bug versão 1.7.0 a 1.9.0 - [Istio 1.7.1 unable to install Kiali addon #27417](https://github.com/istio/istio/issues/27417)

Necessário aplicar o CRD antes do restante dos recursos.

```
cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: monitoringdashboards.monitoring.kiali.io
spec:
  group: monitoring.kiali.io
  names:
    kind: MonitoringDashboard
    listKind: MonitoringDashboardList
    plural: monitoringdashboards
    singular: monitoringdashboard
  scope: Namespaced
  versions:
  - name: v1alpha1
    served: true
    storage: true
EOF
```{{execute}}

Definindo a versão do Istio:

`export ISTIO_VERSION=1.9.0`{{execute}}

Instalando o kiali:

`kubectl apply -f istio-$ISTIO_VERSION/samples/addons/kiali.yaml`{{execute}}

E o prometheus, responsável por coletar dados dos _containers_ que serão utilizados pelo kiali.

`kubectl apply -f istio-$ISTIO_VERSION/samples/addons/prometheus.yaml`{{execute}}

Vamos verificar o que foi instalado.

`kubectl get all -n istio-system`{{execute}}

> Aguarde até que todos os PODS estejam _Running_.

O serviço do kiali é do tipo `ClusterIP`, o que significa que não podemos acessá-lo diretamente de fora do cluster, há algumas alternativas, modificar ou criar um serviço do tipo `NodePort` ou `LoadBalancer`, configurar um `Ingress` ou usar o subcomando `port-forward` do `kubectl`.

Porém o `istioctl` oferece um subcomando conveniente para acessar o kiali:

`istioctl dashboard kiali --address 0.0.0.0`{{execute T1}}

Vamos acessa-lo, mas antes, vamos gerar algum tráfego com o script `assets/scripts/simple-app.sh`{{open}} para a nossa aplicação:

`assets/scripts/simple-app.sh`{{execute T2}}

Procure pelo link kiali na parte superior do terminal, ao lado do link para IDE, e voilá, você está acessando o painel do kiali.

Vamos explorar alguns recursos do kiali.

![kiali overview](./assets/kiali-overview.gif)

O kiali oferece uma visibilidade inpressionante da malha de serviços e tudo que precisamos fazer é anotar o _namespace_ onde nossa aplicação será instalada.

Interrompa a execução do dashboard tecle <kbd>ctrl</kbd>+<kbd>c</kbd> no terminal ou `echo "click aqui"`{{Execute interrupt T1}}

Se você participou do nosso curso de [Kubernetes avançado para iniciantes](TODO) deve imaginar o que o `istioctl`automatizou, foi o comando `kubectl port-forward` e adicionou um comando de ` open` para abrir a página inicial no navegador.

O comando a seguir tem efeito semelhante (sem a parte do navegador)

`kubectl port-forward service/kiali 20001:20001 -n istio-system --address 0.0.0.0`{{execute T1}}

Kiali _dashboard_: <https://[[HOST_SUBDOMAIN]]-20001-[[KATACODA_HOST]].environments.katacoda.com>

Mesmo resultado, mas não tão elegante. Ficaremos com o `istioctl dashboard <dashboard>` pelo resto do curso.

Interrompa a execução do `port-forward` do mesmo jeito que fizemos com o `istioctl` ou `echo "click aqui para interrromper."`{{Execute interrupt T1}}

E vamos executar o kiali novamente, mas agora em segundo plano.

`istioctl dashboard kiali --address 0.0.0.0 &`{{execute}}

`export KIALI_PID=$!`{{execute}}

E acessá-lo pela url <https://[[HOST_SUBDOMAIN]]-20001-[[KATACODA_HOST]].environments.katacoda.com>.

> Se você estiver executando o curso na sua máquina, provavelmente o istioctl irá abrir a URI automaticamente, em outros ambientes e provável que falhe (`Failed to open browser`).

Para cancelar um job em segundo plano, você necessita do PID (id do processo), por isso aramzenamos na variável KIALI_PID, mas se você esquecer de salvá-lo, utilize o comando `jobs -l`{{execute}} e para parar o processo `kill $KIALI_PID`{{execute}}.

### Labels

Para kiali, os rótulos `app` e `version` são reconhecidos automaticamente e utilizados para agrupar os serviços e as cargas de trabalho.

Esses dois rótulos são requeridos e o Kiali irá indicar um alerta caso algum deles esteja faltando, embora isso não afete o funcionamento da aplicação.

Podemos utilizar os rótulos para localizar os recurso no kuberentes:

`kubectl describe deploy -l app=simple-app`{{execute}}

E no nosso _deployment_ `simple-app/deployment.yaml`{{open}} adicionamos na seção _template_ os rótulos que desejamos que sejam adicionados aos PODs que forem criados.

`kubectl get pods -l app=simple-app,version=v1`{{execute}}

A sintaxe para busca de recursos utilizando rótulos é bem rica no kubernetes, para mais exemplos acesse [kubernetes - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).

## Conclusão

O kiali não é uma ferramenta estática, uma das suas forças e exibir a relação entre os recursos em tempo de execução. Nas próximas seções iremos explorar uma aplicação com uma malha de serviços.

Você pode manter o redirecionamento para o dashboard do kiali ou pará-lo, iremos utilizá-lo várias vezes durante o curso. Então lembre-se de não executá-lo novamente se deixa-lo rodando.

Para interrompê-lo pare o processo do `istioctl`, que salvamos na variável `KIALI_PID`.

`kill $KIALI_PID`{{execute}}

`jobs -l`{{execute}}

## Limpando

Não precisaremos mais da nossa aplicação de teste, vamos exluí-la para liberar recursos do cluster.

Os recursos criados podem ser obtidos passando as mesmas configurações que utilizamos para criá-los.

`kubectl get -f simple-app`{{execute}}

E o mesmo vale para excluí-los.

> O kubectl não solicita confirmação para execução, tome cuidado e revise o comando antes de executá-lo.

`kubectl delete -f simple-app`{{execute}}
