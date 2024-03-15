# Emacs configuration files
This are my configuration files for vanilla emacs. This configuration files are made thinking in only using the toold provided for emacs so `use-package` is discarded.
I like to use the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).
Also emacs since version 27 already has support for XDG so the configuration files related to emacs are saved in the folder `~/.config/emacs/`

## config.org
Emacs lisp can be a little bit dificult if you are new to emacs so having a literate config can help to understand what is certain blocks of code doing.
Even if you do know programming in elisp it can be a little dificult to read your configuration file in pure elisp, an unless you comment everything (what is good)
with the time this file (.emacs or init.el or config.el) can grow largley so maintainig that can be very tedious and unecesary complex.

TLDR; I like to use literate config with org mode in emacs, for me and for others is more easy to read and understand what every line of code is doing or 
what is the purpose of certain code.

# The init file
emacs have org mode enable by default, so you only have to create an org file in the directory you want.
After you just put this code in yout init file to babel load your org file.
```emacs-lisp
(org-babel-load-file "~/.config/emacs/config/org"
```
`org-babel-load-file` is a function inside org.el that load emacs lisp source code block from your org file to an elisp file. first exports the source code using another
function `org-babel-tangle` and then loads that code into a lisp file *usually that file have the same name of your org file, so if your org file is called
config.org the lisp file its going to be called config.el*.
`org-babel-load-file` function receive an argument, that argument is the path to your org file.

To check its working you just write some code between this line `#+BEGIN_SRC elisp` and  `#+END_SRC` (this will crate a emas-lisp code block) in your org file
and then go to your init file (can be ~/.emacs, ~/.emacs.d/init.el, ~/init.el) put the code showed before and restart emacs and check if the code works. 
Alternatively you can use M-x `eval-buffer` `RET` (while in your init file) and see if it works


**note: emacs looks for init files using the file names ~/.emacs.d/init.el ~/.emacs ~/.emacs.el directories check [this](https://www.gnu.org/software/emacs/manual/html_node/emacs/Find-Init.html) for more info**
