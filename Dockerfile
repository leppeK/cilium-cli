# syntax=docker/dockerfile:1.9@sha256:fe40cf4e92cd0c467be2cfc30657a680ae2398318afd50b0c80585784c604f28

# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

FROM docker.io/library/golang:1.22.6-alpine3.19@sha256:1bad39361dd21f2f881ce10ff810e40e5be3eba89a0b61e762e05ec42f9bbaf2 AS builder
WORKDIR /go/src/github.com/cilium/cilium-cli
RUN apk add --no-cache git make ca-certificates
COPY . .
RUN make

FROM ubuntu:24.04@sha256:8a37d68f4f73ebf3d4efafbcf66379bf3728902a8038616808f04e34a9ab63ee
LABEL maintainer="maintainer@cilium.io"
WORKDIR /root/app
COPY --from=builder /go/src/github.com/cilium/cilium-cli/cilium /usr/local/bin/cilium

# Install cloud CLIs. Based on these instructions:
# - https://cloud.google.com/sdk/docs/install#deb
# - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# - https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#install-azure-cli
RUN apt-get update -y \
 && apt-get install -y curl gnupg unzip \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && apt-get update -y \
 && apt-get install -y google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin kubectl \
 && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -r ./aws awscliv2.zip \
 && curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENTRYPOINT []
