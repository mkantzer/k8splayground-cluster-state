# Cue Repo Initialization

Here, I'm putting the steps that I took to actually initialize the cuelang components in this repo:

1. `cue mod init`
2. `go mod init github.com/mkantzer/k8splayground-cluster-state`
3. edit `cue.mod/module.cue` to set `module: "github.com/mkantzer/k8splayground-cluster-state"`
4. `go get k8s.io/api/core/v1` (gets all the k8s stuff)
5. `cue get go k8s.io/api/core/v1` (does the cue.mod generation and stuff)