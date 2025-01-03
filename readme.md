for test apply netpol via Argo CD application set

prerequisite
    - install argo cd (openshift gitops)
    - created namespace
    - label namespace with `oc label namespace <namespace-name> argocd.argoproj.io/managed-by=openshift-gitops`

test case 1: simple appset
step
    1. apply appset.yml
    2. verify sync status in argo cd console
    3. verify network policy in ocp console
    4. test add new netpol
        - create netpol2.yml in base/
        ```
        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
          name: deny-all
        spec:
          podSelector: {}
          policyTypes:
            - Ingress
            - Egress
        ```

        - add netpol2.yml to base/kustomization.yml
        ```
        apiVersion: kustomize.config.k8s.io/v1beta1
        kind: Kustomization
        resources:
          - netpol1.yml
          - netpol2.yml
        ```
    5. push to git and see updates << new netpol should apply to all namespace

test case 2: each namespace have different policy config
step
    1. create patch files (edit as you want)
    ```
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-all
    spec:
      podSelector: {}
      policyTypes:
        - Ingress
        - Egress
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  name: nut-2
            - namespaceSelector:
                matchLabels:
                  name: nut-3
      egress: [] 
    ```

    2. update overlay/env/kustomization.yml
    ```
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    namespace: nut-1

    resources:
      - ../../../base

    patches:
      - path: netpol-patch.yml
    ```
    3. push to git and see updates << nut-1 deny-all policy should update as we modified in patch (nut-2,3 should remain same)

test case 3: add new env
step
    1. create dir env2 in repo
    2. copy structure from env dir
    3. create new appset2.yml for apply netpol in env2
    ```
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
