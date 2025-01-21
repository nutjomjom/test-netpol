#!/bin/bash

# allow namespace list
NAMESPACES=(
nut-4
nut-5
)

# create allow namespace
for NAMESPACE in "${NAMESPACES[@]}"; do
  cat <<EOF > "allow-namespace-${NAMESPACE}.yml"
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
  if ! grep -q "allow-namespace-${NAMESPACE}.yml" "kustomization.yml"; then
    echo "  - allow-namespace-${NAMESPACE}.yml" >> "kustomization.yml"
  fi
done

echo "Done!"