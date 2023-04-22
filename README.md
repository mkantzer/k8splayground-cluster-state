# k8splayground-cluster-state
Contains configuration information for applications deployed to kubernetes. Primarily cuelang.

## Repo Structure

This repo is the _module_ called "github.com/mkantzer/k8splayground-cluster-state"
The majority of the files in this module belong to the `kube` _package_.

Each valid working directory (ex: k8s_apps/[appName]/[environment], or similar for infra) is an INSTANCE. Each `instance` contains the working directory, as well as all ancestor directories within the module. 

Using this approach, the different kind of directories within a module can be ascribed the following roles:
- module root: schema assembly
- medial directories: policy
- leaf directories: data

> **Note**
> Almost every `cue cmd` command in this repo will expect to be run from an instance.

### `mikeApp` and the `schema/` directory

`schema/` houses my attempt at a simplified abstraction schema, that can be auto-inflated into a suite of kubernetes manifests. The primary goal is to allow developers to configure only the things they truly care about, while also enforcing/granting best practices from a platform level. EX: developer's don't really care about the intricacies of a `horizontal pod autoscaler`, they simply care about what metric causes their app to scale.

This system should also reduce boilerplate within a given application's `cluster-state` definitions, to decrease the likelihood of a misconfiguration.

The directory itself is structured to allow multiple _types_ of abstraction layers, and to allow those layers themselves to be versioned. 

## Instances

- **k8s_apps/app1/[environment]**: Omitted. Was an initial demo of using cue to validate raw YAML. Complicates the actual use of ArgoCD for rendering.
- **k8s_apps/app2/[environment]**: Demonstrates how a fairly direct import of YAML could be structured, to begin making use of Cue functionality
- **k8s_apps/app3/[environment]**: demonstrates how you can move components up towards root to reduce duplicate boilerplate. It also makes use of `cue.mod/usr` merging, to impose additional schema restrictions and further reduce boilerplate.

> **TODO:** - **k8s_apps/appFour/[environment]**: demonstrates how additional schema and transformers can be introduced to provide a more concise interface to users

## Tasks

### YAML -> CUE file import

Execute this _in an instance with YAML files_:
```sh
cue import -f -l '"kubernetes"' -l 'strings.ToLower(kind)' -l 'metadata.name' -p kube *.yaml
```
You could now delete the YAML files; they have been rendered to `.cue`

### List Objects

Execute this _in an instance that has been rendered to cue_:
```
cue ls
```

### Render Cuelang to YAML at STDOUT

Execute this _in an instance that has been rendered to cue_:
```sh
cue dump
```

## Non-Cue Stuff
- `addOns/` contains the argocd app-of-apps that we use to deploy our cluster addons. It is structured similarly to [aws's example](https://github.com/aws-samples/eks-blueprints-add-ons), but with the addition of versioned directories to allow phased upgrades to exist in `main` in parallel.