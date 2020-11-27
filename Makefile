QUIET=@
KUBE_CONFIG=$(HOME)/.kube/config
ISTIO_VERSION=1.8.0
ISTIO_DIR=istio-$(ISTIO_VERSION)

cluster-create:
	$(QUIET)echo "Creating k3d cluster..." && \
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
	$(QUIET)curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -

istio: $(ISTIO_DIR)
	$(QUIET)helm install --create-namespace --namespace istio-system istio-base $(ISTIO_DIR)/manifests/charts/base && \
	helm install --namespace istio-system istiod $(ISTIO_DIR)/manifests/charts/istio-control/istio-discovery \
    --set global.hub="docker.io/istio" --set global.tag="1.8.0" && \
	helm install --namespace istio-system istio-ingress $(ISTIO_DIR)/manifests/charts/gateways/istio-ingress \
    --set global.hub="docker.io/istio" --set global.tag="1.8.0" && \
	helm install --namespace istio-system istio-egress $(ISTIO_DIR)/manifests/charts/gateways/istio-egress \
    --set global.hub="docker.io/istio" --set global.tag="1.8.0"

istio-demo:
	$(QUIET)kubectl apply -f $(ISTIO_DIR)/samples/bookinfo/platform/kube/bookinfo.yaml && \
	kubectl apply -f $(ISTIO_DIR)/samples/bookinfo/networking/bookinfo-gateway.yaml

create: cluster-create istio
	$(info Done creating cluster...)

delete:
	$(QUIET)k3d cluster delete

delete-all:
	$(QUIET)k3d cluster delete --all
