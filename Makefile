QUIET=@

create:
	$(QUIET)k3d cluster create \
		--update-default-kubeconfig \
		--switch-context \
		--wait && \
	echo "Updating kube config..." && \
	sed -i -e "s/0.0.0.0/host.docker.internal/g" $(HOME)/.kube/config

delete:
	$(QUIET)k3d cluster delete

delete-all:
	$(QUIET)k3d cluster delete --all
