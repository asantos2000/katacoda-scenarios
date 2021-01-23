# Criando o caos

> _In the midst of chaos, there is also opportunity._ - Sun Tzu

Provavelmente você já ouviu falar sobre engenharia do caos, conceito criado no Netflix e envolve quebrar coisas em produção de propósito com objetivo de certificar que a alta disponibilidade e a tolerância à falhas das suas aplicações funcionam.

Faremos aqui uma breve introdução, mas você pode conhecer mais sobre engenharia do caos no livro [Chaos Engineering da O'Reilly](https://www.oreilly.com/library/view/chaos-engineering/9781491988459/). Enquanto escrevemos esse curso você pode obtê-lo gratuitamente em [Verica - The Chaos Engineering Book](https://www.verica.io/the-chaos-engineering-book/).

> _Chaos Engineering é a disciplina de realizar experimentos sobre sistemas distribuídos com o intuito de construir confiança com relação a capacidade de um sistema distribuído suportar condições adversas em produção._ - [PRINCÍPIOS DE CHAOS ENGINEERING](https://principlesofchaos.org/pt/)

Estes experimentos seguem quatro etapas:

* **Comece definindo o que significa “sistema estável”**, uma medida que tem como resultado mensurável um indicativo sobre o comportamento normal do sistema.
* **Crie hipóteses** se o estado “sistema estável” permanecerá tanto no grupo de controle quanto no grupo onde o experimento será executado.
* **Introduza variáveis que reflitam eventos que ocorrem no mundo real**, como por exemplo: servidores que travam, discos rígidos defeituosos, conexões de rede que são interrompidas, etc.
* **Tente refutar cada hipótese** procurando diferenças entre o “sistema estável”, o grupo de controle e o grupo experimental.

Em síntese, a engenharia do caos é uma maneira de surpreender suas aplicações de missão crítica antes que elas surpreendam você.

Com kubernetes você tem uma série de controles e o Istio adiciona ainda mais variáveis que permitem, com um pequeno esforço, conduzir esses experimentos.

Veremos como implementar a injeção de falhas e lentidão do tempo de resposta para os seus experimentos.

## Injetando falhas e atrasos

[Injeção de falhas para protocolo http](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPFaultInjection)  pode ser usado para especificar uma ou mais falhas a serem injetadas ao encaminhar solicitações HTTP para o destino especificado em uma rota. A especificação de falha faz parte de uma regra do _VirtualService_.

As falhas incluem abortar uma solicitação http do serviço e/ou atrasa-la. Uma regra de falha pode ser configurada com um atraso, aborte ou ambos.

### Atrasos


```bash
# Login DestinationRules
kubectl apply -f - <<EOF
kind: DestinationRule
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: login
spec:
  host: login
  subsets:
    - labels:
        version: v1
      name: v1
EOF
```


```bash
# Inject delay
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: login
spec:
  hosts:
  - login
  http:
  - match:
    - headers:
        test-mode:
          exact: "yes"
    fault:
      delay:
        percentage:
          value: 100.0
        fixedDelay: 2s
    route:
    - destination:
        host: login
        subset: v1
  - route:
    - destination:
        host: login
        subset: v1
EOF
```


```bash
kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/"'
```

Sem o campo `test-mode: yes` no cabeçalho o tempo de resposta é inferior a 1s, vamos adicionar o campo.


```bash
kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/" "test-mode: yes"'
```

Agora o tempo de resposta foi acrescido de 2s, experimente tempos diferentes para testar o limite de tempo (_timeout_).

### Falhas


```bash
# Inject abort code
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: login
spec:
  hosts:
  - login
  http:
  - match:
    - headers:
        test-mode:
          exact: "yes"
    fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 404
    route:
    - destination:
        host: login
        subset: v1
  - route:
    - destination:
        host: login
        subset: v1
EOF
```


```bash
kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/"'
```

Sem o campo `test-mode: yes` no cabeçalho o código de retorno foi 200, vamos adicionar o campo.


```bash
kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/" "test-mode: yes"'
```

Com o campo no cabeçalho, o código de retorno foi 404.

### Combinando falhas e atrasos

Vamos combinar o código de retorno com o atraso para obter o equivalente ao que o generic-service faz.


```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: login
spec:
  hosts:
  - login
  http:
  - match:
    - headers:
        test-mode:
          exact: "yes"
    fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 504
      delay:
        percentage:
          value: 100.0
        fixedDelay: 2s
    route:
    - destination:
        host: login
        subset: v1
  - route:
    - destination:
        host: login
        subset: v1
EOF
```

Nesta combinação, em todas as requisições haverá um código de retorno 504 e um atraso de 2s.

> **Dica pro**: Utilizar atrasos e código de retorno é uma boa forma de calibrar as suas métricas. Vá para o grafana e monitore o serviço de login para ver seus comportamento.


```bash
kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/" "test-mode: yes"'
```

Agora combinaremos falhas e erros em uma única confiugração:


```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: login
spec:
  hosts:
  - login
  http:
  - fault:
      abort:
        httpStatus: 500
        percentage:
          value: 50
      delay:
        percentage:
          value: 50
        fixedDelay: 2s
    route:
    - destination:
        host: login
EOF
```


```bash
# Calling service n time
# Better run in a terminal
for i in $(seq 1 10);
    do kubectl exec -it svc/front-end -c front-end -- bash -c 'time http -v "http://login:8000/" "test-mode: yes"';
done
```

Agora você tem uma variedade de situações, com probabilidade de 50% para retornar o código 500 ou 200 e 50% para atrasar 0s ou 2s.

> Como você verá há a propabilidade de requisições retornarem 200 sem atraso. Essa configuração pode não ser muito útil se você procura previsibilidade durante os testes.

Quando aplicamos uma nova configuração ela tem efeito praticamente no mesmo instante, experimente mudar de uma configuração para outra enquanto as executa em um _loop_.

### Limpando o ambiente

Vamos remover o que instalamos para a próxima seção.


```bash
# DestinationRule
kubectl delete dr login
# Virtual service
kubectl delete vs login
```

## Conclusão

Você pode combinar diferentes códigos de retorno e tempos de resposta para criar uma variedade de cenários de testes. Utilizar essas configurações em _pipelines_ de CI/CD permitirá testar essas condições contínuamente.

Com esse recursos, você poderá avaliar problemas em seus serviços antes de acarretarem falhas na malha de produção e mitigá-los.
