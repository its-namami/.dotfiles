;;; -*- lexical-binding: t; -*-

;; set home directory
(setq user-emacs-directory (expand-file-name "~/.config/emacs/"))

;; change location of the native compilation cache
(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
 
(setq package-enable-at-startup nil)

(setq custom-file (expand-file-name "no-littering-customizations.el" user-emacs-directory))
