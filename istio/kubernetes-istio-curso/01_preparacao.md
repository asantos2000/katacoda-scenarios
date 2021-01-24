Você precisará de um cluster de kubernetes para realizar os labs.

Você pode executar todas as lições localmente, por exemplo, com o kubernetes que acompanha o docker-desktop (mac e win), porém, para Linux, não há ainda um docker-desktop.

Uma opção para linux é [kind](https://kind.sigs.k8s.io/), você ainda precisará instalar o [Docker Engine](https://docs.docker.com/engine/install/)

Mas para este curso o Katacoda oferece toda a infraestrutura que precisamos.

## Vamos começar

O Kubernetes já está iniciado e em execução, talvez leve alguns minutos para colocar tudo em execução. Vamos verificar a integridade do cluster.

### Exame de saúde do _cluster_

Neste momento, o seu terminal está executando o comando `watch kubectl get pods --all-namespaces`{{execute}} que exibe a saúde dos pods do kubernetes.

Você pode obter o status do cluster com estes comandos: `kubectl get nodes`{{execute}}, `kubectl cluster-info`{{execute}} e `kubectl get pods -n kube-system`{{execute}}

> Enquanto espera, vá para a aba IDE para carregá-la, isso levará alguns segundos.
> Espere até que todos os pods apareçam e estejam _Running_ e, em seguida, pressione <kbd> Ctrl </kbd> + <kbd> C </kbd> no terminal ou click em  `echo" Pronto para ir. "`{{Execute interrupt}}

## Ferramentas

Algumas ferramentas ajudarão a melhorar nossa produtividade e outras são essenciais para o curso. Todas serão instaladas durante o curso:

* [istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/) - CLI para o Istio, será instalado na seção 02.
* [wercker/stern](https://github.com/wercker/stern) - Stern permite acessar log em multiplos PODs e containers.
* [httpie](https://httpie.io/) - utilitário para enviar requiisções http com um retorno mais amigável.

## Obtendo o código do curso

Vamos clonar o repositório do curso:

```
git clone --no-checkout https://github.com/kdop-dev/istio-curso.git
cd istio-curso
git sparse-checkout init --cone
git sparse-checkout add exemplos
git sparse-checkout add scripts
git checkout
```{{execute}}