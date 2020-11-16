CLUSTER_ID=kubernetes

# create service account in Kuber
kubectl apply -f gocd-admin-service-account.yaml

# get CA cert
yc managed-kubernetes cluster get $CLUSTER_ID --format=json \
| jq -r .master.master_auth.cluster_ca_certificate > cert

# get user token
TOKEN=`kubectl -n kube-system get secrets -o json | \
jq -r '.items[] | select(.metadata.name | startswith("gocd-admin")) | .data.token' | \
base64 --decode`

# get kuber address
K8S_ADDRESS=`yc managed-kubernetes cluster get $CLUSTER_ID --format=json \
| jq -r .master.endpoints.external_v4_endpoint`


kubectl config set-cluster kubernetes --server="$K8S_ADDRESS" --insecure-skip-tls-verify=true
kubectl config set-credentials gocd-admin --token="$TOKEN"
kubectl config set-context default --cluster=$CLUSTER_ID --user=gocd-admin
kubectl config use-context default
