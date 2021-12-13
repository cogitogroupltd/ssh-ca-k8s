# Installation

```bash
https://rancher.com/docs/k3s/latest/en/installation/install-options/
```

# Get cluster running

```bash
sudo k3s server
```

# Copy kube config for use with kubectl
- Helm is preinstalled with k3s, therefore doesn't need to be installed into the cluster separately
```bash
# Backup current kube-config
sudo cp $HOME/.kube/config $HOME/.kube/config-backup-$(date +%s)

# Copy k3s kube-config to kubectl config directory
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
# sudo chmod 644 $HOME/.kube/config
```