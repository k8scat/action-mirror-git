FROM gigrator/base:0.0.2
LABEL maintainer="K8sCat <k8scat@gmail.com>"
COPY mirror.sh /mirror.sh
ENTRYPOINT ["/mirror.sh"]
