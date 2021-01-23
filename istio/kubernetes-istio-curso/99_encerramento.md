# Encerramento

Foi um longo caminho até aqui, parabéns. Se você não compreendeu tudo não se sinta mal, Istio é uma aplicação bem grande, com muitas funcionalidades e sua documentação não é tão abrangente quanto poderia ser, mas conte conosco, deixe seus comentários, contribua criando exemplos e enviando para nós, você pode fazer um _fork_ do [projeto no github](https://github.com/kdop-dev/istio-curso) e enviar _pull requets_ que teremos o maior prazer de analisar. Você também pode enviar _links_ dos seus exemplos que adicionaremos na seção [16_contribuicoes.md](16_contribuicoes.md).

Mas antes de encerrar, gostaria que você colocasse o chapéu de arquiteto de software e vamos discutir sobre a aplicação do Istio como solução arquitetura e quais implicações.

## Eu preciso de uma malha de serviços?

A malha de serviço é o resultado natural da programação de sistemas distribuídos. A primeira pergunta deve ser: "Tenho muitos serviços que se comunicam entre si na minha infraestrutura de aplicativo?"

Se você gerencia uma série de serviços menores (microsserviços), então você você lida com os desafios da computação distribuída. Conforme os microsserviço evoluem, novos recursos são normalmente introduzidos como serviços externos adicionais. À medida que a distribuição de seus aplicativos continua a crescer, também aumentará a necessidade de soluções para a malha de serviços.

Soluções para malha de serviço existem para endereçar os desafios de garantir a confiabilidade (novas tentativas, tempos limite, mitigação de falhas em cascata), solução de problemas (observabilidade, monitoramento, rastreamento, diagnóstico), desempenho (taxa de transferência, latência, balanceamento de carga), segurança (gerenciamento de segredos, garantindo criptografia), topologia dinâmica (descoberta de serviço, roteamento personalizado) e outros problemas comumente encontrados ao gerenciar microsserviços.

Se você atualmente enfrenta esses problemas, ou se adotou um estilo arquitetura declarativo de microsserviços e baseado em protocolo HTTP, então as soluções de malha de serviços são ferramentas que você deve explorar para determinar se funcionará para o seu ambiente.

![Declarativo e reativo](media/declarative_reactive.png)

Porém, se você tem uma arquitetura reativa, baseada em eventos, mesmo com centenas de serviços, você não tem uma malha, basicamente todos os seus serviços se comunicam com uma infraestrutura central, um _hub de mensagens_, nesse caso, você ainda pode tirar proveito de algumas funcionalidades das soluções de malha de serviços, mas você não precisa delas para entender como suas aplicações funcionam.

Ao se concentrar no motivo da existência desse tipo de ferramenta e nos tipos específicos de problemas que ela resolve, você pode evitar o exageros e começar escolher as funcionalidades que trazema valor para você.

## Eu deveria usar microsserviços?

Você provavelmente conhece o [artigo do Martin Fowler](https://martinfowler.com/bliki/MonolithFirst.html) sobre começar primeiro com uma arquitetura monolítica e gradualmente ir migrando para microsserviços, quando for o caso.

![monolítico](media/monolith.png)

Microsserviços tem inúmeras vantagens, mas somente se você têm os problemas que ele resolve, por exemplo:

* Você realmente precisa dimensionar componentes individuais do aplicativo? - Esta é uma das principais vantagens para usar microsserviços, a simplicidade para adicionar escala manual e automática aos seus serviços. Existem inúmeras situações onde essa caracteristica é fundamental, mas para o seu problema, você realmente precisa disso? Vejo diariamente centenas de serviços com apenas uma réplica, ou que não podem ou tiram proveito de uma segunda cópia. A única funcionalidade, do gerenciador de containêres, que a aplicação utiliza é a de manter aquela réplica em funcionamento.
* Você realiza transações distribuídas entre os serviços? Os serviços REST são _stateless_ por definição. E eles não deviriam participar de transações que exceda mais de um serviço. Coordenar transações com, por exemplo, o padrão SAGA, adiciona complexidade.
* Ainda no tema transação, os microsserviços apresentam o problema de consistência eventual, devido a sua natureza descentralizada. Com um monólito, você pode atualizar várias coisas juntas em uma única transação, onde os microsserviços podem exigir várias chamadas para o mesmo objetivo. Isso leva à aplicação a necessidade de lidar com eventuais falta de síncronia entre os estados, aumentando sua complexidade.
* Há necessidade de comunicação frequente entre os serviços? Esse é outro aspecto a ser considerado, seus serviços conversam entre si? Com que frequência? Há dois extremos aqui: sim, com muita frequêcia, onde adicionar uma camada de comunicação de rede pode ser proibitivo; ou não, eles servem apenas a consumidores externos. Em ambos os casos, microsserviços podem não ser a melhor opção.
* Como já discutido, microsserviços trazem uma complexidade adicional, embora eles sejam originalmente projetados para reduzir a complexidade dividindo o aplicativo em partes menores, a arquitetura se torna complexa e mais difícl de manter.
* Eles também aumentam os custos de distribuição. Seu serviço monolítico seria implantado em uma grande VM ou em um contêiner, mas os microsserviços precisam ser implantados de forma independente, em várias VMs ou contêineres e, embora pequenos em tamanho, o esforço para implantá-los e mentê-los não é muito menor.
* A falta de experiência é crítica para qualquer problema e é acentuada quando se trata de computação distribuída.
* Elaborar e manter os contratos de serviços dentro da equipe é muito diferente de compartilhá-los entre as equipes.

Essa não é uma lista exaustiva, microsserviços são ótimos, mas não considere-os bala de prata, ou você poderá enfrentar mais problemas do que os benefícos e rapidamente cair na falácia de que microsserviços não são uma boa arquitetura.

## Papel do _gateway_ de API com a malha de serviço?

A uma confusão compreensível quando comparamos soluções de malha de serviços com as de gerenciamento de APIs e alguns fabricantes não ajudam quando modificam seus produtos de gerenciamento de APIs para cobrirem as funcionalidades de uma malha de serviços.

![API Gateway e malha de serviços](media/api-gw-mesh.png)

Ambas as soluções lidam com o tráfego do aplicativo, portanto, a sobreposição não deve ser surpreendente. A lista a seguir enumera alguns dos recursos de sobreposição:

* Coleção de telemetria
* Rastreamento distribuído
* Descoberta de serviço
* Balanceamento de carga
* Terminação / originação TLS
* Validação JWT
* Gerenciamento de tráfego
* Entregas canário / sombra
* Controles de limites

Porém, uma malha de serviço opera em um nível inferior ao de um API Gateway. A malha de serviço fornece funcionalidades aos aplicativos sobre a topologia da arquitetura, os mecanismos de resiliência, telemetria que são coletas e segurança. Todos essas funcionalidades são fornecidos normalmente por algum processo secundário, retirando a duplicação desse código do desenvolvimento.

Já os problemas na norda da malha de serviços não são iguais. Um gateway de API fornece três recursos principais que uma malha de serviço não resolve no mesmo grau:

* Desacoplamento de fronteira / borda
* Controle rigoroso sobre o que entra ou sai na fornteira
* Ponte segura entre as fronteira

As principais funcionalidadede um API gateway são:

* Transformação de solicitação / resposta
* Transformação de protocolo de aplicativo como REST / SOAP
* Respostas personalizadas de erro / taxas limite
* Respostas síncronas e assíncronas
* Composição / agrupamento de API

Os API Gateways têm uma sobreposição com a malha de serviço em termos de funcionalidade. Eles também podem ter uma sobreposição em termos de tecnologia usada, porém suas funções são diferentes, um está voltado a comunicação entre serviços e o outro entre fronteira, um busca padronizar a comunicação, políticas e observabilidade, o outro lida com o fato de não ter controle sobre esses padrões e investe em adaptabilidade.

![API Gateway and Service Mesh](media/api-gateway-mesh.png)

Pense nisso quando estiver desenhado sua arquitetura, se você precisa expor suas APIs para o mundo, gerenciar uma comunidade de consumidores e monetizá-las, precisará de um gerenciador de APIs, mas se você precisa cuidar do consumo interno e entre os serviços, você está do domíno da malha de serviços.

## Limpeza

Vamos remover tudo que foi instalado no cluster.


```bash
# Apaga todos os recursos do namespace
kubectl delete ns financial

kubectl delete ns legacy

# Remove os add-ons (prometheus, graphana, kiali e jaeger)
kubectl delete -f istio-1.8.1/samples/addons

# Remove a aplicação sleep
kubectl delete -f istio-1.8.1/samples/sleep

# Remove a aplicação sleep
kubectl delete -f istio-1.8.1/samples/httpbin

# Remove todos os compoenntes do istio
istioctl x uninstall --purge -y

# Remove o namespace do istio
kubectl delete ns istio-system

# Remove o rótulo de injeção automática do sidecar do istio
kubectl patch ns default --type=json -p='[{"op": "remove", "path": "/metadata/labels/istio-injection"}]'

# Apaga os recursos criados no curso
kubectl delete -f exemplos/simul-shop/manifests/4

kubectl delete -f exemplos/simul-shop/manifests/8

kubectl delete -f exemplos/simul-shop/manifests/9

kubectl delete -f exemplos/simul-shop/manifests/10
```

## Referências

[Consulte referências](15_referencias.md)
