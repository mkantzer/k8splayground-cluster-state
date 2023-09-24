package kube

import "encoding/base64"

kubernetes: prime: configmap: "demo-simple-cue": {
	apiVersion: "v1"
	kind:       "ConfigMap"
	data: {
		some_data: "I'm Data!"
		another_data: """
			multiline!
			several lines!
			"""
		base64thing: base64.Encode(null, "I'm some data you want to encode")
	}
}
