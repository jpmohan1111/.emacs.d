;; Time-stamp: <2016-10-07 12:58:08 csraghunandan>

;; desktop
;; save the current emacs session under `desktop' to be restored later
(use-package desktop :defer 1
  :config
  (setq desktop-dirname             "~/.emacs.d/desktop/"
        desktop-base-file-name      "emacs.desktop"
        desktop-base-lock-name      "lock"
        desktop-path                (list desktop-dirname)
        desktop-save                t
        desktop-load-locked-desktop nil)
  (desktop-save-mode 0)

  ;; https://github.com/purcell/emacs.d/blob/master/lisp/init-sessions.el
  ;; Save a bunch of variables to the desktop file.
  ;; For lists, specify the length of the maximal saved data too.
  (setq desktop-globals-to-save
        (append '((comint-input-ring . 50)
                  desktop-missing-file-warning
                  (dired-regexp-history . 20)
                  (extended-command-history . 30)
                  (face-name-history . 20)
                  (file-name-history . 100)
                  (magit-read-rev-history . 50)
                  (minibuffer-history . 50)
                  (org-refile-history . 50)
                  (org-tags-history . 50)
                  (query-replace-history . 60)
                  (read-expression-history . 60)
                  (regexp-history . 60)
                  (regexp-search-ring . 20)
                  register-alist
                  (search-ring . 20)
                  (shell-command-history . 50)
                  ;; tags-file-name
                  ;; tags-table-list
                  )))

  ;; Don't save .gpg files. Restoring those files in emacsclients causes
  ;; a problem as the password prompt appears before the frame is loaded.
  (setq desktop-files-not-to-save
        (concat "\\(^/[^/:]*:\\|(ftp)$\\)" ; original value
                "\\|\\(\\.gpg$\\)"
                "\\|\\(\\.plstore$\\)"
                "\\|\\(\\.desktop$\\)"
                ;; FIXME
                ;; If backup files with names like "file.sv.20150619_1641.bkp"
                ;; are saved to the desktop file, emacsclient crashes at launch
                ;; Need to debug why that's the case. But for now, simply not
                ;; saving the .bkp files to the desktop file is a workable
                ;; solution -- Fri Jun 19 16:45:50 EDT 2015 - kmodi
                "\\|\\(\\.bkp$\\)"
                "\\|\\(\\TAGS$\\)"))

  ;; Don't save the eww buffers
  (let (;; http://thread.gmane.org/gmane.emacs.devel/202463/focus=202496
        (default (eval (car (get 'desktop-buffers-not-to-save 'standard-value))))
        (eww-buf-regexp "\\(^eww\\(<[0-9]+>\\)*$\\)"))
    (setq desktop-buffers-not-to-save (concat default
                                              "\\|" eww-buf-regexp)))

  ;; http://emacs.stackexchange.com/a/20036/115
  (defun rag/bury-star-buffers ()
    "Bury all star buffers."
    (mapc (lambda (buf)
            (when (string-match-p "\\`\\*.*\\*\\'" (buffer-name buf))
              (bury-buffer buf)))
          (buffer-list)))
  (add-hook 'desktop-after-read-hook #'rag/bury-star-buffers)

  (defun rag/restore-last-saved-desktop ()
    "Enable `desktop-save-mode' and restore the last saved desktop."
    (interactive)
    (desktop-save-mode 1)
    (desktop-read))

  :bind* (("<S-f2>" . desktop-save-in-desktop-dir)
          ("<C-f2>" . rag/restore-last-saved-desktop)))

(provide 'setup-desktop)
