# Requesting a new signed public key from the ssh-cert-authority from within the cluster

Once the kubernetes cluster is up and running, follow this guide to retrieve a new signed pubic key from the certd pod.

## Prerequisites
- Kubernetes resources are deployed and ready

## Steps

1. Gain terminal access to the request pod.
```bash
kubectl exec -it --namespace default deploy/requester-app -- /bin/bash
```

2. Create a new ssh-agent, and add the requester's ssh key.
```bash
eval $(ssh-agent)
ssh-add /etc/ssh-agent/requester_key
```

3. Request a new certificate using the ssh-cert-authority commandline tool.
```bash
/usr/local/bin/ssh-cert-authority request -e test --reason "reason goes here"
``` 

4. In another terminal, gain terminal access to the signer pod.
```bash
kubectl exec -it --namespace default deploy/signer-app -- /bin/bash
```

5. Load the signer's ssh key into a new ssh-agent.
```bash
eval $(ssh-agent)
ssh-add /etc/ssh-agent/signer_key
```

5. List the pending requests
```bash
/usr/local/bin/ssh-cert-authority sign -e test
```

6. Sign the new certificate request.
```bash
/usr/local/bin/ssh-cert-authority sign -e test <Request ID> # Type Yes to the prompt!
# e.g /usr/local/bin/ssh-cert-authority sign -e test CNYMWIS6RX7OA
```

7. Retrieve the signed public certificate from within the requester pod.
```bash
/usr/local/bin/ssh-cert-authority get -e test --ssh-dir /etc/ssh-agent <Request ID>
# e.g /usr/local/bin/ssh-cert-authority get -e test --ssh-dir /etc/ssh-agent CMS4TA4JKJVMK
```

Your new signed public certificate will be available as `/etc/ssh-agent/requester_key-cert.pub`.

To see details about your new signed certificate, use `ssh-keygen -Lf <cert>`.