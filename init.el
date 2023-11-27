;NOTES
; if using terminal emacs in tmux, you probably will need to add
; `set -sg escape-time 0` into "$HOME/.tmux.conf"
; then in tmux C-b : source-file ~/.tmux.conf
; supposedly this can cause problems with certain fns inside of tmux (especially when ssh'ing, but I haven't
;;;;; noticed any issues personally

;;; PACKAGE LIST
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")))

;; <private fns>

(defun jeff--q ()
  (interactive)
  (if (eq 1 (length (tab-bar-tabs)))
      (kill-emacs)
    (tab-bar-close-tab)))

(defun jeff--wq ()
  (interactive)
  (progn
    (save-buffer)
    (jeff--q)))

(defun jeff--init-c-mode ()
    (let ((the-map (make-sparse-keymap)))
      (eglot-ensure)
      (use-local-map the-map)))

;; </private fns>

;; <Missing Ex Commands>
(defun E ()
  (interactive)
  (let ((cwd (file-name-directory default-directory)))
    (dired cwd)))

(defun scratch ()
  (interactive)
  (switch-to-buffer (get-buffer "*scratch*")))

(defun messages ()
  (interactive)
  (switch-to-buffer (get-buffer "*Messages*")))
;; </Missing Ex Commands>

;; <removing bars>
(scroll-bar-mode -1)                    ; disable the scroll bar
(tool-bar-mode -1)                      ; disable the tool bar
(tooltip-mode -1)                       ; disable tooltips
(menu-bar-mode -1)                      ; disable the menu bar
;; </removing bars>

;; <line numbers>
(custom-set-variables                   ;
 '(global-display-line-numbers-mode t)) ; enables line numbers
;; </line numbers>

;; <mode line>
(setq-default mode-line-format
    (list "%f"
	;; current vim mode
	(list '(:eval (concat " :: " (prin1-to-string evil-state) " ::")))
	;; [line_no:col]
	(list '(:eval (concat " [" (prin1-to-string (line-number-at-pos)) ":"  (prin1-to-string (current-column)) "]")))
	;; git branch
	(list '(:eval (let ((current-branch (car (vc-git-branches))))
			(when current-branch (concat " | " current-branch)))))
	;; file state
	(list '(:eval (let ((file-status (prin1-to-string (vc-state buffer-file-truename))))
			(when file-status (concat " | " file-status)))))))

(run-with-timer 0 0.2 #'(lambda () (force-mode-line-update t)))
;; </mode line>

;; <enable clipboard copyhing>
;; x only? maybe only linux
(setq
    x-select-enable-clipboard t
    x-select-enable-primary t
    select-enable-clipboard t
    select-enable-primary t
		inhibit-startup-screen t
		inhibit-startup-message t)
;; </enable clipboard copyhing>

;;; keymaps
;;; fn to yank to clipboard as well
;;; relies on xclip being installed (at least on linux) see below use-package xclip
(defun custom-yank (beg end)
  "fn to yank to clipboard as well"
  (interactive "r") ; r means -- mark and point -- smallest first
    (progn
	(evil-yank beg end)
	(kill-ring-save beg end)))

(with-eval-after-load 'dired (progn
  (define-key dired-mode-map (kbd "M-d") 'dired-create-directory)
  (define-key dired-mode-map (kbd "M-%") 'dired-create-empty-file)))

(with-eval-after-load 'vterm
	(keymap-global-set "C-c s" #'vterm))


(with-eval-after-load 'evil
    (with-eval-after-load 'company
	(define-key evil-insert-state-map (kbd "C-n") nil)
	(define-key evil-insert-state-map (kbd "C-p") nil)
	(evil-define-key nil company-active-map (kbd "C-n") #'company-select-next)
	(evil-define-key nil company-active-map (kbd "C-p") #'company-select-previous)))

(setq evil-undo-system 'undo-redo)

(with-eval-after-load 'evil
    (evil-ex-define-cmd "q" 'jeff--q)
    (evil-ex-define-cmd "wq" 'jeff--wq)
    ; insert mode -- fix spc
    (define-key evil-insert-state-map (kbd "SPC") nil)

    ; insert mode -- fix tabs
    (define-key evil-insert-state-map (kbd "TAB") nil)
    (define-key evil-insert-state-map (kbd "TAB")
		(lambda ()
		  (interactive)
		  (insert-tab)))
    ; normal mode
    (define-key evil-motion-state-map (kbd "C-z") nil t)
    (define-key evil-normal-state-map (kbd "SPC f s") 'counsel-rg)
    ; visual mode
    (define-key evil-visual-state-map (kbd "y") 'custom-yank)
    ; call elisp buffer
    (define-key evil-normal-state-map (kbd "SPC e") 'eval-expression)
    ; rebind shift-k to give symbol info under cursor in minibuffer
    (define-key evil-motion-state-map (kbd "K") nil)
    (define-key evil-motion-state-map (kbd "K")
	(lambda ()
	    (interactive)
	    (describe-symbol (symbol-at-point))))
    ; evil-window-top-left -- It is bound to C-w C-t and C-w t
    ; unbind both of these
    ; C-w T
    (define-key evil-motion-state-map (kbd "C-w t") nil)
    (define-key evil-motion-state-map (kbd "C-w C-t") nil)
    (define-key evil-motion-state-map (kbd "C-w t")
	(lambda ()
	    (interactive)
	    (tab-switch ""))))

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

; hooks
(add-hook 'c-mode-hook #'jeff--init-c-mode)
; /hooks

;;; BOOTSTRAP USE-PACKAGE
(package-initialize)
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;;; Vim Bindings
(use-package evil
  :demand t
  :bind (("<escape>" . keyboard-escape-quit)) ; allows escaping from minibuffer prompts
  :init
  ;; allows for using cgn
  ;; (setq evil-search-module 'evil-search)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll 1)
  (setq evil-want-C-d-scroll 1)
  ;; no vim insert bindings
  ;; (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

;;; nix mode
(use-package nix-mode
  :mode "\\.nix\\'")

;;; vshell
(use-package vterm :ensure t)

;;; org/roam
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/RoamNotes")
  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
	 ("C-c n s" . org-store-link)
   ("C-c n o" . org-open-at-point))
  :config
  (org-roam-setup))

;;; Vim bindings everywhere else
(use-package evil-collection
  :after evil
  :config
  (setq evil-want-integration t)
  (evil-collection-init))

;; ivy -- file finding / directory stepping
(use-package ivy
  :config (ivy-mode))

;; Counsel
(use-package counsel
  :config (counsel-mode))

;; brings in xclip to allow copying between xwindows. necessary for yanking to clipboard and pasting across windows
(use-package xclip
  :config (xclip-mode))

;; rainbow brackets
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(setq make-backup-files nil)

(load-theme 'modus-vivendi-deuteranopia)
(setq-default tab-width 2)
