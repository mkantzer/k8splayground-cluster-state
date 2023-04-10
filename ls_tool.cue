package kube

import "strings"

command: ls: {
	task: print: {
		kind: "print"
		let Lines = [
			for x in k8sObjects {
				"\(x.kind)  \t\(x.metadata.name)"
			},
		]
		text: strings.Join(Lines, "\n")
	}
}
