;;; mongolog.el --- A major mode for MongoDB log files  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Lungang FANG

;; Author: Lungang FANG <lungang.fang@gmail.com>
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is NOT part of Emacs.

;; This major mode provides syntax highlights and a number of hot keys to
;; facilitate reading/analysing *legacy* mongod log files. Newer versions of
;; MongoDB write structured log, which is in json format. Hence, just use
;; "js-mode" for such logs.

;; Refer to mongolog-mode-map for funtionality provided.

;;; Code:

(require 'hide-lines nil t)

(defvar mongolog-mode-hook nil)

(defvar mongolog-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map "n" 'next-line)
    (define-key map "p" 'previous-line)
    (define-key map (kbd "SPC") 'scroll-up-command)
    (define-key map (kbd "DEL") 'scroll-down-command)
    (define-key map "t" 'mongolog-track)
    (define-key map "h" 'mongolog-hide)
    (define-key map "s" 'hide-lines-show-all)
    map)
  "Keymap for mongolog major mode.")

;;;###autoload

;; ; no longer the default mode for log files
;; (add-to-list 'auto-mode-alist '("\\.log\\'" . mongolog-mode))

(defvar mongolog-ts-re
  (concat "^"                                        ; start of line
          "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}"   ; date
          "T[0-9]\\{2\\}:[0-9]\\{2\\}:[0-9]\\{2\\}"  ; time
          "\\(?:\\.[0-9]\\{3\\}\\)?"                   ; fraction
          "\\(?:[+-][0-9]\\{2\\}:?[0-9]\\{2\\}\\|Z\\)" ; timezone
          )
  "Regex for timestamp.")

(defvar mongolog-severity-re
  (concat mongolog-ts-re " [FEWID]"))

(defvar mongolog-info-re
  (concat mongolog-ts-re " \\([ID]\\)"))

(defvar mongolog-warn-re
  (concat mongolog-ts-re " \\(W\\)"))

(defvar mongolog-error-re
  (concat mongolog-ts-re " \\([EF]\\)"))

(defvar mongolog-component-re
  (concat mongolog-severity-re " \\([^ ]*\\)"))

(defvar mongolog-context-re "^[^[]*\\(\\[[^]]*\\]\\)")

(defvar mongolog-warn-msg-re
  (concat mongolog-warn-re "[^]]*\\]\\(.*\\)"))

(defvar mongolog-error-msg-re
  (concat mongolog-error-re "[^]]*\\]\\(.*\\)"))

(defvar mongolog-font-lock-keywords
  (list
   (cons mongolog-ts-re '(0 font-lock-comment-face))
   (cons mongolog-info-re '(1 compilation-info-face))
   (cons mongolog-warn-re '(1 compilation-warning-face))
   (cons mongolog-error-re '(1 compilation-error-face))
   (cons mongolog-component-re '(1 font-lock-builtin-face))
   (cons mongolog-context-re '(1 font-lock-function-name-face))
   (cons mongolog-warn-msg-re '(2 compilation-warning-face))
   (cons mongolog-error-msg-re '(2 compilation-error-face))))

(defvar mongolog-mode-syntax-table
  (make-syntax-table))

(defun mongolog-mode ()
  "A major mode for MongoDB log files."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table mongolog-mode-syntax-table)
  (use-local-map mongolog-mode-map)
  (setq font-lock-defaults '(mongolog-font-lock-keywords t))
  (setq major-mode 'mongolog-mode)
  (setq mode-name "MongoLog")
  (run-hooks mongolog-mode-hook))

(defun mongolog-get-selected-string ()
  "Return selected string or word at point."
  (if (use-region-p)
      (buffer-substring-no-properties
       (region-beginning) (region-end))
    (word-at-point)))

(defun mongolog-track ()
  "Show only lines contain selected string or word at point."
  (interactive)
  (hide-lines-not-matching (mongolog-get-selected-string)))

(defun mongolog-hide ()
  "Hide lines contain selected string or word at point."
  (interactive)
  (hide-lines-matching (mongolog-get-selected-string)))
  
(provide 'mongolog)
;;; mongolog.el ends here
