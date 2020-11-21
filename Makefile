QUIET=@
KUBE_CONFIG=$(HOME)/.kube/config

create:
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

# Access the dashboard at http://localhost:<port>/dashboard/
# Where <port> maps to the exposted 80@loadbalancer port
traefik2:
	$(QUIET)helm repo add traefik https://helm.traefik.io/traefik && \
	helm repo update && \
	helm install traefik traefik/traefik && \
	kubectl apply -f dashboard.yaml

delete:
	$(QUIET)k3d cluster delete

delete-all:
	$(QUIET)k3d cluster delete --all
