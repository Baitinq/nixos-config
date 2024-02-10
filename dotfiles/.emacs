;; load package manager, add the Melpa package registry
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(use-package evil
  :ensure t 
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t 
  :config
  (evil-collection-init))

(use-package doom-themes
  :ensure t )
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-one t)

(defun my/setup-font-faces ()
(when (display-graphic-p)
  (set-face-attribute 'default nil
                     :font "Inconsolata LGC Nerd Font 11"
                     :weight 'medium)
  )
)

(defun my/on-init ()
	(my/setup-font-faces)
	(dired-sidebar-toggle-sidebar)
(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)

	)

(add-hook 'after-init-hook 'my/on-init)
(add-hook 'server-after-make-frame-hook 'my/on-init)

(setq default-line-spacing 0.10)

(setq make-backup-files nil)
(setq create-lockfiles nil)

;; Disable toolbar, menubar and scrollbar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(use-package doom-modeline
  :ensure t 
  :init (doom-modeline-mode 1))

;; One line scrolling
(setq scroll-step 1)
(setq scroll-conservatively 10000)

(global-display-line-numbers-mode)

(global-visual-line-mode t)
      
(use-package dashboard
  :ensure t 
  :init
  (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  (setq dashboard-center-content nil)
  (setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
			(projects . 5)
			(agenda . 5)
                        (registers . 5)))
  (setq dashboard-set-navigator t)
  :config
  (dashboard-setup-startup-hook))

(setq dashboard-footer-messages '("I showed you my source code, plz respond."))

;;(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

;;TODO, make it work with directories
(setq initial-buffer-choice
  (lambda ()
    (if (buffer-file-name)
      (current-buffer) ;; leave as-is
      (get-buffer-create "*dashboard*"))))

(use-package direnv
  :ensure t 
  :config
  (direnv-mode))

(use-package nix-mode
  :ensure t 
  :mode "\\.nix\\'")

(use-package haskell-mode
  :ensure t )

(use-package typescript-mode
  :ensure t )

(use-package jq-mode
  :ensure t )

(use-package yasnippet
  :ensure t)
(yas-global-mode 1)

(use-package lsp-bridge
  :ensure t 
  :hook ((haskell-mode nix-mode jq-mode c-mode c++-mode c-or-c++-mode rust-mode) . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-clients-clangd-args '("-j=4" "-background-index" "--log=error" "--clang-tidy" "--enable-config"))
  (setq lsp-auto-guess-root t))

(use-package lsp-haskell
  :ensure t )

(use-package company
  :ensure t)

(use-package rustic
  :ensure t)

(use-package dired-sidebar
  :ensure t)

(eval-after-load 'dired
  '(evil-define-key 'normal dired-mode-map [mouse-2] 'dired-mouse-find-file)
)
