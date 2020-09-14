#!/bin/bash

: ${NAMESPACE:="default"}
# : ${ACTION:="apply"}
: ${ORKA_API:="http://10.221.188.100"}

USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> ORKA_API=<url> ./install [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install all tasks and config map
  -d, --delete : Uninstall all tasks and config map
  --help : Display this message
Environment:
  NAMESPACE : defaults to "default"
  ORKA_API : defaults to "http://10.221.188.100"
EOF
)

if [ -n "$1" ]; then
  if [[ "$1" == "-a" || "$1" == "--apply" ]]; then
    ACTION="apply"
  elif [[ "$1" == "-d" || "$1" = "--delete" ]]; then
    ACTION="delete"
  elif [[ "$1" == "--help" ]]; then
    echo "$USAGE"
    exit 0
  else
    echo -e "Unkown argument: $1\n"
    echo "$USAGE"
    exit 1
  fi
else
  ACTION="apply"
fi

# Install config map
sed -e 's|$(url)|'"$ORKA_API"'|' resources/orka-tekton-config.yml.tmpl \
  > resources/orka-tekton-config.yml
kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-tekton-config.yml
rm -f resources/orka-tekton-config.yml

# Install tasks
kubectl $ACTION --namespace=$NAMESPACE \
  -f tasks/orka-full.yml \
  -f tasks/orka-init.yml \
  -f tasks/orka-deploy.yml \
  -f tasks/orka-teardown.yml
