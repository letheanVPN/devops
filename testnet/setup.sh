#!/usr/bin/env bash
# shellcheck shell=bash

# make testnet dir
if [ ! -f "../data/itw3/testnet" ]; then
  mkdir -p ../data/itw3/testnet
fi

if [ ! -f "../blockchain/bin" ]; then
  mkdir -p ../blockchain/bin
fi

# Check for iTw3
if [ ! -d "../blockchain/itw3" ]; then
  echo "Cloning iTw3 Blockchain"
  git clone --recursive --branch=main https://github.com/letheanVPN/blockchain-iTw3.git ../blockchain/itw3
else
  echo "Updating iTw3 Blockchain"
  rm -rf blockchain/bin/itw3* || true
  (cd ../blockchain/itw3 && git pull)
fi

# compile program
if [ ! -f "../blockchain/bin/itw3d" ]; then
  echo "Building iTw3 Blockchain"
  cd ../blockchain/itw3 || exit
  make release-testnet -j2
#  make ci-release
  mv build/release/src/letheand ../../blockchain/bin/letheand
  mv build/release/src/simplewallet ../../blockchain/bin/simplewallet
  cd ../../
fi





echo "FIN"