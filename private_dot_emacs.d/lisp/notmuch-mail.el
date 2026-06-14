(defun stig/sendmail-via-gmi ()
  "Send mail using the `gmi-sendmail' shell script as the `sendmail' program."
  (let ((sendmail-program "gmi-sendmail"))
    (message-send-mail-with-sendmail)))

(use-package notmuch
  :ensure t
  :bind (("C-c m" . notmuch)) ; Global shortcut to open your mail dashboard
  :config

  (setq sendmail-program "gmi-sendmail"
        message-send-mail-function #'stig/sendmail-via-gmi
        notmuch-fcc-dirs nil
        notmuch-always-prompt-for-sender 'nil
        notmuch-search-oldest-first nil)

  ;; 1. Point Emacs to your local mail storage directories
  (setq notmuch-saved-searches
        '((:name "📥 Inbox"   :query "tag:inbox" :key "i")
          (:name "🔥 Unread"  :query "tag:unread and tag:inbox" :key "u")
          (:name "⭐️ Flagged" :query "tag:flagged" :key "f")
          (:name "📤 Sent"    :query "tag:sent" :key "s")
          (:name "📝 Drafts"  :query "tag:draft" :key "d")))

  ;; 2. Visual polish for the mail client view
  (setq notmuch-show-logo nil          ; Ditch the giant ASCII logo to save space
        notmuch-crypto-process-mime t  ; Automatically check and verify PGP signatures
        message-kill-buffer-on-exit t) ; Clean up buffers when you finish sending an email

  ;; 3. Make links and email addresses clickable natively
  (add-hook 'notmuch-show-mode-hook 'goto-address-mode))
