# Emacs configuration files
This are my configuration files for vanilla emacs. This configuration
files are made thinking in only using the tools that emacs provides
minimizing the use of plugins for managing the packages so
`use-package` and other plugins are discarded.  Also I want to learn emacs lisp
o I'll try to write the configuration entirely in emacs lisp,
avoiding the use of macros or tools that make the user life more easy.

I like to use the [XDG Base Directory
Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Also emacs since version 27 already has support for XDG so the
configuration files related to emacs are saved in the folder
`~/.config/emacs/`

## The basics.
The absolute minimum to know about emacs, to be able to *anything* is more that you
need to know in othe applications or software. Emacs depends to much on keyboard
shorcuts so the use of the mouse is almost inexistent this ends in you working
much faster.

The majority of shorcuts used in emacs are like compound key presses, emacs use
3 major compose keys almost every shortcut these are:
* M - Alt in modern keyboards, in emacs is called emacs because in older keyboard th 'alt' key was called 'meta' thats why alt is represented with an M
* C - Control
* S - Super is the windows/penguin key in modern keyboards, again on ancient keyboards (unix era) it was called 'super'

This is useful because in the configuration file I explain how to 
do certain thigs with the shorcuts so for you to understand what it 
mean and most of the emacs documentation you find online I'm sure sooner
or later you will encounter with this way of representing shorcuts (also that is the syntax to create new shortcuts) 
also is not very different in comparision with other programs.
So for example to open a file in emacs you need to press the combination 
control+x release and then press f, this can be represented in the way
of C-x f. Or for example to open the command palette you press Meta+x
that will be M-x in the *emacs way*, going down with this if you see
~M-x load-theme~ it means that you press M-x to open the command pallete
and write the command ~load-theme~.


## The lirete configuration file
Emacs lisp can be a little bit dificult if you are new to emacs so
having a literate config can help to understand what is certain blocks
of code doing.  Even if you do know programming in elisp it can be a
little dificult to read your configuration file in pure elisp, an
unless you comment everything (what is good) with the time this file
(.emacs or init.el or config.el) can grow largley so maintainig that
can be very tedious and unecesary complex.

# The init file
emacs have org mode enable by default, so you only have to create an
org file in the directory you want.  After you just put this code in
yout init file to babel load your org file.  ```emacs-lisp
(org-babel-load-file "~/.config/emacs/config/org" ```
`org-babel-load-file` is a function inside org.el that load emacs lisp
source code block from your org file to an elisp file. first exports
the source code using another function `org-babel-tangle` and then
loads that code into a lisp file *usually that file have the same name
of your org file, so if your org file is called config.org the lisp
file its goingto be called config.el*.  `org-babel-load-file`
function receive an argument, that argument is the path to your org
file.

To check its working you just write some code between this line
`#+BEGIN_SRC elisp` and `#+END_SRC` (this will crate a emas-lisp code
block) in your org file and then go to your init file (can be
~/.emacs, ~/.emacs.d/init.el, ~/init.el) put the code showed before
and restart emacs and check if the code works.  Alternatively you can
use M-x `eval-buffer` `RET` (while in your init file) and see if it
works


**note: emacs looks for init files using the file names
~/.emacs.d/init.el ~/.emacs ~/.emacs.el directories check
[this](https://www.gnu.org/software/emacs/manual/html_node/emacs/Find-Init.html)
for more info**
