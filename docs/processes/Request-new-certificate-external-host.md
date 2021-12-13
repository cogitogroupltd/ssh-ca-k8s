# Requesting a new signed public key from the ssh-cert-authority from outside the cluster

Once the kubernetes cluster is up and running, follow this guide to retrieve a new signed pubic key from the certd pod.

## Prerequisites
- Kubernetes resources are deployed and ready
- NodePort 300080 is accessible
  - `curl <cluster address>:30080` should return "404 Not Found"
- ssh-cert-authority binary installed on your host

## Steps
Replace "localhost" with your cluster address if not running on localhost. 


1. Generate a new configuration file for a requester for your host.
   - Point to your public key with the --key-file tag.
```bash
ssh-cert-authority generate-config --url http://localhost:30080 --key-file <public key path> > req.conf.json 
# e.g ssh-cert-authority generate-config --url http://localhost:30080 --key-file ./requester-key.pub > req.conf.json 
```

2. Create a new ssh-agent, and add your specified ssh key.
```bash
eval $(ssh-agent)
ssh-add <key file>
# e.g ssh-add $(pwd)/requester-key.pub
```

3. Request a new certificate using the ssh-cert-authority commandline tool.
   - Set the reason to be something indicative of why you require this access.
```bash
ssh-cert-authority request -e test --config-file req.conf.json --reason "reason goes here"
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

6. List the pending requests
```bash
/usr/local/bin/ssh-cert-authority list -e test
```

7. Sign the new certificate request.
```bash
/usr/local/bin/ssh-cert-authority sign -e test <Request ID> # Type Yes to the prompt!
# e.g /usr/local/bin/ssh-cert-authority sign -e test CNYMWIS6RX7OA
```

8. Retrieve the signed public certificate from your host.
   - If your ssh key isn't in the current directory, replace the value of --ssh-dir with the directory containing your ssh key. Leave blank if it's in the default ssh directory (for example ~/.ssh/). 
```bash
ssh-cert-authority get -e test --config-file req.conf.json --ssh-dir . <Request ID>
# e.g ssh-cert-authority get -e test --ssh-dir /etc/ssh-agent CMS4TA4JKJVMK
```

Your new signed public certificate will be available as `<your private key name>-cert.pub`.

To see details about your new signed certificate, use `ssh-keygen -Lf <cert>`.