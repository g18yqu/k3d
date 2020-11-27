#!/usr/bin/env /usr/bin/zsh

pip3 install --user -r /workspaces/k3d/requirements.txt

# Install arkade
curl -sLS https://dl.get-arkade.dev | sudo sh

# Install k3d
arkade get k3d --version v3.2.1
sudo ln -s $HOME/.arkade/bin/k3d /usr/local/bin/k3d

# shell completion
echo "source <(kubectl completion zsh)" >> $HOME/.zshrc
echo 'alias k=kubectl' >>$HOME/.zshrc
echo 'complete -F __start_kubectl k' >> $HOME/.zshrc

# Persist shell history across dev containers
echo "export PROMPT_COMMAND='history -a'" >> $HOME/.zshrc 
echo "export HISTFILE=/commandhistory/.zsh_history" >> $HOME/.zshrc 

# Set git config
git config --global user.name "Andrew N."
git config --global user.email git@hb2r5y.xyz

# Set kubeconfig for any already running k3d clusters
mkdir -p $HOME/.kube
touch $HOME/.kube/config
k3d kubeconfig merge --all --output $HOME/.kube/config
# Modify kubeconfig such that we can resolve host docker daemon
sed --in-place "s/0.0.0.0/host.docker.internal/g" $HOME/.kube/config
