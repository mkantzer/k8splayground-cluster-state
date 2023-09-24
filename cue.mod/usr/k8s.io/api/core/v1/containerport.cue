package v1

#ContainerPort: {
	_nameValidation: {
		lengthCheck: len(name) <= 15 & true
	}
	name?: string
}
