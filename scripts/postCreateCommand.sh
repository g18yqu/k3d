#!/usr/bin/env /bin/bash

pip3 install --user -r /workspaces/k3d/requirements.txt
curl -sLS https://dl.get-arkade.dev | sudo sh
sudo /workspaces/k3d/script-library/docker-debian.sh
