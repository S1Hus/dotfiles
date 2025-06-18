(setq gc-cons-threshold (* 50 1000 1000))

;; font ans layout stuff
(defvar default-font-size 150)
(defvar default-variable-font-size 150)

(set-face-attribute 'default nil :font "Fira Code Retina" :height default-font-size)
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height default-font-size)
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height default-font-size :weight 'regular)

(setq inhibit-startup-message t) ; Disable annyoing home screen
(scroll-bar-mode -1)        ; Disable side scroll bar
(tool-bar-mode -1)          ; Disable the toolbar Icons above
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Add border buffer around frame
(menu-bar-mode -1)            ; Disable the menu bar from the top of emacs
(setq visible-bell t)       ; Add visual alerts
(column-number-mode)        ; Add column lines
(global-display-line-numbers-mode t) ; make it display everywhere

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0)))
  :defer t) ; disable it for these modes

(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; esc for quitting out of command

;; package setup
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; load themes
(use-package doom-themes  
  :init (load-theme 'doom-dracula t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)  
  :custom ((doom-modeline-height 15)))


;; load packages for basic functions i like to have
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5))


(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done))
  :config (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-b" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config (counsel-mode 1))



;; org mode stuff
(defun org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :hook (org-mode . org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done nil)
  (setq org-log-into-drawer t)

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
  '((sequence "TODO(t)" "DOING(n)" "DONE(d)")))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (org-font-setup)
  :defer t)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●"))
  :defer t)

(defun org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . org-mode-visual-fill))

(require 'org-tempo)

;; LSP and programming stuff
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :defer t)

(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :after prog-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-ivy
  :after lsp)

;; configure company box
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))


;; Load language-specific configurations
(load-file (expand-file-name "language_config.el" user-emacs-directory))

;; terminal stuff
(defun configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt)

(use-package eshell
  :hook (eshell-first-time-mode . configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline)
  :defer t)


;; can comment out later
(defun display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                   (time-subtract after-init-time before-init-time)))
           gcs-done)) ; display time on startup

(add-hook 'emacs-startup-hook #'display-startup-time)

(setq gc-cons-threshold (* 2 1000 1000))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(eshell-git-prompt which-key visual-fill-column rainbow-delimiters org-bullets lsp-ui lsp-ivy ivy-rich doom-themes doom-modeline counsel company-box all-the-icons)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)
