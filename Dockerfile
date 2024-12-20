FROM alpine:3

ENV HELM_VERSION=3.16.4
ENV KUBECTL_VERSION=1.29.12

# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN apk add --update --no-cache curl ca-certificates bash && \
    curl -L ${BASE_URL}/${TAR_FILE} | tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    apk del curl && \
    rm -f /var/cache/apk/*

# Install kubectl (same version of aws esk)
RUN apk add --update --no-cache curl && \
    curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"  && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install tools that are used in the scripts
RUN apk add --update --no-cache unzip perl gettext

WORKDIR /apps

COPY scripts/ .

CMD ["helm", "--help"]
