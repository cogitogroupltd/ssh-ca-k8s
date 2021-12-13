# Part 2
This is a second NOTES file to separate phase 1 (initial POC for proving ssh-CA is usable) and phase 2 (ssh hardening and streamlining of workflows)

Tasks
1. Replace pod definitions with a generic helm chart. DONE
2. Test if rsa‐sha2‐512 keys work
   - https://github.com/cloudtools/ssh-cert-authority/pull/49/commits/e4883330ef6f3f337621d0e6e5704acea870d192
   - https://github.com/cloudtools/ssh-cert-authority/issues/48
   - Upgrade CA Signatures to RSA-SHA2-256 instead of MD5
3. Client side SSH config + ASSH POC
4. Configure OpenSSH server to store keys (priv + priv CAs in memory (e.g. /dev/shm)
5. Server side SSH config
6. ZeroTier integration

Processes
1. Authorize new user to be able to request certificates from certd server
   1. New user:
   - Generate a new ssh-keypair
   - Generate MD5 hash of the new keypair
   - Send MD5 hash to certd server
     - This process can be automated or done by hand
     - Intially we will assume the certd server (ssh-certificate-authrority runserver) and sshd server (ssh server to be logged in to) are owned by the same person.
   1. Certd server: 
   - Input new MD5 hash into config file
   - Restart server
2. Authorize new user to be able to sign certificate requests


2021-12-10 TODO

- [ ] Document process of recreating keypairs
- [ ] ASSH example
 - [ ] Document process of establishing assh connection
 - [ ] Include assh configuration within certd docker image
 - [ ] Update diagram to include sshd-hostb and sshd-hostc pods
 - [ ] Update diagram to include assh connection pathway
- [ ] Add SSH client side configuration to certd docker image
  - [ ] Document process of updating client side ssh configuration
- [ ] Serverside SSH configuration
- [ ] ZeroTier integration
- [ ] Simple UI for cert signing
  - [ ] Write html ui - calls ssh-ca list and prints to screen with sign buttons
    - [ ] Auto-sign toggle
  - [ ] Expose using NodePort
- [ ] Script to create full kubernetes cluster and populate resources automatically