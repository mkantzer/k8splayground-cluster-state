# Why not just use Helm?

On the surface, the `mikeApp` abstraction provides similar functionality to a decent helm chart: a vastly simplified input produces a suite of templated and standardized Kubernetes manifests. 


However, cue provides significant advantages over helm, and resolves many frustrations I've had with helm in general:

Fully structured, always: Helm's templating engine is not purpose-built for structured data. 
Not white space sensitive: you don't need to deal with figuring out indents
Trivial validation against API objects: Can directly import golang types.
Trivial use of cascading generation / values: can just directly reference stuff.
Trivial CI of instance rendering: see our github action.
Trivial CI of abstraction schema: see tests/
Access template fields within template: we do it all the time
Readability: it's not an impenetrable field of `{{}}`'s
Maintainability: see above.
Escapable: we can still just directly create `kubernetes:` objects if need be.