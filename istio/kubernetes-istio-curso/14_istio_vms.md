# Istio em VMs

Trazendo VMs e outros serviços de fora do kubernetes para a malha de serviços.

Executar serviços em contêineres adicionam muitos benefícios, tasi como escalonamento automático, isolamento de dependência e otimização de recursos. Adicionar o Istio ao seu ambiente Kubernetes pode simplificar radicalmente a agregação de métricas e o gerenciamento de políticas, principalmente se você estiver operando muitos contêineres.

Mas como ficam os aplicativos legados em máquinas virtuais? Ou se você estiver migrando de VMs para contêineres?

Embora contêineres e Kubernetes sejam amplamente usados, ainda há muitos serviços implantados em máquinas virtuais e APIs fora do cluster Kubernetes que precisam ser gerenciados pela malha do Istio. É um grande desafio unificar a gestão dos ambientes [_brownfield_](https://en.wikipedia.org/wiki/Brownfield_(software_development)) e [_greenfield_](https://en.wikipedia.org/wiki/Greenfield_project).

Você ja conhece muitos recursos do Istio e sabe que podemos acessar serviços que estão fora da malha registrando-os com o _ServiceEntry_, então P\por que instalar o Istio em uma máquina virtual?

O _ServiceEntry_ habilita serviços dentro da malha para descobrir e acessar serviços externos e a gerenciar o tráfego para esses serviços externos. Em conjunto com o _VirtualService_ configura regras de acesso para o serviço externo, tais como tempo limite de solicitação, injeção de falha, etc.

Porém, esse recurso controla apenas o tráfego do lado do cliente. A implantação de _sidecars_ em máquinas virtuais e a configuração das carga de trabalho para o kubernetes, permite que ela seja gerenciada como um POD e o gerenciamento de tráfego aplicado uniformemente em ambis os lados.

Neste cenário, nosso sistema de pagamanetos necessita integrar-se com um ERP legado para enviar os pagamentos realizados. Este sistema está em execução em uma máquina virtual.

Para simular este legado, iremos criar uma VM e executar o script python que usamos no generic-services.

A arquitetura da solução ficará assim:

![Simulshpo vm architecture](media/simul-shop-vms-arch.png)

## Configuração

Antes de iniciarmos as configurações no Kubernetes e Istio, precisamos colocar nosso sistema legado em operação, para isso você precisará de um host.

Você tem duas alternativas:

1. Usar seu computador - Se você estiver executando o kubernetes em sua máquina, você poderá executar o generic-services usando docker localmente. Na seção 4 você tem um exemplo de como fazer isso.
2. Criar uma VM - Você pode criar uma vm na nuvem ou local, se você tiver recursos.

Iremos utilizar uma VM na nuvem, mas a diferença é como criar a vm, os demias passos são os mesmos.

### Criando uma VM

Não há uma maneira única de criar uma VM, depende do provedor de nuvem ou do software de virtualização que você escolher, o que precisamos é de um IP que o cluster de kubernetes consiga alcançar.

Crie a VM onde for mais conveniente, ela pode ser o menor tamanho possível, utilize cotas gratuítas das nuvens.

Nossa VM foi criada na Azure e abrimos as portas 22 (ssh), 8000 (aplicação) e ICMP (protocolos para diagnósticos de rede)

> **Dica pro**: Em ambientes de produção não é recomendado abrir portas como a 22 e ICMP, pelo menos não para qualquer origem e é recomendado colocar a(s) máquina(s) atrás de um balanceador de carga e registrar o IP em um DNS.

Vamos testar a conectividade do cluster:


```bash
# Verificando conectividade
VM_ADDRESS=10.240.0.115 # Usando o IP interno, o mesmo da subnet do cluster k8s
kubectl exec -it svc/payment -c payment -- ping -c 5 $VM_ADDRESS
```

Para simplificar, instalamos docker na VM e executaremos o nosso aplicativo usando a imagem do generic-services. Para mais informações de como instalar docker no seu sistema operacional [Install Docker Engine](https://docs.docker.com/engine/install/).

> Se você instalar docker em linux provavelmente precisará ajustar as permissões do usuário. Acesse [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

Acesse a VM via SSH (linux) ou RDP (windows) e execute o serviço:

```bash
# pegasus-pay API
docker run -d --rm \
-p 8000:8000 \
--hostname pegasus-pay \
--name pegasus-pay \
-e SCHED_CALL_URL_LST=http://localhost:8000/healthz \
-e SCHED_CALL_INTERVAL=300 \
-e APP=pegasus-pay \
-e VERSION=v1 \
kdop/generic-service:0.0.5

# Logs (CTRL+C para sair)
docker logs -f pegasus-pay

# Parando o servico
kubectl stop pegasus-pay
```

Vamos verificar a conectividade e o serviço:


```bash
ssh-vm docker run -d --rm \
-p 8000:8000 \
--hostname pegasus-pay \
--name pegasus-pay \
-e SCHED_CALL_URL_LST=http://localhost:8000/healthz \
-e SCHED_CALL_INTERVAL=300 \
-e APP=pegasus-pay \
-e VERSION=v1 \
kdop/generic-service:0.0.5
```


```bash
# Verificando firewall e serviço
SVC_PORT=8000
kubectl exec -it svc/payment -c payment -- curl http://$VM_ADDRESS:$SVC_PORT
```

## Configuring Cluster

### Prepare the guide environment


```bash
# Defina as variáveis
VM_PUB_ADDRESS="pegasus.eastus.cloudapp.azure.com"
VM_APP="pegasus-pay"
VM_NAMESPACE="legacy"
WORK_DIR="bkp/vmintegration"
SERVICE_ACCOUNT="legacy-pegasus"
VM_USER="peguser"
VM_PKEY_PATH="bkp/pegasus_key.pem"

# Alias ssh command
alias ssh-vm="ssh -i $VM_PKEY_PATH $VM_USER@$VM_PUB_ADDRESS"

mkdir -p "${WORK_DIR}"
```

### Instalando o Istio

Você já fez isso antes neste curso, mas agora iremos modificar a instalação para registrar as VMs automaticamente.


```bash
# Instala ou modifica a instalação coma configuração para resgistrar VMs automaticamente
istioctl install --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true --skip-confirmation
```


```bash
# Deploy do east-west gateway:
istio-1.8.1/samples/multicluster/gen-eastwest-gateway.sh --single-cluster | istioctl install -y -f -
```


```bash
# Expor o gateway criando um serviço LoadBalancer:
kubectl apply -f istio-1.8.1/samples/multicluster/expose-istiod.yaml
```


```bash
# Verificando o que foi criado
kubectl get pods,dr,vs,gw -n istio-system
```

Verifique o endereço e as portas expostas pelo `gateway/istio-eastwestgateway`, usaremos esses dados para a comunicação da VM com o cluster.


```bash
kubectl get svc -n istio-system
```

### Configurando o namespace para a VM

As VMs serão registradas em um _namespace_, iremos criá-lo e associar uma conta de serviço.


```bash
# Namespace
kubectl create namespace "${VM_NAMESPACE}"
```


```bash
# ServiceAccount
kubectl create serviceaccount "${SERVICE_ACCOUNT}" -n "${VM_NAMESPACE}"
```

### Criando os arquivos e transferindo para a VM

Para configurar o Envoy na VM, o `istioctl` fornece um utilitário que permite criar o [WorkloadGroup](https://istio.io/latest/docs/reference/config/networking/workload-group/) e os arquivos de configuração, token e certificado que são utiliza para configurar o Envoy na VM.


```bash
# Crie um modelo de WorkloadGroup para as VMs
istioctl x workload group create --name "${VM_APP}" --namespace "${VM_NAMESPACE}" --labels app="${VM_APP}" --serviceAccount "${SERVICE_ACCOUNT}" > workloadgroup.yaml
```

Cria os arquivos para configuração:

* `cluster.env`: Contém metadados que identificam qual namespace, conta de serviço, rede CIDR e (opcionalmente) quais portas de entrada capturar.
* `istio-token`: um token do Kubernetes usado para obter certificados da CA.
* `mesh.yaml`: fornece metadados adicionais do Istio, incluindo nome de rede, domínio confiável e outros valores.
* `root-cert.pem`: O certificado raiz usado para autenticação.
* `hosts`: Um adendo ao arquivo `/etc/hosts` que o proxy usará para alcançar istiod para.


```bash
# Criando os arquivo em WORK_DIR
istioctl x workload entry configure -f workloadgroup.yaml -o "${WORK_DIR}"
# Aplicando o template no cluster
kubectl apply -f workloadgroup.yaml
```


```bash
# Verificando o que foi criado
ls -l $WORK_DIR
```

## Configurando a VM

Nesta etápa iremos configurar a VM.

> **Dica pro**: Fora do escopo deste curso, idealmente você deve ter um script para automatizar essas etapas para cada nova VM criada que fará parte da malha.


```bash
# Transferindo os arquivos para a VM
scp -i $VM_PKEY_PATH $WORK_DIR/* $VM_USER@$VM_PUB_ADDRESS:/home/$VM_USER
```

> Se vc preferir, abra um terminal para a sua máquina virtual e entre com os comandos abaixo, retirando o comando `ssh-vm`.


```bash
# Instalando o certificado root
ssh-vm sudo mkdir -p /etc/certs
ssh-vm sudo cp /home/$VM_USER/root-cert.pem /etc/certs/root-cert.pem
```


```bash
# Instalando o token
ssh-vm sudo mkdir -p /var/run/secrets/tokens
ssh-vm sudo cp /home/$VM_USER/istio-token /var/run/secrets/tokens/istio-token
```


```bash
# Instalando a configuração cluster.env
ssh-vm sudo cp /home/$VM_USER/cluster.env /var/lib/istio/envoy/cluster.env
```


```bash
# Instalando a configuração mesh.yaml
ssh-vm sudo cp /home/$VM_USER/mesh.yaml /etc/istio/config/mesh
```


```bash
# Ajustando permissões
ssh-vm sudo mkdir -p /etc/istio/proxy
ssh-vm sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem
```


```bash
# Adicionando o endereço do LoadBalancer do gateway/istio-eastwestgateway no /etc/hosts
ssh-vm sudo -- sh -c "cat /home/peguser/hosts >> /etc/hosts" # TODO: Não funciona adicionar manualmente
```

> **Dica pro**: O objetivo desse comando é resolver o nome do serviço de descobert do Istio (discoveryAddress). Em produção, não adicione entradas no `/etc/hosts`, registre o endereço em um DNS e utilize o registro. Se não for possível, certifique-se de que o endereço atribuído ao balanceador de carga não mudará.


```bash
# Instando o sidecar (Linux)
ssh-vm curl -LO https://storage.googleapis.com/istio-release/releases/1.8.1/deb/istio-sidecar.deb
ssh-vm sudo dpkg -i istio-sidecar.deb
```

> Nesta versão, o Istio suporta apenas os sistemas operacionais Linux baseados em centos e debian.


```bash
# Inicia o sidecar
ssh-vm sudo systemctl start istio
```


```bash
# Habilita a inicialização automática do sidecar após o boot
ssh-vm sudo systemctl enable istio
```

### Verificando o funcionamento do _sidecar_


```bash
# Check the log in /var/log/istio/istio.log. You should see entries similar to the following:
ssh-vm tail /var/log/istio/istio.log
```

Os logs não devem exibir erros, e devem se parecer com este:

```bash
2020-12-26T14:48:26.699574Z	info	cache	GenerateSecret from file ROOTCA
2020-12-26T14:48:26.699958Z	info	sds	resource:ROOTCA pushed root cert to proxy
2020-12-26T14:48:26.700180Z	info	sds	resource:default new connection
2020-12-26T14:48:26.700215Z	info	sds	Skipping waiting for gateway secret
2020-12-26T14:48:26.700370Z	info	cache	adding watcher for file ./etc/certs/cert-chain.pem
2020-12-26T14:48:26.700396Z	info	cache	GenerateSecret from file default
2020-12-26T14:48:26.700582Z	info	sds	resource:default pushed key/cert pair to proxy
2020-12-26T15:18:33.664500Z	info	xdsproxy	disconnected from XDS server: istiod.istio-system.svc:15012
2020-12-26T15:18:34.115504Z	info	xdsproxy	Envoy ADS stream established
2020-12-26T15:18:34.115625Z	info	xdsproxy	connecting to upstream XDS server: istiod.istio-system.svc:15012
```

Os erros que encontramos durante a instalação:

* Conexão recusada ou tempo de espera esgotado: Verifique a conectividade a VM com o serviço do ingress. Execute o comando `kubectl get svc -n istio-system`, procure o endereço externo do serviço `istio-egressgateway` e execute comandos de `telnet` ou `netcat` com o endereço e portas. Exemplo: `telnet 52.150.37.127 15012` deve retornar sucesso `Connected to 52.150.37.127.`.
* Erro de validação de token ou certificados - Verifique se os arquivos criados na pasta vmintegration foram corretamente copiados para a VM e copiados para os diretório. Caso necessário pare o serviço do istio na VM, repita o processo e inicie o serviço novamente.
* [TODO] Erro de conexão TLS: Não aparce nos logs. Foi necessário desligar o TLS múto para o namespace `legacy` para conexão Cluster -> VM, o caminho inverso não tem problema.

Para verificar a conectividade da máquina virtual, execute o seguinte comando:


```bash
ssh-vm curl localhost:15000/clusters | grep payment
```

Vamos enviar requisições para os serviços no cluster:


```bash
ssh-vm curl -s payment.default.svc:8000/
```


```bash
ssh-vm curl -s "front-end.default.svc:8000/r?code=404&wait=1s"
```

### Conectando os serviços do cluster aos da VM

Conseguimos consumir serviços do cluster desde a VM, agora vamos configurar o cluster para consumir os serviços na VM.

Como instalamos o Istio com o parâmetro de criação automática de [WorkLoadEntry](https://istio.io/latest/docs/reference/config/networking/workload-entry/), a nossa VM já foi registrada, podemos verificar:


```bash
kubectl get workloadentry.networking.istio.io -A
```

Você pode configurar qualquer endereço que o cluster consiga chegar na VM, verificamos que o autoregistro do Istio escolheu o endereço privado.

Se o Istio não estiver configurado para autogegistrar as VMs ou se você deseja configurá-los em um _pipeline_, por exemplo, basta escrever e aplicar no cluster a configuração abaixo.


```bash
echo "Interno: $VM_ADDRESS"
echo "Público: $VM_PUB_ADDRESS"
```


```bash
# [Desnecessário se o autoregistro estiver ligado]
cat <<EOF | kubectl -n legacy apply -f -
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: "pegasus-pay"
  namespace: "legacy"
spec:
  address: "$VM_ADDRESS"
  labels:
    app: pegasus-pay
  serviceAccount: "legacy-pegasus"
EOF
```

A configuração a seguir registrar um serviço kubernetes para a nossa VM, dessa forma os demais serviços poderão acessá-la como qualquer outro serviço:


```bash
# Add virtual machine services to the mesh
cat <<EOF | kubectl -n legacy apply -f -
apiVersion: v1
kind: Service
metadata:
  name: pegasus-pay
  labels:
    app: pegasus-pay
spec:
  ports:
  - port: 8000
    name: http-vm
    targetPort: 8000
  selector:
    app: pegasus-pay
EOF
```

Acessando o serviço da VM pelo cluster:


```bash
kubectl exec -it svc/payment -c payment -- curl pegasus-pay.legacy.svc.cluster.local:8000
```

#### TLS mutuo

Ao executar o comando acima retornou o erro:

`upstream connect error or disconnect/reset before headers. reset reason: connection failure`

Vamos desabilitar o TLS mútuo para o _namespace_


```bash
# Desabilitando o MTLS para o namesapce legacy
# Solução de contorno para comunicação Cluster -> VM
cat <<EOF | kubectl apply -f -
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "disable-mtls-legacy"
  namespace: "legacy"
spec:
  mtls:
    mode: DISABLE
EOF
```


```bash
#kubectl delete peerauthentication.security.istio.io/disable-mtls-legacy -n legacy
```

E executar o teste novamente:


```bash
kubectl exec -it svc/payment -c payment -- curl pegasus-pay.legacy.svc.cluster.local:8000
```

Ver Issues.

### Monitorando a VM

TODO

Inicie o kiali e jaeger.

Abra um terminal e execute o comando algumas vezes.


```bash
kubectl exec -it svc/payment -c payment -- bash
```


```bash
for i in $(seq 1 10);
do curl pegasus-pay.legacy.svc.cluster.local:8000;
done
```

Conecte um terminal a VM e execute o comando abaixo algumas vezes.


```bash
for i in $(seq 1 100); do curl payment.default.svc.cluster.local:8000; done
```

Para que o kiali represente corretamente o serviço.


```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: pegasus-pay
  namespace: legacy
spec:
  hosts:
  - pegasus-pay.legacy
  location: MESH_INTERNAL
  ports:
  - number: 8000
    name: http
    protocol: HTTP
  resolution: DNS
EOF
```


```bash
kubectl get se/pegasus-pay -n legacy
```

## Limpando o ambiente

Esta é a última seção do curso, então não se esqueça de remover todos os recursos criados, principalmente se houver algum custo associado.

> A exclusão dos recursos abaixo só é necessário se você não excluir a VM e o cluster.


```bash
# Na VM
#Stop Istio on the virtual machine:
ssh-vm sudo systemctl stop istio

# Remove a instalação do sidecar
ssh-vm sudo dpkg -r istio-sidecar
ssh-vm dpkg -s istio-sidecar
```


```bash
# No cluster
# Namespace legacy
kubectl delete ns legacy

# Deploys do istio para simul-shop
kubectl delete -f exemplos/simul-shop/istio/

# Deploys do simul-shop
kubectl delete -f exemplos/simul-shop/manifests/

# Istio
kubectl delete namespace istio-system
```

## Issues

### Cluster -> VM fail to validade TLS


```bash
kubectl apply -f istio-1.8.1/samples/sleep/sleep.yaml
```


```bash
# On VM
python -m SimpleHTTPServer 8080
```


```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: WorkloadEntry
metadata:
  name: cloud-vm
  namespace: legacy
spec:
  address: 10.240.0.115
  labels:
    app: cloud-vm
  serviceAccount: pegasus-legacy
EOF
```


```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cloud-vm
  name: cloud-vm
  namespace: legacy
spec:
  clusterIP: 10.0.183.31
  ports:
  - name: http-vm
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: cloud-vm
  type: ClusterIP
EOF
```


```bash
kubectl exec -it svc/sleep -c sleep -- curl cloud-vm.legacy.svc.cluster.local:8080
```


```bash
kubectl exec -it svc/payment -c payment -- curl pegasus-pay.legacy.svc.cluster.local:8000
```


```bash
# Desabilitando o MTLS
cat <<EOF | kubectl apply -f -
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "disable-mtls-legacy"
  namespace: "legacy"
spec:
  mtls:
    mode: DISABLE
EOF
```


```bash
kubectl delete PeerAuthentication/disable-mtls-legacy -n legacy
```

### Fail DNS resolution for external URI on VM

Mesmo com o padrão do cluster que permite acessar qualquer endereço fora fora da malha, na VM não é observado o mesmo comportamento.


```bash
kubectl get istiooperator installed-state -n istio-system -o jsonpath='{.spec.meshConfig.outboundTrafficPolicy.mode}'
```


```bash
kubectl exec -it svc/payment -c payment -- nslookup azure.archive.ubuntu.com
```


```bash
ssh-vm nslookup azure.archive.ubuntu.com
```

Problema está relacionado a configuração do `cluster.env` no sidecar da VM

```ini
CANONICAL_REVISION='latest'
CANONICAL_SERVICE='pegasus-pay'
DNS_AGENT=''
ISTIO_INBOUND_PORTS='*'
ISTIO_METAJSON_LABELS='{"app":"pegasus-pay","service.istio.io/canonical-name":"pegasus-pay","service.istio.io/canonical-version":"latest"}'
ISTIO_META_CLUSTER_ID='Kubernetes'
ISTIO_META_DNS_CAPTURE='true'
ISTIO_META_MESH_ID=''
ISTIO_META_NETWORK=''
ISTIO_META_WORKLOAD_NAME='pegasus-pay'
ISTIO_NAMESPACE='legacy'
ISTIO_SERVICE='pegasus-pay.legacy'
ISTIO_SERVICE_CIDR='*'
POD_NAMESPACE='legacy'
SERVICE_ACCOUNT='legacy-pegasus'
TRUST_DOMAIN='cluster.local'
```

O parâmetro `ISTIO_META_DNS_CAPTURE` captura as chamadas para o serviço de DNS de acordo com a [documentação](https://istio.io/latest/docs/reference/commands/pilot-agent/).

Adicionado DNS primário para 8.8.8.8 em `/etc/resolv.conf`


```bash
kubectl exec -it svc/payment -c payment -- nslookup azure.archive.ubuntu.com
```


```bash
ssh-vm nslookup azure.archive.ubuntu.com
```

### Notes

* Removido o DNS do /etc/resolv.conf e continua a funcionar. Inconclusivo
