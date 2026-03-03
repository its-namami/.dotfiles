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
(load-theme 'everforest-hard-dark t)

;; Check if we are running EXWM
(when (and (string= system-type "gnu/linux")
           (display-graphic-p)
           (not (getenv "XDG_CURRENT_DESKTOP"))
	   (not (getenv "WSL_DISTRO_NAME")))
  (load-file (expand-file-name "exwm.el" "~/.config/emacs/")))

;; no-litter - helps keeping ~/.config/emacs clean
(unless (package-installed-p 'no-littering)
  (package-install 'no-littering))
(require 'no-littering)
(setq custom-file (expand-file-name "no-littering-customizations.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; magit - git porcelain
(unless (package-installed-p 'magit)
  (package-install 'magit))

;; wakatime - time tracking
(when (or (string= system-type "gnu/linux")
          (string= system-type "darwin")
          (string= system-type "windows-nt"))
  (unless (package-installed-p 'wakatime-mode)
    (package-install 'wakatime-mode))
  
  (if (or (string= system-type "gnu/linux")
	  (string= system-type "darwin"))
      (setq wakatime-cli-path "wakatime-cli")

      (if (string= system-type "windows-nt")
          (setq wakatime-cli-path (concat (expand-file-name "~") "/.wakatime/wakatime-windows-cli-amd64.exe"))))
  (global-wakatime-mode))

;; xclip - yank to system clipboard
(when (or (string= system-type "gnu/linux")
	  (string= system-type "darwin"))
  (unless (package-installed-p 'xclip)
    (package-install 'xclip)))

;; rspec - testing without using the shell
(unless (package-installed-p 'rspec-mode)
  (package-install 'rspec-mode))

;; twig mode
(unless (package-installed-p 'twig-mode)
  (package-install 'twig-mode))

;; php mode
(unless (package-installed-p 'php-mode)
  (package-install 'php-mode))

;; sass mode
(unless (package-installed-p 'sass-mode)
  (package-install 'sass-mode))

;; scss mode
(unless (package-installed-p 'scss-mode)
  (package-install 'scss-mode))

;; typescript mode
(unless (package-installed-p 'typescript-mode)
  (package-install 'typescript-mode))

;; avy - precise spatial jump
(unless (package-installed-p 'avy)
  (package-install 'avy))
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "C-;") 'avy-goto-char-timer)

;; consult-project-extra - fast project file fuzzy-searching
(unless (package-installed-p 'consult-project-extra)
  (package-install 'consult-project-extra))

;; having this in my config makes me feel pro
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq initial-scratch-message "")
(global-set-key (kbd "M-o") 'other-window)

;; QOL utils
(fido-vertical-mode 1)
(winner-mode 1)
