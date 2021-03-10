YAML_FILES = $(shell find ./argocd/ -type f -name "*.yaml")
GITOPS_ENV?=local
BUILD_DIR := build/$(GITOPS_ENV)

.PHONY: directories prometheus-operator

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

directories: $(BUILD_DIR)

$(BUILD_DIR)/argocd.yaml: $(BUILD_DIR) $(YAML_FILES)
	kustomize build argocd/environments/$(GITOPS_ENV)/ > $(BUILD_DIR)/argocd.yaml

template-argo: $(BUILD_DIR)/argocd.yaml

prometheus-operator:
	@cd ./prometheus-operator/ && make template

deploy_cert-manager:
	kustomize build cert-manager/base/ | kubectl apply -f -

deploy_argocd: template-argo
	kustomize build argocd/overlays/$(ENV)/ | kubectl apply -f -

deploy_root:
	kustomize build root/base/ | kubectl apply -f -

wait:
	kubectl wait --for=condition=available deployment --all -n argocd --timeout 2m

deploy: prometheus-operator deploy_cert-manager deploy_argocd deploy_root