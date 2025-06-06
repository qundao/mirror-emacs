;;; perl-mode.el --- Perl code editing commands for GNU Emacs  -*- lexical-binding:t -*-

;; Copyright (C) 1990, 1994, 2001-2025 Free Software Foundation, Inc.

;; Author: William F. Mann
;; Maintainer: emacs-devel@gnu.org
;; Adapted-By: ESR
;; Keywords: languages

;; Adapted from C code editing commands 'c-mode.el', Copyright 1987 by the
;; Free Software Foundation, under terms of its General Public License.

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; To enter `perl-mode' automatically, change the first line of your
;; perl script to:
;; #!/usr/bin/perl --	 # -*-Perl-*-
;; With arguments to perl:
;; #!/usr/bin/perl -P-	 # -*-Perl-*-
;; To handle files included with do 'filename.pl';, add something like
;; (setq auto-mode-alist (append (list (cons "\\.pl\\'" 'perl-mode))
;;                               auto-mode-alist))
;; to your init file; otherwise the .pl suffix defaults to prolog-mode.

;; This code is based on the 18.53 version c-mode.el, with extensive
;; rewriting.  Most of the features of c-mode survived intact.

;; I added a new feature which adds functionality to TAB; it is controlled
;; by the variable perl-tab-to-comment.  With it enabled, TAB does the
;; first thing it can from the following list:  change the indentation;
;; move past leading white space; delete an empty comment; reindent a
;; comment; move to end of line; create an empty comment; tell you that
;; the line ends in a quoted string, or has a # which should be a \#.

;; I also tuned a few things:  comments and labels starting in column
;; zero are left there by perl-indent-exp; perl-beginning-of-function
;; goes back to the first open brace/paren in column zero, the open brace
;; in 'sub ... {', or the equal sign in 'format ... ='; perl-indent-exp
;; (meta-^q) indents from the current line through the close of the next
;; brace/paren, so you don't need to start exactly at a brace or paren.

;; It may be good style to put a set of redundant braces around your
;; main program.  This will let you reindent it with meta-^q.

;; Known problems (these are all caused by limitations in the Emacs Lisp
;; parsing routine (parse-partial-sexp), which was not designed for such
;; a rich language; writing a more suitable parser would be a big job):
;; 2)  The globbing syntax <pattern> is not recognized, so special
;;       characters in the pattern string must be backslashed.
;;
;; Here are some ugly tricks to bypass some of these problems:  the perl
;; expression /`/ (that's a back-tick) usually evaluates harmlessly,
;; but will trick perl-mode into starting a quoted string, which
;; can be ended with another /`/.  Assuming you have no embedded
;; back-ticks, this can used to help solve problem 3:
;;
;;     /`/; $ugly = q?"'$?; /`/;
;;
;; The same trick can be used for problem 6 as in:
;;     /{/; while (<${glob_me}>)
;; but a simpler solution is to add a space between the $ and the {:
;;     while (<$ {glob_me}>)
;;
;; Problem 7 is even worse, but this 'fix' does work :-(
;;     $DB'stop#'
;;         [$DB'line#'
;;          ] =~ s/;9$//;

;;; Code:

(eval-when-compile (require 'cl-lib))

(defgroup perl nil
  "Major mode for editing Perl code."
  :link '(custom-group-link :tag "Font Lock Faces group" font-lock-faces)
  :prefix "perl-"
  :group 'languages)

(defface perl-non-scalar-variable
  '((t :inherit font-lock-variable-name-face :underline t))
  "Face used for non-scalar variables."
  :version "28.1")

(define-abbrev-table 'perl-mode-abbrev-table ()
  "Abbrev table in use in perl-mode buffers.")

(defvar-keymap perl-mode-map
  :doc "Keymap used in Perl mode."
  "C-M-a" #'perl-beginning-of-function
  "C-M-e" #'perl-end-of-function
  "C-M-h" #'perl-mark-function
  "C-M-q" #'perl-indent-exp
  "DEL"   #'backward-delete-char-untabify)

(defvar perl-mode-syntax-table
  (let ((st (make-syntax-table (standard-syntax-table))))
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?# "<" st)
    ;; `$' is also a prefix char so I was tempted to say "/ p",
    ;; but the `p' thingy basically overrides the `/' :-(   -- Stef
    (modify-syntax-entry ?$ "/" st)
    (modify-syntax-entry ?% ". p" st)
    (modify-syntax-entry ?@ ". p" st)
    (modify-syntax-entry ?& "." st)
    (modify-syntax-entry ?\' "\"" st)
    (modify-syntax-entry ?* "." st)
    (modify-syntax-entry ?+ "." st)
    (modify-syntax-entry ?- "." st)
    (modify-syntax-entry ?/ "." st)
    (modify-syntax-entry ?< "." st)
    (modify-syntax-entry ?= "." st)
    (modify-syntax-entry ?> "." st)
    (modify-syntax-entry ?\\ "\\" st)
    (modify-syntax-entry ?` "\"" st)
    (modify-syntax-entry ?| "." st)
    st)
  "Syntax table in use in `perl-mode' buffers.")

(defvar perl-imenu-generic-expression
  '(;; Functions
    (nil "^[ \t]*sub\\s-+\\([-[:alnum:]+_:]+\\)" 1)
    ;;Variables
    ("Variables" "^[ \t]*\\(?:has\\|local\\|my\\|our\\|state\\)\\s-+\\([$@%][-[:alnum:]+_:]+\\)\\s-*=" 1)
    ("Packages" "^[ \t]*package\\s-+\\([-[:alnum:]+_:]+\\);" 1)
    ("Doc sections" "^=head[0-9][ \t]+\\(.*\\)" 1))
  "Imenu generic expression for Perl mode.  See `imenu-generic-expression'.")

;; Regexps updated with help from Tom Tromey <tromey@cambric.colorado.edu> and
;; Jim Campbell <jec@murzim.ca.boeing.com>.

(defconst perl--prettify-symbols-alist
  '(("->"  . ?→)
    ("=>"  . ?⇒)
    ("::" . ?∷)))

(defconst perl-font-lock-keywords-1
  '(;; What is this for?
    ;;("\\(--- .* ---\\|=== .* ===\\)" . font-lock-string-face)
    ;;
    ;; Fontify preprocessor statements as we do in `c-font-lock-keywords'.
    ;; Ilya Zakharevich <ilya@math.ohio-state.edu> thinks this is a bad idea.
    ;; ("^#[ \t]*include[ \t]+\\(<[^>\"\n]+>\\)" 1 font-lock-string-face)
    ;; ("^#[ \t]*define[ \t]+\\(\\sw+\\)(" 1 font-lock-function-name-face)
    ;; ("^#[ \t]*if\\>"
    ;;  ("\\<\\(defined\\)\\>[ \t]*(?\\(\\sw+\\)?" nil nil
    ;;   (1 font-lock-constant-face) (2 font-lock-variable-name-face nil t)))
    ;; ("^#[ \t]*\\(\\sw+\\)\\>[ \t]*\\(\\sw+\\)?"
    ;;  (1 font-lock-constant-face) (2 font-lock-variable-name-face nil t))
    ;;
    ;; Fontify function and package names in declarations.
    ("\\<\\(package\\|sub\\)\\>[ \t]*\\(\\(?:\\sw\\|::\\)+\\)?"
     (1 'font-lock-keyword-face) (2 'font-lock-function-name-face nil t))
    ("\\(?:^\\|[^$@%&\\]\\)\\<\\(import\\|no\\|require\\|use\\)\\>[ \t]*\\(\\(?:\\sw\\|::\\)+\\)?"
     (1 'font-lock-keyword-face) (2 'font-lock-constant-face nil t)))
  "Subdued level highlighting for Perl mode.")

(defconst perl-font-lock-keywords-2
  (append
   '(;; Fontify function, variable and file name references. They have to be
     ;; handled first because they might conflict with keywords.
     ("&\\(\\sw+\\(::\\sw+\\)*\\)" 1 'font-lock-function-name-face)
     ;; Additionally fontify non-scalar variables.  `perl-non-scalar-variable'
     ;; will underline them by default.
     ("[$*]{?\\(\\sw+\\(::\\sw+\\)*\\)" 1 'font-lock-variable-name-face)
     ("\\([@%]\\|\\$#\\)\\(\\sw+\\(::\\sw+\\)*\\)"
      (2 'perl-non-scalar-variable)))
   perl-font-lock-keywords-1
   `( ;; Fontify keywords, except those fontified otherwise.
     ,(concat "\\<"
              (regexp-opt '("if" "until" "while" "elsif" "else" "unless"
                            "do" "dump" "for" "foreach" "exit" "die"
                            "BEGIN" "END" "return" "exec" "eval"
                            "when" "given" "default")
                          t)
              "\\>")
     ;;
     ;; Fontify declarators and prefixes as types.
     ("\\<\\(has\\|local\\|my\\|our\\|state\\)\\>" . 'font-lock-keyword-face) ; declarators
     ("<\\(\\sw+\\)>" 1 'font-lock-constant-face)
     ;;
     ;; Fontify keywords with/and labels as we do in `c++-font-lock-keywords'.
     ("\\<\\(continue\\|goto\\|last\\|next\\|redo\\)\\>[ \t]*\\(\\sw+\\)?"
      (1 'font-lock-keyword-face) (2 'font-lock-constant-face nil t))
     ("^[ \t]*\\(\\sw+\\)[ \t]*:[^:]" 1 'font-lock-constant-face)))
  "Gaudy level highlighting for Perl mode.")

(defvar perl-font-lock-keywords perl-font-lock-keywords-1
  "Default expressions to highlight in Perl mode.")

(defvar perl-quote-like-pairs
  '((?\( . ?\)) (?\[ . ?\]) (?\{ . ?\}) (?\< . ?\>)))

(eval-and-compile
  (defconst perl--syntax-exp-intro-keywords
    '("split" "if" "unless" "until" "while" "print" "printf"
      "grep" "map" "not" "or" "and" "for" "foreach" "return" "die"
      "warn" "eval"))

  (defconst perl--syntax-exp-intro-regexp
    (concat "\\(?:\\(?:^\\|[^$@&%[:word:]]\\)"
            (regexp-opt perl--syntax-exp-intro-keywords)
            ;; A HERE document as an argument to printf?
            ;; when printing to a filehandle.
            "\\|printf?[ \t]*\\$?[_[:alpha:]][_[:alnum:]]*"
            "\\|=>"
            "\\|[?:.,;|&*=!~({[]"
            "\\|[^-+][-+]"    ;Bug#42168: `+' is intro but `++' isn't!
            "\\|\\(^\\)\\)[ \t\n]*"))

  (defconst perl--format-regexp "^[ \t]*format.*=[ \t]*\\(\n\\)"
  "Regexp to match the start of a format declaration."))

(defun perl-syntax-propertize-function (start end)
  (let ((case-fold-search nil))
    (goto-char start)
    (perl-syntax-propertize-special-constructs end)
    (funcall
     (syntax-propertize-rules
      ;; Turn POD into b-style comments.  Place the cut rule first since it's
      ;; more specific.
      ("^=cut\\>.*\\(\n\\)" (1 "> b"))
      ("^\\(=\\)\\sw" (1 "< b"))
      ;; Catch ${ so that ${var} doesn't screw up indentation.
      ;; This also catches $' to handle 'foo$', although it should really
      ;; check that it occurs inside a '..' string.
      ("\\(\\$\\)[{']" (1 (unless (and (eq ?\' (char-after (match-end 1)))
                                       (save-excursion
                                         (not (nth 3 (syntax-ppss
                                                      (match-beginning 0))))))
                            (string-to-syntax ". p"))))
      ;; If "\" is acting as a backslash operator, it shouldn't start an
      ;; escape sequence, so change its syntax.  This allows us to handle
      ;; correctly the \() construct (Bug#11996) as well as references
      ;; to string values.
      ("\\(\\\\\\)['`\"($]" (1 (unless (nth 3 (syntax-ppss))
                                 (string-to-syntax "."))))
      ;; A "$" in Perl code must escape the next char to protect against
      ;; misinterpreting Perl's punctuation variables as unbalanced
      ;; quotes or parens.  This is not needed in strings and broken in
      ;; the special case of "$\"" (Bug#69604).  Make "$" a punctuation
      ;; char in strings.
      ("\\$" (0 (if (save-excursion
                      (nth 3 (syntax-ppss (match-beginning 0))))
                    (string-to-syntax ".")
                  (string-to-syntax "/"))))
      ;; Handle funny names like $DB'stop.
      ("\\$ ?{?\\^?[_[:alpha:]][_[:alnum:]]*\\('\\)[_[:alpha:]]" (1 "_"))
      ;; format statements
      (perl--format-regexp
       (1 (prog1 "\"" (perl-syntax-propertize-special-constructs end))))
      ;; Propertize perl prototype chars `$%&*;+@\[]' as punctuation
      ;; in `sub' arg-specs like `sub myfun ($)' and `sub ($)'.  But
      ;; don't match subroutine signatures like `sub add ($a, $b)', or
      ;; anonymous subs like "sub { (...) ... }".
      ("\\<sub\\(?:[\s\t\n]+\\(?:\\sw\\|\\s_\\)+\\)?[\s\t\n]*(\\([][$%&*;+@\\]+\\))"
       (1 "."))
      ;; Turn __DATA__ trailer into a comment.
      ("^\\(_\\)_\\(?:DATA\\|END\\)__[ \t]*\\(?:\\(\n\\)#.-\\*-.*perl.*-\\*-\\|\n.*\\)"
       (1 "< c") (2 "> c")
       (0 (ignore (put-text-property (match-beginning 0) (match-end 0)
                                     'syntax-multiline t))))
      ;; Regexp and funny quotes.  Distinguishing a / that starts a regexp
      ;; match from the division operator is ...interesting.
      ;; Basically, / is a regexp match if it's preceded by an infix operator
      ;; (or some similar separator), or by one of the special keywords
      ;; corresponding to builtin functions that can take their first arg
      ;; without parentheses.  Of course, that presume we're looking at the
      ;; *opening* slash.  We can afford to mismatch the closing ones
      ;; here, because they will be re-treated separately later in
      ;; perl-font-lock-special-syntactic-constructs.
      ((concat perl--syntax-exp-intro-regexp "\\(/\\)")
       (2 (ignore
           (if (and (match-end 1)       ; / at BOL.
                    (save-excursion
                      (goto-char (match-end 1))
                      (forward-comment (- (point-max)))
                      (put-text-property (point) (match-end 2)
                                         'syntax-multiline t)
                      (not (or (and (eq ?w (char-syntax (preceding-char)))
                                    (let ((end (point)))
                                      (backward-sexp 1)
                                      (member (buffer-substring (point) end)
                                              perl--syntax-exp-intro-keywords)))
                               (bobp)
                               (memq (char-before)
                                     '(?? ?: ?. ?, ?\; ?= ?! ?~ ?\( ?\[))))))
               nil ;; A division sign instead of a regexp-match.
             (put-text-property (match-beginning 2) (match-end 2)
                                'syntax-table (string-to-syntax "\""))
             (perl-syntax-propertize-special-constructs end)))))
      ("\\(^\\|[?:.,;=|&!~({[ \t]\\|=>\\)\\([msy]\\|q[qxrw]?\\|tr\\)\\>\\(?:\\s-\\|\n\\)*\\(?:\\([^])}>= \n\t]\\)\\|\\(?3:=\\)[^>]\\)"
       ;; Nasty cases:
       ;; /foo/m  $a->m  $#m $m @m %m
       ;; \s (appears often in regexps).
       ;; -s file
       ;; y => 3
       ;; sub tr {...}
       (3 (ignore
           (if (save-excursion (goto-char (match-beginning 0))
                               (forward-word-strictly -1)
                               (looking-at-p "sub[ \t\n]"))
               ;; This is defining a function.
               nil
             (unless (nth 8 (save-excursion (syntax-ppss (match-beginning 1))))
               ;; Don't add this syntax-table property if
               ;; within a string, which would misbehave in cases such as
               ;; $a = "foo y \"toto\" bar" where we'd end up changing the
               ;; syntax of the backslash and hence de-escaping the embedded
               ;; double quote.
               (let* ((b3 (match-beginning 3))
                      (c (char-after b3)))
                 (put-text-property
                  b3 (match-end 3) 'syntax-table
                  (cond
                   ((assoc c perl-quote-like-pairs)
                    (string-to-syntax "|"))
                   ;; If the separator is a normal quote and the operation
                   ;; only takes a single arg, then there's nothing
                   ;; special to do.
                   ((and (memq c '(?\" ?\'))
                         (memq (char-after (match-beginning 2)) '(?m ?q)))
                    nil)
                   (t
                    (string-to-syntax "\"")))))
               (perl-syntax-propertize-special-constructs end))))))
      ;; Here documents.
      ((concat
        "\\(?:"
        ;; << "EOF", << 'EOF', or << \EOF
        "<<\\(~\\)?[ \t]*\\('[^'\n]*'\\|\"[^\"\n]*\"\\|\\\\[[:alpha:]][[:alnum:]]*\\)"
        ;; The <<EOF case which needs perl--syntax-exp-intro-regexp, to
        ;; disambiguate with the left-bitshift operator.
        "\\|" perl--syntax-exp-intro-regexp "<<\\(?1:~\\)?\\(?2:\\sw+\\)\\)"
        ".*\\(\n\\)")
       (4 (let* ((eol (match-beginning 4))
                 (st (get-text-property eol 'syntax-table))
                 (name (match-string 2))
                 (indented (match-beginning 1)))
            (goto-char (match-end 2))
            (if (save-excursion (nth 8 (syntax-ppss (match-beginning 0))))
                ;; '<<' occurred in a string, or in a comment.
                ;; Leave the property of the newline unchanged.
                st
              ;; Beware of `foo <<'BAR' #baz` because
              ;; the newline needs to start the here-doc
              ;; and can't be used to close the comment.
              (let ((eol-state (save-excursion (syntax-ppss eol))))
                (when (nth 4 eol-state)
                  (if (/= (1- eol) (nth 8 eol-state))
                      ;; make the last char of the comment closing it
                      (put-text-property (1- eol) eol
                                         'syntax-table (string-to-syntax ">"))
                    ;; In `foo <<'BAR' #` the # is the last character
                    ;; before eol and can't both open and close the
                    ;; comment.  Workaround: disguise the "#" as
                    ;; whitespace and fontify it as a comment.
                    (put-text-property (1- eol) eol
                                       'syntax-table (string-to-syntax "-"))
                    (put-text-property (1- eol) eol
                                       'font-lock-face
                                       'font-lock-comment-face))))
              (cons (car (string-to-syntax "< c"))
                    ;; Remember the names of heredocs found on this line.
                    (cons (cons (pcase (aref name 0)
                                  (?\\ (substring name 1))
                                  ((or ?\" ?\' ?\`) (substring name 1 -1))
                                  (_ name))
                                indented)
                          (cdr st)))))))
      ;; We don't call perl-syntax-propertize-special-constructs directly
      ;; from the << rule, because there might be other elements (between
      ;; the << and the \n) that need to be propertized.
      ("\\(?:$\\)\\s<"
       (0 (ignore (perl-syntax-propertize-special-constructs end))))
      )
     (point) end)))

(defvar perl-empty-syntax-table
  (let ((st (copy-syntax-table)))
    ;; Make all chars be of punctuation syntax.
    (dotimes (i 256) (aset st i '(1)))
    (modify-syntax-entry ?\\ "\\" st)
    st)
  "Syntax table used internally for processing quote-like operators.")

(defun perl-quote-syntax-table (char)
  (let ((close (cdr (assq char perl-quote-like-pairs)))
	(st (copy-syntax-table perl-empty-syntax-table)))
    (if (not close)
	(modify-syntax-entry char "\"" st)
      (modify-syntax-entry char "(" st)
      (modify-syntax-entry close ")" st))
    st))

(defun perl-syntax-propertize-special-constructs (limit)
  "Propertize special constructs like regexps and formats."
  (let ((state (syntax-ppss))
        char)
    (cond
     ((eq 2 (nth 7 state))
      ;; A Here document.
      (let ((names (cdr (get-text-property (nth 8 state) 'syntax-table))))
        (when (cdr names)
          (setq names (reverse names))
          ;; Multiple heredocs on a single line, we have to search from the
          ;; beginning, since we don't know which names might be
          ;; before point.
          (goto-char (nth 8 state)))
        (while (and names
                    (re-search-forward
                     (pcase-let ((`(,name . ,indented) (pop names)))
                       (concat "^" (if indented "[ \t]*")
                               (regexp-quote name) "\n"))
                     limit 'move))
          (unless names
            (put-text-property (1- (point)) (point) 'syntax-table
                               (string-to-syntax "> c"))))))
     ((or (null (setq char (nth 3 state)))
          (and (characterp char)
               (null (get-text-property (nth 8 state) 'syntax-table))))
      ;; Normal text, or comment, or docstring, or normal string.
      nil)
     ((eq (nth 3 state) ?\n)
      ;; A `format' command.
      (when (re-search-forward "^\\s *\\.\\s *\n" limit 'move)
        (put-text-property (1- (point)) (point)
                           'syntax-table (string-to-syntax "\""))))
     (t
      ;; This is regexp like quote thingy.
      (setq char (char-after (nth 8 state)))
      (let ((startpos (point))
            (twoargs (save-excursion
                       (goto-char (nth 8 state))
                       (skip-syntax-backward " ")
                       (skip-syntax-backward "w")
                       (member (buffer-substring
                                (point) (progn (forward-word-strictly 1)
                                               (point)))
                               '("tr" "s" "y"))))
            (close (cdr (assq char perl-quote-like-pairs)))
            (middle nil)
            (st (perl-quote-syntax-table char)))
        (when (with-syntax-table st
		(if close
		    ;; For paired delimiters, Perl allows nesting them, but
		    ;; since we treat them as strings, Emacs does not count
		    ;; those delimiters in `state', so we don't know how deep
		    ;; we are: we have to go back to the beginning of this
		    ;; "string" and count from there.
		    (condition-case nil
			(progn
			  ;; Start after the first char since it doesn't have
			  ;; paren-syntax (an alternative would be to let-bind
			  ;; parse-sexp-lookup-properties).
			  (goto-char (1+ (nth 8 state)))
			  (up-list 1)
			  t)
                      ;; In case of error, make sure we don't move backward.
		      (scan-error (goto-char startpos) nil))
		  (not (or (nth 8 (parse-partial-sexp
				   ;; Since we don't know if point is within
				   ;; the first or the second arg, we have to
				   ;; start from the beginning.
				   (if twoargs (1+ (nth 8 state)) (point))
				   limit nil nil state 'syntax-table))
			   ;; If we have a self-paired opener and a twoargs
			   ;; command, the form is s/../../ so we have to skip
			   ;; a second time.
			   ;; In the case of s{...}{...}, we only handle the
			   ;; first part here and the next below.
			   (when (and twoargs (not close))
			     (setq middle (point))
			     (nth 8 (parse-partial-sexp
				     (point) limit
				     nil nil state 'syntax-table)))))))
	  ;; Point is now right after the arg(s).
	  (when (eq (char-before (1- (point))) ?$)
	    (put-text-property (- (point) 2) (1- (point))
			       'syntax-table '(1)))
	  (if (and middle (memq char '(?\" ?\')))
	      (put-text-property (1- middle) middle
			     'syntax-table '(1))
	    (put-text-property (1- (point)) (point)
			       'syntax-table
			       (if close
				   (string-to-syntax "|")
				 (string-to-syntax "\""))))
	  ;; If we have two args with a non-self-paired starter (e.g.
	  ;; s{...}{...}) we're right after the first arg, so we still have to
	  ;; handle the second part.
	  (when (and twoargs close)
	    ;; Skip whitespace and make sure that font-lock will
	    ;; refontify the second part in the proper context.
	    (put-text-property
	     (point) (progn (forward-comment (point-max)) (point))
	     'syntax-multiline t)
	    ;;
	    (when (< (point) limit)
	      (put-text-property (point) (1+ (point))
				 'syntax-table
				 (if (assoc (char-after)
					    perl-quote-like-pairs)
                                     ;; Put an `e' in the cdr to mark this
                                     ;; char as "second arg starter".
				     (string-to-syntax "|e")
				   (string-to-syntax "\"e")))
	      (forward-char 1)
	      ;; Reuse perl-syntax-propertize-special-constructs to handle the
	      ;; second part (the first delimiter of second part can't be
	      ;; preceded by "s" or "tr" or "y", so it will not be considered
	      ;; as twoarg).
	      (perl-syntax-propertize-special-constructs limit)))))))))

(defface perl-heredoc
  '((t (:inherit font-lock-string-face)))
  "The face for here-documents.  Inherits from `font-lock-string-face'.")

(defun perl-font-lock-syntactic-face-function (state)
  (cond
   ((and (eq 2 (nth 7 state)) ; c-style comment
         (cdr-safe (get-text-property (nth 8 state) 'syntax-table))) ; HERE doc
    'perl-heredoc)
   ((and (nth 3 state)
         (eq ?e (cdr-safe (get-text-property (nth 8 state) 'syntax-table)))
         ;; This is a second-arg of s{..}{...} form; let's check if this second
         ;; arg is executable code rather than a string.  For that, we need to
         ;; look for an "e" after this second arg, so we have to hunt for the
         ;; end of the arg.  Depending on whether the whole arg has already
         ;; been syntax-propertized or not, the end-char will have different
         ;; syntaxes, so let's ignore syntax-properties temporarily so we can
         ;; pretend it has not been syntax-propertized yet.
         (let* ((parse-sexp-lookup-properties nil)
                (char (char-after (nth 8 state)))
                (paired (assq char perl-quote-like-pairs)))
           (with-syntax-table (perl-quote-syntax-table char)
             (save-excursion
               (if (not paired)
                   (parse-partial-sexp (point) (point-max)
                                       nil nil state 'syntax-table)
                 (condition-case nil
                     (progn
                       (goto-char (1+ (nth 8 state)))
                       (up-list 1))
                   (scan-error (goto-char (point-max)))))
               (put-text-property (nth 8 state) (point)
                                  'jit-lock-defer-multiline t)
               (looking-at "[ \t]*\\sw*e")))))
    nil)
   (t (funcall (default-value 'font-lock-syntactic-face-function) state))))

(defcustom perl-indent-level 4
  "Indentation of Perl statements with respect to containing block."
  :type 'integer)

;; It is not unusual to put both things like perl-indent-level and
;; cperl-indent-level in the local variable section of a file. If only
;; one of perl-mode and cperl-mode is in use, a warning will be issued
;; about the variable. Autoload these here, so that no warning is
;; issued when using either perl-mode or cperl-mode.
;;;###autoload(put 'perl-indent-level 'safe-local-variable 'integerp)
;;;###autoload(put 'perl-continued-statement-offset 'safe-local-variable 'integerp)
;;;###autoload(put 'perl-continued-brace-offset 'safe-local-variable 'integerp)
;;;###autoload(put 'perl-brace-offset 'safe-local-variable 'integerp)
;;;###autoload(put 'perl-brace-imaginary-offset 'safe-local-variable 'integerp)
;;;###autoload(put 'perl-label-offset 'safe-local-variable 'integerp)

(defcustom perl-continued-statement-offset 4
  "Extra indent for lines not starting new statements."
  :type 'integer)
(defcustom perl-continued-brace-offset -4
  "Extra indent for substatements that start with open-braces.
This is in addition to `perl-continued-statement-offset'."
  :type 'integer)
(defcustom perl-brace-offset 0
  "Extra indentation for braces, compared with other text in same context."
  :type 'integer)
(defcustom perl-brace-imaginary-offset 0
  "Imagined indentation of an open brace that actually follows a statement."
  :type 'integer)
(defcustom perl-label-offset -2
  "Offset of Perl label lines relative to usual indentation."
  :type 'integer)
(defcustom perl-indent-continued-arguments nil
  "If non-nil offset of argument lines relative to usual indentation.
If nil, continued arguments are aligned with the first argument."
  :type '(choice integer (const nil)))

(defcustom perl-indent-parens-as-block nil
  "Non-nil means that non-block ()-, {}- and []-groups are indented as blocks.
The closing bracket is aligned with the line of the opening bracket,
not the contents of the brackets."
  :version "24.3"
  :type 'boolean)

(defcustom perl-tab-always-indent tab-always-indent
  "Non-nil means TAB in Perl mode always indents the current line.
Otherwise it inserts a tab character if you type it past the first
nonwhite character on the line."
  :type 'boolean)

;; I changed the default to nil for consistency with general Emacs
;; conventions -- rms.
(defcustom perl-tab-to-comment nil
  "Non-nil means TAB moves to eol or makes a comment in some cases.
For lines which don't need indenting, TAB either indents an
existing comment, moves to end-of-line, or if at end-of-line already,
create a new comment."
  :type 'boolean)

(defcustom perl-nochange "\f"
  "Lines starting with this regular expression are not auto-indented."
  :type 'regexp
  :options '(";?#\\|\f\\|\\s(\\|\\(\\w\\|\\s_\\)+:[^:]"))

;; Outline support

(defvar perl-outline-regexp
  (concat (mapconcat #'cadr perl-imenu-generic-expression "\\|")
	  "\\|^=cut\\>"))

(defun perl-outline-level ()
  (cond
   ((looking-at "[ \t]*\\(package\\)\\s-")
    (- (match-beginning 1) (match-beginning 0)))
   ((looking-at "[ \t]*s\\(ub\\)\\s-")
    (- (match-beginning 1) (match-beginning 0)))
   ((looking-at "=head[0-9]") (- (char-before (match-end 0)) ?0))
   ((looking-at "=cut") 1)
   (t 3)))

(defun perl-current-defun-name ()
  "The `add-log-current-defun' function in Perl mode."
  (save-excursion
    (if (re-search-backward "^sub[ \t]+\\([^({ \t\n]+\\)" nil t)
	(match-string-no-properties 1))))


;;; Flymake support
(defcustom perl-flymake-command '("perl" "-w" "-c")
  "External tool used to check Perl source code.
This is a non-empty list of strings: the checker tool possibly
followed by required arguments.  Once launched it will receive
the Perl source to be checked as its standard input."
  :version "26.1"
  :type '(repeat string))

(defvar-local perl--flymake-proc nil)

;;;###autoload
(defun perl-flymake (report-fn &rest _args)
  "Perl backend for Flymake.
Launch `perl-flymake-command' (which see) and pass to its
standard input the contents of the current buffer.  The output of
this command is analyzed for error and warning messages."
  (unless (executable-find (car perl-flymake-command))
    (error "Cannot find a suitable checker"))

  (when (process-live-p perl--flymake-proc)
    (kill-process perl--flymake-proc))

  (let ((source (current-buffer)))
    (save-restriction
      (widen)
      (setq
       perl--flymake-proc
       (make-process
        :name "perl-flymake" :noquery t :connection-type 'pipe
        :buffer (generate-new-buffer " *perl-flymake*")
        :command perl-flymake-command
        :sentinel
        (lambda (proc _event)
          (when (eq 'exit (process-status proc))
            (unwind-protect
                (if (with-current-buffer source (eq proc perl--flymake-proc))
                    (with-current-buffer (process-buffer proc)
                      (goto-char (point-min))
                      (cl-loop
                       while (search-forward-regexp
                              "^\\(.+\\) at - line \\([0-9]+\\)"
                              nil t)
                       for msg = (match-string 1)
                       for (beg . end) = (flymake-diag-region
                                          source
                                          (string-to-number (match-string 2)))
                       for type =
                       (if (string-match
                            "\\(Scalar value\\|Useless use\\|Unquoted string\\)"
                            msg)
                           :warning
                         :error)
                       collect (flymake-make-diagnostic source
                                                        beg
                                                        end
                                                        type
                                                        msg)
                       into diags
                       finally (funcall report-fn diags)))
                  (flymake-log :debug "Canceling obsolete check %s"
                               proc))
              (kill-buffer (process-buffer proc)))))))
      (process-send-region perl--flymake-proc (point-min) (point-max))
      (process-send-eof perl--flymake-proc))))


(defvar perl-mode-hook nil
  "Normal hook to run when entering Perl mode.")

;;;###autoload
(define-derived-mode perl-mode prog-mode "Perl"
  "Major mode for editing Perl code.
Expression and list commands understand all Perl brackets.
Tab indents for Perl code.
Comments are delimited with # ... \\n.
Paragraphs are separated by blank lines only.
Delete converts tabs to spaces as it moves back.
\\{perl-mode-map}
Variables controlling indentation style:
 `perl-tab-always-indent'
    Non-nil means TAB in Perl mode should always indent the current line,
    regardless of where in the line point is when the TAB command is used.
 `perl-tab-to-comment'
    Non-nil means that for lines which don't need indenting, TAB will
    either delete an empty comment, indent an existing comment, move
    to end-of-line, or if at end-of-line already, create a new comment.
 `perl-nochange'
    Lines starting with this regular expression are not auto-indented.
 `perl-indent-level'
    Indentation of Perl statements within surrounding block.
    The surrounding block's indentation is the indentation
    of the line on which the open-brace appears.
 `perl-continued-statement-offset'
    Extra indentation given to a substatement, such as the
    then-clause of an if or body of a while.
 `perl-continued-brace-offset'
    Extra indentation given to a brace that starts a substatement.
    This is in addition to `perl-continued-statement-offset'.
 `perl-brace-offset'
    Extra indentation for line if it starts with an open brace.
 `perl-brace-imaginary-offset'
    An open brace following other text is treated as if it were
    this far to the right of the start of its line.
 `perl-label-offset'
    Extra indentation for line that is a label.
 `perl-indent-continued-arguments'
    Offset of argument lines relative to usual indentation.

Various indentation styles:       K&R  BSD  BLK  GNU  LW
  perl-indent-level                5    8    0    2    4
  perl-continued-statement-offset  5    8    4    2    4
  perl-continued-brace-offset      0    0    0    0   -4
  perl-brace-offset               -5   -8    0    0    0
  perl-brace-imaginary-offset      0    0    4    0    0
  perl-label-offset               -5   -8   -2   -2   -2

Turning on Perl mode runs the normal hook `perl-mode-hook'."
  :abbrev-table perl-mode-abbrev-table
  (setq-local paragraph-start (concat "$\\|" page-delimiter))
  (setq-local paragraph-separate paragraph-start)
  (setq-local paragraph-ignore-fill-prefix t)
  (setq-local indent-line-function #'perl-indent-line)
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(^\\|\\s-\\);?#+ *")
  (setq-local comment-indent-function #'perl-comment-indent)
  (setq-local parse-sexp-ignore-comments t)

  ;; Tell font-lock.el how to handle Perl.
  (setq font-lock-defaults '((perl-font-lock-keywords
                              perl-font-lock-keywords-1
                              perl-font-lock-keywords-2)
                             nil nil ((?\_ . "w")) nil
                             (font-lock-syntactic-face-function
                              . perl-font-lock-syntactic-face-function)))
  (setq-local prettify-symbols-alist perl--prettify-symbols-alist)
  (setq-local syntax-propertize-function #'perl-syntax-propertize-function)
  (add-hook 'syntax-propertize-extend-region-functions
            #'syntax-propertize-multiline 'append 'local)
  ;; Electricity.
  ;; FIXME: setup electric-layout-rules.
  (setq-local electric-indent-chars
	      (append '(?\{ ?\} ?\; ?\:) electric-indent-chars))
  (add-hook 'electric-indent-functions #'perl-electric-noindent-p nil t)
  ;; Tell imenu how to handle Perl.
  (setq-local imenu-generic-expression perl-imenu-generic-expression)
  (setq imenu-case-fold-search nil)
  ;; Setup outline-minor-mode.
  (setq-local outline-regexp perl-outline-regexp)
  (setq-local outline-level 'perl-outline-level)
  (setq-local add-log-current-defun-function #'perl-current-defun-name)
  ;; Setup Flymake
  (add-hook 'flymake-diagnostic-functions #'perl-flymake nil t))

;; This is used by indent-for-comment
;; to decide how much to indent a comment in Perl code
;; based on its context.
(defun perl-comment-indent ()
  (if (and (bolp) (not (eolp)))
      0					;Existing comment at bol stays there.
    comment-column))

(defun perl-electric-noindent-p (_char)
  ;; To reproduce the old behavior, ;, {, }, and : are made electric, but
  ;; we only want them to be electric at EOL.
  (unless (or (bolp) (eolp)) 'no-indent))

(defun perl-electric-terminator (arg)
  "Insert character and maybe adjust indentation.
If at end-of-line, and not in a comment or a quote, correct the indentation."
  (interactive "P")
  (let ((insertpos (point)))
    (and (not arg)			; decide whether to indent
	 (eolp)
	 (save-excursion
	   (beginning-of-line)
	   (and (not			; eliminate comments quickly
		 (and comment-start-skip
		      (re-search-forward comment-start-skip insertpos t)) )
		(or (/= last-command-event ?:)
		    ;; Colon is special only after a label ....
		    (looking-at "\\s-*\\(\\w\\|\\s_\\)+$"))
		(let ((pps (parse-partial-sexp
			    (perl-beginning-of-function) insertpos)))
		  (not (or (nth 3 pps) (nth 4 pps) (nth 5 pps))))))
	 (progn				; must insert, indent, delete
	   (insert-char last-command-event 1)
	   (perl-indent-line)
	   (delete-char -1))))
  (self-insert-command (prefix-numeric-value arg)))
(make-obsolete 'perl-electric-terminator 'electric-indent-mode "24.4")

;; not used anymore, but may be useful someday:
;;(defun perl-inside-parens-p ()
;;  (condition-case ()
;;      (save-excursion
;;	(save-restriction
;;	  (narrow-to-region (point)
;;			    (perl-beginning-of-function))
;;	  (goto-char (point-max))
;;	  (= (char-after (or (scan-lists (point) -1 1) (point-min))) ?\()))
;;    (error nil)))

(defun perl-indent-command (&optional arg)
  "Indent Perl code in the active region or current line.
In Transient Mark mode, when the region is active, reindent the region.
Otherwise, with a prefix argument, reindent the current line
unconditionally.

Otherwise, if `perl-tab-always-indent' is nil and point is not in
the indentation area at the beginning of the line, insert a tab.

Otherwise, indent the current line.  If point was within the
indentation area, it is moved to the end of the indentation area.
If the line was already indented properly and point was not
within the indentation area, and if `perl-tab-to-comment' is
non-nil (the default), then do the first possible action from the
following list:

  1) delete an empty comment
  2) move forward to start of comment, indenting if necessary
  3) move forward to end of line
  4) create an empty comment
  5) move backward to start of comment, indenting if necessary."
  (interactive "P")
  (cond ((use-region-p)            ; indent the active region
	 (indent-region (region-beginning) (region-end)))
	(arg
	 (perl-indent-line "\f"))  ; just indent this line
	((and (not perl-tab-always-indent)
	      (> (current-column) (current-indentation)))
	 (insert-tab))
	(t
	 (let* ((oldpnt (point))
		(lsexp (progn (beginning-of-line) (point)))
		(bof (perl-beginning-of-function))
		(delta (progn
			 (goto-char oldpnt)
			 (perl-indent-line "\f\\|;?#"))))
	   (and perl-tab-to-comment
		(= oldpnt (point))   ; done if point moved
		(if (listp delta)    ; if line starts in a quoted string
		    (setq lsexp (or (nth 2 delta) bof))
		  (= delta 0))	     ; done if indenting occurred
		(let ((eol (progn (end-of-line) (point)))
		      state)
		  (cond ((= (char-after bof) ?=)
			 (if (= oldpnt eol)
			     (message "In a format statement")))
			((progn (setq state (parse-partial-sexp lsexp eol))
				(nth 3 state))
			 (if (= oldpnt eol) ; already at eol in a string
			     (message "In a string which starts with a %c."
				      (nth 3 state))))
			((not (nth 4 state))
			 (if (= oldpnt eol) ; no comment, create one?
			     (indent-for-comment)))
			((progn (beginning-of-line)
				(and comment-start-skip
				     (re-search-forward
				      comment-start-skip eol 'move)))
			 (if (eolp)
			     (progn	    ; delete existing comment
			       (goto-char (match-beginning 0))
			       (skip-chars-backward " \t")
			       (delete-region (point) eol))
			   (if (or (< oldpnt (point)) (= oldpnt eol))
			       (indent-for-comment) ; indent existing comment
			     (end-of-line))))
			((/= oldpnt eol)
			 (end-of-line))
			(t
			 (message "Use backslash to quote # characters.")
			 (ding t)))))))))
(make-obsolete 'perl-indent-command 'indent-according-to-mode "24.4")

(defun perl-indent-line (&optional nochange)
  "Indent current line as Perl code.
Return the amount the indentation
changed by, or (parse-state) if line starts in a quoted string."
  (let ((case-fold-search nil)
	(pos (- (point-max) (point)))
	beg indent shift-amt)
    (beginning-of-line)
    (setq beg (point))
    (setq shift-amt
	  (cond ((eq 1 (nth 7 (syntax-ppss))) 0) ;For doc sections!
		((listp (setq indent (perl-calculate-indent))) indent)
                ((eq 'noindent indent) indent)
		((looking-at (or nochange perl-nochange)) 0)
		(t
		 (skip-chars-forward " \t\f")
		 (setq indent (perl-indent-new-calculate nil indent))
		 (- indent (current-column)))))
    (skip-chars-forward " \t\f")
    (if (and (numberp shift-amt) (/= 0 shift-amt))
	(progn (delete-region beg (point))
	       (indent-to indent)))
    ;; If initial point was within line's indentation,
    ;; position after the indentation.  Else stay at same point in text.
    (if (> (- (point-max) pos) (point))
	(goto-char (- (point-max) pos)))
    shift-amt))

(defun perl--end-of-format-p ()
  "Non-nil if point is at the end of a format declaration, skipping whitespace."
  (save-excursion
    (skip-chars-backward " \t\n")
    (beginning-of-line)
    (when-let* ((comm (and (looking-at "^\\.$")
                           (nth 8 (syntax-ppss)))))
      (goto-char comm)
      (beginning-of-line)
      (looking-at perl--format-regexp))))

(defun perl-continuation-line-p ()
  "Move to end of previous line and return non-nil if continued."
  ;; Statement level.  Is it a continuation or a new statement?
  ;; Find previous non-comment character.
  (perl-backward-to-noncomment)
  ;; Back up over label lines, since they don't
  ;; affect whether our line is a continuation.
  (while (and (eq (preceding-char) ?:)
              (memq (char-syntax (char-after (- (point) 2)))
                    '(?w ?_)))
    (beginning-of-line)
    (perl-backward-to-noncomment))
  ;; Now we get the answer.
  (unless (or (memq (preceding-char) '(?\; ?\} ?\{))
              (perl--end-of-format-p))
    (preceding-char)))

(defun perl-hanging-paren-p ()
  "Non-nil if we are right after a hanging parenthesis-like char."
  (and (looking-at "[ \t]*\\(?:#.*\\)?$")
       (save-excursion
	 (skip-syntax-backward " (") (not (bolp)))))

(defun perl-indent-new-calculate (&optional virtual default)
  (or
   (and virtual (save-excursion (skip-chars-backward " \t") (bolp))
	(current-column))
   (and (looking-at "\\(\\w\\|\\s_\\)+:[^:]")
	(max 1 (+ (or default (perl-calculate-indent))
		  perl-label-offset)))
   (and (= (char-syntax (following-char)) ?\))
	(save-excursion
	  (forward-char 1)
          (when (condition-case nil (progn (forward-sexp -1) t)
                  (scan-error nil))
            (perl-indent-new-calculate 'virtual))))
   (and (and (= (following-char) ?{)
	     (save-excursion (forward-char) (perl-hanging-paren-p)))
	(+ (or default (perl-calculate-indent))
	   perl-brace-offset))
   (or default (perl-calculate-indent))))

(defun perl-calculate-indent ()
  "Return appropriate indentation for current line as Perl code.
In usual case returns an integer: the column to indent to.
Returns (parse-state) if line starts inside a string."
  (save-excursion
    (let* ((indent-point (point))
	   (case-fold-search nil)
	   (colon-line-end 0)
           prev-char
	   (state (syntax-ppss))
	   (containing-sexp (nth 1 state))
	   ;; Don't auto-indent in a quoted string or a here-document.
           (unindentable (or (nth 3 state) (eq 2 (nth 7 state))))
           (format (and (nth 3 state)
                        (char-equal (nth 3 state) ?\n))))
      (when (and (eq t (nth 3 state))
                 (save-excursion
                   (goto-char (nth 8 state))
                   (looking-back "qw[ \t]*" (- (point) 4))))
        ;; qw(...) is a list of words so the spacing is not meaningful,
        ;; and makes indentation possible (and desirable).
        (setq unindentable nil)
        (setq containing-sexp (nth 8 state)))
      (cond
       (unindentable (if format 0 'noindent))
       ((null containing-sexp)          ; Line is at top level.
        (skip-chars-forward " \t\f")
        (if (memq (following-char)
                  (if perl-indent-parens-as-block '(?\{ ?\( ?\[) '(?\{)))
            0          ; move to beginning of line if it starts a function body
          ;; indent a little if this is a continuation line
          (perl-backward-to-noncomment)
          (if (or (bobp)
                  (memq (preceding-char) '(?\; ?\}))
                  (perl--end-of-format-p))
              0 perl-continued-statement-offset)))
       ((/= (char-after containing-sexp) ?{)
        ;; line is expression, not statement:
        ;; indent to just after the surrounding open.
        (goto-char (1+ containing-sexp))
        (if (perl-hanging-paren-p)
            ;; We're indenting an arg of a call like:
            ;;    $a = foobarlongnamefun (
            ;;             arg1
            ;;             arg2
            ;;         );
            (progn
              ;; Go just before the open paren (don't rely on the
              ;; skip-syntax-backward to jump over it, because it could
              ;; have string-fence syntax instead!).
              (goto-char containing-sexp)
              (skip-syntax-backward "(") ;FIXME: Not sure if still want this.
              (condition-case nil
                  (while (save-excursion
                           (skip-syntax-backward " ") (not (bolp)))
                    (forward-sexp -1))
                (scan-error nil))
              (+ (current-column) perl-indent-level))
          (if perl-indent-continued-arguments
              (+ perl-indent-continued-arguments (current-indentation))
            (skip-chars-forward " \t")
            (current-column))))
       ;; Statement level.  Is it a continuation or a new statement?
       ((setq prev-char (perl-continuation-line-p))
        ;; This line is continuation of preceding line's statement;
        ;; indent  perl-continued-statement-offset  more than the
        ;; previous line of the statement.
        (perl-backward-to-start-of-continued-exp)
        (+ (if (or (save-excursion
                     (perl-continuation-line-p))
                   (and (eq prev-char ?\,)
                        (looking-at "[[:alnum:]_]+[ \t\n]*=>")))
               ;; If the continued line is itself a continuation
               ;; line, then align, otherwise add an offset.
               0 perl-continued-statement-offset)
           (current-column)
           (if (save-excursion (goto-char indent-point)
                               (looking-at
                                (if perl-indent-parens-as-block
                                    "[ \t]*[{([]" "[ \t]*{")))
               perl-continued-brace-offset 0)))
       (t
        ;; This line starts a new statement.
        ;; Position at last unclosed open.
        (goto-char containing-sexp)
        (or
         ;; Is line first statement after an open-brace?
         ;; If no, find that first statement and indent like it.
         (save-excursion
           (forward-char 1)
           ;; Skip over comments and labels following openbrace.
           (while (progn
                    (skip-chars-forward " \t\f\n")
                    (cond ((looking-at ";?#\\|^=\\w+")
                           (forward-comment 1) t)
                          ((looking-at "\\(\\w\\|\\s_\\)+:[^:]")
                           (setq colon-line-end (line-end-position))
                           (search-forward ":")))))
           ;; The first following code counts
           ;; if it is before the line we want to indent.
           (and (< (point) indent-point)
                (if (> colon-line-end (point))
                    (- (current-indentation) perl-label-offset)
                  (current-column))))
         ;; If no previous statement,
         ;; indent it relative to line brace is on.
         ;; For open paren in column zero, don't let statement
         ;; start there too.  If perl-indent-level is zero,
         ;; use perl-brace-offset + perl-continued-statement-offset
         ;; For open-braces not the first thing in a line,
         ;; add in perl-brace-imaginary-offset.
         (+ (if (and (bolp) (zerop perl-indent-level))
                (+ perl-brace-offset perl-continued-statement-offset)
              perl-indent-level)
            ;; Move back over whitespace before the openbrace.
            ;; If openbrace is not first nonwhite thing on the line,
            ;; add the perl-brace-imaginary-offset.
            (save-excursion (skip-chars-backward " \t")
                            (if (bolp) 0 perl-brace-imaginary-offset))
            (perl-indent-new-calculate 'virtual))))))))

(defun perl-backward-to-noncomment ()
  "Move point backward to after the first non-white-space, skipping comments."
  (forward-comment (- (point-max))))

(defun perl-backward-to-start-of-continued-exp ()
  (while
      (let ((c (preceding-char)))
      (cond
        ((memq c '(?\; ?\{ ?\[ ?\()) (forward-comment (point-max)) nil)
        ((memq c '(?\) ?\] ?\} ?\"))
         (forward-sexp -1) (forward-comment (- (point))) t)
        ((eq ?w (char-syntax c))
         (forward-word-strictly -1) (forward-comment (- (point))) t)
        (t (forward-char -1) (forward-comment (- (point))) t)))))

;; note: this may be slower than the c-mode version, but I can understand it.
(defun perl-indent-exp ()
  "Indent each line of the Perl grouping following point."
  (interactive)
  (let* ((case-fold-search nil)
	 (oldpnt (point-marker))
	 (bof-mark (save-excursion
		     (end-of-line 2)
		     (perl-beginning-of-function)
		     (point-marker)))
	 eol last-mark lsexp-mark delta)
    (if (= (char-after (marker-position bof-mark)) ?=)
	(message "Can't indent a format statement")
      (message "Indenting Perl expression...")
      (setq eol (line-end-position))
      (save-excursion			; locate matching close paren
	(while (and (not (eobp)) (<= (point) eol))
	  (parse-partial-sexp (point) (point-max) 0))
	(setq last-mark (point-marker)))
      (setq lsexp-mark bof-mark)
      (beginning-of-line)
      (while (< (point) (marker-position last-mark))
	(setq delta (perl-indent-line nil))
	(if (numberp delta)		; unquoted start-of-line?
	    (progn
	      (if (eolp)
		  (delete-horizontal-space))
	      (setq lsexp-mark (point-marker))))
	(end-of-line)
	(setq eol (point))
	(if (nth 4 (parse-partial-sexp (marker-position lsexp-mark) eol))
	    (progn			; line ends in a comment
	      (beginning-of-line)
	      (if (or (not (looking-at "\\s-*;?#"))
		      (listp delta)
		      (and (/= 0 delta)
			   (= (- (current-indentation) delta) comment-column)))
		  (if (and comment-start-skip
			   (re-search-forward comment-start-skip eol t))
		      (indent-for-comment))))) ; indent existing comment
	(forward-line 1))
      (goto-char (marker-position oldpnt))
      (message "Indenting Perl expression...done"))))

(defun perl-beginning-of-function (&optional arg)
  "Move backward to next beginning-of-function, or as far as possible.
With argument, repeat that many times; negative args move forward.
Returns new value of point in all cases."
  (interactive "p")
  (or arg (setq arg 1))
  (if (< arg 0) (forward-char 1))
  (and (/= arg 0)
       (re-search-backward
        "^\\s(\\|^\\s-*sub\\b[ \t\n]*\\_<[^{]+{\\|^\\s-*format\\b[^=]*=\\|^\\."
        nil 'move arg)
       (goto-char (1- (match-end 0))))
  (point))

;; note: this routine is adapted directly from emacs lisp.el, end-of-defun;
;; no bugs have been removed :-)
(defun perl-end-of-function (&optional arg)
  "Move forward to next end-of-function.
The end of a function is found by moving forward from the beginning of one.
With argument, repeat that many times; negative args move backward."
  (interactive "p")
  (or arg (setq arg 1))
  (let ((first t))
    (while (and (> arg 0) (< (point) (point-max)))
      (let ((pos (point)))
	(while (progn
		(if (and first
			 (progn
			  (forward-char 1)
			  (perl-beginning-of-function 1)
			  (not (bobp))))
		    nil
		  (or (bobp) (forward-char -1))
		  (perl-beginning-of-function -1))
		(setq first nil)
		(forward-list 1)
		(skip-chars-forward " \t")
		(if (looking-at "[#\n]")
		    (forward-line 1))
		(<= (point) pos))))
      (setq arg (1- arg)))
    (while (< arg 0)
      (let ((pos (point)))
	(perl-beginning-of-function 1)
	(forward-sexp 1)
	(forward-line 1)
	(if (>= (point) pos)
	    (if (progn (perl-beginning-of-function 2) (not (bobp)))
		(progn
		  (forward-list 1)
		  (skip-chars-forward " \t")
		  (if (looking-at "[#\n]")
		      (forward-line 1)))
	      (goto-char (point-min)))))
      (setq arg (1+ arg)))))

(defun perl-mark-function ()
  "Put mark at end of Perl function, point at beginning."
  (interactive)
  (push-mark)
  (perl-end-of-function)
  (push-mark)
  (perl-beginning-of-function)
  (backward-paragraph))

(define-obsolete-function-alias 'indent-perl-exp #'perl-indent-exp "29.1")
(define-obsolete-function-alias 'mark-perl-function #'perl-mark-function "29.1")

(provide 'perl-mode)

;;; perl-mode.el ends here
