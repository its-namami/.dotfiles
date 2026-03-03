(require 'exec-path-from-shell)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(require 'exwm)
;; Set the initial workspace number.
(setq exwm-workspace-number 4)
;; Make class name the buffer name.
(add-hook 'exwm-update-class-hook
  (lambda () (exwm-workspace-rename-buffer exwm-class-name)))
;; Global keybindings.
(setq exwm-input-global-keys
      `(([?\s-r] . exwm-reset) ;; s-r: Reset (to line-mode).
        ([?\s-w] . exwm-workspace-switch) ;; s-w: Switch workspace.
        ([?\s-d] . (lambda (cmd) ;; s-&: Launch application.
                     (interactive (list (read-shell-command "$ ")))
                     (start-process-shell-command cmd nil cmd)))
        ;; s-N: Switch to certain workspace.
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))

(add-hook 'exwm-init-hook
          (lambda ()
            (start-process-shell-command
             "startup-commands" nil
             "xrandr --output Virtual-1 --mode 1920x1080 & setxkbmap -layout us -variant colemak_dh")))

;; Enable EXWM
(exwm-wm-mode)
