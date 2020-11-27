# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.148.1/containers/python-3/.devcontainer/base.Dockerfile

# [Choice] Python version: 3, 3.9, 3.8, 3.7, 3.6
ARG VARIANT="3"
FROM mcr.microsoft.com/vscode/devcontainers/python:0-${VARIANT}

COPY .devcontainer/library-scripts/*.sh /tmp/library-scripts/

RUN apt-get update \
    && bash /tmp/library-scripts/common-debian.sh \
    && bash /tmp/library-scripts/docker-debian.sh \
    && bash /tmp/library-scripts/kubectl-helm-debian.sh \
    && apt-get install -y make vim \
    && rm -rf /tmp/library-scripts \
    && mkdir /commandhistory \
    && touch /commandhistory/.zsh_history \
    && chown -R vscode /commandhistory \
    && chsh --shell /usr/bin/zsh vscode

ENTRYPOINT ["/usr/local/share/docker-init.sh"]
CMD ["sleep", "infinity"]
