# Raw Kubernetes Schema

This package is used for defining the schema for any Kubernetes objects that we cannot directly import via the normal cuelang tooling.

This is primarily for cases where we are using a provider-specific CRD, who's controller codebase is not open-source (or not in golang).

CRDs are defined using OpenAPI, and while `cue` can _export_ an OpenAPI spec from a cue definition, it cannot go the other direction. [See here](https://cuelang.org/docs/integrations/openapi/).
