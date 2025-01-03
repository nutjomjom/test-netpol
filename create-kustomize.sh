#!/bin/bash

# Input list of namespaces
namespaces=(
    nut-1
    nut-2
    nut-3
    nut-4
    nut-5
)

# Base directory for creating folders
base_dir="./"

# Iterate over the namespaces
for namespace in "${namespaces[@]}"; do
    # Create directory for the namespace
    folder_path="${base_dir}${namespace}"
    mkdir -p "$folder_path"

    # Create the kustomization.yml file
    kustomization_file="${folder_path}/kustomization.yml"
    cat <<EOF > "$kustomization_file"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: $namespace

bases:
  - ../../../base
EOF

    echo "Created folder and kustomization.yml for namespace: $namespace"
done