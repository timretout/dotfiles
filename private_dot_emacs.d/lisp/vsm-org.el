(require 'org-agenda)


;; 1. File and Directory Settings
(setq org-directory "~/vsm")
(setq org-default-notes-file "~/vsm/notes.org")

;; Tell the Agenda to look at all Org files in your ~/vsm directory
(setq org-agenda-files '("~/vsm"))

;; 2. Global Keybindings
;; These are the standard, highly recommended shortcuts for Org-mode
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; 3. Behavior & Visual Tweaks
(with-eval-after-load 'org
  (setq org-startup-indented t          ; Visually indent text matching heading level
        org-hide-leading-stars t        ; Only show the rightmost star on headings
        org-log-done 'time              ; Automatically insert a timestamp when marking a task DONE
        org-src-fontify-natively t      ; Syntax highlighting inside code blocks
        org-src-tab-acts-natively t)    ; Use standard language tabbing in code blocks

  ;; Custom TODO Keywords
  (setq org-todo-keywords
    '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "SOMEDAY(s)")))

  ;; Basic Capture Templates
  ;; Press 'C-c c t' to quickly dump a task into notes.org
  (setq org-capture-templates
        '(("t" "Todo Task" entry (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n  Logged: %U")
          ("n" "Quick Note" entry (file+headline org-default-notes-file "Notes")
           "* %?\n  Logged: %U"))))

(defun my/open-waybar-calendar ()
  "Open a full-frame Org Agenda view optimized for the Waybar clock click."
  (interactive)
  (let ((org-agenda-window-setup 'only-window))
    (org-agenda-list)

    ;; 3. Bind the smart frame-closing quit handle locally
    (local-set-key [remap org-agenda-quit]
                   (lambda ()
                     (interactive)
                     (if (string= (frame-parameter nil 'name) "waybar-calendar")
                         (delete-frame)
                       (org-agenda-quit))))))
