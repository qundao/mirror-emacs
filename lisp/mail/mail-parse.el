;;; mail-parse.el --- Interface functions for parsing mail  -*- lexical-binding: t -*-

;; Copyright (C) 1998-2025 Free Software Foundation, Inc.

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>
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

;; This file contains wrapper functions for a wide range of mail
;; parsing functions.  The idea is that there are low-level libraries
;; that implement according to various specs (RFC2231, DRUMS, USEFOR),
;; but that programmers that want to parse some header (say,
;; Content-Type) will want to use the latest spec.
;;
;; So while each low-level library (rfc2231.el, for instance) decodes
;; faithfully according to that (proposed) standard, this library is
;; the interface library.  If some later RFC supersedes RFC2231, one
;; would just have to write a new low-level library, adjust the
;; aliases in this library, and the users and programmers won't notice
;; any changes.

;;; Code:

(require 'mail-prsvr)
(require 'ietf-drums)
(require 'rfc2231)
(require 'rfc2047)
(require 'rfc2045)

(defalias 'mail-header-parse-content-type 'rfc2231-parse-qp-string)
(defalias 'mail-header-parse-content-disposition 'rfc2231-parse-qp-string)
(defalias 'mail-content-type-get 'rfc2231-get-value)
(defalias 'mail-header-encode-parameter 'rfc2047-encode-parameter)

(defalias 'mail-header-remove-comments 'ietf-drums-remove-comments)
(defalias 'mail-header-remove-whitespace 'ietf-drums-remove-whitespace)
(defalias 'mail-header-strip 'ietf-drums-strip)
(defalias 'mail-header-strip-cte 'ietf-drums-strip-cte)
(defalias 'mail-header-get-comment 'ietf-drums-get-comment)
(defalias 'mail-header-parse-address 'ietf-drums-parse-address)
(defalias 'mail-header-parse-addresses 'ietf-drums-parse-addresses)
(defalias 'mail-header-parse-date 'ietf-drums-parse-date)
(defalias 'mail-narrow-to-head 'ietf-drums-narrow-to-header)
(defalias 'mail-quote-string 'ietf-drums-quote-string)
(defalias 'mail-header-make-address 'ietf-drums-make-address)

(defalias 'mail-header-fold-field 'rfc2047-fold-field)
(defalias 'mail-header-unfold-field 'rfc2047-unfold-field)
(defalias 'mail-header-narrow-to-field 'rfc2047-narrow-to-field)
(defalias 'mail-header-field-value 'rfc2047-field-value)

(defalias 'mail-encode-encoded-word-region 'rfc2047-encode-region)
(defalias 'mail-encode-encoded-word-buffer 'rfc2047-encode-message-header)
(defalias 'mail-encode-encoded-word-string 'rfc2047-encode-string)
(defalias 'mail-decode-encoded-word-region 'rfc2047-decode-region)
(defalias 'mail-decode-encoded-word-string 'rfc2047-decode-string)
(defalias 'mail-decode-encoded-address-region 'rfc2047-decode-address-region)
(defalias 'mail-decode-encoded-address-string 'rfc2047-decode-address-string)

(defun mail-header-parse-addresses-lax (string)
  "Parse STRING as a comma-separated list of mail addresses.
The return value is a list with mail/name pairs."
  (delq nil
        (mapcar (lambda (elem)
                  (or (ignore-errors
                        (mail-header-parse-address elem))
                      (mail-header-parse-address-lax elem)))
                (mail-header-parse-addresses string t))))

(defun mail-header-parse-address-lax (string)
  "Parse STRING as a mail address.
Returns a mail/name pair.

This function uses heuristics to determine the email address and
the name in the string.  If you have an RFC822(bis)
standards-compliant STRING, use `mail-header-parse-address'
instead."
  (with-temp-buffer
    (insert (string-clean-whitespace string))
    ;; Find the bit with the @ and guess that that's the mail.
    (goto-char (point-max))
    (when (search-backward "@" nil t)
      (if (re-search-backward " " nil t)
          (forward-char 1)
        (goto-char (point-min)))
      (let* ((start (point))
             (mail (buffer-substring
                    start (or (re-search-forward " " nil t)
                              (goto-char (point-max))))))
        (delete-region start (point))
        ;; We've now removed the email bit, so the rest of the stuff
        ;; has to be the name.
        (cons (string-trim mail "[<]+" "[>]+")
              (let ((name (string-trim (buffer-string)
                                       "[ \t\n\r(]+" "[ \t\n\r)]+")))
                (if (length= name 0)
                    nil
                  name)))))))

(provide 'mail-parse)

;;; mail-parse.el ends here
