;;;; Pull Up Line
;; http://emacs.stackexchange.com/q/7519/115
(defun modi/pull-up-line ()
  "Join the following line onto the current one (analogous to `C-e', `C-d') or
`C-u M-^' or `C-u M-x join-line'.
If the current line is a comment and the pulled-up line is also a comment,
remove the comment characters from that line."
  (interactive)
  (join-line -1)
  ;; If the current line is a comment
  (when (nth 4 (syntax-ppss))
    ;; Remove the comment prefix chars from the pulled-up line if present
    (save-excursion
      ;; Delete all comment-start and space characters
      (while (looking-at (concat "\\s<" ; comment-start char as per syntax table
                                 "\\|" (substring comment-start 0 1) ; first char of `comment-start'
                                 "\\|" "\\s-")) ; extra spaces
        (delete-forward-char 1))
      (insert-char ? )))) ; insert space

;;;; Open Line
(defun modi/smart-open-line (&optional n)
  "Move the current line down if there are no word chars between the start of
line and the cursor. Else, insert empty line after the current line."
  (interactive "p")
  (if (derived-mode-p 'org-mode)
      (dotimes (cnt n)
        (org-open-line 1))
    ;; Get the substring from start of line to current cursor position
    (let ((str-before-point (buffer-substring (line-beginning-position) (point))))
      ;; (message "%s" str-before-point)
      (if (not (string-match "\\w" str-before-point))
          (progn
            (dotimes (cnt n)
              (newline-and-indent))
            ;; (open-line 1)
            (previous-line n)
            (indent-relative-maybe))
        (progn
          (move-end-of-line nil)
          (dotimes (cnt n)
            (newline-and-indent))
          (previous-line (- n 1)))))))

(defun xah-copy-line-or-region ()
  "Copy current line, or text selection.
When called repeatedly, append copy subsequent lines.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region')."
  (interactive)
  (let (-p1 -p2)
    (if current-prefix-arg
        (setq -p1 (point-min) -p2 (point-max))
      (if (use-region-p)
          (setq -p1 (region-beginning) -p2 (region-end))
        (setq -p1 (line-beginning-position) -p2 (line-end-position))))
    (if (eq last-command this-command)
        (progn
          (progn ; hack. exit if there's no more next line
            (end-of-line)
            (forward-char)
            (backward-char))
          ;; (push-mark (point) "NOMSG" "ACTIVATE")
          (kill-append "\n" nil)
          (kill-append (buffer-substring-no-properties (line-beginning-position) (line-end-position)) nil)
          (message "Line copy appended"))
      (progn
        (kill-ring-save -p1 -p2)
        (if current-prefix-arg
            (message "Buffer text copied")
          (message "Text copied"))))
    (end-of-line)
    (forward-char)))

(defun xah-cut-line-or-region ()
  "Cut current line, or text selection.
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region')."
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (if (use-region-p)
        (kill-region (region-beginning) (region-end) t)
      (progn
        (kill-region (line-beginning-position) (line-beginning-position 2))
        (back-to-indentation)))))

(defun sk/select-inside-line ()
  "Select the current line."
  (interactive)
  (smarter-move-beginning-of-line 1)
  (set-mark (line-end-position))
  (exchange-point-and-mark))

(defun sk/select-around-line ()
  "Select line including the newline character"
  (interactive)
  (sk/select-inside-line)
  (next-line 1)
  (sk/smarter-move-beginning-of-line 1))

(defun align-whitespace (start end)
  "Align columns by whitespace"
  (interactive "r")
  (align-regexp start end
                "\\(\\s-*\\)\\s-" 1 1 t))
(defun align-equals (start end)
  "Align columns by equals sign"
  (interactive "r")
  (align-regexp start end
                "\\(\\s-*\\)=" 1 1 t))

(defun modi/align-columns (begin end)
  "Align text columns"
  (interactive "r")
  ;; align-regexp syntax:  align-regexp (beg end regexp &optional group spacing repeat)
  (align-regexp begin end "\\(\\s-+\\)[a-zA-Z0-9=(),?':`\.{}]" 1 1 t)
  (indent-region begin end)) ; indent the region correctly after alignment

(use-package goto-chg
  :bind* (("C-c g l" . goto-last-change)
          ("C-c g r" . goto-last-change-reverse)))

(use-package expand-region
  :bind* ("C-c e" . er/expand-region)
  :config
  (progn
    (setq expand-region-contract-fast-key "|")
    (setq expand-region-reset-fast-key "<ESC><ESC>")))

(use-package subword
  :diminish subword-mode
  :config (subword-mode +1))

(use-package saveplace
  :init (save-place-mode 1))

(use-package electric-operator
  :config (electric-operator-add-rules-for-mode 'haskell-mode (cons "|" "| ")))

(bind-keys*
 ("C-o" . modi/smart-open-line)
 ("M-j" . modi/pull-up-line)
 ("s-j" . delete-indentation)
 ("C-M-SPC" . cycle-spacing)
 ("M-?" . mark-paragraph)
 ("C-h" . delete-backward-char)
 ("C-M-h" . backward-kill-word)
 ("C-w" . xah-cut-line-or-region)
 ("M-w" . xah-copy-line-or-region)
 ("C-c b n" . copy-buffer-file-name-as-kill)
 ("M-;" . comment-line)
 ("C-c s l" . sk/select-inside-line)
 ("C-c s n" . sk/select-around-line))

(provide 'setup-editing)
