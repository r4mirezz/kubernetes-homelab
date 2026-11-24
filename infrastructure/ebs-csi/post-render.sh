#!/usr/bin/env bash
set -euo pipefail

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cat > "$workdir/resources.yaml"

cat > "$workdir/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - resources.yaml
patches:
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: ebs-csi-controller
    patch: |-
      - op: add
        path: /spec/template/spec/hostNetwork
        value: true
      - op: add
        path: /spec/template/spec/dnsPolicy
        value: ClusterFirstWithHostNet
YAML

kubectl kustomize "$workdir"
