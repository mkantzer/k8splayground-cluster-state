# Why not just use Helm?

On the surface, the `mikeApp` abstraction provides similar functionality to a decent helm chart: a vastly simplified input produces a suite of templated and standardized Kubernetes manifests. 


However, cue provides significant advantages over helm, and resolves many frustrations I've had with helm in general:

Fully structured, always:
Helm's templating engine is not purpose-built for structured data. 

Not white space sensitive:

Trivial validation against API objects:

Trivial backwards compatibility checks:

Trivial use of cascading generation / values:

Trivial CI of instance rendering:

Hermetic:

Trivial CI of abstraction schema:

Access template fields within template:

Readability:

Maintainability:

Escapable: 