;;; -*- lexical-binding: t; -*-

;; WINDOWS:
;; Coulnd't symbol link the config files from this repo to emacs config
;; thus, on windows, use this:
;;(load (concat (expand-file-name "~") "/repos/.dotfiles/emacs/init.el"))

(require 'package)

;; melpa - package manager
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; sync with melpa archives when booting emacs for the first time
(unless package-archive-contents
  (package-refresh-contents))

;; everforest - superior theme
(unless (package-installed-p 'everforest-emacs)
  (package-vc-install "https://github.com/theorytoe/everforest-emacs"))   


;; autodark - change theme based on CURRENT system preference
(setq custom-safe-themes t) ;; make all themes safe to load
(use-package auto-dark
  :ensure t
  :custom
  (auto-dark-themes '((everforest-hard-dark) (everforest-hard-light)))
  :init
  (auto-dark-mode))

;; Check if we are running EXWM
(when (and (eq system-type 'gnu/linux)
           (display-graphic-p)
           (not (getenv "XDG_CURRENT_DESKTOP"))
	   (not (getenv "WSL_DISTRO_NAME")))
  (load-file (expand-file-name "exwm.el" "~/.config/emacs/")))

;; no-litter - helps keeping ~/.config/emacs clean
(use-package no-littering
  :ensure t)
(require 'no-littering)
(setq custom-file (expand-file-name "no-littering-customizations.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; magit - git porcelain
(use-package magit
  :ensure t)
(add-hook 'git-commit-mode-hook #'flyspell-mode)

;; wakatime - time tracking
(use-package wakatime-mode
  :ensure t)

(if (memq system-type '(gnu/linux darwin))
    (setq wakatime-cli-path "~/.wakatime/wakatime-cli")

  (if (eq system-type 'windows-nt)
      (setq wakatime-cli-path (concat (expand-file-name "~") "/.wakatime/wakatime-cli-windows-amd64.exe"))))
(global-wakatime-mode)

;; xclip - yank to system clipboard
(when (memq system-type '(gnu/linux darwin))
  (use-package xclip
    :ensure t))
(setq selection-coding-system 'utf-8-unix
      x-select-request-type 'UTF8_STRING)

;; rspec - testing without using the shell
(use-package rspec-mode
  :ensure t)

;; twig mode
(use-package twig-mode
  :ensure t)

;; php mode
(use-package php-mode
  :ensure t)

;; sass mode
(use-package sass-mode
  :ensure t)

;; typescript mode
(use-package typescript-mode
  :ensure t)

;; avy - precise spatial jump
(use-package avy
  :ensure t)
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "C-;") 'avy-goto-char-timer)

;; consult-project-extra - fast project file fuzzy-searching
(use-package consult-project-extra
  :ensure t)

;; consult - fast project search and navigation
(use-package consult
  :ensure t
  :bind (("C-c p f" . consult-project-extra-find)
         ("C-c p g" . consult-ripgrep)
         ("C-c p b" . its/project-switch-buffer)
         ("C-c p i" . consult-imenu)
         ("M-g g" . consult-goto-line)))
(global-set-key (kbd "C-c b") #'consult-buffer)
(global-set-key (kbd "C-c p p") #'its/project-switch-repository)

(defun its/project-switch-repository ()
  "Discover Git projects under ~/repos, then choose one."
  (interactive)
  (let ((repos (expand-file-name "~/repos")))
    (unless (file-directory-p repos)
      (user-error "Repository directory does not exist: %s" repos))
    (project-remember-projects-under repos t)
    (call-interactively #'project-switch-project)))

(defun its/project-switch-buffer ()
  "Switch only between live file buffers belonging to the current project."
  (interactive)
  (let* ((project (project-current t))
         (root (file-name-as-directory (project-root project)))
         (buffers
          (seq-filter
           (lambda (buffer)
             (with-current-buffer buffer
               (when-let* ((directory (or (buffer-file-name buffer)
                                          (and (derived-mode-p 'vterm-mode)
                                               default-directory))))
                 (file-in-directory-p directory root))))
           (buffer-list))))
    (if buffers
        (switch-to-buffer
         (completing-read "Project buffer: " (mapcar #'buffer-name buffers)
                          nil t))
      (user-error "No file buffers are open for this project"))))

;; Built-in in-buffer completion (Emacs 30+)
(when (fboundp 'global-completion-preview-mode)
  (global-completion-preview-mode 1))

;; vterm - terminal emulator for long-running development processes
(use-package vterm
  :ensure t
  :commands vterm
  :bind (("C-c t" . vterm)))

;; markdown-mode - readable Markdown editing and tables
(use-package markdown-mode
  :ensure t
  :custom
  (markdown-command "cmark")
  :mode ("\\.md\\'" . markdown-mode)
  :hook (markdown-mode . visual-line-mode)
  :bind (:map markdown-mode-map
              ("C-c m p" . markdown-preview)
              ("C-c m l" . markdown-live-preview-mode)
              ("C-c m e" . markdown-export-and-preview)
              ("C-c m g" . its/markdown-grip-preview)))

(defvar its/markdown-grip-process nil)

(defun its/markdown-grip-preview ()
  "Open the current Markdown file in a GitHub-style Grip preview."
  (interactive)
  (unless buffer-file-name
    (user-error "Current buffer is not visiting a file"))
  (unless (executable-find "grip")
    (user-error "Grip is not installed; run: python3 -m pip install --user grip"))
  (when (process-live-p its/markdown-grip-process)
    (delete-process its/markdown-grip-process))
  (let ((file buffer-file-name)
        (directory (file-name-directory buffer-file-name)))
    (setq its/markdown-grip-process
          (start-process "markdown-grip" "*markdown-grip*" "grip"
                         file "127.0.0.1:6419"))
    (run-at-time
     1 nil
     (lambda (directory)
       (let ((default-directory directory))
         (browse-url "http://localhost:6419")))
     directory)
    (message "Starting Grip preview for %s" (file-name-nondirectory file))))

;; emmet - HTML/CSS abbreviation expansion
(use-package emmet-mode
  :ensure t
  :hook ((html-mode mhtml-mode css-mode scss-mode) . emmet-mode)
  :bind (:map emmet-mode-keymap
              ("C-c e" . emmet-expand-line)))

;; eglot - language-server support for exact definitions, references,
;; completion, diagnostics, and documentation
(use-package eglot
  :ensure nil
  :hook ((ruby-mode ruby-ts-mode) . its/eglot-ensure-if-server)
  :hook ((js-mode js-ts-mode
          typescript-mode
          html-mode mhtml-mode
          css-mode scss-mode) . its/eglot-ensure-if-server)
  :bind (("M-." . xref-find-definitions)
         ("M-," . xref-go-back)
         ("C-c x r" . xref-find-references)
         ("C-c x d" . xref-find-definitions)
         ("C-c x a" . eglot-code-actions)
         ("C-c x h" . eldoc)
         ("C-c f b" . eglot-format-buffer)
         ("C-c f r" . eglot-format))
  :config
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode) . ("ruby-lsp")))
  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode typescript-mode)
                 . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((html-mode mhtml-mode) . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((css-mode scss-mode) . ("vscode-css-language-server" "--stdio"))))

(with-eval-after-load 'eglot
  (put 'eglot-flymake-backend 'flymake-always-safe t))

(defun its/eglot-ensure-if-server ()
  "Start Eglot only when a configured language server is installed."
  (when (seq-some #'executable-find
                  '("solargraph" "ruby-lsp"
                    "typescript-language-server"
                    "vscode-html-language-server"
                    "vscode-css-language-server"))
    (eglot-ensure)))

;; flymake - show language-server diagnostics in the buffer
(use-package flymake
  :ensure nil
  :bind (("C-c x n" . flymake-goto-next-error)
         ("C-c x p" . flymake-goto-prev-error)
         ("C-c x l" . flymake-show-buffer-diagnostics)))

;; rubocop - on-demand Ruby style checks and autocorrection
(use-package rubocop
  :ensure t
  :commands (rubocop-check-current-file
             rubocop-autocorrect-current-file)
  :bind (("C-c r c" . rubocop-check-current-file)
         ("C-c r a" . rubocop-autocorrect-current-file)))

;; inf-ruby - ruby REPL
(use-package inf-ruby
  :ensure t
  :hook ((ruby-mode . inf-ruby-minor-mode)
         (ruby-ts-mode . inf-ruby-minor-mode))
  :config
  (defun its/ruby-ensure-inf-process ()
    "Start inf-ruby if there is no running process for this session."
    (unless (get-buffer-process (or (inf-ruby-buffer) inf-ruby-buffer))
      (save-window-excursion
        (inf-ruby))))

  (defun its/ruby-send-region (start end)
    "Ensure inf-ruby is running, then send region from START to END."
    (interactive "r")
    (its/ruby-ensure-inf-process)
    (ruby-send-region start end))

  (defun its/ruby-send-buffer ()
    "Ensure inf-ruby is running, then send current buffer."
    (interactive)
    (its/ruby-send-region (point-min) (point-max)))

  (defun its/ruby-send-line ()
    "Ensure inf-ruby is running, then send the current line."
    (interactive)
    (its/ruby-ensure-inf-process)
    (ruby-send-line))

  (define-key inf-ruby-minor-mode-map (kbd "C-c C-d") #'its/ruby-send-line)
  (define-key inf-ruby-minor-mode-map (kbd "C-c C-r") #'its/ruby-send-buffer)
  (define-key inf-ruby-minor-mode-map (kbd "C-c C-a") #'its/ruby-send-region))

;; having this in my config makes me feel pro
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(add-to-list 'default-frame-alist '(undecorated . t))

;; indentation defaults: 2 spaces, no tabs
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; keybindings
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "C-c o") #'browse-url-of-file)
(global-set-key (kbd "C-c j t") #'its/javascript-test-exercise)

(defun its/javascript-test-exercise ()
  "Run the Jest spec matching the current JavaScript exercise."
  (interactive)
  (unless (and buffer-file-name
               (string-match-p "\\.js\\'" buffer-file-name))
    (user-error "Current buffer is not a JavaScript file"))
  (let* ((file (file-name-nondirectory buffer-file-name))
         (spec (if (string-suffix-p ".spec.js" file)
                   file
                 (concat (file-name-sans-extension file) ".spec.js")))
         (root (or (locate-dominating-file buffer-file-name "package.json")
                   (user-error "No package.json found for this exercise")))
         (default-directory root))
    (compile (format "npm test -- %s" (shell-quote-argument spec)))))

(defun its/two-space-indentation ()
  "Use two spaces and never literal tabs in the current buffer."
  (setq-local tab-width 2)
  (setq-local standard-indent 2)
  (setq-local indent-tabs-mode nil))

(dolist (hook '(ruby-mode-hook ruby-ts-mode-hook
                js-mode-hook js-ts-mode-hook typescript-mode-hook
                html-mode-hook mhtml-mode-hook
                css-mode-hook scss-mode-hook))
  (add-hook hook #'its/two-space-indentation))
(setq-default css-indent-offset 2
              js-indent-level 2
              typescript-indent-level 2
              js2-basic-offset 2
              sgml-basic-offset 2
              ruby-indent-level 2)

;; QOL things
(fido-vertical-mode 1)
(winner-mode 1)
(setopt frame-resize-pixelwise t)
