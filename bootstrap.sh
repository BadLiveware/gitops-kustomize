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

if ! docker -v &> /dev/null
then
  echo "Unable to connect to docker daemon"
  exit 1
fi

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

echo
echo "Waiting for pods..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout 2m