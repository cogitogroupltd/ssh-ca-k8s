# 1 +2 Setup ssh-cert-authority locally to confirm workflow + in VMs

git repo: https://github.com/cloudtools/ssh-cert-authority


## Setup ssh_ca on EC2 machine

Launch EC2 into frankfurt region

Add test ssh key pair for access `naqeeb-test.pem`
- Convert pem to ppk for Putty using PuttyGen

ext dns: ec2-46-137-38-1.eu-west-1.compute.amazonaws.com
  - use PuTTy to access the ec2 ec2-user@ec2-46-137-38-1.eu-west-1.compute.amazonaws.com
Get ssh-cert-authority for linux-amd-64

## Get ssh-cert-authority installed on EC2
```bash
wget https://github.com/cloudtools/ssh-cert-authority/releases/download/2.0.0/ssh-cert-authority-linux-amd64.gz
gunzip ssh-cert-authority-linux-amd64.gz
mv ssh-cert-authority-linux-amd64 ssh-ca
chmod +x ssh-ca

# Generate new ssh key for CA (make sure to put the signature into the certd config)
ssh-keygen

# Get MD5 signature to put into config file
ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5
```

## Setup ssh-cert-authority runserver
### Create config file for certd (ssh-ca runserver daemon)
```bash
mkdir ~/.ssh_ca
nano ~/.ssh_ca/sign_certd_config.json
```

### Get `SigningKeyFingerprint` for default ssh key
```bash
# ssh-keygen -lf ~/.ssh/id_rsa.pub MUST BE MD5 FINGERPRINT!, amend in config file
ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5
```

### Test config file:
```json
{
  "test": {
        "NumberSignersRequired": -1,
        "MaxCertLifetime": 0,
        "SigningKeyFingerprint": "65:d2:88:26:62:38:4a:d1:b1:ba:70:42:c0:b3:b7:e3",
        "AuthorizedSigners": {
          "50:a9:a7:c5:1f:32:83:ac:a0:cc:7e:3f:b6:a5:e9:d7":"ca"
        },
        "AuthorizedUsers": {
          "50:a9:a7:c5:1f:32:83:ac:a0:cc:7e:3f:b6:a5:e9:d7":"ca"
        }
  }
}
```

### Config file with 1 approval required (add signatures of authrorized signers and users)
```json
{
  "test": {
        "NumberSignersRequired": 1,
        "MaxCertLifetime": 0,
        "SigningKeyFingerprint": "65:d2:88:26:62:38:4a:d1:b1:ba:70:42:c0:b3:b7:e3",
        "AuthorizedSigners": {
          "65:d2:88:26:62:38:4a:d1:b1:ba:70:42:c0:b3:b7:e3":"daemon"
        },
        "AuthorizedUsers": {
          "50:a9:a7:c5:1f:32:83:ac:a0:cc:7e:3f:b6:a5:e9:d7":"naqeeb",
          "65:d2:88:26:62:38:4a:d1:b1:ba:70:42:c0:b3:b7:e3":"daemon",
          "f2:3a:a9:54:70:aa:a6:04:d5:23:18:24:e5:55:24:4f":"naqeeb2",
          "d9:41:c0:01:a2:71:a2:18:2b:a5:5f:2a:b9:ef:82:ab":"george
        }
  }
}
```
### Run ssh-ca runserver

```bash
# Expose SSH_AUTH_SOCK for a new ssh agent
export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK

# Add default ssh key (~/.ssh/id_rsa) to ssh agent running on SSH_AUTH_SOCK
ssh-add ~/.ssh/id_rsa

# Run the ssh-ca certd server
./ssh-ca runserver

# For remote access need to expose on internal IP address instead of 127.0.0.1:8080 (default)
./ssh-ca runserver --listen-address "$(curl http://169.254.169.25ata/local-ipv4 -s):8080"
```

- Allow inbound port 8080 traffic on EC2
  - `ssh-CA runserver` hosts on port 8080

## User side

Get ssh-ca
```bash
wget https://github.com/cloudtools/ssh-cert-authority/releases/download/2.0.0/ssh-cert-authority-linux-amd64.gz
gunzip ssh-cert-authority-linux-amd64.gz
mv ssh-cert-authority-linux-amd64 ssh-ca
chmod +x ssh-ca
```

Get config file for client side
```bash
./ssh-ca generate-config --url http://ec2-46-137-38-1.eu-west-1.compute.amazonaws.com
nano ~/.ssh_ca/requester_config.json
./ssh-ca request
```


