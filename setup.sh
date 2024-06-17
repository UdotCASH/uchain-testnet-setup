#!/bin/bash

# Create the devnet directory
mkdir devnet

# Copy the required files to the devnet directory
cp genesis.json config.yml jwt.hex secret.txt devnet/

# Change to the devnet directory
cd devnet

# Clone the prysm repository and build the necessary binaries
git clone --branch release-v5.0.2 https://github.com/prysmaticlabs/prysm.git && cd prysm
CGO_CFLAGS="-O2 -D__BLST_PORTABLE__" go build -o=../beacon-chain ./cmd/beacon-chain
CGO_CFLAGS="-O2 -D__BLST_PORTABLE__" go build -o=../validator ./cmd/validator
CGO_CFLAGS="-O2 -D__BLST_PORTABLE__" go build -o=../prysmctl ./cmd/prysmctl
cd ..

# Clone the go-ethereum repository and build the geth binary
git clone https://github.com/ethereum/go-ethereum && cd go-ethereum
make geth
cp ./build/bin/geth ../geth
cd ..

# Generate the genesis file using prysmctl
./prysmctl testnet generate-genesis --fork deneb --num-validators 64 --genesis-time-delay 90 --chain-config-file config.yml --geth-genesis-json-in genesis.json --geth-genesis-json-out genesis.json --output-ssz genesis.ssz

# Call the geth command and import the account with the password "yay"
echo -e "yay\nyay" | ./geth --datadir=gethdata account import secret.txt

# Initialize the datadir with the genesis file
./geth --datadir=gethdata init genesis.json
