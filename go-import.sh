#!/bin/bash

# download imported golang packages
go get
# make sure go.sum is correct, and everything's good
go mod tidy

# Import all _golang_ packages into _cue_ definitions
PACKAGE_LIST=$(go list -f '{{range $imp := .Imports}}{{printf "%s\n" $imp}}{{end}}' | sort)

for p in $PACKAGE_LIST
do
  cue get go $p
  echo "Imported $p"
done
