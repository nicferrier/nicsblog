;;; nicblog-make.el --- Make nic's blog

;;; Copyright (C) 2012 by Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Maintainer: Nic Ferrier <nferrier@ferrier.me.uk>
;; Created: 28th March 2012
;; Version: 0.0.1
;; Package-Requires: ((creole "0.8.4"))
;; Keywords: lisp, creole, wiki

;; This file is NOT part of GNU Emacs.

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

;; This is a set of functions to build a static version of Nic's blog
;; using his WikiCreole wiki parser. WikiCreole is something like the
;; Wiki language used by OddMuse, which is the EmacsWiki wiki
;; language.

;;; Code:

(require 'creole)

;; This walk stuff pinched from the emacs lisp cookbook, though I had
;; to alter it for some reason.
(defun nicblog-make-walk-path (dir action)
  "walk DIR executing ACTION with (dir file)"
  (cond ((file-directory-p dir)
         (or (char-equal ?/ (aref dir(1- (length dir))))
             (setq dir (file-name-as-directory dir)))
         (let ((lst (directory-files dir nil nil t))
               fullname file)
           (while lst
             (setq file (car lst))
             (setq lst (cdr lst))
             (cond ((member file '("." "..")))
                   ((and file (file-directory-p (concat dir file)))
                    (nicblog-make-walk-path (concat dir file) action))
                   (t
                    (funcall action dir file))))))
        (t
         (funcall action
                  (file-name-directory dir)
                  (file-name-nondirectory dir)))))

(defun nicblog-make-walk-path-visitor (dir file)
  "Make HTML from the creole we find."
  (when (equal (file-name-extension file) "creole")
    (let ((html (expand-file-name
                     (concat
                      dir
                      (file-name-sans-extension file)
                      ".html"))))
      (let ((wikibuf
             (creole-wiki
              (concat dir file)
              :destination html
              :docroot "/~nferrier/nics-blog"
              :css "/~nferrier/nics-blog/stuff/css/site.css"
              :body-header "~/work/nics-blog/template/headerhtml"
              :body-footer "~/work/nics-blog/template/footerhtml")))
        (with-current-buffer wikibuf
          (condition-case nil
              (delete-file html)
            (error nil))
          (write-file html))
        (kill-buffer wikibuf)))))

(defun nicblog-make-root-maker (dir)
  "Make a path based on the load-path and the DIR."
  (expand-file-name
   (concat
    (file-name-directory
     (or (buffer-file-name)
         load-file-name))
    dir)))

(defun nicblog-make-run (&optional root)
  "Run the blog make.

ROOT is an optionally specified root to creolize everything."
  (interactive "D")
  (when (not root)
    (setq root (nicblog-make-root-maker "blog")))
  (nicblog-make-walk-path
   root
   'nicblog-make-walk-path-visitor))

(provide 'nicblog-make)

;;; nicblog-make.el ends here
