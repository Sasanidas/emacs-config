(setq lisp-simple-loop-indentation 1
      lisp-loop-keyword-indentation 6
      lisp-loop-forms-indentation 6
      blink-matching-paren nil)

(show-paren-mode 1)

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

(require 'paredit nil t)
(require 'redshank nil t)

(defmacro parens (mode)
  `(add-hook ',mode (lambda ()
                      ,(if (featurep 'paredit)
                           '(paredit-mode))
                      ,(if (featurep 'redshank)
                           '(turn-on-redshank-mode)))))

(parens lisp-mode-hook)
(parens emacs-lisp-mode-hook)
(parens scheme-mode-hook)

(require-and-eval (slime slime)
  (defun load-slime ()
    (slime-setup '(slime-fancy slime-asdf slime-sbcl-exts))

    (setq
     lisp-indent-function 'common-lisp-indent-function
     slime-complete-symbol-function 'slime-fuzzy-complete-symbol
     slime-net-coding-system 'utf-8-unix
     slime-startup-animation nil
     slime-auto-connect 'always
     slime-auto-select-connection 'always
     common-lisp-hyperspec-root "/home/stas/doc/comp/lang/lisp/HyperSpec/"
     inferior-lisp-program "~/lisp/bin/sbcl"
     slime-complete-symbol*-fancy t
     slime-kill-without-query-p t
     slime-when-complete-filename-expand t))

  (load-slime)

  (defun reload-slime ()
    (interactive)
    (mapc (lambda (x)
            (let ((name (symbol-name x)))
              (if (string-match "^slime.+" name)
                  (load-library name))))
          features)
    (load-slime)
    (setq slime-protocol-version (slime-changelog-date)))

  (macrolet ((define-lisps (&rest lisps)
               `(progn
                  ,@(loop for lisp in lisps
                          for consp = (consp lisp)
                          for name = (if consp (car lisp) lisp)
                          for path = (or (and consp (second lisp)) (symbol-name name))
                          for coding = (when consp (third lisp))
                          collect `(defun ,name () (interactive)
                                          (slime ,path ',coding))))))

    (define-lisps (sbcl "~/lisp/bin/sbcl")
        (ecl nil iso-8859-1-unix)
      ccl clisp scl acl)))

;;; Scheme
(setq scheme-program-name "gosh"
      quack-default-program "gosh"
      scheme-mit-dialect nil
      quack-fontify-style 'emacs
      quack-global-menu-p nil
      quack-pretty-lambda-p t)

(require 'quack nil t)

(require-and-eval (lisppaste)
  (push '("http://paste\\.lisp\\.org/display" . lisppaste-browse-url)
        browse-url-browser-function))

;;; Clojure
(require-and-eval (clojur-mode clojure-mode)
  (require 'clojure-paredit))

(require-and-eval (swank-clojure swank-clojure)
  (setq swank-clojure-jar-path "/home/stas/clojure/clojure.jar"))
