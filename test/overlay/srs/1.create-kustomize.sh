#!/bin/bash

# namespace list
namespaces=(
nut-4
nut-5
nut-6
)


base_dir="./"

for namespace in "${namespaces[@]}"; do
    # create directory
    folder_path="${base_dir}${namespace}"
    mkdir -p "$folder_path"

    # create kustomization.yml
    kustomization_file="${folder_path}/kustomization.yml"
    cat <<EOF > "$kustomization_file"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace

resources:
  - ../../../base
EOF

  # Add Label to namespace
  echo "label namespace: $namespace"
  oc label namespace "$namespace" argocd.argoproj.io/managed-by=openshift-gitops --overwrite
  echo "Created folder and kustomization.yml for namespace: $namespace"
done
