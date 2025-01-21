#!/bin/bash

# namespace list
namespaces=(
nut-4
nut-5
nut-6
)


for namespace in "${namespaces[@]}"; do
  oc new-project $namespace
  # oc create namespace $namespace
  # oc label namespace "$namespace" argocd.argoproj.io/managed-by=openshift-gitops --overwrite
done
