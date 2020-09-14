#!/bin/bash

: ${NAMESPACE:="default"}

USAGE=$(cat <<EOF
Usage:
  NAMESPACE=<namespace> SSH_USERNAME=<email> SSH_PASSWORD=<password> ./add-service-account.sh [-a|-d|--apply|--delete]
Options:
  -a, --apply : Install secret with VM SSH credentials.
  -d, --delete : Uninstall secret with VM SSH credentials.
  --help : Display this message
Environment:
  NAMESPACE : Kubernetes namespace. Defaults to "default"
  SSH_USERNAME (required) : Username for SSH access to VM
  SSH_PASSWORD (required) : Password for SSH access to VM
EOF
)

if [ -n "$1" ]; then
  if [[ "$1" == "-a" || "$1" == "--apply" ]]; then
    ACTION="apply"
  elif [[ "$1" == "-d" || "$1" = "--delete" ]]; then
    ACTION="delete"
    kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-ssh-creds.yml.tmpl
    exit 0
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

if [[ ! $SSH_USERNAME || ! $SSH_PASSWORD ]]; then
  echo -e "Username and password required!\n"
  echo "$USAGE"
  exit 1
fi

sed -e 's|$(username)|'"$SSH_USERNAME"'|' \
  -e 's|$(password)|'"$SSH_PASSWORD"'|' resources/orka-ssh-creds.yml.tmpl \
  > resources/orka-ssh-creds.yml
kubectl $ACTION --namespace=$NAMESPACE -f resources/orka-ssh-creds.yml
rm -f resources/orka-ssh-creds.yml
