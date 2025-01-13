#!/usr/bin/env bash
# shellcheck shell=bash
if [ ! -d "blockchain/legacy" ]; then
  echo "This script is going to take quite some time... don't wait around"
  echo "waiting for 15 seconds just to let you see this"
  sleep 15
fi
# Check for Lethean
if [ ! -d "blockchain/legacy" ]; then
  echo "Cloning Lethean Legacy Blockchain"
  git clone --recursive --depth=1 https://github.com/letheanVPN/blockchain-iz.git blockchain/legacy
else
  echo "Updating Lethean Legacy Blockchain"
  rm -rf blockchain/bin/lethean* || true
  (cd blockchain/legacy && git pull)
fi

# Check for iTw3
if [ ! -d "blockchain/itw3" ]; then
  echo "Cloning iTw3 Blockchain"
  git clone --recursive --branch=main --depth=1 https://github.com/letheanVPN/blockchain-iTw3.git blockchain/itw3
else
  echo "Updating iTw3 Blockchain"
  rm -rf blockchain/bin/itw3* || true
  (cd blockchain/itw3 && git pull)
fi


if [ ! -f "blockchain/bin/letheand" ]; then
  echo "Building Lethean Blockchain"
  mkdir -p blockchain/bin
  cd blockchain/lthn || exit
  make -j2 release-static-linux-x86_64-local-boost
  make ci-release
  mv build/packaged/* ../../blockchain/bin
  cd ../../
fi

if [ ! -f "blockchain/bin/itw3d" ]; then
  echo "Building iTw3 Blockchain"
  cd blockchain/itw3 || exit
  make release-testnet -j2
#  make ci-release
  mv build/release/bin/* ../../blockchain/bin
  cd ../../
fi


mkdir -p data/itw3/testnet
mkdir -p data/legacy/testnet

echo "FIN"