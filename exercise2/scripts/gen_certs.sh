#!/usr/bin/env bash
# Resource used for creating this script:
# https://devopscube.com/create-self-signed-certificates-openssl/

dir="handin2/priv/cert"

# RootCA
## Clean up
rm -rf $dir/ca || true
mkdir -p $dir/ca

## Generate a CA certificate
openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=SEC1MA2/C=DK/L=Copenhagen" \
            -keyout $dir/ca/rootCA.key -out $dir/ca/rootCA.crt 


for person in "alice" "bob"
do
    # Clean up
    rm -rf $dir/$person || true
    mkdir -p $dir/$person

    # Generate the private key
    openssl genrsa -out $dir/$person/$person.key 2048

    # Generate the CSR
    openssl req -new -sha256 \
                -key $dir/$person/$person.key \
                -subj "/CN=$person/C=DK/L=Copenhagen" \
                -out $dir/$person/$person.csr

    # Sign the CSR with the CA
    openssl x509 -req -sha256 \
                 -in $dir/$person/$person.csr \
                 -CA $dir/ca/rootCA.crt \
                 -CAkey $dir/ca/rootCA.key \
                 -CAcreateserial \
                 -out $dir/$person/$person.crt \
                 -days 356
done


debugPrint() {
    echo "[GENCERTS] $*"
}