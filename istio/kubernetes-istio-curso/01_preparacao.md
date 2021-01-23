# Preparando o ambiente execução

Ref: [Docker Desktop overview](https://docs.docker.com/desktop/)

Você precisará de um cluster de kubernetes para realizar os labs, a forma mais simples é utilizar o kubernetes que acompanha o docker-desktop, porém, se estiver acompanhando este curso em Linux, não há ainda um docker-desktop e as opçoes estão listadas abaixo.

## Linux com kind

Ref: [Install Docker Engine](https://docs.docker.com/engine/install/) e [kind](https://kind.sigs.k8s.io/)

Siga as instruções para criar um cluster de kubernetes com kind e ajuste o contexto para o cluster criado.

Exemplo:

Crie o cluster, isso pode demorar alguns minutos

`kind create cluster --name curso-istio` {{execute}}

Verifique o cluster

`kubectl cluster-info --context kind-curso-istio` {{execute}}

Ajuste o contexto para não precisar mais adicionar o parâmetro contexto

`kubectl config set-context kind-curso-istio` {{execute}}

Teste novamente

`kubectl cluster-info` {{execute}}

Verifique que todos os pods estejam no estado Running antes de prosseguir

PODs Pending ou Invicted podem indicar que você precisará prover mais recursos (memória / cpu) para o Docker

Execute: `kubectl get pods --field-selector=status.phase=Pending --all-namespaces` {{execute}}

Referência: <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle>

`kubectl get pods -n kube-system` {{execute}}

## Mac

Você precisará aumentar os recursos de CPU e memória disponíveis para o docker, ajuste-os em configurações e, dependendo o seu hardware, habilite o máximo uso de CPU e pelo menos 4GB de memória.

Ref: [Install Docker Desktop on Mac](https://docs.docker.com/docker-for-mac/install/)

## Windows

Se você estiver utilizando o docker-desktop com WSL2 não é necessário aumentar os recursos, porém, se estiver utilizando com máquina virtual, nas configurações incremente a CPU para o máximo e memória para pelo menos 8GB.

Ref: [Install Docker Desktop on Windows](https://docs.docker.com/docker-for-windows/install/)

## Testando o acesso

Dependendo da opção que você escolheu, provavelmente você precisará definir a variável `KUBECONFIG`

`export KUBECONFIG=$PWD/config` {{execute}}

> Aponte para onde está o arquivo de config

Para o docker-desktop você não precisa fazer nada, teste com o comando:

`echo $KUBECONFIG` {{execute}}

`kubectl cluster-info` {{execute}}

## Outras alternativas para kubernetes

Você pode optar por não usar o kubernetes que acompanha o docker-desktop, ou no caso do linux, usar o kind.

A seguir algumas opções com baixo consumo de recursos da sua máquina.

* [rke](https://rancher.com/products/rke/)
* [minikube](https://minikube.sigs.k8s.io/docs/start/)
* [microk8s](https://microk8s.io/)

Caso você tenha acesso a alguma nuvem, poderá utilizar um cluster de kuberentes como o GKE, AKS ou EKS, mas fique ciente que eles terão custo. Uma outra alternativa é utilizar a infraestrutura do [Katacoda](https://www.katacoda.com/), este curso [Olá K8s v1.08](https://www.katacoda.com/adsantos/courses/k8s/k8s-hello) é uma introdução ao kuberentes e você terá um cluster de kuberentes operacional por algumas horas. Em breve teremos uma versão deste curso também para esta plataforma.

## Ferramentas

Algumas ferramentas ajudarão a melhorar nossa produtividade e outras são essenciais para o curso. Todas serão instaladas no seu computador de trabalho, são elas:

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - A ferramenta de linha de comando do kubernetes. Necessário para executar comandos para o cluster.
* [istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/) - CLI para o Istio, será instalado na seção 02.
* [wercker/stern](https://github.com/wercker/stern) - Stern permite acessar log em multiplos PODs e containers.
* curl - CLI para transferir dados via URLs. Procure no google como instala-lo em seu sistema operacional.
* watch - é uma ferramenta de linha de comando, que executa o comando especificado repetidamente. Procure no google para instala-la.
* [hey](https://github.com/rakyll/hey) - Gera carga para aplicações web.
* [httpie](https://httpie.io/) - utilitário para enviar requiisções http com um retorno mais amigável.
