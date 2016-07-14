#!/bin/sh -e

cd src

nix-build

cp -r result/* ..


