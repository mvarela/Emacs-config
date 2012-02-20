
(setq user-full-name "Martin Varela")
(setq user-mail-address (
                         if (string= (system-name) "mvr-cnl") 
                            "martin.varela@vtt.fi" 
                          "mvr.rennes@gmail.com"))
(setq mvr-elisp-root "~/.emacs.d")

;(add-to-list 'custom-theme-load-path (concat mvr-elisp-root "/src/djcb-elisp/themes/"))
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
#+LATEX_HEADER: \\runningheads{}{RUNNING TITLE GOES HERE}\n
#+LATEX_HEADER: \\hypersetup{bookmarks=true, unicode=true, pdfstartview={FitH}, pdftitle={TITLE GOES HERE}, pdfauthor={Martín Varela}, pdfsubject={SUBJECT GOES HERE}, pdfkeywords={KW1} {KW2},pdfnewwindow=true, colorlinks=true}\n"))

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
;     (add-to-list 'haskell-mode-hook '(auto-fill-mode -1))

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

(setq org-export-latex-default-packages-alist  '(("" "fixltx2e" nil)
                                                 ("" "graphicx" t)
                                                 ("" "longtable" nil)
                                                 ("" "float" nil)
                                                 ("" "wrapfig" nil)
                                                 ("" "soul" t)
                                                 ("" "textcomp" t)
                                                 ("" "marvosym" t)
                                                 ("" "wasysym" t)
                                                 ("" "latexsym" t)
                                                 ("" "amssymb" t)
                                                 ("" "fontspec" t)
                                                 ("" "natbib" t)
                                                 ("" "fancyhdr" t)
                                                 "\\tolerance=1000"))

(require 'org-google-weather)
(setq org-google-weather-icon-directory (concat mvr-elisp-root "/src/google-weather-el/icons/"))

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

(add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
(setq TeX-source-correlate-method 'synctex)
(add-hook 'LaTeX-mode-hook (lambda ()
(add-to-list 'TeX-expand-list
               '("%q" skim-make-url))))
(defun skim-make-url () (concat
                (TeX-current-line)
                " "
                (expand-file-name (funcall file (TeX-output-extension) t)
                        (file-name-directory (TeX-master-file)))
                " "
                (buffer-file-name)))
(setq TeX-view-program-list '(("Okular" "okular --unique %u") ("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline %q")))
(if (eq system-type 'darwin)
    (setq TeX-view-program-selection '((output-pdf "Skim"))))

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
     "@"
     (system-name)
     "]: "
     (eshell/pwd)
     "\n"
      (if (= (user-uid) 0) "# " "$ "))))

(autoload 'forth-mode "gforth.el")
(autoload 'forth-block-mode "gforth.el")
(add-to-list 'auto-mode-alist '("\\.fs$" . forth-mode))

(require 'breadcrumb)

(require 'expand-region)

(require 'cl)
(defun fill-keymap (keymap &rest mappings)
  "Fill `KEYMAP' with `MAPPINGS'.
See `pour-mappings-to'."
  (pour-mappings-to keymap mappings))

(defun pour-mappings-to (map mappings)
  "Calls `cofi/set-key' with `map' on every key-fun pair in `MAPPINGS'.
`MAPPINGS' is a list of string-fun pairs, with a `READ-KBD-MACRO'-readable string and a interactive-fun."
  (dolist (mapping (group mappings 2))
    (cofi/set-key map (car mapping) (cadr mapping)))
  map)

(defun cofi/set-key (map spec cmd)
  "Set in `map' `spec' to `cmd'.

`Map' may be `'global' `'local' or a keymap.
A `spec' can be a `read-kbd-macro'-readable string or a vector."
  (let ((setter-fun (case map
                      (global #'global-set-key)
                      (local  #'local-set-key)
                      (t      (lambda (key def) (define-key map key def)))))
        (key (typecase spec
               (vector spec)
               (string (read-kbd-macro spec))
               (t (error "wrong argument")))))
    (funcall setter-fun key cmd)))

(defun group (lst n)
  "Group `LST' into portions of `N'."
  (let (groups)
    (while lst
      (push (take n lst) groups)
      (setq lst (nthcdr n lst)))
    (nreverse groups)))

(defun take (n lst)
  "Return atmost the first `N' items of `LST'."
  (let (acc '())
    (while (and lst (> n 0))
      (decf n)
      (push (car lst) acc)
      (setq  lst (cdr lst)))
    (nreverse acc)))

(require 'evil-numbers)
  (setq evil-leader/leader ",")
  (require 'evil-leader)
  (require 'evil)
  (evil-mode 1)
  (fill-keymap evil-normal-state-map
               "+"     'evil-numbers/inc-at-pt
               "-"     'evil-numbers/dec-at-pt
               "SPC"   'ace-jump-char-mode
               "S-SPC" 'ace-jump-word-mode
               "C-SPC" 'ace-jump-line-mode
               "go"    'goto-char
               "C-t"   'transpose-chars
               "M-t"   'transpose-words 
               "C-:"   'eval-expression)
  
  (fill-keymap evil-motion-state-map
               "_"     'evil-first-non-blank
               "C-e"   'end-of-line
               "C-S-d" 'evil-scroll-up
               "C-S-f" 'evil-scroll-page-up
               "_"     'evil-first-non-blank
               "C-y"   nil)
  
  (fill-keymap evil-insert-state-map
               "C-e" 'end-of-line)
(evil-declare-key 'normal org-mode-map
  (kbd "RET") 'org-open-at-point
  "za"        'org-cycle
  "zA"        'org-shifttab
  "zm"        'hide-body
  "zr"        'show-all
  "zo"        'show-subtree
  "zO"        'show-all
  "zc"        'hide-subtree
  "zC"        'hide-all
  (kbd "M-j") 'org-shiftleft
  (kbd "M-k") 'org-shiftright
  (kbd "M-H") 'org-metaleft
  (kbd "M-J") 'org-metadown
  (kbd "M-K") 'org-metaup
  (kbd "M-L") 'org-metaright)

(evil-declare-key 'insert org-mode-map
  (kbd "M-j") 'org-shiftleft
  (kbd "M-k") 'org-shiftright
  (kbd "M-H") 'org-metaleft
  (kbd "M-J") 'org-metadown
  (kbd "M-K") 'org-metaup
  (kbd "M-L") 'org-metaright)  
  

(evil-leader/set-key
  "b" 'ido-switch-buffer
  "m" 'compile
  "g" 'magit-status)

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

(global-set-key (kbd "M-]") 'bc-set)
(global-set-key (kbd "M-[") 'bc-previous)

(global-set-key (kbd "C-{") 'er/expand-region)
