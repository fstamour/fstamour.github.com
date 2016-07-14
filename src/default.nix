#!/usr/bin/env nix-build

# Heavily inspired by http://utdemir.com/posts/hakyll-on-nixos.html

{ pkgs ? import <nixpkgs> {} }:
let generator = pkgs.stdenv.mkDerivation {
      name = "generator";
      src = ./generator;
      phases = "unpackPhase buildPhase";
      buildInputs = [
        (pkgs.haskellPackages.ghcWithPackages (p: with p; [ hakyll ]))
      ];
      buildPhase = ''
        mkdir -p $out/bin
        ghc -O2 -dynamic --make main.hs -o $out/bin/generate-site
      '';
    };
    # "Bootswatch is a collection of open source themes for Bootstrap."
    bootswatch = pkgs.fetchgit {
      url = "git://github.com/thomaspark/bootswatch";
      rev = "15748399fcd2d06b58206cfcb4b7560cf7243637";
      sha256 = "12l9s8lj4lwx0xf0w17xqaqhnvh5mj6qngxyppdi3mrg2zhvh3jc";
    };
    # Jquery!
    jquery = pkgs.fetchgit {
       url = "git://github.com/jquery/jquery";
       rev = "7751e69b615c6eca6f783a81e292a55725af6b85";
       sha256 = "1rqsinlj7yjcf5fdnbiksmklkpam3cxmsqlnpnwi5di0pxw79jr1";
    };
in pkgs.stdenv.mkDerivation {
     name = "mpsyco-site";
     src = ./site;
     phases = "unpackPhase buildPhase";
     buildInputs = [ generator bootswatch ];
     buildPhase = ''
       export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
       cp ${bootswatch}/readable/bootstrap.min.css static/
       cp ${jquery}/dist/jquery.min.js static/
       LANG=en_US.UTF-8 generate-site build
       mkdir $out
       cp -r _site/* $out
     '';
   }
