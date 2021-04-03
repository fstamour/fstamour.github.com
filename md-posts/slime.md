---
title: How Slime/Swank works internally
date: 2020-04-27
---

I have been interested in how slime works in emacs, here are my notes.

## Motivations

I was wondering what kind of (smart) extensions could be build on top
of slime's framework. And I was also interested to understand how does
it support other languages and how tied is it to emacs and common
lisp.

## Starting point

I started slime in emacs, `M-x slime RET`, then I opened a scratch
buffer with `M-x slime-scratch`.

In this new buffer I used `C-h k` to find out which function is called
by emacs when pressing `C-M-x`.

By default, it is bound to `slime-eval-defun`. To find this (emacs
lisp) function definition, I switched to the `*scratch*` buffer typed
`slime-eval-defun` and pressed `M-.` (xref-find-definitions).

## Digging down the call stack

```lisp
(defun slime-eval-defun ()
  "Evaluate the current toplevel form.
Use `slime-re-evaluate-defvar' if the from starts with '(defvar'"
  (interactive)
  (let ((form (slime-defun-at-point)))
    (cond ((string-match "^(defvar " form)
           (slime-re-evaluate-defvar form))
          (t
           (slime-interactive-eval form)))))
```

> `(slime-eval-defun)` uses `(slime-defun-at-point)` to get the
> form to evaluate and uses `(slime-interactive-eval form)` and
> `defvar`s are handled differently.

```lisp
(defun slime-interactive-eval (string)
  "Read and evaluate STRING and print value in minibuffer.

Note: If a prefix argument is in effect then the result will be
inserted in the current buffer."
  (interactive (list (slime-read-from-minibuffer "Slime Eval: ")))
  (cl-case current-prefix-arg
    ((nil)
     (slime-eval-with-transcript `(swank:interactive-eval ,string)))
    ((-)
     (slime-eval-save string))
    (t
     (slime-eval-print string))))
```

`slime-interactive-eval` calls either 

* `slime-eval-with-transcript` when there is no modifier.
* `slime-eval-save` with the `C--` prefix modifier.
* `slime-eval-print` with the `C-u` prefix modifier.

> `slime-eval-with-transcript` uses the macro 'slime-rex' (rex stands
> for remote execute) whereas `slime-eval-{print,save}` use
> `slime-eval-async` which in turn also uses `slime-rex`.

### Analysing `slime-rex`

`slime-rex` is a macro, here is it definition (without the body).

```lisp
(defmacor slime-rex ((&rest saved-vars)
                        (sexp &optional
                              (package '(slime-current-package))
                              (thread 'slime-current-thread))
                        &rest continuations)
						...)
```

Let's dissect its documentation.

It starts with an example usage of the macro. We can see that some
arguments don't have the same name (`saved-vars` is `var ...` and
`continuations` is `clauses`).

> (slime-rex (VAR ...) (SEXP &optional PACKAGE THREAD) CLAUSES ...)

Followed by pretty broad description of what the macros does.
 
> Remote EXecute SEXP.


> VARs are a list of saved variables visible in the other forms.  Each
> VAR is either a symbol or a list (VAR INIT-VALUE).

Visible to what? And why would it need a initial value?

> SEXP is evaluated and the princed version is sent to Lisp.

That's some lisp jargon, the takeaway is that the macro takes a form
in, evaluate it in emacs and use `printc` 
 
> PACKAGE is evaluated and Lisp binds *BUFFER-PACKAGE* to this package.
> The default value is (slime-current-package).
> 
> CLAUSES is a list of patterns with same syntax as
> `slime-dcase'.  The result of the evaluation of SEXP is
> dispatched on CLAUSES.  The result is either a sexp of the
> form (:ok VALUE) or (:abort CONDITION).  CLAUSES is executed
> asynchronously.
> 
> Note: don't use backquote syntax for SEXP, because various Emacs
> versions cannot deal with that.

## Other useful or interesting functions I found while digging

* slime-current-package
* slime-current-thread
* slime-connected-p




