FROM ghcr.io/gigrator/base:0.0.3
LABEL maintainer="K8sCat <k8scat@gmail.com>"
COPY mirror.sh /mirror.sh
ENTRYPOINT ["/mirror.sh"]
