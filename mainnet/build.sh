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


if [ ! -f "blockchain/bin/letheand" ]; then
  echo "Building Lethean Blockchain"
  mkdir -p blockchain/bin
  cd blockchain/legacy || exit
  make -j2 release-static-linux-x86_64-local-boost
  make ci-release
  mv build/packaged/* ../../blockchain/bin
  cd ../../
fi

mkdir -p data/legacy/testnet

echo "FIN"