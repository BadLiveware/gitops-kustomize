CHART = $(shell find ./upstream/ -iname "*.tgz")

yq_VERSION := v4.2.0
yq_BINARY := yq_linux_amd64
yq_PATH := bin
yq_BIN := $(yq_PATH)/yq

.PHONY: $(yq_PATH) base/upstream.yaml

$(yq_PATH):
	mkdir -p $(yq_PATH)

$(yq_BIN): $(yq_PATH)
	wget https://github.com/mikefarah/yq/releases/download/$(yq_VERSION)/$(yq_BINARY) -O $(yq_BIN) && \
	chmod +x $(yq_BIN)
install_yq: $(yq_BIN)

# kube-prometheus-stack-$(CHART_VERSION).tgz
# $(yq_BIN) e '.dependencies.[] | select(.name == "kube-prometheus-stack") | .version' ./upstream/Chart.yaml

base/upstream.yaml: upstream/Chart.yaml $(CHART)
	helm dependency update upstream
update-upstream: base/upstream.yaml

resources/upstream.yaml: base/upstream.yaml
	helm template \
		--include-crds \
		--namespace prometheus-operator \
		prometheus-operator \
		./upstream > resources/upstream.yaml
template: base/upstream.yaml
