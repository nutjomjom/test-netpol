# Test Apply Network Policy via Argo CD ApplicationSet

## Prerequisite
- Install Argo CD (OpenShift GitOps)
- Create a namespace
- Label the namespace with `oc label namespace <namespace-name> argocd.argoproj.io/managed-by=openshift-gitops`

---

## Test Case 1: Simple AppSet

### Steps
1. Apply `appset.yml`<< this will apply default network policy in base directory to all namespace under env/directory
    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: test-env-network-policies
      namespace: openshift-gitops
    spec:
      generators:
        - git:
            repoURL: https://github.com/nutjomjom/test-netpol.git
            revision: HEAD
            directories:
              - path: test/overlay/env/*
      template:
        metadata:
          name: "{{path.basename}}-network-policy"
        spec:
          project: default
          source:
            repoURL: https://github.com/nutjomjom/test-netpol.git
            targetRevision: HEAD
            path: "test/overlay/env/{{path.basename}}"
          destination:
            server: https://kubernetes.default.svc
            namespace: "{{path.basename}}"
          syncPolicy:
            automated:
              prune: true
              selfHeal: true
    ```
2. Verify sync status in Argo CD console.
3. Verify network policy in OpenShift console.
4. Test adding a new NetworkPolicy:
   - Create `allow-namespace.yml` in `base/`:
     ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-namespace
    spec:
      podSelector: {}
      ingress: []
     ```
   - Add `allow-namespace.yml` to `base/kustomization.yml`:
     ```yaml
     apiVersion: kustomize.config.k8s.io/v1beta1
     kind: Kustomization
     resources:
       - netpol1.yml
       - allow-namespace.yml
     ```
5. Push to Git and verify updates. << New NetworkPolicy should apply to all namespaces.

---

## Test Case 2: Different Network Policies per Namespace

### Steps
1. Create `patch.yml` files (edit as needed):
   ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-namespace
    spec:
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              app.kubernetes.io/instance: nut-2
        - namespaceSelector:
            matchLabels:
              app.kubernetes.io/instance: nut-3
     ``` 
2. Update the `overlay/env/kustomization.yml`
    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    namespace: nut-1

    bases:
      - ../../../base

    patchesStrategicMerge:
      - patch.yaml
    ```
3. Push to Git and verify updates. << nut-1 should apply the updated deny-all policy as defined in the patch, while nut-2 and nut-3 remain unaffected.

---

## Test Case 3: Add New Environment

### Steps
1. Create a new directory `env2` in the repository.
2. Copy the structure from the existing `env` directory.
3. Create and apply new `appset-env2.yml`
    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: test-env2-network-policies
      namespace: openshift-gitops
    spec:
      generators:
        - git:
            repoURL: https://github.com/nutjomjom/test-netpol.git
            revision: HEAD
            directories:
              - path: test/overlay/env2/*
      template:
        metadata:
          name: "{{path.basename}}-network-policy"
        spec:
          project: default
          source:
            repoURL: https://github.com/nutjomjom/test-netpol.git
            targetRevision: HEAD
            path: "test/overlay/env2/{{path.basename}}"
          destination:
            server: https://kubernetes.default.svc
            namespace: "{{path.basename}}"
          syncPolicy:
            automated:
              prune: true
              selfHeal: true
    ``` 
4. Push the changes and verify if the new environment (`env2`) gets the correct network policies applied.
