KUBE_CONFIG ?= $(HOME)/.kube/config
ISTIO_VERSION ?= 1.8.0
ISTIO_DIR := istio-$(ISTIO_VERSION)
ISTIO_DOWNLOAD_URL ?= https://istio.io/downloadIstio
CURL_FLAGS ?=--silent --show-error --location
ISTIO_NAMESPACE ?= istio-system
HELM_FLAGS ?=--create-namespace --atomic --namespace $(ISTIO_NAMESPACE)

.DEFAULT: create
.PHONY: clean

ifndef VERBOSE
.SILENT:
endif

cluster-create:
	echo "Creating k3d cluster..." && \
	k3d cluster create \
		--port 80@loadbalancer \
		--port 443@loadbalancer \
		--k3s-server-arg "--no-deploy=traefik" \
		--update-default-kubeconfig \
		--switch-context \
		--wait && \
	echo "Updating kube config..." && \
	sed --in-place "s/0.0.0.0/host.docker.internal/g" $(KUBE_CONFIG)

$(ISTIO_DIR):
	echo "Downloading istio files..." && \
	curl $(CURL_FLAGS) $(ISTIO_DOWNLOAD_URL) | ISTIO_VERSION=$(ISTIO_VERSION) sh -

istio: $(ISTIO_DIR)
	echo "Installing istio..." && \
	helm install istio-base $(ISTIO_DIR)/manifests/charts/base $(HELM_FLAGS) && \
	helm install istiod $(ISTIO_DIR)/manifests/charts/istio-control/istio-discovery $(HELM_FLAGS) \
    	--set global.hub="docker.io/istio" --set global.tag="$(ISTIO_VERSION)" && \
	helm install istio-ingress $(ISTIO_DIR)/manifests/charts/gateways/istio-ingress $(HELM_FLAGS) \
    	--set global.hub="docker.io/istio" --set global.tag="$(ISTIO_VERSION)" && \
	helm install istio-egress $(ISTIO_DIR)/manifests/charts/gateways/istio-egress $(HELM_FLAGS) \
    	--set global.hub="docker.io/istio" --set global.tag="$(ISTIO_VERSION)" && \
	kubectl label namespace default istio-injection=enabled

istio-demo:
	echo "Installing istio demo application..." && \
	kubectl apply -f $(ISTIO_DIR)/samples/bookinfo/platform/kube/bookinfo.yaml && \
	kubectl apply -f $(ISTIO_DIR)/samples/bookinfo/networking/bookinfo-gateway.yaml

create: cluster-create istio
	$(info Done creating cluster...)

delete:
	k3d cluster delete

delete-all:
	k3d cluster delete --all

clean:
	-rm -rf $(ISTIO_DIR)
