;;; auth-source-pass.el --- Integrate auth-source with password-store -*- lexical-binding: t -*-

;; Copyright (C) 2015, 2017-2025 Free Software Foundation, Inc.

;; Author: Damien Cassou <damien@cassou.me>,
;;         Nicolas Petton <nicolas@petton.fr>
;;         Keith Amidon <camalot@picnicpark.org>
;; Version: 5.0.0
;; Created: 07 Jun 2015

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

;; Integrates password-store (https://passwordstore.org/) within
;; auth-source.

;;; Code:

(require 'seq)
(require 'cl-lib)
(require 'auth-source)
(require 'url-parse)
;; Use `eval-when-compile' after the other `require's to avoid spurious
;; "might not be defined at runtime" warnings.
(eval-when-compile (require 'subr-x))

(defgroup auth-source-pass nil
  "password-store integration within auth-source."
  :prefix "auth-source-pass-"
  :group 'auth-source
  :version "27.1")

(defcustom auth-source-pass-filename
  (or (getenv "PASSWORD_STORE_DIR") "~/.password-store")
  "Filename of the password-store folder."
  :type 'directory
  :version "27.1")

(defcustom auth-source-pass-port-separator ":"
  "Separator string between host and port in entry filename."
  :type 'string
  :version "27.1")

(defcustom auth-source-pass-extra-query-keywords nil
  "Whether to consider additional keywords when performing a query.
Specifically, when the value is t, recognize the `:max' and
`:require' keywords and accept lists of query parameters for
certain keywords, such as `:host' and `:user'.  Beyond that, wrap
all returned secrets in a function and don't bother considering
subdomains when matching hosts.  Also, forgo any further results
filtering unless given an applicable `:require' argument.  When
this option is nil, do none of that, and enact the narrowing
behavior described toward the bottom of the Info node `(auth) The
Unix password store'."
  :type 'boolean
  :version "29.1")

(cl-defun auth-source-pass-search (&rest spec
                                         &key backend type host user port
                                         require max
                                         &allow-other-keys)
  "Given some search query, return matching credentials.

See `auth-source-search' for details on the parameters SPEC, BACKEND, TYPE,
HOST, USER, PORT, REQUIRE, and MAX."
  (cl-assert (or (null type) (eq type (oref backend type)))
             t "Invalid password-store search: %s %s")
  (cond ((eq host t)
         (warn "auth-source-pass does not handle host wildcards.")
         nil)
        ((null host)
         ;; Do not build a result, as none will match when HOST is nil
         nil)
        (auth-source-pass-extra-query-keywords
         (auth-source-pass--build-result-many host port user require max))
        (t
         (when-let* ((result (auth-source-pass--build-result host port user)))
           (list result)))))

(defun auth-source-pass--build-result (hosts port user)
  "Build auth-source-pass entry matching HOSTS, PORT and USER.

HOSTS can be a string or a list of strings."
  (let ((entry-data (auth-source-pass--find-match hosts user port)))
    (when entry-data
      (let ((retval (list
                     :host (auth-source-pass--get-attr "host" entry-data)
                     :port (or (auth-source-pass--get-attr "port" entry-data) port)
                     :user (or (auth-source-pass--get-attr "user" entry-data) user)
                     :secret (lambda () (auth-source-pass--get-attr 'secret entry-data)))))
        (auth-source-pass--do-debug "return %s as final result (plus hidden password)"
                                    (seq-subseq retval 0 -2)) ;; remove password
        retval))))

(defvar auth-source-pass--match-regexp nil)

(defun auth-source-pass--match-regexp (s)
  (rx-to-string ; autoloaded
   `(: (or bot "/")
       (or (: (? (group-n 20 (+ (not (in ?/ ,s)))) "@")     ; user prefix
              (group-n 10 (+ (not (in ?/ ?@ ,s))))          ; host
              (? ,s (group-n 30 (+ (not (in ?\s ?/ ,s)))))) ; port
           (: (group-n 11 (+ (not (in ?/ ?@ ,s))))          ; host
              (? ,s (group-n 31 (+ (not (in ?\s ?/ ,s)))))  ; port
              (? "/" (group-n 21 (+ (not (in ?/ ,s)))))))   ; user suffix
       eot)
   'no-group))

(defun auth-source-pass--build-result-many (hosts ports users require max)
  "Return multiple `auth-source-pass--build-result' values."
  (setq hosts (ensure-list hosts))
  (setq users (ensure-list users))
  (setq ports (ensure-list ports))
  (let* ((auth-source-pass--match-regexp (auth-source-pass--match-regexp
                                          auth-source-pass-port-separator))
         (rv (auth-source-pass--find-match-many hosts users ports
                                                require (or max 1))))
    (when auth-source-debug
      (auth-source-pass--do-debug "final result: %S" rv))
    (let (out)
      (dolist (e rv out)
        (when-let* ((s (plist-get e :secret)) ; not captured by closure in 29.1
                    (v (auth-source--obfuscate s)))
          (setf (plist-get e :secret)
                (lambda () (auth-source--deobfuscate v))))
        (push e out)))))

;;;###autoload
(defun auth-source-pass-enable ()
  "Enable auth-source-password-store."
  ;; To add password-store to the list of sources, evaluate the following:
  (add-to-list 'auth-sources 'password-store)
  ;; clear the cache (required after each change to #'auth-source-pass-search)
  (auth-source-forget-all-cached))

(defvar auth-source-pass-backend
  (auth-source-backend
   :source "." ;; not used
   :type 'password-store
   :search-function #'auth-source-pass-search)
  "Auth-source backend for password-store.")

(defun auth-source-pass-backend-parse (entry)
  "Create a password-store auth-source backend from ENTRY."
  (when (eq entry 'password-store)
    (auth-source-backend-parse-parameters entry auth-source-pass-backend)))

(if (boundp 'auth-source-backend-parser-functions)
    (add-hook 'auth-source-backend-parser-functions #'auth-source-pass-backend-parse)
  (advice-add 'auth-source-backend-parse :before-until #'auth-source-pass-backend-parse))


;;;###autoload
(defun auth-source-pass-get (key entry)
  "Return the value associated to KEY in the password-store entry ENTRY.

ENTRY is the name of a password-store entry.
The key used to retrieve the password is the symbol `secret'.

The convention used as the format for a password-store file is
the following (see URL `https://www.passwordstore.org/#organization'):

secret
key1: value1
key2: value2"
  (let ((data (auth-source-pass-parse-entry entry)))
    (auth-source-pass--get-attr key data)))

(defun auth-source-pass--get-attr (key entry-data)
  "Return value associated with KEY in an ENTRY-DATA.

ENTRY-DATA is the data from a parsed password-store entry.
The key used to retrieve the password is the symbol `secret'.

See `auth-source-pass-get'."
  (or (cdr (assoc key entry-data))
      (and (string= key "user")
           (cdr (assoc "username" entry-data)))))

(defun auth-source-pass--read-entry (entry)
  "Return a string with the file content of ENTRY."
  (with-temp-buffer
    ;; `file-name-handler-alist' could be nil, or miss the
    ;; `epa-file-handler' entry.  We ensure that it does exist.
    ;; (Bug#67937)
    (let ((file-name-handler-alist
           (cons epa-file-handler file-name-handler-alist)))
      (insert-file-contents (expand-file-name
                             (format "%s.gpg" entry)
                             auth-source-pass-filename))
      (buffer-substring-no-properties (point-min) (point-max)))))

(defun auth-source-pass-parse-entry (entry)
  "Return an alist of the data associated with ENTRY.

ENTRY is the name of a password-store entry."
  (let ((file-contents (ignore-errors (auth-source-pass--read-entry entry))))
    (and file-contents
         (cons `(secret . ,(auth-source-pass--parse-secret file-contents))
               (auth-source-pass--parse-data file-contents)))))

(defun auth-source-pass--parse-secret (contents)
  "Parse the password-store data in the string CONTENTS and return its secret.
The secret is the first line of CONTENTS."
  (car (split-string contents "\n" t)))

(defun auth-source-pass--parse-data (contents)
  "Parse the password-store data in the string CONTENTS and return an alist.
CONTENTS is the contents of a password-store formatted file."
  (let ((lines (cdr (split-string contents "\n" t "[ \t]+"))))
    (seq-remove #'null
                (mapcar (lambda (line)
                          (when-let* ((pos (seq-position line ?:)))
                            (cons (string-trim (substring line 0 pos))
                                  (string-trim (substring line (1+ pos))))))
                        lines))))

(defun auth-source-pass--do-debug (&rest msg)
  "Call `auth-source-do-debug' with MSG and a prefix."
  (apply #'auth-source-do-debug
         (cons (concat "auth-source-pass: " (car msg))
               (cdr msg))))

;; TODO: add tests for that when `assess-with-filesystem' is included
;; in Emacs
(defun auth-source-pass-entries ()
  "Return a list of all password store entries."
  (let ((store-dir (expand-file-name auth-source-pass-filename)))
    (mapcar
     (lambda (file) (file-name-sans-extension (file-relative-name file store-dir)))
     (directory-files-recursively store-dir "\\.gpg\\'"))))

(defun auth-source-pass--find-match (hosts user port)
  "Return password-store entry data matching HOSTS, USER and PORT.

Disambiguate between user provided inside HOSTS (e.g., user@server.com) and
inside USER by giving priority to USER.  Same for PORT.
HOSTS can be a string or a list of strings."
  (seq-some (lambda (host)
              (let ((entry (apply #'auth-source-pass--find-match-unambiguous
                                   (auth-source-pass--disambiguate host user port))))
                (if (or (null entry) (assoc "host" entry))
                    entry
                  (cons (cons "host" host) entry))))
            (if (listp hosts)
                hosts
              (list hosts))))

(defun auth-source-pass--retrieve-parsed (seen path port-number-p)
  (when (string-match auth-source-pass--match-regexp path)
    (puthash path
             `( :host ,(or (match-string 10 path) (match-string 11 path))
                ,@(if-let* ((tr (match-string 21 path)))
                      (list :user tr :suffix t)
                    (list :user (match-string 20 path)))
                :port ,(and-let* ((p (or (match-string 30 path)
                                         (match-string 31 path)))
                                  (n (string-to-number p)))
                         (if (or (zerop n) (not port-number-p))
                             (format "%s" p)
                           n)))
             seen)))

(defun auth-source-pass--match-parts (cache key reference require)
  (let ((value (plist-get cache key)))
    (cond ((memq key require)
           (if reference (equal value reference) value))
          ((and value reference) (equal value reference))
          (t))))

(defun auth-source-pass--find-match-many (hosts users ports require max)
  "Return plists for valid combinations of HOSTS, USERS, PORTS."
  (let ((seen (make-hash-table :test #'equal))
        (entries (auth-source-pass-entries))
        out suffixed suffixedp)
    (catch 'done
      (dolist (host hosts out)
        (pcase-let ((`(,_ ,u ,p) (auth-source-pass--disambiguate host)))
          (unless (or (not (equal "443" p)) (string-prefix-p "https://" host))
            (setq p nil))
          (dolist (user (or users (list u)))
            (dolist (port (or ports (list p)))
              (dolist (e entries)
                (when-let*
                    ((m (or (gethash e seen) (auth-source-pass--retrieve-parsed
                                              seen e (integerp port))))
                     ((equal host (plist-get m :host)))
                     ((auth-source-pass--match-parts m :port port require))
                     ((auth-source-pass--match-parts m :user user require))
                     ;; For now, ignore body-content pairs, if any,
                     ;; from `auth-source-pass--parse-data'.
                     (secret (let ((parsed (auth-source-pass-parse-entry e)))
                               (or (auth-source-pass--get-attr 'secret parsed)
                                   (not (memq :secret require))))))
                  (push
                   `( :host ,host ; prefer user-provided :host over h
                      ,@(and-let* ((u (plist-get m :user))) (list :user u))
                      ,@(and-let* ((p (plist-get m :port))) (list :port p))
                      ,@(and secret (not (eq secret t)) (list :secret secret)))
                   (if (setq suffixedp (plist-get m :suffix)) suffixed out))
                  (unless suffixedp
                    (when (or (zerop (decf max))
                              (null (setq entries (delete e entries))))
                      (throw 'done out)))))
              (setq suffixed (nreverse suffixed))
              (while suffixed
                (push (pop suffixed) out)
                (when (zerop (decf max))
                  (throw 'done out))))))))))

(defun auth-source-pass--disambiguate (host &optional user port)
  "Return (HOST USER PORT) after disambiguation.
Disambiguate between having user provided inside HOST (e.g.,
user@server.com) and inside USER by giving priority to USER.
Same for PORT."
  (let* ((url (url-generic-parse-url (if (string-match-p ".*://" host)
                                         host
                                       (format "https://%s" host)))))
    (list
     (or (url-host url) host)
     (or user (url-user url))
     ;; url-port returns 443 (because of the https:// above) by default
     (or port (number-to-string (url-port url))))))

(defun auth-source-pass--find-match-unambiguous (hostname user port)
  "Return password-store entry data matching HOSTNAME, USER and PORT.
If many matches are found, return the first one.  If no match is found,
return nil.

HOSTNAME should not contain any username or port number."
  (let ((all-entries (auth-source-pass-entries))
        (suffixes (auth-source-pass--generate-entry-suffixes hostname user port)))
    (auth-source-pass--do-debug "searching for entries matching hostname=%S, user=%S, port=%S"
                                hostname (or user "") (or port ""))
    (auth-source-pass--do-debug "corresponding suffixes to search for: %S" suffixes)
    (catch 'auth-source-pass-break
      (dolist (suffix suffixes)
        (let* ((matching-entries (auth-source-pass--entries-matching-suffix suffix all-entries))
               (best-entry-data (auth-source-pass--select-from-entries matching-entries user)))
          (pcase (length matching-entries)
            (0 (auth-source-pass--do-debug "found no entries matching %S" suffix))
            (1 (auth-source-pass--do-debug "found 1 entry matching %S: %S"
                                           suffix
                                           (car matching-entries)))
            (_ (auth-source-pass--do-debug "found %s entries matching %S: %S"
                                           (length matching-entries)
                                           suffix
                                           matching-entries)))
          (when best-entry-data
            (throw 'auth-source-pass-break best-entry-data)))))))

(defun auth-source-pass--select-from-entries (entries user)
  "Return best matching password-store entry data from ENTRIES.

If USER is non-nil, give precedence to entries containing a user field
matching USER."
  (let (fallback)
    (catch 'auth-source-pass-break
      (dolist (entry entries fallback)
        (let ((entry-data (auth-source-pass-parse-entry entry)))
          (when (and entry-data (not fallback))
            (setq fallback entry-data)
            (when (or (not user) (equal (auth-source-pass--get-attr "user" entry-data) user))
              (throw 'auth-source-pass-break entry-data))))))))

(defun auth-source-pass--entries-matching-suffix (suffix entries)
  "Return entries matching SUFFIX.
If ENTRIES is nil, use the result of calling `auth-source-pass-entries' instead."
  (cl-remove-if-not
   (lambda (entry) (string-match-p
               (format "\\(^\\|/\\)%s$" (regexp-quote suffix))
               entry))
   (or entries (auth-source-pass-entries))))

(defun auth-source-pass--generate-entry-suffixes (hostname user port)
  "Return a list of possible entry path suffixes in the password-store.

Based on the supported filename patterns for HOSTNAME, USER, &
PORT, return a list of possible suffixes for matching entries in
the password-store.

PORT may be a list of ports."
  (let ((domains (auth-source-pass--domains (split-string hostname "\\."))))
    (seq-mapcat (lambda (domain)
                  (seq-mapcat
                   (lambda (p)
                     (auth-source-pass--name-port-user-suffixes domain user p))
                   (if (consp port) port (list port))))
                domains)))

(defun auth-source-pass--domains (name-components)
  "Return a list of possible domain names matching the hostname.

This function takes a list of NAME-COMPONENTS, the strings
separated by periods in the hostname, and returns a list of full
domain names containing the trailing sequences of those
components, from longest to shortest."
  (cl-maplist (lambda (components) (mapconcat #'identity components "."))
              name-components))

(defun auth-source-pass--name-port-user-suffixes (name user port)
  "Return a list of possible path suffixes for NAME, USER, & PORT.

The resulting list is ordered from most specific to least
specific, with paths matching all of NAME, USER, & PORT first,
then NAME & USER, then NAME & PORT, then just NAME."
  (seq-mapcat
   #'identity
   (list
    (when (and user port)
      (list
       (format "%s@%s%s%s" user name auth-source-pass-port-separator port)
       (format "%s%s%s/%s" name auth-source-pass-port-separator port user)))
    (when user
      (list
       (format "%s@%s" user name)
       (format "%s/%s" name user)))
    (when port
      (list
       (format "%s%s%s" name auth-source-pass-port-separator port)))
    (list
     (format "%s" name)))))

(defun auth-source-pass-file-name-p (file)
  "Say whether FILE is used by `auth-source-pass'."
  (and (stringp file) (stringp auth-source-pass-filename)
       (string-equal
        (expand-file-name file) (expand-file-name auth-source-pass-filename))))

(with-eval-after-load 'bookmark
  (add-hook 'bookmark-inhibit-context-functions
	    #'auth-source-pass-file-name-p))

(provide 'auth-source-pass)
;;; auth-source-pass.el ends here

;; LocalWords:  backend hostname
