echo "Installing Modela..."

# Wait for Kubernetes to start
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do kubectl get pods --all-namespaces && break || sleep 5; done

/cache-image.sh

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -sL https://metaprov.github.io/install | sh
cp /root/.modela/bin/modela /usr/local/bin/modela

# Helm has issues running on containers; we need to retry the command until it works :-(
function try_add_repo() {
    n=0
    until [ "$n" -ge 10 ]
    do
        ( helm repo add $1 $2 ) & pid=$!
        ( sleep 3 && kill -HUP $pid ) 2>/dev/null & watcher=$!
        if wait $pid 2>/dev/null; then
            pkill -HUP -P $watcher
            wait $watcher
            return
        else
            echo "Repo add $1 hanging; trying again"
            n=$((n+1))
        fi
    done
    echo "Unable to install repo $1"
}

try_add_repo jetstack https://charts.jetstack.io
try_add_repo bitnami https://charts.bitnami.com/bitnami
try_add_repo modela-charts https://metaprov.github.io/helm-charts/

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.7.1 

kubectl create ns modela-system 
kubectl create ns modela-catalog
kubectl create ns default-tenant

helm install modela-storage bitnami/minio --namespace modela-system --set volumePermissions.enabled=true
helm install modela-postgresql --namespace modela-system bitnami/postgresql --set volumePermissions.enabled=true
helm install modela modela-charts/modela

while [[ $(kubectl get pods -l app.kubernetes.io/name=modela-control-plane -n modela-system -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "Waiting for control plane..." && sleep 1; 
done

helm install modela-default-tenant modela-charts/modela-default-tenant


cp /supervisord.conf /etc/supervisord.conf
supervisorctl reread
supervisorctl update
supervisorctl start modela
