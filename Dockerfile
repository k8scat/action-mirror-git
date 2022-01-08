FROM ghcr.io/gigrator/base:0.0.7
LABEL maintainer="K8sCat <k8scat@gmail.com>"
LABEL repository="https://github.com/k8scat/action-mirror-git.git"
COPY mirror.sh /mirror.sh
ENTRYPOINT ["/mirror.sh"]
