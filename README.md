# k8splayground-cluster-state
Contains configuration information for applications deployed to kubernetes. Primarily cuelang.

## Repo Structure

- `addOns/` contains the argocd app-of-apps that we use to deploy our cluster addons. It is structured similarly to [aws's example](https://github.com/aws-samples/eks-blueprints-add-ons), but with the addition of versioned directories to allow phased upgrades to exist in `main` in parallel.