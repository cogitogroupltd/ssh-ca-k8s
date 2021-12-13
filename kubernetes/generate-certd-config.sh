#!/bin/bash

cat ./templates/sign_certd_config-template.json | \
    sed "s/##CA_KEY##/$(ssh-keygen -lf ./keys/ca-key -E md5 | cut -d' ' -f 2 | sed 's/MD5://g')/g" | \
    sed "s/##REQUESTER##/$(ssh-keygen -lf ./keys/requester-key -E md5 | cut -d' ' -f 2 | sed 's/MD5://g')/g" | \
    sed "s/##SIGNER##/$(ssh-keygen -lf ./keys/signer-key -E md5 | cut -d' ' -f 2 | sed 's/MD5://g')/g" > sign_certd_config.json