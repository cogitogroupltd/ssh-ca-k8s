#!/bin/bash

cat ./templates/signer_config-template.json | \
    sed "s/##SIGNER##/$(ssh-keygen -lf ./keys/signer-key -E md5 | cut -d' ' -f 2 | sed 's/MD5://g')/g" > signer_config.json