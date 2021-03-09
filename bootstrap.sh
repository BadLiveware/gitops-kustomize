#!/usr/bin/env bash

if ! command -v k3d &> /dev/null
then
    echo "k3d could not be found, installing"
	curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
	command -v k3d &> /dev/null || echo "Unable to find or install helm" & exit 1
fi

if ! command -v helm &> /dev/null
then
    echo "helm could not be found, installing"
	# curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
	chmod 700 get_helm.sh
	sudo ./get_helm.sh
	rm ./get_helm.sh
fi

if ! docker -v &> /dev/null
then
	echo "Unable to connect to docker daemon"
	exit 1
fi

echo
echo "Deleting cluster"
k3d cluster delete

echo
echo "Creating local cluster"
k3d cluster create --api-port 6550 -p "8081:443@loadbalancer" -p "8080:80@loadbalancer" --agents 1

echo
kubectl config use-context k3d-k3s-default
kubectl cluster-info

echo
echo "Applying initial cert-manager install"
kustomize build cert-manager/base/ | kubectl apply -f -

echo
echo "Applying initial argo install"
kustomize build argocd/overlays/production/ | kubectl apply -f -

echo
echo "Applying argo root project"
kustomize build root/base/ | kubectl apply -f -

# echo
# echo "Waiting for pods..."
# # kubectl wait --for=condition=ready pods -l app.kubernetes.io/part-of=argocd -n argocd --timeout 5m 
# kubectl wait --for=condition=ready deployment -l app.kubernetes.io/part-of=argocd -n argocd --timeout 5m