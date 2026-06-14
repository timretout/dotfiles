(defun my/hugo-ensure-server (blog-root)
  "Ensure the Hugo server buffer exists and runs interactively in the background."
  (let* ((hugo-buf (get-buffer-create "*hugo-server*"))
         (hugo-proc (get-buffer-process hugo-buf)))

    ;; Process safety fence: if the shell process isn't running, boot it silently
    (unless (and hugo-proc (process-live-p hugo-proc))
      (let ((default-directory blog-root))
        ;; make-comint-in-buffer spawns an interactive shell without altering windows
        (make-comint-in-buffer "hugo-server" hugo-buf (or explicit-shell-file-name (getenv "SHELL") "bash"))
        (sit-for 0.1) ; Tiny pause to let the stream initialize

        ;; Inject the boot command directly into the background terminal
        (comint-send-string
          (get-buffer-process hugo-buf)
          (format "cd %s && hugo server -D\n" (shell-quote-argument blog-root)))))))

(defun my/hugo-new-post ()
  "Initialize the Hugo environment, prompt for a title, and open the preview generically."
  (interactive)
  (let ((blog-root (expand-file-name "~/src/retout.co.uk/")))

    ;; 1. Fire up or verify the local server inside Emacs
    (my/hugo-ensure-server blog-root)

    (switch-to-buffer "*hugo-server*")
    (redisplay)

    (condition-case nil
        (let* ((title (read-string "Enter post title: "))
               (year (format-time-string "%Y"))
               (month (format-time-string "%m"))
               (day (format-time-string "%d"))
               (slug (downcase title))
               (slug (replace-regexp-in-string "[^a-z0-9 ]" "" slug))
               (slug (replace-regexp-in-string " +" "-" slug))
               (relative-path (format "blog/%s/%s/%s/%s.md" year month day slug))
               (absolute-path (expand-file-name (concat "content/" relative-path) blog-root))
               (preview-url (format "http://localhost:1313/%s/%s/%s/%s/" year month day slug)))

          (let ((process-environment (cons (format "HUGO_POST_TITLE=%s" title) process-environment))
                (default-directory blog-root))
            (shell-command (format "hugo new %s" (shell-quote-argument relative-path)))

            (if (file-exists-p absolute-path)
                (progn
                  ;; Open the newly minted markdown post
                  (find-file absolute-path)

                  ;; Bonus Points: Hand off the URL to the OS via xdg-open natively
                  (browse-url preview-url)

                  (message "Hugo post created and preview requested!"))
              (error "Hugo failed to create the file at %s" absolute-path))))

      (quit
       (message "Post creation cancelled.")))))
