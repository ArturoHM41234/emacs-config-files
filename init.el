;; -*- lexical-binding: t -*-
;; -----------------------------------------------------------------------------
;; Package Management
;; -----------------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(unless package--initialized (package-initialize))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;; -----------------------------------------------------------------------------
;; Appearance (themes)
;; -----------------------------------------------------------------------------
(defun my/change-cursor-color ()
  "Change the color of the cursor to white
	 when the theme is a dark theme"
  (let* ((color-mode (frame-parameter nil 'background-mode))
	 (cursor-color (if (eq color-mode 'dark)
			   "white"
			 nil)))
    (set-face-attribute 'cursor nil :background cursor-color)))

(defun my/load-theme (theme)
  "Custom `load-theme' function.
  This function disable all other themes you may have enabled"
  (interactive
   (list
    (intern (completing-read "Load custom theme: "
			     (mapcar #'symbol-name
				     (custom-available-themes))))))
  (if theme
      (progn
	(load-theme theme t)
	(mapc #'disable-theme (cdr custom-enabled-themes)))
    (message "A theme is needed"))

  (customize-save-variable 'custom-enabled-themes custom-enabled-themes))

;;(setq modus-themes-mixed-fonts t)
;; Transparent background
;;(set-frame-parameter nil 'alpha-background 90)
;;(add-to-list 'default-frame-alist '(alpha-background . 90))

;; -----------------------------------------------------------------------------
;; Fonts and faces
;; -----------------------------------------------------------------------------
(set-face-attribute 'default nil
		    :font "Input Mono Narrow 11")

(set-face-attribute 'font-lock-comment-face nil
		    :slant 'italic
		    :weight 'regular)

(set-face-attribute 'fixed-pitch nil
		    :family "Input Mono Narrow") ; :height 130)

(set-face-attribute 'variable-pitch nil
		    :font "Input Sans Narrow 16" ; "Fira Sans" ; "Input Sans Narrow"
		    :weight 'light)

;; If you want to use a proportional font and
;; relative line numbers you will experience some
;; stuttering in lines, this is solved by using a
;; monospaced font for the line-number face.

;; (set-face-attribute 'line-number nil :inherit 'fixed-pitch :weight 'regular)

;; -----------------------------------------------------------------------------
;; Behavior customization
;; -----------------------------------------------------------------------------
;; Line and column numbers and lines
;; -------------------------------------------------------
(line-number-mode -1)                     ; Prevent line numbers from appearing in the mode line 
(column-number-mode 1)                    ; Display columns in the mode line
(setq display-line-numbers-type 'relative ; 'relative, 'visual, t -> for absolute line numbers
 truncate-lines t                         ; Disable word wrapping
      mode-line-percent-position nil)     ; Remove the legend in the mode line that indicates the percentage of where are in the file

;; -------------------------------------------------------
;; Add new lines with C-n
;; -------------------------------------------------------
(setq next-line-add-newlines t)

;; -------------------------------------------------------
;; The cursor
;; -------------------------------------------------------
(defun my/change-cursor-type ()
  "Change the cursor type, according the major-mode"
  (let ((cursor_type
	 (if (derived-mode-p 'prog-mode)
	     'box
	   'bar)))
    (setq cursor-type cursor_type)))

;; -------------------------------------------------------
;; Delimiters
;; -------------------------------------------------------
(show-paren-mode 1)
(setq show-paren-context-when-offscreen 'overlay)
(electric-pair-mode 1)

;; -------------------------------------------------------
;; Completion
;; -------------------------------------------------------
(setq-default confirm-nonexistent-file-or-buffer nil) ;; nil means don't confirm when visiting a new file or buffer
(fido-vertical-mode 1)

;; -------------------------------------------------------
;; Backup files
;; -------------------------------------------------------
(setq make-backup-files nil                     ; Desactiva la creación de archivos de respaldo
      backup-inhibited t)                       ; No hace respaldo
(global-auto-revert-mode 1)                     ; Actualiza automáticamente los buffers si el archivo cambia en disco
(setq global-auto-revert-non-file-buffers t)    ; Revierte buffers como dired

;; -------------------------------------------------------
;; The custom file
;; -------------------------------------------------------
(save-place-mode 1)

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 't)

;; -------------------------------------------------------
;; Search
;; -------------------------------------------------------
(setq isearch-lazy-count t)

;; -----------------------------------------------------------------------------
;; User defined function
;; -----------------------------------------------------------------------------

;; -------------------------------------------------------
;; Copy whole line
;; -------------------------------------------------------
(defun copy-region-or-lines (n &optional beg end)
  "Copy region or the next N lines into the kill ring.
  When called repeatedly, move to the next line and append it to
  the previous kill."
  (interactive "p")
  ;; defining variables
  (let* ((repeatp (eq last-command 'copy-region-or-lines))
         (kill-command
          (if repeatp
	      ;;These lambda functions execute the copying
              #'(lambda (b e) (kill-append (concat "\n" (buffer-substring b e)) nil)) ; This one executes if your repeatedly press M-w
            #'(lambda (b e) (kill-ring-save b e (use-region-p)))))                    ; This one is the normal one
         beg
         end)
    
    ;; body and asigning values to the variables
    (if repeatp
        (let ((goal-column (current-column)))
          (next-line)))
    (setq beg (or beg
                  (if (use-region-p)
                      (region-beginning)
                    (line-beginning-position))))
    (setq end (or end
                  (if (use-region-p)
                      (region-end)
                    (line-end-position n))))
    (funcall kill-command beg end)
    (pulse-momentary-highlight-region beg end)
    (message "copied --> \"%s\"" (car kill-ring))
    (if repeatp (message "%s" (car kill-ring)))))

(global-set-key (kbd "M-w") 'copy-region-or-lines)

;; -------------------------------------------------------
;; Copy word
;; -------------------------------------------------------
(defun copy-word ()
  "Copy word under the cursor."
  ;; TODO: add that when you repeatedly press M-W append the next word to the copy sort like expand-region
  (interactive)
  (let ((symbol (thing-at-point 'symbol))
	(bounds (bounds-of-thing-at-point 'symbol))
	beg end)
    (setq beg (car bounds)
	  end (cdr bounds))
    (when symbol
      (kill-new symbol)
      (pulse-momentary-highlight-region beg end)
      (message "copied --> \"%s\"" symbol))))

;;(global-set-key (kbd "C-c ww") 'my-get-boundary-and-thing)
(global-set-key (kbd "M-W") 'copy-word)

;; -----------------------------------------------------------------------------
;; Org mode
;; -----------------------------------------------------------------------------
;; Better Defaults
;; -------------------------------------------------------
(setq org-src-preserve-indentation t      ; Preserva indentacion original
      org-edit-src-content-indentation 0  ; No agregar indentacion adicional
      org-src-tab-acts-natively t         ; Usa la tecla tab para indentar codigo
      org-src-fontify-natively t          ; Resalta sintaxis en bloques de codigo
      org-src-tab-indent t                ; Indenta codigo con tab
      org-hide-emphasis-markers t         ; Hide the // ** markers that indicates bold, italics etc
      org-bullets-bullet-list '(" ")      ; No bullets, needs org-bullets package
      org-pretty-entities t               ; Show utf-8 characters
      org-fontify-whole-heading-line t
      org-fontify-done-headline t
      org-fontify-quote-and-verse-blocks t)

;; Change the *, - used in lists for --> •
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

;; -------------------------------------------------------
;; Custom headings
;; -------------------------------------------------------
(with-eval-after-load "org"
  (dolist (level '((1 . 1.2) (2 . 1.1) (3 . 1.0) (4 . 0.9) (5 . 0.8)))
    (set-face-attribute (intern (format "org-level-%d" (car level))) nil
			:inherit (intern (format "outline-%d" (car level)))
			:height (cdr level)))

  (set-face-attribute 'org-document-title nil :height 1.3)
  (set-face-attribute 'org-todo nil :height 1.2))

(setq org-num-skip-unnumbered t)

;; I'm using org bullets check that configuration in the packages section

;; -------------------------------------------------------
;; Mixed fonts
;; -------------------------------------------------------
;; This is to have proportional fonts and monospaced fonts
;; in org mode, note that the modus themes have options to
;; make this more easy. This is for all themes.

;; (with-eval-after-load "org"
;;   (dolist (face '(org-block org-table org-list-dt org-tag
;; 			    org-todo org-checkbox
;; 			    org-hide))
;;     (set-face-attribute face nil :inherit 'fixed-pitch))
;;   (dolist (face1 '(org-document-info-keyword org-meta-line))
;;     (set-face-attribute face1 nil :inherit '(shadow fixed-pitch))))

;; I use custom-set-faces because doing it with the code above will
;; not maitain the fixed pitch after loading a theme

(custom-set-faces
 '(org-block ((t (:inherit fixed-pitch))))
 '(org-table ((t (:inherit fixed-pitch))))
 '(org-list-dt ((t (:inherit fixed-pitch))))
 '(org-tag ((t (:inherit fixed-pitch))))
 '(org-todo ((t (:inherit fixed-pitch))))
 '(org-checkbox ((t (:inherit fixed-pitch))))
 '(org-hide ((t (:inherit fixed-pitch))))
 '(org-block-begin-line ((t (:extend t :overline "foreground" :slant italic))))
 '(org-block-end-line ((t (:extend t :overline nil :underline (:color foreground-color :style line :position t))))))

;; -----------------------------------------------------------------------------
;; Tree-sitter
;; -----------------------------------------------------------------------------
(use-package treesit
  :init
  (setq treesit-font-lock-level 4))

(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'treesit-language-source-alist
	     '(typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
	     '(tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")))

(setq major-mode-remap-alist
      '((c-mode . c-ts-mode)
	(c++-mode . c++-ts-mode)
	(yaml-mode . yaml-ts-mode)
	(conf-toml-mode . toml-ts-mode)))

;; -----------------------------------------------------------------------------
;; Programming languages configuration
;; -----------------------------------------------------------------------------
;; C-like languages
;; -------------------------------------------------------
(dolist (mode-iter '(c-mode c++-mode c-ts-mode c++-ts-mode glsl-mode java-mode javascript-mode rust-mode))
  (font-lock-add-keywords
    mode-iter
    '(("\\([~^&\|!<>=,.\\+*/%e-]\\)" 0 'font-lock-operator-face keep)))
  (font-lock-add-keywords
    mode-iter
    '(("\\([\]\[}{)(:;]\\)" 0 'font-lock-delimit-face keep)))
  ;; functions
  (font-lock-add-keywords
    mode-iter
    '(("\\([_a-zA-Z][_a-zA-Z0-9]*\\)\s*(" 1 'font-lock-function-name-face keep))))

;; -------------------------------------------------------
;; Web languages (js, ts, etc)
;; -------------------------------------------------------
(setq js-indent-level 2) ;; set indentation on js jsx, ts, tsx files to 2

;; -----------------------------------------------------------------------------
;; Keybindings
;; -----------------------------------------------------------------------------
(repeat-mode 1)
(global-set-key (kbd "C-x w t") 'enlarge-window)              ; t for taller
(global-set-key (kbd "C-x w s") 'shrink-window)               ; s for shrink
(global-set-key (kbd "C-x w n") 'shrink-window-horizontally)  ; n for narrow
(global-set-key (kbd "C-x w e") 'enlarge-window-horizontally) ; e for enlarge

(defun my/create-new-window (direction)
  "Create a new window based on DIRECTION if DIRECTION is 'vertical, do
    split-window-horizontally (new window on the on the right), otherwise do
    split-window-vertically (new window bellow) and move the cursor to that window."
  (interactive "sDirection (h for horizontal, v for vertical): ")
  (let ((split-func
	 (if (string= direction "v")
	     #'split-window-horizontally
	   (if (string= direction "h")
	       #'split-window-vertically
	     nil))))
    (when split-func
      (funcall split-func)
      (other-window 1))))

(global-set-key (kbd "C-c wr") '("split-window-right" . (lambda () (interactive) (my/create-new-window "v"))))
(global-set-key (kbd "C-c wd") '("split-window-bellow" . (lambda () (interactive) (my/create-new-window "h"))))

(global-set-key (kbd "C-c wq") #'delete-other-windows)            ; Deleted all the windows except the current window
(global-set-key (kbd "C-c wc") '("close window" . delete-window)) ; Close current window

(defun prev-window ()
  "Jump to the previous window (to the left)"
  (interactive)
  (other-window -1))

(global-set-key (kbd "M-o") #'other-window) ; Move cursor to window on the rigth
(global-set-key (kbd "M-O") #'prev-window)  ; Move cursor to window of the left

(global-set-key (kbd "C-c w b") #'switch-to-buffer-other-window) ; Switch buffers in another window
(global-set-key (kbd "C-c w f") #'find-file-other-window)        ; Find file in other window file-other-window
(defvar my/resize-window-repeat-map
  (let ((map (make-sparse-keymap)))
    (define-key map "t" 'enlarge-window)
    (define-key map "s" 'shrink-window)1
    (define-key map "n" 'shrink-window-horizontally)
    (define-key map "e" 'enlarge-window-horizontally)
    map)
  "Keymap to repeat resize window key sequences.")

(dolist (cmd '(enlarge-window shrink-window shrink-window-horizontally enlarge-window-horizontally))
  (put cmd 'repeat-map 'my/resize-window-repeat-map))

  (global-set-key (kbd "C-. p") #'previous-buffer)
  (global-set-key (kbd "C-. n") #'next-buffer)

  (global-set-key (kbd "C-c d") #'duplicate-dwim) ; Duplicate current line
  (global-set-key [remap dabbrev-expand] 'hippie-expand) ; Change dabbrev-expand for hippie-expand
  (global-set-key (kbd "C-x C-b") 'ibuffer) ; Change `list-buffer' for `ibuffer'

;; -----------------------------------------------------------------------------
;; Packages (plugins, minor modes, etc)
;; -----------------------------------------------------------------------------
(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom))

(use-package company
  :ensure t)


(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-/") #'company-complete))
(with-eval-after-load 'company-complete
  (define-key company-active-map
	      (kbd "TAB")
	      #'company-complete-common-or-cycle)
  (define-key company-active-map
	      (kbd "<backtab>")
	      (lambda ()
		(interactive)
		(company-complete-common-or-cycle -1))))
(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-.") #'company-show-location)
  (define-key company-active-map (kbd "RET") nil))

;; (use-package dashboard
;;   :ensure t
;;   :init
;;   (progn
;;     ;; (setq dashboard-items '((recents . 5)
;;     ;; 			    (projects . 5)
;;     ;; 			    (agenda . 5)))
;;     (setq dashboard-center-content t)
;;     (setq dashboard-set-file-icons t)
;;     (setq dashboard-set-heading-icons t)
;;     (setq dashboard-startup-banner 'official)
;;     (setq dashboard-projects-backend 'project-el)
;;     ;; (setq dashboard-projects-switch-function 'project-find-file)
;;     )
;;   :config
;;   (dashboard-setup-startup-hook))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-force-refresh t)
  :custom
  (dashboard-center-content t)
  (dashboard-banner-logo-title nil)
  (dashboard-vertically-center-content t)
  (dashboard-hide-cursor t)
  (dashboard-items nil))

(use-package nerd-icons :ensure t)

;; Nerd Icons Dired
(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package delight
  :ensure t
  :delight
  (which-key-mode nil)
  (company-mode nil)
  (org-num-mode nil org-num)
  (org-indent-mode nil "org-indent")
  (eldoc-mode " eldoc" "eldoc"))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package emmet-mode  :ensure t)

(use-package rjsx-mode  :ensure t)

(use-package org-appear :ensure t)

(use-package hl-todo
       :ensure t
       :custom-face
       (hl-todo ((t (:inherit hl-todo :italic t))))
       :hook ((prog-mode . hl-todo-mode)
              (yaml-mode . hl-todo-mode)))

(display-time-mode)

;; -----------------------------------------------------------------------------
;; Spell checking
;; -----------------------------------------------------------------------------
(setq-default ispell-program-name "aspell")

;; -----------------------------------------------------------------------------
;; Hooks
;; -----------------------------------------------------------------------------
;; Custom hooks
;; -------------------------------------------------------
(defvar after-enable-theme-hook nil
  "Hook to run after enabling a theme.")

(defun run-after-enable-theme-hook (&rest _args)
  "Run `after-enable-theme-hook'."
  (run-hooks 'after-enable-theme-hook)
  (my/change-cursor-color))

(advice-add 'enable-theme :after #'run-after-enable-theme-hook)
(add-hook 'after-init-hook #'run-after-enable-theme-hook)

;; -------------------------------------------------------
;; After init hook
;; -------------------------------------------------------
(add-hook 'after-init-hook 'global-company-mode)

;; -------------------------------------------------------
;; Org mode hooks
;; -------------------------------------------------------
(defun org-startup-hooks ()
  (org-indent-mode)
  (variable-pitch-mode)
  (visual-line-mode))

(add-hook 'org-mode-hook #'org-startup-hooks)
(add-hook 'org-mode-hook #'my/change-cursor-type)

;; -------------------------------------------------------
;; prog mode hooks
;; -------------------------------------------------------
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
