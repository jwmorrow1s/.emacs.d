(delete-selection-mode 1)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")))
(setq-default indent-tabs-mode nil)
;; <private fns>
(setq custom-safe-themes t)
(require 'treesit)
(setq treesit-font-lock-level 4)

(setq major-mode-remap-alist
			'((js-mode . js-ts-mode)))

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

(defun jeff--regex-find-capture (regex string capture-index)
    (progn
    (let ((str string))
        (string-match regex str)
        (match-string capture-index str))))

(defun jeff--init-c-mode ()
    (let ((the-map (make-sparse-keymap)))
      (eglot-ensure)
      (use-local-map the-map)))

(defun jeff--init-zig-mode ()
    (let ((the-map (make-sparse-keymap)))
      (eglot-ensure)
      (use-local-map the-map)
			(keymap-local-set "C-c b" #'zig-compile)
			(keymap-local-set "C-c f" #'zig-format-buffer)
			(keymap-local-set "C-c r" #'zig-run)
			(keymap-local-set "C-c t" #'zig-test-buffer)
			(keymap-local-unset "K")
			(keymap-local-set "K" #'eldoc)))

(defun jeff--init-js-mode ()
    (let ((the-map (make-sparse-keymap)))
      (eglot-ensure)
			(setq js-indent-level 2)
      (use-local-map the-map)
			(keymap-local-set "C-c f" #'eglot-format-buffer)
			(keymap-local-set "C-c e" #'eglot-code-action-extract)
			(keymap-local-set "C-c i" #'eglot-code-action-inline)
			(keymap-local-set "C-c a" #'eglot-code-actions)
			(keymap-local-set "C-c r" #'eglot-rename)
			(keymap-local-set "C-c o i" #'eglot-code-action-organize-imports)
			(keymap-local-unset "K")
			(keymap-local-set "K" #'eldoc)))

(defun jeff--init-nix-mode ()
    (let ((the-map (make-sparse-keymap)))
      (eglot-ensure)
      (use-local-map the-map)
			(keymap-local-unset "K")
			(keymap-local-set "K" #'eldoc)))

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

(setq
		inhibit-startup-screen t
		inhibit-startup-message t)

(with-eval-after-load 'dired (progn
  (define-key dired-mode-map (kbd "C-c d") 'dired-create-directory)
  (define-key dired-mode-map (kbd "C-c %") 'dired-create-empty-file)))

(with-eval-after-load 'vterm
	(keymap-global-set "C-c s" #'vterm))

(with-eval-after-load 'flycheck
	(global-flycheck-mode))

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
    ; (define-key evil-insert-state-map (kbd "C-v") nil)

    ; insert mode -- fix tabs
    (define-key evil-insert-state-map (kbd "TAB") nil)
    (define-key evil-insert-state-map (kbd "TAB")
		(lambda ()
		  (interactive)
		  (insert-tab)))
    ; normal mode
    (define-key evil-motion-state-map (kbd "C-z") nil t)
    (define-key evil-normal-state-map (kbd "SPC f s") 'counsel-rg)
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

(with-eval-after-load 'eglot
	(add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
	(add-to-list 'eglot-server-programs `(js-mode . ("typescript-language-server"
																										"--stdio"
																									 ))))

; hooks
(add-hook 'c-mode-hook #'jeff--init-c-mode)
(add-hook 'zig-mode-hook #'jeff--init-zig-mode)
(add-hook 'ts-mode-hook #'jeff--init-js-mode)
(add-hook 'js-mode-hook #'jeff--init-js-mode)
(add-hook 'nix-mode-hook #'jeff--init-nix-mode)
(add-hook 'after-init-hook 'global-company-mode)
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

;; flycheck
(use-package flycheck)

;; Counsel
(use-package counsel
  :config (counsel-mode))

;; Company
(use-package company
	:config
	(setq company-idle-delay 0.1))

;; brings in xclip to allow copying between xwindows. necessary for yanking to clipboard and pasting across windows
(use-package xclip
  :config (xclip-mode))

;; rainbow brackets
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(setq make-backup-files nil)

(setq-default tab-width 2)

(load-theme 'modus-vivendi t)
