#!/usr/bin/env bash

if ! command -v helm &> /dev/null
then
    echo "helm could not be found, installing"
  # curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod 700 get_helm.sh
  sudo ./get_helm.sh
  rm ./get_helm.sh
fi

kubectl cluster-info

echo
echo "Applying initial cert-manager install"
kustomize build cert-manager/base/ | kubectl apply -f -

echo
echo "Applying initial argo install"
kustomize build argocd/environments/local/ | kubectl apply -f -

echo
echo "Applying argo root project"
kustomize build root/environments/local | kubectl apply -f -

echo
echo "Waiting for pods..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout 2m