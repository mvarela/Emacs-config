
(setq user-full-name "Martin Varela")
(setq user-mail-address "mvr.rennes@gmail.com")
(setq mvr-elisp-root "~/.emacs.d")

(add-to-list 'custom-theme-load-path (concat mvr-elisp-root "/src/djcb-elisp/themes/"))
(load-theme 'zenburn t)

(defun make-frame-transparent ()
  (interactive)
  (set-frame-parameter nil 'alpha '(75 70)))

(defun make-frame-opaque ()
  (interactive)
  (set-frame-parameter nil 'alpha '(100 100)))


(set-frame-parameter (selected-frame) 'alpha '(100 100))
(add-to-list 'default-frame-alist '(alpha 100 100))
(eval-when-compile (require 'cl))
(defun toggle-transparency ()
  (interactive)
  (if (/=
           (cadr (frame-parameter nil 'alpha))
           100)
          (make-frame-opaque)
          (make-frame-transparent)))

(defun print-to-pdf ()
  "Prints the current buffer to a pdf file"
  (interactive)
  (ps-spool-buffer-with-faces)
  (switch-to-buffer "*PostScript*")
  (write-file "/tmp/tmp.ps")
  (kill-buffer "tmp.ps")
  (setq cmd (concat "ps2pdf14 /tmp/tmp.ps " (buffer-name) ".pdf"))
  (shell-command cmd)
  (shell-command "rm /tmp/tmp.ps")
  (message (concat "Saved to:  " (buffer-name) ".pdf")))

(defun disable-print-headers ()  (interactive) (setq ps-print-header nil))
(defun enable-print-headers ()  (interactive) (setq ps-print-header 1))
(defun disable-color-printing ()  (interactive) (setq ps-print-color-p nil))
(defun enable-color-printing ()  (interactive) (setq ps-print-color-p 1))

(defun get-frame-max-lines ()
  (- 
   (/ 
    (* (- (display-pixel-height) 20) (frame-height)) 
    (frame-pixel-height))
   2))

(defun get-frame-max-cols ()
  (-
   (/
    (* (display-pixel-width) (frame-width))
    (frame-pixel-width)) 
   0  ))

(defun maximize-frame () 
  (interactive)
  (set-frame-position (selected-frame) 0 20)
  (set-frame-size (selected-frame) (get-frame-max-cols) (get-frame-max-lines)))

(defun half-frame-h ()
  (interactive)
  (set-frame-position (selected-frame) 0 20)
  (set-frame-size (selected-frame) (/ (get-frame-max-cols) 2) (get-frame-max-lines)))

(defun half-frame-v ()
  (interactive)
  (set-frame-position (selected-frame) 0 20)
  (set-frame-size (selected-frame) (get-frame-max-cols) (/ (get-frame-max-lines)
                                                         2)))

(defun halve-frame-h ()
  (interactive)
  (set-frame-position (selected-frame) 0 20)
  (set-frame-size (selected-frame) (/ (frame-width) 2) (frame-height)))

(defun halve-frame-v ()
  (interactive)
  (set-frame-position (selected-frame) 0 20)
  (set-frame-size (selected-frame) (frame-width) (/ (frame-height)
                                                   2)))

(maximize-frame)

(defun shrink-window-two-thirds ()
  (interactive)
  (shrink-window-horizontally (truncate (* (get-frame-max-cols) 0.20))))

(defun lorem ()
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Praesent libero orci, auctor sed, faucibus vestibulum, gravida vitae, arcu. Nunc posuere. Suspendisse potenti. Praesent in arcu ac nisl ultricies ultricies. Fusce eros. Sed pulvinar vehicula ante. Maecenas urna dolor, egestas vel, tristique et, porta eu, leo. Curabitur vitae sem eget arcu laoreet vulputate. Cras orci neque, faucibus et, rhoncus ac, venenatis ac, magna. Aenean eu lacus. Aliquam luctus facilisis augue. Nullam fringilla consectetuer sapien. Aenean neque augue, bibendum a, feugiat id, lobortis vel, nunc. Suspendisse in nibh quis erat condimentum pretium. Vestibulum tempor odio et leo. Sed sodales vestibulum justo. Cras convallis pellentesque augue. In eu magna. In pede turpis, feugiat pulvinar, sodales eget, bibendum consectetuer, magna. Pellentesque vitae augue."))

(defun org-extract-mm ()
  "Extracts the outline of an org-mode file and exports it as a Freemind mindmap"
  (interactive)
  (save-excursion
    (let ((t-name (concat (buffer-name) "-freemind.mm"))
          (target (get-buffer-create (concat (buffer-name) "-freemind.org"))) 
          (title (re-search-forward "^#\+.*[tT]itle" (point-max) t)))
      (if (not (null title))
          (progn (goto-char title)
                 (append-to-buffer target (line-beginning-position)(+ 1 (line-end-position)))))
      (goto-char (point-min))
      (while (re-search-forward "^\*" nil t nil)
        (append-to-buffer (get-buffer target) (line-beginning-position)(+ 1 (line-end-position))))
      (switch-to-buffer target)
      (write-file t-name nil)
      (org-freemind-from-org-mode (buffer-name) (concat "out-"(format-time-string "%Y-%m-%d-%H.%M.%S") t-name)))))

(defun mvr-org-latex-report-header ()
"Inserts custom packages to be used in org-mode LaTeX exports of a certain type"
(interactive)
(insert-string "
#+LATEX_HEADER: \\usepackage{float}
#+LATEX_HEADER: \\usepackage{amssymb,amsfonts,amsmath,latexsym,setspace}
#+LATEX_HEADER: \\usepackage{natbib,fancyhdr}
#+LATEX_HEADER: \\usepackage{pdflscape}
#+LATEX_HEADER: \\usepackage{mvrreport}
#+LATEX_HEADER: \\runningheads{}{RUNNING TITLE GOES HERE}\n"))

(defun mvr-latex-table-fit-to-page ()
  "Wrap the next tabular environment in a resizebox command, so that it does not spill out of the page"
  (interactive)
  (progn
    (re-search-forward "^[\t ]*[\\]begin[\t ]*{[\t ]*tabular" (point-max) t)
    (move-beginning-of-line nil)
    (insert "\\resizebox{\\textwidth}{!}{\n")
    (re-search-forward "[\\]end[\t ]*{[\t ]*tabular[\t ]*}" (point-max) t)
    (insert "}")
    ))

(global-highlight-changes-mode t)
(setq highlight-changes-visibility-initial-state nil)

(setq frame-title-format
  '("emacs%@" (:eval (system-name)) ": " (:eval (if (buffer-file-name)
                (abbreviate-file-name (buffer-file-name))
                  "%b")) " [%*]"))

(add-hook 'latex-mode-hook 'flyspell-mode)
(add-hook 'org-mode-hook 'flyspell-mode)

(starter-kit-load "starter-kit-haskell.org")

(load "haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-hook 'haskell-mode-hook 'turn-off-auto-fill)
(setq haskell-literate-default 'tex)
(add-to-list 'haskell-mode-hook '(auto-fill-mode -1))

(setq diary-file (concat mvr-elisp-root "/diary/diary"))
(setq org-agenda-include-diary t)
(setq org-agenda-files (file-expand-wildcards (concat mvr-elisp-root "/org-agenda-files/*.org")))

(require 'org-mac-iCal)
(setq org-agenda-custom-commands
      '(("I" "Import diary from iCal" agenda ""
         ((org-agenda-mode-hook
           (lambda ()
             (org-mac-iCal)))))))

(add-hook 'org-agenda-cleanup-fancy-diary-hook
          (lambda ()
            (goto-char (point-min))
            (save-excursion
              (while (re-search-forward "^[a-z]" nil t)
                (goto-char (match-beginning 0))
                (insert "0:00-24:00 ")))
            (while (re-search-forward "^ [a-z]" nil t)
              (goto-char (match-beginning 0))
              (save-excursion
                (re-search-backward "^[0-9]+:[0-9]+-[0-9]+:[0-9]+ " nil t))
              (insert (match-string 0)))))

(setq
  appt-message-warning-time 20 ;; warn 15 min in advance

  appt-display-mode-line t     ;; show in the modeline
  appt-display-format 'window) ;; use our func
(appt-activate 1)              ;; active appt (appointment notification)
(display-time)                 ;; time display is required for this...

 ;; update appt each time agenda opened

(add-hook 'org-finalize-agenda-hook 'org-agenda-to-appt)


(defun mvr-display-appt (minutes current-time msg)
  "Display appt messages"
  (let ((gmsg 
         (if (null (listp msg))
             (format "In %s minutes: \n\t%s" minutes msg )
             (format "In %s minutes: \n\t%s" 
                     (if (listp minutes) 
                         (car minutes)
                       (minutes)) 
                     (concat 
                      (mapconcat '(lambda (x) (identity x)) msg "\n\t" ) "\n")))))
    (growl "Reminder" gmsg)))

(setq appt-disp-window-function (function mvr-display-appt))

(setq org-ditaa-jar-path
          (concat mvr-elisp-root "/src/org/contrib/scripts/ditaa.jar"))

(org-babel-do-load-languages
 'org-babel-load-languages
  (cons '(gnuplot . t)
     org-babel-load-languages))

(org-babel-do-load-languages
'org-babel-load-languages
(cons '(org . t)
      org-babel-load-languages))

(setq org-startup-indented t)

(setq org-export-html-validation-link nil)

(ido-mode t)
(ido-everywhere 1)
(setq ido-enable-flex-matching t) ; fuzzy matching is a must have
(setq ido-enable-last-directory-history t) 
(setq ido-show-dot-for-dired t)
(setq ido-use-filename-at-point nil)

(smex-initialize)
(setq smex-save-file (concat mvr-elisp-root "/smex-persist/smex.history"))

(setq ido-create-new-buffer 'always)

(setq ido-file-extensions-order '(".org" ".tex" ".txt" ".hs" ".lhs" ".el" ".rb"
".cfg" ".c" ".h" ".html"))

(load "~/.ercpass.el")
   
(require 'erc-services)
(erc-services-mode 1)
(setq erc-prompt-for-nickserv-password nil)     
(setq erc-nickserv-passwords
       `((freenode     (("mvarela" . ,mvr-freenode-pass)))))

    
(require 'erc-join)
(erc-autojoin-mode 1)
(setq erc-autojoin-channels-alist
          '(("freenode.net" "#emacs" "#haskell")))
    
    
(require 'erc-match)
(setq erc-keywords '("mvarela"))
(erc-match-mode)
    
(require 'erc-track)
(erc-track-mode t) ; was (erc-track-modified-channels-mode t)
                       ; Note: erc-track-modified-channels-mode changed
                       ; to erc-track-mode as of erc-track.el
                       ; CVS revision 1.23 (November 2002)
    
(add-hook 'erc-mode-hook
          '(lambda ()
              (require 'erc-pcomplete)
              (pcomplete-erc-setup)
              (erc-completion-mode 1)))
    
(require 'erc-fill)
(erc-fill-mode t)
    
(require 'erc-ring)
(erc-ring-mode t)
    
(require 'erc-netsplit)
(erc-netsplit-mode t)
    
(erc-timestamp-mode t)
(setq erc-timestamp-format "[%R-%m/%d]")
    
(erc-button-mode t) ;slow
(erc-readonly-mode nil)
(setq erc-user-full-name "Martin Varela")
(setq erc-email-userid "mvr.rennes@gmail.com")
    
    
(setq erc-log-insert-log-on-open nil)
(setq erc-log-channels nil)
(setq erc-log-channels-directory "~/.irclogs/")
(setq erc-save-buffer-on-part nil)
(setq erc-hide-timestamps nil)
    
    
(defadvice save-buffers-kill-emacs (before save-logs (arg) activate)
  (save-some-buffers t (lambda () (when (and (eq major-mode 'erc-mode)
                                             (not (null buffer-file-name)))))))
    
(add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)
(add-hook 'erc-mode-hook '(lambda () (when (not (featurep 'xemacs))
                                       (set (make-variable-buffer-local
                                             'coding-system-for-write)
                                             'emacs-mule))))
;; end logging
    
;; Truncate buffers so they don't hog core.
(setq erc-max-buffer-size 20000)
(defvar erc-insert-post-hook)
(add-hook 'erc-insert-post-hook 'erc-truncate-buffer)
(setq erc-truncate-buffer-on-save t)
    
    
;; Clears out annoying erc-track-mode stuff for when we don't care.
;; Useful for when ChanServ restarts :P
(defun reset-erc-track-mode ()
  (interactive)
  (setq erc-modified-channels-alist nil)
  (erc-modified-channels-update))
(global-set-key (kbd "C-c r") 'reset-erc-track-mode)
    
    
;;; Finally, connect to the networks.
(defun irc-maybe ()
  "Connect to IRC."
  (interactive)
  (when (y-or-n-p "IRC? ")
    (erc :server "irc.freenode.net" :port 6667
                :nick "mvarela" :full-name "Martin Varela")))

(add-to-list 'auto-mode-alist '("\\.gnup$" . gnuplot-mode))

(eval-after-load "ispell"
   (progn
     (setq ispell-dictionary "en_US"
           ispell-extra-args '("-a" "-c" )
           ispell-silently-savep t
 )))
  (setq-default ispell-program-name "aspell")

(setq reftex-plug-into-AUCTeX t)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

(custom-set-variables '(TeX-command-list 
   (quote (
           ("XeLaTeX_SyncteX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX
   nil (latex-mode doctex-mode) :help "Run XeLaTeX") 
           ("XeLaTeX_NonStop" "%`xelatex --interaction=nonstopmode%' %t" TeX-run-TeX nil (latex-mode doctex-mode) :help "Run XeLaTeX") 
           ("TeX" "%(PDF)%(tex) %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (plain-tex-mode texinfo-mode ams-tex-mode) :help "Run plain TeX") 
           ("LaTeX" "%`%l%(mode)%' %t" TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX") 
           ("Makeinfo" "makeinfo %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with Info output") 
           ("Makeinfo HTML" "makeinfo --html %t" TeX-run-compile nil (texinfo-mode) :help "Run Makeinfo with HTML output") 
           ("AmSTeX" "%(PDF)amstex %`%S%(PDFout)%(mode)%' %t" TeX-run-TeX nil (ams-tex-mode) :help "Run AMSTeX") 
           ("ConTeXt" "texexec --once --texutil %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt once") 
           ("ConTeXt Full" "texexec %(execopts)%t" TeX-run-TeX nil (context-mode) :help "Run ConTeXt until completion") 
           ("BibTeX" "bibtex %s" TeX-run-BibTeX nil t :help "Run BibTeX") 
           ("View" "%V" TeX-run-discard-or-function nil t :help "Run Viewer") 
           ("Print" "%p" TeX-run-command t t :help "Print the file") 
           ("Queue" "%q" TeX-run-background nil t :help "View the printer queue" :visible TeX-queue-command) 
           ("File" "%(o?)dvips %d -o %f " TeX-run-command t t :help "Generate PostScript file") 
           ("Index" "makeindex %s" TeX-run-command nil t :help "Create index file") 
           ("Check" "lacheck %s" TeX-run-compile nil (latex-mode) :help "Check LaTeX file for correctness") 
           ("Spell" "(TeX-ispell-document \"\")" TeX-run-function nil t :help "Spell-check the document") 
           ("Clean" "TeX-clean" TeX-run-function nil t :help "Delete generated intermediate files") 
           ("Clean All" "(TeX-clean t)" TeX-run-function nil t :help "Delete generated intermediate and output files") 
           ("Other" "" TeX-run-command t t :help "Run an arbitrary command") 
           ("Jump to PDF" "%V" TeX-run-discard-or-function nil t :help "Run Viewer")))))


(custom-set-variables
 '(LaTeX-command "latex -synctex=1")
 '(TeX-view-program-list (quote (("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline %n %o %b") ("Preview" "open -a Preview.app %o"))))
)
(setq TeX-source-correlate-method 'synctex)
(add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)

(setq reftex-toc-split-windows-horizontally t)

(add-hook 'text-mode-hook 'orgtbl-mode)

(require 'textlint)
(require 'artbollocks-mode)

(add-hook 'prog-mode-hook 'which-func-mode)

(setq gnus-select-method '(nnimap "gmail"
                                  (nnimap-address "imap.gmail.com")
                                  (nnimap-server-port 993)
                                  (nnimap-stream ssl)))

(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials '(("smtp.gmail.com" 587 "mvr.rennes@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

(setq gnus-thread-sort-functions
      '((not gnus-thread-sort-by-date) gnus-thread-sort-by-author))

(setq gnus-article-sort-functions
      '((not gnus-article-sort-by-date) gnus-article-sort-by-author))

(setq eshell-prompt-function
  (lambda ()
    (concat 
     (format-time-string "<%H:%M:%S> [" (current-time))
     (eshell/whoami)
     "]: "
     (eshell/pwd)
     "\n"
      (if (= (user-uid) 0) "# " "$ "))))

(set-default 'fill-column 80)

(setq truncate-lines t)
(setq truncate-partial-width-windows nil)

(setq column-number-mode t)

(setq savehist-file (concat mvr-elisp-root "/history"))

(when (fboundp 'toggle-scroll-bar)
  (toggle-scroll-bar -1))

(global-auto-revert-mode t)

(visual-line-mode t)
(add-hook 'text-mode-hook 'visual-line-mode)

(starter-kit-load "ruby")
;;(starter-kit-load "lisp")
;;(starter-kit-load "misc-recommended")
(starter-kit-load "org")

(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1))

(menu-bar-mode -1)

(add-hook 'after-save-hook
  'executable-make-buffer-file-executable-if-script-p)

(setq confirm-nonexistent-file-or-buffer nil)

(require 'growl)

;;(if (eq system-type 'darwin) (funcall (lambda ()(setenv "PATH" (concat "/opt/local/bin:/usr/local/bin:" (getenv "PATH"))) (push "/opt/local/bin" exec-path))))
(if (eq system-type 'darwin) (progn (setenv "PATH" (concat
"/opt/local/bin:/usr/local/bin:/usr/texbin/:" (getenv "PATH"))) (append
(list "/opt/local/bin" "/usr/local/bin" "/usr/texbin/" "/Users/mvr/bin")
exec-path)
(setq exec-path (append
(list "/opt/local/bin" "/usr/local/bin" "/usr/texbin/" "/Users/mvr/bin")
exec-path))))

(defun ns-raise-emacs ()
  (ns-do-applescript "tell application \"Emacs\" to activate"))

(setq ns-command-modifier (quote meta))

(setq browse-url-browser-function 'browse-default-macosx-browser)

(setq ns-pop-up-frames nil)

(server-start)

(global-set-key (kbd "C-c v") 'clipboard-yank)
(global-set-key (kbd "C-c c") 'clipboard-kill-ring-save)

(global-set-key (kbd "M-g") 'goto-line)

(global-set-key (kbd "C-w") 'backward-kill-word)
(global-set-key (kbd "C-c w") 'kill-region)

(global-set-key (kbd "M-p") 'print-to-pdf)

(defun zone-on ()
  (interactive)
  (zone-when-idle 60))
  (global-set-key (kbd "C-x M-z") 'zone-on)

;; Map the window manipulation keys to meta 0, 1, 2, o
(global-set-key (kbd "M-3") 'split-window-horizontally) ; was digit-argument
(global-set-key (kbd "M-2") 'split-window-vertically) ; was digit-argument
(global-set-key (kbd "M-1") 'delete-other-windows) ; was digit-argument
(global-set-key (kbd "M-0") 'delete-window) ; was digit-argument
(global-set-key (kbd "M-o") 'other-window) ; was facemenu-keymap
;; Replace dired's M-o
(add-hook 'dired-mode-hook (lambda () (define-key dired-mode-map (kbd "M-o") 'other-window))) ; was dired-omit-mode
;; Replace ibuffer's M-o
(add-hook 'ibuffer-mode-hook (lambda () (define-key ibuffer-mode-map (kbd "M-o") 'other-window))) ; was ibuffer-visit-buffer-1-window
(windmove-default-keybindings 'meta)

(global-set-key (kbd "C-x t") 'toggle-transparency)

(global-set-key (kbd "C-|") 'maximize-frame)
(global-set-key (kbd "C->") 'halve-frame-h)
(global-set-key (kbd "C-<") 'halve-frame-v)

(defun orgtbl-latex-keys ()
 (progn 
    (define-key LaTeX-mode-map (kbd "C-c C-t i") 'orgtbl-insert-radio-table)
    (define-key LaTeX-mode-map (kbd "C-c C-t s") 'orgtbl-send-table)))

(add-hook 'LaTeX-mode-hook 'orgtbl-latex-keys)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

(global-set-key (kbd "C-M-'") 'comment-or-uncomment-region)
