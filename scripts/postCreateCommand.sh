#!/usr/bin/env /bin/bash

pip3 install --user -r /workspaces/k3d/requirements.txt
curl -sLS https://dl.get-arkade.dev | sudo sh
arkade get k3d --version v3.2.1
echo "export PATH=$PATH:$HOME/.arkade/bin/" >> $HOME/.zshrc
echo "source <(kubectl completion zsh)" >> $HOME/.zshrc
echo 'alias k=kubectl' >>$HOME/.zshrc
echo 'complete -F __start_kubectl k' >> $HOME/.zshrc
echo "export PROMPT_COMMAND='history -a'" >> $HOME/.zshrc 
echo "export HISTFILE=/commandhistory/.zsh_history" >> $HOME/.zshrc 
