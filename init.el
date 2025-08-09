;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              ;Package Setup;                                              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages"))
(unless package--initialized (package-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
      ;Download Evil;                                                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
(unless (package-installed-p 'evil) 
  (package-install 'evil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
      ;Download Company;                                                          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
(unless (package-installed-p 'company)
  (package-refresh-contents)
  (package-install 'company))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
      ;Download Geiser;             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
(use-package geiser-guile :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                        ;Custom Theme Load Path and Theme;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'custom-theme-load-path "~/.emacs.d/packages/")
(load-theme 'masked t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              ;Evil;                                              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
      ;Enable Evil;                                                               
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
(require 'evil)
(evil-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
      ;Set Global Leader;                                                         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
(setq custom-leader (kbd "SPC"))
(define-prefix-command 'custom-leader-map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
      ;Evil Keybinds;                                                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                             
;;;;;;;;;;;;;;;                                                                   
;Global Unbind;                                                                   
;;;;;;;;;;;;;;;                                                                   
(keymap-global-unset "C-u")
;;;;;;;;;;;;;;;                                                                   
;Global Rebind;                                                                   
;;;;;;;;;;;;;;;                                                                   
(evil-define-key 'normal 'global (kbd "C-u") 'evil-scroll-up)

(defun custom-re-eval-config ()
  (interactive)
  (load-file user-init-file))

;;;;;;;;;;;;;;;;;
;Leader Bindings;
;;;;;;;;;;;;;;;;;
(defun custom-pretty-print ()
  (interactive) (when (derived-mode-p 'emacs-lisp-mode) (pp-buffer)))
(defun custom-open-emacs-config ()
  (interactive)
  (find-file user-init-file))
(defun custom-language-specific-behavior-start ()
  (interactive)
  (cond ((derived-mode-p 'scheme-mode) (progn
					 (setq
					  geiser-active-implementations
					  '(guile))
					 (geiser 'guile)))
	(t (princ "language specific behavior not defined"))))

(define-key evil-normal-state-map custom-leader custom-leader-map)
(define-key custom-leader-map (kbd "f f") 'find-file)
(define-key custom-leader-map (kbd "f c") 'custom-open-emacs-config)
(define-key custom-leader-map (kbd "f s") 'rgrep)
(define-key custom-leader-map (kbd "h f") 'describe-function)
(define-key custom-leader-map (kbd "h a") 'apropos)
(define-key custom-leader-map (kbd "h v") 'describe-variable)
(define-key custom-leader-map (kbd "h k") 'describe-key)
(define-key custom-leader-map (kbd ". .") 'custom-re-eval-config)
(define-key custom-leader-map (kbd ". e") 'eval-expression)
(define-key custom-leader-map (kbd "l l")
	    'custom-language-specific-behavior-start)
(define-key custom-leader-map (kbd "p r") 'package-refresh-contents)
(define-key custom-leader-map (kbd "p p") 'custom-pretty-print)

;;;;;;;;;;;;;;;;;;;;;                                                             
;ESC kills minibuf;;;                                                             
;;;;;;;;;;;;;;;;;;;;;                                                             
(defun custom-minibuffer-keyboard-quit ()
  (interactive)
  (when (company--active-p)
    (company-abort)
    (keyboard-quit)))

(with-eval-after-load 'evil
  (define-key evil-insert-state-map [escape]
	      'custom-minibuffer-keyboard-quit)
					; to quit completions from company
  (define-key evil-normal-state-map [escape] 'keyboard-quit)
  (define-key evil-visual-state-map [escape] 'keyboard-quit)
  (define-key minibuffer-local-map [escape] 'abort-recursive-edit)
  (define-key evil-insert-state-map [escape] 'evil-normal-state))

;;;;;;;;;;;;;;;;;;;;;                                                             
;ESC kills select ;;;                                                             
;;;;;;;;;;;;;;;;;;;;;                                                             
(with-eval-after-load 'evil
  (define-key evil-visual-state-map [escape] 'evil-exit-visual-state))

;;;;;;;;;;;;;;;;;;;;;;                                                            
;:E opens current dir;                                                             
;;;;;;;;;;;;;;;;;;;;;;                                                            
(defun custom-dired-this-dir ()
  (interactive)
  (dired default-directory))

(evil-ex-define-cmd "E" 'custom-dired-this-dir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Line Numbers;                                      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq column-number-mode t)
(defun custom-line-highlight ()
  (progn 
    (display-line-numbers-mode)
    (hl-line-mode)
    (set-face-attribute 'hl-line nil :background "#becbf7" :foreground
			"#000000")))

(add-hook 'prog-mode-hook 'custom-line-highlight)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Status Line;                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  %b: Buffer name
;;;  %f: Visited file name
;;;  %m: Major mode
;;;  %l: Current line number
;;;  %c: Current column number (requires column-number-mode enabled)
;;;  %p: Percentage of buffer above top of window (or "Top", "Bot", "All")
;;;  %P: Percentage of buffer above bottom of window (or "Bottom", "All")
;;;  %*: Indicates modified (*) or read-only (%) status
;;;  %s: Process status
;;;  %z: Mnemonics of coding systems 
(setq-default mode-line-format
  (list ":: %b :: " "%* :: " "%m :: " "#L=%l #C=%c :: " "%z :: " 
	'(:eval
	  (propertize
	   (upcase (symbol-name evil-state))
           'face
	   '(:weight bold :background "white" :foreground "black")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;No Tool Bar;                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if window-system
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (toggle-scroll-bar -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Kill Splat Noise;                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ring-bell-function 'ignore)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Disable File Poopsies;                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Transparent Window;                                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-frame-parameter (selected-frame) 'alpha '(95 . 95))
(add-to-list 'default-frame-alist '(alpha . (95 . 95)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Completion;                                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	  enable globally             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'after-init-hook 'global-company-mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	  behaviors                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq company-minimum-prefix-length 1       ; start completing after 1 char
      company-idle-delay 0.0                ; no delay before suggestions pop up
      company-selection-wrap-around t       ; cycle suggestions
      company-tooltip-align-annotations t)
					; align annotations to the right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	 Evil Mode Compatability      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun custom-tab-evil-company-behavior ()
  (interactive)
  (if (company--active-p)
      (company-select-next)
      (indent-for-tab-command)))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") 'company-select-next)
  (define-key company-active-map (kbd "<tab>") 'company-select-next)
  (define-key company-active-map (kbd "<backtab>")
	      'company-select-next)

  (define-key company-active-map [escape] #'company-abort)
  (define-key company-active-map (kbd "ESC") #'company-abort)

  (define-key company-active-map (kbd "RET")
	      'company-complete-selection)
  (define-key company-active-map (kbd "<return>")
	      'company-complete-selection)

  (evil-define-key 'insert-company-active-map
    (kbd "C-n")
    'company-select-next
    (kbd "C-p") 'company-select-previous)

  (define-key evil-insert-state-map (kbd "TAB")
	      'custom-tab-evil-company-behavior))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ;Language Specific;                                      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keybinds
(with-eval-after-load 'geiser
  (define-key custom-leader-map (kbd "e b") 'geiser-eval-buffer)
  (define-key custom-leader-map (kbd "e e") 'geiser-eval-definition)
  (define-key custom-leader-map (kbd "g d") 'geiser-edit-symbol-at-point)
  (define-key custom-leader-map (kbd "c l") 'geiser-insert-lambda)
  (define-key custom-leader-map (kbd "k") 'geiser-doc-symbol-at-point)
  (define-key custom-leader-map (kbd "d d") 'geiser-autodoc-mode))
  
; todo ;
; c?
; nix?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                              ;STOP;                                              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(company evil geiser-scheme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
