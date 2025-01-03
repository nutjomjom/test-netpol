#!/bin/bash

# Input list of namespaces
namespaces=(
    nut-1
    nut-2
    nut-3
)

for namespace in "${namespaces[@]}"; do

    oc label namespace "$namespace" argocd.argoproj.io/managed-by=openshift-gitops

done