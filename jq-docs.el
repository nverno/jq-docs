;;; jq-docs.el --- search jq docs -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;; Author: Noah Peart <noah.v.peart@gmail.com>
;; URL: https://github.com/nverno/jq-docs
;; Package-Requires: 
;; Created: 15 August 2023

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Search jq documentation in org-mode.
;;
;;; Code:

(eval-when-compile (require 'org))

(declare-function org-narrow-to-subtree "org")
(autoload 'outline-show-subtree "outline")
(autoload 'outline-show-all "outline")

(defvar jq-docs--dir
  (file-name-directory
   (cond (load-in-progress load-file-name)
         ((and (boundp 'byte-compile-current-file) byte-compile-current-file)
          byte-compile-current-file)
         (t (buffer-file-name)))))

(defvar jq-docs-org (expand-file-name "jq.org" jq-docs--dir))

(defvar jq-docs--sections nil)

(defun jq-docs--read-sections ()
  (car
   (read-from-string
    (concat
     "("
     (with-temp-buffer
       (call-process
        "jq" "sections.json" t nil
        "-r"
        ".|to_entries|map(\"(\\\"\\(.key)\\\" . \\\"\\(.value)\\\")\") | .[]")
       (buffer-string))
     ")"))))

(defun jq-docs-ensure (&optional sections)
  (let ((default-directory jq-docs--dir))
    (unless (file-exists-p jq-docs-org)
      (call-process "make" nil nil nil))
    (when (and sections (null jq-docs--sections))
      (setq jq-docs--sections (jq-docs--read-sections)))))


;;;###autoload
(defun jq-docs-search (section &optional href interactive)
  (interactive
   (progn (jq-docs-ensure 'sections)
          (list (cdr (assoc-string
                      (completing-read
                       "Search: " jq-docs--sections nil t (thing-at-point 'symbol))
                      jq-docs--sections))
                'href
                'interactive)))
  (unless interactive
    (jq-docs-ensure)
    (unless href
      (setq section (assoc-string section jq-docs--sections t))))
  (let ((section-id (concat "\\s-*:CUSTOM_ID: " (regexp-quote section) "\\s-*$"))
        (org-startup-folded nil)
        (org-hide-drawer-startup nil))
    (with-current-buffer (find-file-noselect jq-docs-org)
      (widen)
      (outline-show-all)
      (goto-char (point-min))
      (when (re-search-forward section-id)
        (org-narrow-to-subtree)
        (outline-show-subtree)
        (goto-char (point-min))
        (display-buffer (current-buffer))
        (current-buffer)))))


(provide 'jq-docs)
;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:
;;; jq-docs.el ends here
