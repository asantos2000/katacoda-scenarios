# Build time
install_helm() {
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
}

install_helm

# Runtime
cat <<EOF > /opt/configure-environment.sh
#!/bin/bash
# Wait until k8s is ready
waitk8s=true
while [ \$waitk8s == true ]
do
    if [[ "\$(kubectl get nodes 2>/dev/null | grep Ready | wc | awk '{ print \$1}')"  == "2" ]]; then
        waitk8s=false
    else
        echo "Waiting for k8s" >> /opt/configure-environment.logs
        sleep 1
    fi
done

EOF
chmod +x /opt/configure-environment.sh