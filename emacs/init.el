;;; -*- lexical-binding: t; -*-

(require 'package)

;; melpa - repository of packages
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; when first time (new machine), sync with melpa archives
(unless package-archive-contents
  (package-refresh-contents))

;; no-litter - helps keeping ~/.config/emacs clean
(unless (package-installed-p 'no-littering)
  (package-install 'no-littering))
(require 'no-littering)
(setq custom-file (expand-file-name "no-littering-customizations.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; magit - git client
(unless (package-installed-p 'magit)
  (package-install 'magit))

;; Add lisp folder to path safely
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; pdftotext - CLI pdf reading
(unless (package-installed-p 'pdftotext)
  (package-vc-install "https://github.com/tecosaur/pdftotext.el"))
(require 'pdftotext nil 'noerror)

;; wakatime - time tracking
(unless (package-installed-p 'wakatime-mode)
  (package-install 'wakatime-mode))
(setq wakatime-cli-path "wakatime-cli") ; Set variable FIRST
(global-wakatime-mode)

;; elcord - rich presence
(unless (package-installed-p 'elcord)
  (package-install 'elcord))
(elcord-mode 1)

;; expand region - semantic expansion
(unless (package-installed-p 'expand-region)
  (package-install 'expand-region))
(global-set-key (kbd "C-.") 'er/expand-region)

;; avy - precise spatial jump
(unless (package-installed-p 'avy)
  (package-install 'avy))
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "C-;") 'avy-goto-char-timer)

;; global UI setup
(setq inhibit-startup-message t
      initial-scratch-message ""
      ring-bell-function 'ignore
      frame-resize-pixelwise t)

(menu-bar-mode -1)

;; consolidate frame appearance
(let ((my-frame-settings '((undecorated . t)
                           (internal-border-width . 8)
                           (fullscreen . maximized))))
  (setq default-frame-alist my-frame-settings
        initial-frame-alist my-frame-settings))

;; GUI specifics (font, theme and UI)
(if (display-graphic-p)
    (progn
      (scroll-bar-mode -1)
      (tool-bar-mode -1)
      (tooltip-mode -1)
      (set-fringe-mode 10)

      ;; load everforest theme
      (unless (package-installed-p 'everforest-emacs)
	(package-vc-install "https://github.com/theorytoe/everforest-emacs"))
      (load-theme 'everforest-hard-dark t)

      ;; set up font
      (set-face-attribute 'default nil
                          :family "Hack Nerd Font"
                          :height 240)))

(defun my-config ()
  "Quickly jump to emacs init.el"
  (interactive)
  (find-file user-init-file))

;; pretty markdown
(add-hook 'markdown-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (markdown-toggle-markup-hiding 1)
	    (custom-set-faces
	     '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "variable-pitch"))))
	     '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.8))))
	     '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.4))))
	     '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.2)))))
	    (markdown-toggle-markup-hiding)))
