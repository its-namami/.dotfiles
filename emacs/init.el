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

;; Development tools: Eglot -> Flymake underlines + ElDoc messages.
;; See emacs-development-setup.md for installation and troubleshooting.
;; No separate Flycheck/RuboCop Emacs package is needed.
(require 'cl-lib)
(require 'subr-x)

;; GUI/daemon Emacs may not inherit the PATH used by npm and Ruby.
;; Native Windows inherits PATH from Windows; do not invoke a Unix shell.
(use-package exec-path-from-shell
  :ensure t
  :if (and (memq system-type '(gnu/linux darwin))
           (or (display-graphic-p) (daemonp)))
  :config
  (dolist (variable '("GEM_HOME" "GEM_PATH"))
    (add-to-list 'exec-path-from-shell-variables variable))
  (exec-path-from-shell-initialize))

(defgroup its-development nil
  "Small, native development-tool customizations."
  :group 'tools)

(defcustom its/typescript-tsserver-path nil
  "Optional absolute path to TypeScript's lib/tsserver.js.
Normally leave nil: use the workspace TypeScript, with global npm as
a fallback.  Set this only to explicitly override that selection."
  :type '(choice (const :tag "Automatic" nil) file)
  :group 'its-development)

(defun its/npm-global-tsserver ()
  "Find a usable global npm TypeScript entry point, or return nil.
Run npm directly, without shell interpolation.  Do not probe local
tools when visiting a remote directory."
  (unless (file-remote-p default-directory)
    (when-let* ((npm (executable-find "npm")))
      (condition-case nil
          (with-temp-buffer
            (when (eq 0 (process-file npm nil (list t nil) nil "root" "--global"))
              (let* ((root (string-trim (buffer-string)))
                     (path (expand-file-name "typescript/lib/tsserver.js" root)))
                (when (and (file-name-absolute-p root)
                           (file-regular-p path)
                           (file-readable-p path))
                  path))))
        (file-error nil)))))

(defun its/eglot-typescript-contact (&rest _)
  "Build the TypeScript server command when Eglot connects.
Accept both older and Emacs 31 functional-contact argument lists.
Keep workspace TypeScript preferred unless explicitly overridden."
  (let ((override its/typescript-tsserver-path)
        (fallback (unless its/typescript-tsserver-path
                    (its/npm-global-tsserver))))
    (when (and override
               (not (and (file-name-absolute-p override)
                         (file-regular-p override)
                         (file-readable-p override))))
      (user-error "its/typescript-tsserver-path must name a readable tsserver.js"))
    (append '("typescript-language-server" "--stdio")
            (when (or override fallback)
              (list :initializationOptions
                    (list :tsserver
                          (if override
                              (list :path override)
                            (list :fallbackPath fallback))))))))

(defun its/eglot-server-executable ()
  "Return the executable configured for this buffer's language."
  (cond
   ((derived-mode-p 'ruby-mode 'ruby-ts-mode) "ruby-lsp")
   ((derived-mode-p 'html-mode 'mhtml-mode 'html-ts-mode)
    "vscode-html-language-server")
   ((derived-mode-p 'css-mode 'css-ts-mode 'scss-mode)
    "vscode-css-language-server")
   ((derived-mode-p 'js-mode 'js-ts-mode 'typescript-mode
                    'typescript-ts-mode 'tsx-ts-mode)
    "typescript-language-server")))

(defun its/eglot-ensure-if-server ()
  "Start the right server for a local file, or explain what is missing.
Remote/TRAMP buffers are intentionally left to manual Eglot setup."
  (when (and buffer-file-name (not (file-remote-p default-directory)))
    (when-let* ((server (its/eglot-server-executable)))
      (if (executable-find server)
          (eglot-ensure)
        (message "Eglot: %s is not on Emacs's PATH; see C-c x v" server)))))

;; Eagerly load the built-in package: the custom hook above needs
;; eglot-ensure and our server registrations ready before a file opens.
(use-package eglot
  :ensure nil
  :demand t
  :custom
  ;; These servers expect an object, not JSON null, for their settings.
  ;; Project .dir-locals.el can still override this configuration.
  (eglot-workspace-configuration
   '(:css (:validate t :format (:enable t))
     :scss (:validate t :format (:enable t))))
  :hook ((ruby-mode ruby-ts-mode
          js-mode js-ts-mode typescript-mode typescript-ts-mode tsx-ts-mode
          html-mode mhtml-mode html-ts-mode
          css-mode css-ts-mode scss-mode) . its/eglot-ensure-if-server)
  :bind (("M-." . xref-find-definitions)
         ("M-," . xref-go-back)
         ("C-c x r" . xref-find-references)
         ("C-c x d" . xref-find-definitions)
         ("C-c x a" . eglot-code-actions)
         ("C-c x h" . eldoc-doc-buffer)
         ("C-c x R" . eglot-rename)
         ("C-c x v" . its/development-doctor)
         ("C-c f b" . eglot-format-buffer)
         ("C-c f r" . its/format-region)
         ("C-c f s" . its/format-on-save-mode)
         ("C-c r c" . flymake-show-buffer-diagnostics)
         ("C-c r a" . eglot-format-buffer))
  :config
  ;; Ruby LSP supplies Ruby navigation/completion AND RuboCop diagnostics.
  ;; Run ruby-lsp directly: it composes its own bundle with the project's.
  ;; RuboCop MUST be in the project's Gemfile (see the setup guide).
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode)
                 . ("ruby-lsp" :initializationOptions
                    (:formatter "rubocop" :linters ["rubocop"]))))
  (add-to-list 'eglot-server-programs
               '(((js-mode :language-id "javascript")
                  (js-ts-mode :language-id "javascript")
                  (typescript-mode :language-id "typescript")
                  (typescript-ts-mode :language-id "typescript")
                  (tsx-ts-mode :language-id "typescriptreact"))
                 . its/eglot-typescript-contact))
  (add-to-list 'eglot-server-programs
               '(((html-mode :language-id "html")
                  (mhtml-mode :language-id "html")
                  (html-ts-mode :language-id "html"))
                 . ("vscode-html-language-server" "--stdio"
                    :initializationOptions
                    (:provideFormatter t
                     :embeddedLanguages (:css t :javascript t)))))
  (add-to-list 'eglot-server-programs
               '(((css-mode :language-id "css")
                  (css-ts-mode :language-id "css")
                  (scss-mode :language-id "scss"))
                 . ("vscode-css-language-server" "--stdio"
                    :initializationOptions (:provideFormatter t)))))

