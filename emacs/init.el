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


;; keybindings
(global-set-key (kbd "M-o") 'other-window)

;; QOL things
(fido-vertical-mode 1)
(winner-mode 1)
(setopt frame-resize-pixelwise t)
