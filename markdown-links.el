;;; markdown-links.el --- insert Markdown links from various sources -*- lexical-binding: t; -*-
;;
;; Author: Andreas Jonsson <ajdev8@gmail.com>
;; Maintainer: Andreas Jonsson <ajdev8@gmail.com>
;; URL: https://github.com/sonofjon/markdown-links.el
;; Version: 0.1
;; Package-Requires: ((emacs "30.1") (markdown-mode "2.7"))
;; Keywords: markdown, links, convenience
;;
;;; Commentary:
;;
;; This small library provides a single helper and five interactive
;; commands to insert Markdown inline links from different sources:
;;  - files on disk
;;  - open buffers
;;  - project files
;;  - git-tracked files
;;  - dired marked files
;;
;; All commands delegate to `markdown-links-insert-links`, which
;; inserts one inline link per file, using the file’s basename as
;; link text.
;;
;; Usage:
;;
;;   (use-package markdown-links
;;     :load-path "/path/to/where/you/put/markdown-links.el"
;;     :commands (markdown-links-insert-from-files
;;                markdown-links-insert-from-buffers
;;                markdown-links-insert-from-project
;;                markdown-links-insert-from-git
;;                markdown-links-insert-from-dired))
;;
;;; Code:

(require 'markdown-mode)
(require 'project)
(require 'vc)             ; for vc-git-root
(require 'seq)            ; for seq-filter

;;;###autoload
(defun markdown-links-insert-links (files &optional buffer)
  "Insert Markdown links for each element of FILES.
FILES is a list of file paths.  For each link, the link text is the
filename (basename of the path).  If BUFFER is non-nil, insert into that
buffer, otherwise into `current-buffer`."
  (let ((target (or buffer (current-buffer))))
    (with-current-buffer target
      (unless (derived-mode-p 'markdown-mode)
        (user-error "Buffer %S is not a Markdown buffer" target))
      (dolist (f files)
        (let ((text (file-name-nondirectory f)))
          (markdown-insert-inline-link text f))
        (insert "\n")))))

;;;###autoload
(defun markdown-links-insert-from-files ()
  "Prompt for a file and insert a Markdown link to it at point."
  (interactive)
  (let ((file (read-file-name "Insert link to file: ")))
    (markdown-links-insert-links (list file))))

;;;###autoload
(defun markdown-links-insert-from-buffers ()
  "Prompt for a buffer and insert a Markdown link to its associated file."
  (interactive)
  (let* ((buffers (delq nil (mapcar #'buffer-file-name (buffer-list))))
         (file (completing-read "Insert link to buffer file: "
                                  buffers nil t)))
    (markdown-links-insert-links (list file))))

;;;###autoload
(defun markdown-links-insert-from-project ()
  "Insert Markdown links for all files in the current project."
  (interactive)
  (let ((proj (project-current t)))
    (unless proj
      (user-error "No project detected"))
    (let ((files (project-files proj)))
      (markdown-links-insert-links files))))

;;;###autoload
(defun markdown-links-insert-from-git ()
  "Insert Markdown links for all files tracked by Git in this repository."
  (interactive)
  (let ((root (vc-git-root default-directory)))
    (unless root
      (user-error "Not inside a Git repository"))
    (let* ((default-directory root)
           (files (split-string
                   (shell-command-to-string "git ls-files")
                   "\n" t))
           (paths (mapcar (lambda (f) (expand-file-name f root)) files)))
      (markdown-links-insert-links paths))))


;;;###autoload
(defun markdown-links-insert-from-dired ()
  "In Dired, insert Markdown links for marked files (or file at point).
If any marked item is a directory, optionally recurse into it.
Then prompt for a target buffer and insert links at point."
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "Must be in Dired"))
  (let* ((files (dired-get-marked-files))
         (dirs (seq-filter #'file-directory-p files))
         (recurse (and dirs
                       (y-or-n-p
                        (format "Recurse into %d director%s? "
                                (length dirs)
                                (if (= (length dirs) 1) "" "ies")))))
         (all-files
          (apply #'append
                 (mapcar (lambda (f)
                           (if (and recurse (file-directory-p f))
                               (directory-files-recursively f ".*")
                             (list f)))
                         files)))
         (target (read-buffer "Insert links into buffer: "
                              (other-buffer (current-buffer) t))))
    (with-current-buffer target
      (markdown-links-insert-links all-files target))))

(provide 'markdown-links)
;;; markdown-links.el ends here
