#!/bin/bash

# Define the file path
file_path="2.namespace-all"

# Check if the file exists
if [[ ! -f "$file_path" ]]; then
  echo "File not found: $file_path"
  exit 1
fi

# Declare an associative array to store grouped values
declare -A grouped_data

# Read the file line by line
while IFS=$'\t' read -r key value || [[ -n "$key" ]]; do
  # Skip empty lines
  if [[ -z "$key" || -z "$value" ]]; then
    continue
  fi

  # Append the value to the key in the associative array
  if [[ -z "${grouped_data[$key]}" ]]; then
    grouped_data["$key"]="$value"
  else
    grouped_data["$key"]+=" $value"
  fi
done < "$file_path"

# Print the grouped data
for key in "${!grouped_data[@]}"; do

    echo "$key = ${grouped_data[$key]}"

    # Split the string into an array
    IFS=' ' read -r -a source_namespace <<< "${grouped_data[$key]}"

# create allow namespace
for NAMESPACE in "${source_namespace[@]}"; do
echo "NAMESPACE: $NAMESPACE"

cat <<EOF > "${key}/allow-namespace-${NAMESPACE}.yml"
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-namespace-${NAMESPACE}
spec:
  podSelector: {}
  ingress:
    - from:
    - namespaceSelector:
        matchLabels:
          app.kubernetes.io/instance: ${NAMESPACE}
EOF

# update kustomization.yml
  if ! grep -q "allow-namespace-${NAMESPACE}.yml" "${key}/kustomization.yml"; then
    echo "  - allow-namespace-${NAMESPACE}.yml" >> "${key}/kustomization.yml"
  fi
  # if ! grep -q -- "- . " "${key}/kustomization.yml"; then
  #   echo "  - . " >> "${key}/kustomization.yml"
  # fi

done

done

echo "Done!"


