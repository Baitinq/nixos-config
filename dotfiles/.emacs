(eval-when-compile
  (require 'use-package))

(use-package evil
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package doom-themes)
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-one t)

(set-face-attribute 'default nil
                    :font "Inconsolata LGC Nerd Font 11"
                    :weight 'medium)

(setq-default line-spacing 0.10)

;; Needed for emacsclient or fonts will be smaller than expected
(add-to-list 'default-frame-alist '(font . "Inconsolata LGC Nerd Font 11"))

;; Disable toolbar, menubar and scrollbar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; One line scrolling
(setq scroll-step 1)
(setq scroll-conservatively 10000)

(global-display-line-numbers-mode)

(global-visual-line-mode t)
      
(use-package dashboard
  :init
  (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  (setq dashboard-center-content nil)
  (setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
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
  :config
  (direnv-mode))

(use-package nix-mode
    :mode "\\.nix\\'")

(use-package haskell-mode)

(use-package typescript-mode)

(use-package jq-mode)

(use-package lsp-mode
  :hook ((haskell-mode . lsp-deferred))
  :commands (lsp lsp-deferred))

(use-package lsp-haskell)