Get config file for client side
```bash
./ssh-ca generate-config --url http://localhost:8080 > ~/.ssh_ca/requester_config.json
nano ~/.ssh_ca/requester_config.json
cat ~/.ssh_ca/requester_config.json
```


Test config
```json
{
    "test": {
        "PublicKeyPath": "/home/noqib/.ssh/id_rsa.pub",
        "SignerUrl": "http://localhost:8080/"
    }
}
```

Request cert
```bash

export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK
ssh-add ~/.ssh/id_rsa

./ssh-ca request --environment test --reason "very important urgent work mhmm mhmm"

```

Signer config (~/.ssh_ca/signer_config.json)
```json
{
    "test": {
        "KeyFingerprint": "50:a9:a7:c5:1f:32:83:ac:a0:cc:7e:3f:b6:a5:e9:d7",
        "SignerUrl": "http://ec2-46-137-38-1.eu-west-1.compute.amazonaws.com:8080/"
    },
    "test2": {
        "KeyFingerprint": "f2:3a:a9:54:70:aa:a6:04:d5:23:18:24:e5:55:24:4f",
        "SignerUrl": "http://ec2-46-137-38-1.eu-west-1.compute.amazonaws.com:8080/"
    }
}
```
```json
{
    "test": {
        "KeyFingerprint": "65:d2:88:26:62:38:4a:d1:b1:ba:70:42:c0:b3:b7:e3",
        "SignerUrl": "http://ec2-46-137-38-1.eu-west-1.compute.amazonaws.com:8080/"
    }
}
```

Sign cert
```bash
export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK
ssh-add ~/.ssh/id_rsa-2

./ssh-ca sign --environment test2 AE2Q6HOO7GEPU

```


Test connection from non-authorised key
```bash
wget https://github.com/cloudtools/ssh-cert-authority/releases/download/2.0.0/ssh-cert-authority-darwin-amd64.gz
gunzip ssh-cert-authority-darwin-amd64.gz
mv ssh-cert-authority-darwin-amd64 ssh-ca
chmod +x ssh-ca

export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK
ssh-add

mkdir ~/.ssh_ca
./ssh-ca generate-config --url http://ec2-46-137-38-1.eu-west-1.compute.amazonaws.com:8080 > ~/.ssh_ca/requester_config.json

CERT_ID=KNNYW4ZXB5OT6
# ./ssh-ca request --environment test --reason "very important urgent work mhmm mhmm"
# ./ssh-ca approve --environment test $CERT_ID
./ssh-ca get --environment test $CERT_ID
```

ssh ec2-user@ip-172-31-2-7

## Notes
- Only requester can retrieve certificate using certificate ID
  - is based on requesting ssh key
- Only non-requester(s) can approve a cert


# 3. Containerise! (+ deploy into local `kind` cluster)

## Build and push docker image
```bash
cd docker

docker build -t ssh-ca .

docker tag ssh-ca naqibdocker/ssh-ca-test:latest

docker login --username naqibdocker -p ###

docker push naqibdocker/ssh-ca-test:latest
```

## Build kind cluster
```bash
cd kind

kind create cluster --config cluster.yml
```

## Deploy ssh-ca to kind cluster
```bash

kubectl delete secret sshd-key --ignore-not-found ;  kubectl create secret generic ca-key --from-file=./keys/ca-key
kubectl delete secret sshd-pub-key --ignore-not-found ;  kubectl create secret generic ca-pub-key --from-file=./keys/ca-key.pub
kubectl delete configmap ssh-ca-config --ignore-not-found ;  kubectl create configmap ssh-certd-config --from-file=sign_certd_config.json

k create -f pod.yml
k create -f svc.yml

echo "Waiting for ssh-ca pod to become ready"
kubectl wait --for=condition=ready pod -l run=ssh-ca
```
## Deploy requester to kind cluster
```bash
k create -f requester.yml

echo "Waiting for ssh-ca pod to become ready"
kubectl wait --for=condition=ready pod -l run=requester
```

## Deploy ssh worker pod to kind cluster

```bash
cd /mnt/c/Users/Naqeeb/Desktop/tasks/CogitoGroup/poc/lsyncd-sshd
helm upgrade --install sshd ./sshd
```

## Deploy requester pod to kind cluster
```bash
# Setup ssh-agent and auth socket env var
export $(ssh-agent | cut -d';' -f1 | head -n 1) ; echo $SSH_AUTH_SOCK
ssh-add
ssh-add -l # Confirm key has been added to ssh agent

# Get config
./ssh-cert-authority generate-config --url http://localhost:8080 > ~/.ssh_ca/requester_confg.json
```