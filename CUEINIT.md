# Cue Repo Initialization

Here, I'm putting the steps that I took to actually initialize the cuelang components in this repo:

1. `cue mod init github.com/mkantzer/k8splayground-cluster-state`
2. `go mod init github.com/mkantzer/k8splayground-cluster-state`
3. Create and fill out `tools.go` to make sure go tooling gets everything
4. `go mod tidy` 
  1. gotta do [this thing](https://argo-cd.readthedocs.io/en/stable/user-guide/import/) to fix problems.
  2. `go mod tidy` again
6. `cue get go`