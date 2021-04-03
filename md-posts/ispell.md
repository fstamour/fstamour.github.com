---
title: Spell checking in Emacs on Nix-OS
date: 2016-07-20
---

Hi again,
I said in my first post that I wanted to add spell checking to my "writing process". First reflex, I open Emacs and type `M-x ispell`. I never used it, but I had a hunch. (I will write this post while I try to set this up).

Being on nix-OS, `ispell` was not installed because I didn't asked it to be installed. So I got the message `Searching for program: no such file or directory, ispell` from Emacs.

Time to Google a little bit, I quickly found [https://www.emacswiki.org/emacs/InteractiveSpell](https://www.emacswiki.org/emacs/InteractiveSpell) which I read _very_, _very_ superficially.

Having done "reading", I decided to install `hunspell`:

```shell
nix-env -i hunspell
```

And installing some dictionaries too:

```shell
nix-env -i hunspell-dict-fr-moderne-dicollecte hunspell-dict-fr-any-dicollecte hunspell-dict-en-gb-ize-wordlist hunspell-dict-es-cu-rediris
```

Trying again `M-x ispell` in Emacs, still got the same error message... Hmm maybe it is literally searching for `ispell` and nix-OS simply install `hunspell`.

Back to the terminal, `ispell` is not found, but `hunspell` is.
Looking at the website again, found the gem `(setq ispell-program-name "hunspell")`
Eval'd it in Emacs, now I get the error `ispell-parse-hunspell-affix-file: ispell-phaf: No matching entry for nil.`

Thanks to [StackOverflow: spell check not working in Emacs text editor](http://stackoverflow.com/a/29481811) (and the [first site](https://www.emacswiki.org/emacs/InteractiveSpell)), I eval'd that little piece of s-exp:

```elisp
(add-to-list 'ispell-local-dictionary-alist '("english-hunspell"
                                              "[[:alpha:]]"
                                              "[^[:alpha:]]"
                                              "[']"
                                              t
                                              ("-d" "en_US")
                                              nil
					      UTF-8))
```					      

Trying `M-x ispell` again. Got
`Starting new Ispell process hunspell with default dictionary...
ispell-send-string: Process ispell not running`.

My guess was that hunspell wasn't able to find the dictionary file.
```shell
[mpsyco@lambda:~]$ hunspell
Can't open affix or dictionary files for dictionary named "en_US".
```
Looks like it (and, yes, I named my computer with nix-OS installed on it _lambda_). It is completely normal that it doesn't find it since I installed en_GB instead of en_US...

Changing the LANG doesn't seems to help:
```shell
[mpsyco@lambda:~]$ export LANG=en_GB

[mpsyco@lambda:~]$ hunspell
Can't open affix or dictionary files for dictionary named "en_GB".
```

Here, it took me a while to figure exactly what to do :(

BUT! Thank to [this](http://comments.gmane.org/gmane.linux.distributions.nixos.scm/29893) commit, I finally figured where the dictionaries were and how to tell hunspell to search there:

```shell
[mpsyco@lambda:~]$ export DICPATH=$HOME/.nix-profile/share/hunspell

[mpsyco@lambda:~]$ hunspell -D
SEARCH PATH:
.::/home/mpsyco/.nix-profile/share/hunspell:/usr/share/hunspell:/usr/share/myspell:/usr/share/myspell/dicts:/Library/Spelling:/home/mpsyco/.openoffice.org/3/user/wordbook:.openoffice.org2/user/wordbook:.openoffice.org2.0/user/wordbook:Library/Spelling:/opt/openoffice.org/basis3.0/share/dict/ooo:/usr/lib/openoffice.org/basis3.0/share/dict/ooo:/opt/openoffice.org2.4/share/dict/ooo:/usr/lib/openoffice.org2.4/share/dict/ooo:/opt/openoffice.org2.3/share/dict/ooo:/usr/lib/openoffice.org2.3/share/dict/ooo:/opt/openoffice.org2.2/share/dict/ooo:/usr/lib/openoffice.org2.2/share/dict/ooo:/opt/openoffice.org2.1/share/dict/ooo:/usr/lib/openoffice.org2.1/share/dict/ooo:/opt/openoffice.org2.0/share/dict/ooo:/usr/lib/openoffice.org2.0/share/dict/ooo
AVAILABLE DICTIONARIES (path is not mandatory for -d option):
/home/mpsyco/.nix-profile/share/hunspell/fr-toutesvariantes
/home/mpsyco/.nix-profile/share/hunspell/en_GB-ize
/home/mpsyco/.nix-profile/share/hunspell/es_CU
/home/mpsyco/.nix-profile/share/hunspell/fr-moderne
Can't open affix or dictionary files for dictionary named "en_GB".
```

Note to myself: In the future, look into `~/.nix-profile/` for something installed via `nix-env -i`.

Good enough, now I can tweak the `ispell-local-dictionary-alist`:
```
(setq ispell-local-dictionary-alist '(("english-gb"
                                              "[[:alpha:]]"
                                              "[^[:alpha:]]"
                                              "[']"
                                              t
                                              ("-d" "en_GB-ize")
                                              nil
					      UTF-8)))
```

`M-x ispell`
```
Starting new Ispell process hunspell with default dictionary...
Spell-checking ispell.md using hunspell with default dictionary...done
ispell-send-string: Process ispell not running
```

... Forgot to set the DICPATH environment variable for the _still running_ Emacs!

`(setenv "DICPATH" "/home/mpsyco/.nix-profile/share/hunspell")`

Still not working. Ah, the LANG environment variable is also "not OK", my computer is actually configured with the "en_US.UTF-8" locale. Better install a "en_US" dictionary to make sure.

```shell
[mpsyco@lambda:~]$ echo $LANG
en_US.UTF-8

[mpsyco@lambda:~] # Just a small utility that I found on internet
[mpsyco@lambda:~]$ type nix-search
nix-search is a function
nix-search () 
{ 
    echo "Searching...";
    nix-env -qaP --description '*' | grep -i "$1"
}

[mpsyco@lambda:~]$ nix-search hunspell | fgrep -i us
nixos.hunspellDicts.en-us                                             hunspell-dict-en-us-wordlist-2014.11.17                                       Hunspell dictionary for English (United States) from Wordlist
nixos.mythes                                                          mythes-1.2.4                                                                  Thesaurus library from Hunspell project

[mpsyco@lambda:~]$ nix-env -i hunspell-dict-en-us-wordlist
installing ‘hunspell-dict-en-us-wordlist-2014.11.17’
these paths will be fetched (0.16 MiB download, 0.53 MiB unpacked):
  /nix/store/ffq4kp48xm12mpiaklrk2yp2l491fgfa-hunspell-dict-en-us-wordlist-2014.11.17
fetching path ‘/nix/store/ffq4kp48xm12mpiaklrk2yp2l491fgfa-hunspell-dict-en-us-wordlist-2014.11.17’...

*** Downloading ‘https://cache.nixos.org/nar/1nl4wq5s5n1h1g450rzwxi79xiyqmi8gm8j82wqida9cflaqqicg.nar.xz’ (signed by ‘cache.nixos.org-1’) to ‘/nix/store/ffq4kp48xm12mpiaklrk2yp2l491fgfa-hunspell-dict-en-us-wordlist-2014.11.17’...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  159k  100  159k    0     0   365k      0 --:--:-- --:--:-- --:--:--  364k

building path(s) ‘/nix/store/793l0bjhlq2ffm7jkx5p891b7gbps28i-user-environment’
created 4355 symlinks in user environment
```

Now, hunspell works out of the box in the shell:
```shell
[mpsyco@lambda:~]$ hunspell
Hunspell 1.3.3
^C
```

And drum roll....

`M-x ispell`

```
Starting new Ispell process hunspell with default dictionary...
Spell-checking ispell.md using hunspell with default dictionary...
Spell-checking suspended; use C-u z = to resume
```

Oh yeah! Now I [can] have spell checking everywhere in Emacs.

But, I'm not done yet, I want to make sure it will works the next time I open Emacs.

Adding

```
export DICPATH="$HOME/.nix-profile/share/hunspell:$DICPATH"
```

Into my `~/.profile`.

Opening Emacs in a new terminal:

<script type="text/javascript" src="https://asciinema.org/a/cqebb1bylw9nyq0rbbq6spmh9.js" id="asciicast-cqebb1bylw9nyq0rbbq6spmh9" async></script>

Looks all good!


The funny thing is that, in the end, I didn't have to tweak my Emacs' configurations _at all_, not `ispell-local-dictionary-alist`, nor `ispell-program-name`, not even a little `(setenv ...)`. Which means they were all red-hearing that could probably have been avoided with better error reporting from Emacs. But as I keep finding out on nix-OS, people don't seem to be good at reporting this kind of thing. [Here](https://github.com/roswell/roswell/issues/151) is one example, it was a program (that I tried on Windows) that tried to start Emacs, but spewed around 30 lines of backtrace when it wasn't found.

One last note, the last post was written with Vim in a terminal, this one was written within Emacs. Unfortunately Emacs didn't colored the markdown out of the box which is reaaally annoying when re-reading the whole thing, or when seeking for something.
