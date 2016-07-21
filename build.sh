#!/bin/sh -e

cd src

nix-build

cp --no-preserve=mode -r result/* ..


