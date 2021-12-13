# Installing the latest version (8.8p1) of OpenSSH on Ubuntu

## Background

Ubuntu focal (20.04.x)'s default package manager does not contain the latest version of OpenSSH. There are some key differences between version 8.8 and 8.2. To install it you must build the binary from source.


## Steps

1. Download the tar archive of your required version:
    https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
2. Unzip the tar archive and `cd` into it's extracted directory.
3. Install prerequisite packages:
```bash
sudo apt update
sudo apt install build-essential zlib1g-dev libssl-dev
```
4. Configure your build (use -h for a list of available options):

```bash
./configure
```

5. Build and install the application:

```bash
make
sudo make install
```

6. Confirm your version has been updated:
```bash
ssh -V
```
