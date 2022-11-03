;;;
; NOTES
; if using terminal emacs in tmux, you probably will need to add
; `set -sg escape-time 0` into "$HOME/.tmux.conf"
; then in tmux C-b : source-file ~/.tmux.conf
; supposedly this can cause problems with certain fns inside of tmux (especially when ssh'ing, but I haven't
;;;;; noticed any issues personally

;;; PACKAGE LIST
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")))

(scroll-bar-mode -1)  ; disable the scroll bar
(tool-bar-mode -1)    ; disable the tool bar
(tooltip-mode -1)     ; disable tooltips
(menu-bar-mode -1)    ; disable the menu bar
(global-linum-mode 1) ; enable line numbers globally

; figure out how to get git branch
(setq-default mode-line-format '("%f" "  " (car (vc-git-branches)) "  " (vc-git-state buffer-file-truename)))

(add-hook 'dired-mode-hook (lambda () (linum-mode 0)))  ; disable line numbers in dired

(setq
    x-select-enable-clipboard t
    x-select-enable-primary t
    select-enable-clipboard t
    select-enable-primary t)

;;; keymaps
;;; fn to yank to clipboard as well
;;; relies on xclip being installed (at least on linux) see below use-package xclip
(defun custom-yank (beg end)
  "fn to yank to clipboard as well"
  (interactive "r") ; r means -- mark and point -- smallest first
    (progn
	(evil-yank beg end)
	(kill-ring-save beg end)))

(global-set-key(kbd "C-M-j") 'counsel-switch-buffer)

(with-eval-after-load 'dired (progn
  (define-key dired-mode-map (kbd "M-d") 'dired-create-directory)
  (define-key dired-mode-map (kbd "C-M-]") 'dired-create-empty-file)))

(with-eval-after-load 'evil (progn
    ; normal mode
    (define-key evil-normal-state-map (kbd "SPC f s") 'counsel-rg)
    (define-key evil-normal-state-map (kbd "C-M-o") 'previous-buffer)
    ; visual mode
    (define-key evil-visual-state-map (kbd "y") 'custom-yank)))

(with-eval-after-load 'sly (progn
    (define-key sly-mode-map (kbd "C-q C-q") 'sly-quit-lisp)
    (define-key sly-mode-map (kbd "C-M-h") 'sly-describe-symbol)))

(with-eval-after-load 'ivy (progn
    (setq ivy-use-virtual-buffers t)
    (setq ivy-count-format "(%d/%d) ")))

(with-eval-after-load 'counsel (progn
    (define-key evil-normal-state-map (kbd "M-x") 'counsel-M-x)
    (define-key evil-normal-state-map (kbd "C-M-b") 'counsel-switch-buffer)
    (define-key evil-normal-state-map (kbd "SPC f f") 'counsel-file-jump)))

;;; BOOTSTRAP USE-PACKAGE
(package-initialize)
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;;; UNDO
;; Vim style undo not needed for emacs 28
;(use-package undo-fu)

;;; Vim Bindings
(use-package evil
  :demand t
  :bind (("<escape>" . keyboard-escape-quit)) ; allows escaping from minibuffer prompts
  :init
  ;; allows for using cgn
  ;; (setq evil-search-module 'evil-search)
  (setq evil-want-keybinding nil)
  ;; no vim insert bindings
  ;; (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

;;; Vim Bindings Everywhere else
(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))

;; command-log-mode to see keys being used
(use-package command-log-mode
  :config (and nil; set to t to see keys logged in buffer on right of screen
	(progn
	    (global-command-log-mode 1)
	    (clm/open-command-log-buffer))))

;; ivy -- file finding / directory stepping
(use-package ivy
  :config (ivy-mode))

;; sly -- common emacs repl - ide features
(use-package sly
  :config (sly-mode))
;; counsel

(use-package counsel
  :config (counsel-mode))

;; brings in xclip to allow copying between xwindows. Necessary for yanking to clipboard and pasting across windows
(use-package xclip
  :config (xclip-mode))

;; theme
(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox t))

;; rainbow brackets
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; don't touch this junk
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("b1a691bb67bd8bd85b76998caf2386c9a7b2ac98a116534071364ed6489b695d" default))
 '(package-selected-packages '(gruvbox use-package undo-fu evil-collection)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