;; Underlines/fringe marks use your theme's normal Flymake faces.
;; No global flymake-mode: Eglot enables it where a backend is available.
(use-package flymake
  :ensure nil
  :demand t
  :custom
  (flymake-no-changes-timeout 0.5)
  :bind (("C-c x n" . flymake-goto-next-error)
         ("C-c x p" . flymake-goto-prev-error)
         ("C-c x l" . flymake-show-buffer-diagnostics)
         ("C-c x L" . flymake-show-project-diagnostics)
         ("C-c x e" . its/toggle-inline-diagnostics)))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-idle-delay 0.4))

(defun its/eglot-eldoc-setup ()
  "Let diagnostics and documentation share the native echo area."
  (when (eglot-managed-p)
    (setq-local eldoc-documentation-strategy
                #'eldoc-documentation-compose-eagerly)
    (eldoc-mode 1)))
(add-hook 'eglot-managed-mode-hook #'its/eglot-eldoc-setup)

(defun its/toggle-inline-diagnostics ()
  "Toggle extra diagnostic text in this buffer, keeping underlines.
Support both the bundled Flymake option and newer GNU ELPA Flymake."
  (interactive)
  (require 'flymake)
  (let* ((option (if (boundp 'flymake-inline-diagnostics)
                     'flymake-inline-diagnostics
                   'flymake-show-diagnostics-at-end-of-line))
         (enabled (not (symbol-value option))))
    (set (make-local-variable option)
         (and enabled (if (eq option 'flymake-inline-diagnostics) 'short t)))
    (when (bound-and-true-p flymake-mode)
      (flymake-start))
    (message "Inline diagnostic text %s; underlines unchanged"
             (if enabled "enabled" "disabled"))))

(defun its/format-region (beg end)
  "Format the selected region, without silently formatting the whole file."
  (interactive "r")
  (unless (use-region-p)
    (user-error "Select a region first, or use C-c f b for the whole buffer"))
  (when (derived-mode-p 'ruby-mode 'ruby-ts-mode)
    (user-error "RuboCop needs the whole Ruby buffer; use C-c f b"))
  (eglot-format beg end))

(defun its/format-before-save ()
  "Format through Eglot; leave the buffer unsaved if formatting fails."
  (unless (eglot-managed-p)
    (user-error "No Eglot connection; connect or disable C-c f s to save"))
  (eglot-format-buffer))

(define-minor-mode its/format-on-save-mode
  "Opt-in, buffer-local formatting before save.
Disabled by default to avoid surprise rewrites.  If the formatter
fails, saving stops; fix the error or toggle this mode off to save."
  :lighter " Fmt"
  :group 'its-development
  (if its/format-on-save-mode
      (add-hook 'before-save-hook #'its/format-before-save nil t)
    (remove-hook 'before-save-hook #'its/format-before-save t)))

(defun its/development-doctor ()
  "Show the development tools visible to this Emacs, without installing any."
  (interactive)
  (let ((directory default-directory)
        (mode major-mode)
        (server (its/eglot-server-executable))
        (connected (eglot-managed-p)))
    (with-help-window "*Development tools*"
      (princ (format "Emacs: %s\nDirectory: %s\nMode: %s\n"
                     emacs-version directory mode))
      (princ (format "Expected server: %s\nEglot managing this buffer: %s\n\n"
                     (or server "none configured here") (if connected "yes" "no")))
      (if (file-remote-p directory)
          (princ "Remote buffer: automatic local-tool detection is disabled.\n")
        (dolist (program '("node" "npm" "typescript-language-server" "tsserver"
                           "vscode-html-language-server" "vscode-css-language-server"
                           "ruby" "gem" "bundle" "ruby-lsp" "rubocop"))
          (princ (format "%-30s %s\n" program
                         (or (executable-find program) "NOT FOUND"))))
        (princ (format "\nExplicit tsserver override: %s\nGlobal tsserver fallback: %s\n"
                       (or its/typescript-tsserver-path "none")
                       (or (its/npm-global-tsserver) "not found"))))
      (princ "\nThis reports executable discovery, not server health or gem versions.\n")
      (princ "For connection errors: M-x eglot-events-buffer and *Messages*.\n")
      (princ "Ruby: RuboCop must also be in your project's Gemfile.\n")
      (princ "After installing tools, restart Emacs and run M-x eglot.\n"))))

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
                typescript-ts-mode-hook tsx-ts-mode-hook
                html-mode-hook mhtml-mode-hook html-ts-mode-hook
                css-mode-hook css-ts-mode-hook scss-mode-hook))
  (add-hook hook #'its/two-space-indentation))
(setq-default css-indent-offset 2
              js-indent-level 2
              typescript-indent-level 2
              typescript-ts-mode-indent-offset 2
              js2-basic-offset 2
              sgml-basic-offset 2
              ruby-indent-level 2)

;; QOL things
(fido-vertical-mode 1)
(winner-mode 1)
(setopt frame-resize-pixelwise t)
