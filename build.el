;; Batch run stuff

(setq debug-on-error t)

(setq package-dir
      (concat
       (file-name-directory
        (or (buffer-file-name)
            load-file-name))
       ".elpa"))

(setq package-user-dir package-dir)

(when (file-exists-p package-dir)
  (delete-directory package-dir t))

(setq package-archives
      '(("localcache" . "/home/nferrier/elpacache")
        ("gnu" . "http://elpa.gnu.org/packages/")
        ("marmalade" . "http://marmalade-repo.org/packages/")))

(package-initialize)
(package-refresh-contents)

(let ((nicblogmake (concat
                    (file-name-directory
                     (or (buffer-file-name)
                         load-file-name))
                    "nicblog-make.el")))
  (package-install-file nicblogmake))

(require 'nicblog-make)
(nicblog-make-run (nicblog-make-root-maker "blog"))

;; End
