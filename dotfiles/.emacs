;; bootstrap straight start
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package straight
  :custom
  (straight-use-package-by-default t))
;; bootstrap straight end

(use-package which-key
  :ensure t
  :init
  (setq which-key-idle-delay 0.4)
  (which-key-setup-minibuffer)
  (which-key-mode))

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

(use-package general
  :ensure t
  :config
  (general-evil-setup)
  ;; set up 'SPC' as the global leader key
  (general-create-definer my/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  ;; set up ',' as the local leader key
  (general-create-definer my/local-leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "," ;; set local leader
    :global-prefix "M-,") ;; access local leader in insert mode
  (my/leader-keys
    "SPC" '(execute-extended-command :wk "execute command");; an alternative to 'M-x'
    "x" (general-simulate-key "C-x" :state 'emacs :which-key "execute keybind");; an alternative to 'C-x'
  ))

(use-package doom-themes
  :ensure t )
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-one t)

(defun my/setup-font-faces ()
(when (display-graphic-p)
  (cond
    ((find-font (font-spec :name "Inconsolata LGC Nerd Font 11"))
      (set-face-attribute 'default nil
                     :font "Inconsolata LGC Nerd Font 11"
                     :weight 'medium)))
  )
)

(defun my/on-init ()
	(my/setup-font-faces)
)

(add-hook 'after-init-hook 'my/on-init)
(add-hook 'server-after-make-frame-hook 'my/on-init)

(setq ring-bell-function 'ignore)

(setq default-line-spacing 0.10)

(setq make-backup-files nil)
(setq auto-save-mode -1)
(auto-save-visited-mode 1)
(setq create-lockfiles nil)
(setq warning-minimum-level :error)
(setq inhibit-startup-screen t)

;; Refresh buffers if underlying file changes
(global-auto-revert-mode 1)

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
(setq display-line-numbers-type 'relative) 
(global-visual-line-mode t)
      
(use-package dashboard
  :ensure t 
  :config
  (setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
  (setq dashboard-footer-messages '("I showed you my source code, plz respond."))
  (setq dashboard-center-content nil)
  (setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
			(projects . 5)))
  (setq dashboard-set-navigator t)
  (if (< (length command-line-args) 2)
    (setq initial-buffer-choice (lambda ()
	(get-buffer-create "*dashboard*")
	(dashboard-refresh-buffer)))))

(use-package direnv
  :ensure t 
  :config
  (direnv-mode))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package consult
  :ensure t
  :config
  (setq consult-async-min-input 2)
  :bind
  (:map evil-normal-state-map
  ("C-S-f" . consult-line)
  ("C-p" . consult-find)
  ("C-S-p" . consult-ripgrep)))

(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/src/"))
  :config
  (projectile-mode +1))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(basic partial-completion orderless)))

(use-package corfu
  :ensure t
  :config
  (setq corfu-auto t)
  :init
  (global-corfu-mode))

(use-package kind-icon
  :ensure t
  :after corfu
  ;:custom
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package eglot
  :ensure t
  :config
  (add-to-list 'eglot-ignored-server-capabilites :hoverProvider)
  (setq read-process-output-max (* 1024 1024))
  (setq gc-cons-threshold 100000000))

(use-package eldoc-box
  :ensure t
  :init
  (add-hook 'eldoc-mode-hook 'eldoc-box-hover-at-point-mode))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("dist" "*.el"))
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'copilot-mode)
  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion))

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save t)
  (setq rustic-lsp-client 'eglot)
  (delete 'rust treesit-auto-langs))

(use-package go-mode
  :ensure t
  :init
  (add-hook 'go-mode-hook 'eglot-ensure)
  (delete 'go treesit-auto-langs))

(use-package gotest
  :ensure t
  :init
  (setq go-test-args "-tags dynamic"))

(use-package treemacs
  :ensure t
  :config
  (treemacs-project-follow-mode t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  :init
  (my/leader-keys
    "et" '(treemacs :wk "toggle sidebar"))
  :bind
  (:map evil-normal-state-map ("C-b" . treemacs)))

(use-package minimap
  :ensure t
  :config
  (setq minimap-window-location 'right)
  (setq minimap-dedicated-window t)
  (setq minimap-enlarge-certain-faces nil)
  (setq minimap-width-fraction 0.0)
  (setq minimap-minimum-width 12)
  :init
  (my/leader-keys
    "em" '(minimap-mode :wk "toggle minimap"))
  :bind
  (:map evil-normal-state-map ("C-n" . minimap-mode)))

(use-package centaur-tabs
  :ensure t
  :bind
  (:map evil-normal-state-map
  ("C-S-t" . centaur-tabs-mode)))

(use-package eat
    :ensure t
    :init
    (setq eat-term-name "xterm-256color"))

(use-package shell-pop
  :ensure t
  :init
  (setq shell-pop-shell-type '("terminal" "*terminal*" (lambda nil (eat shell-pop-term-shell))))
  (setq shell-pop-term-shell "zsh")
  (my/leader-keys
    "t" '(shell-pop :wk "toggle terminal")))

(eval-after-load 'dired
  '(evil-define-key 'normal dired-mode-map [mouse-2] 'dired-mouse-find-file)
)
