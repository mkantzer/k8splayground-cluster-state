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

## Example Instances

- **k8s_apps/echo/[environment]**: Demonstrates how a fairly direct import of YAML could be structured, to begin making use of Cue functionality.
- **k8s_apps/schemaTest/[environment]**: Demonstrates usage of a developer-facing abstraction layer to generate managed kubernetes manifests.

## Usage

This repo requires the installation of [cuelang](https://cuelang.org) tooling.

### Creating a new configuration

Create a new directory under `k8s_apps`. Put all configuration shared between environments (`local`/`dev`/`prod`) in `app.cue` in that directory. Then create a subdirectory for each environment, and place an `app.cue` in each with that environments specific configuration (`env` tags, image tags, env vars, etc). Remember that an instance contains both its directory as well as all containing directories.

### Onboarding to ArgoCD

TODO

### Executing cue commands

All of the following commands should be executed from the innermost directory of an instance (ex: `k8s_apps/schemaTest/dev/`)

#### List Objects

To get a list of what kubernetes objects will be rendered:
```
cue ls
```

#### Render Cuelang to YAML at STDOUT

To output a YAML document stream of kubernetes manifests (usable without any additional processing):
```sh
cue dump
```

## Non-Cue Stuff
- `addOns/` contains the argocd app-of-apps that we use to deploy our cluster addons. It is structured similarly to [aws's example](https://github.com/aws-samples/eks-blueprints-add-ons), but with the addition of versioned directories to allow phased upgrades to exist in `main` in parallel.