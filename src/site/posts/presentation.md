---
title: Presentation
date: 2016-07-13
---

Hello, this is my first post ever.
It is simply about how it was built.

First of all, all credits goes to [Utku Demir](https://github.com/utdemir), because I mostly copied [his setup](http://utdemir.com/posts/hakyll-on-nixos.html). I simply removed font-awesome and Disqus in order to make it work, I also used a different style (from the [same theme repository](http://bootswatch.com/)).

It was built with the aid of [nix](http://nixos.org/nix/) and [hakyll](https://jaspervdj.be/hakyll/). This is also my first attemps at haskell, looks good to me :D.

Another choice that I made differently is that I keep the sources of the static pages in the same repository as the static pages. It save me a little bit of (unecessary) git-foo.

## Why

I wanted something minimal, but using nix. [Utmedir]'s way seemed nice, so I tried it and liked it. So I will stick with that for the moment.

## Pros

* Deterministic builds!
* I can work on a post without publishing it, as long as I don't re-compile _and_ re-commit/push the changes. This is really a fundamental feature for blogging, but I wasn't sure how it would work if I used something that minimal.
* I can write post in every format supported by [Pandoc](http://pandoc.org/).
* I can customize the build at will. Of course, I could do that with a project written by some scaffolding tool like yeoman. But here, I didn't have to learn anything special. Hell, I never touched haskell code, but I had no difficulty modifying the DSL Hakyll uses.
* I can write posts in _any_ editor (currently using vim in a terminal). Also, I didn't check, but I am sure there are some editor with live preview (maybe Atom?).

## Cons

* No minification out of the box.
* No as interactive as I like, at my job I maintain a whole application written in common lisp, it is highly satisfying to re-evaluate a small piece of code in emacs and see the result in the browser almost immediatly. With this setup, I need to call something at the command line to rebuild the whole thing. I am pretty sure I can fix those issues with some file watchers and some live-reload.
* It doesn't use boring technology. It might be harder to find help/documentation/etc.

## Future

* Spell checker - I know myself, I will need it :P
* Multiple language - I speak mainly french and I would like to post things in french as well as english. I also used to speak spanish, but I didn't pratice it in 10 years, it could be a nice (re-)learning experience to translate my posts in spanish.

