#!/bin/bash

echo "Starting!"

export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK
ssh-add /etc/ssh-agent/ca_key
/usr/local/bin/ssh-cert-authority runserver --listen-address 0.0.0.0:8080