;;; rmailedit.el --- "RMAIL edit mode"  Edit the current message  -*- lexical-binding: t; -*-

;; Copyright (C) 1985, 1994, 2001-2025 Free Software Foundation, Inc.

;; Maintainer: emacs-devel@gnu.org
;; Keywords: mail
;; Package: rmail

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

;;; Code:

(require 'rmail)

(defcustom rmail-edit-mode-hook nil
  "List of functions to call when editing an RMAIL message."
  :type 'hook
  :version "21.1"
  :group 'rmail-edit)


(defvar-keymap rmail-edit-map
  :parent text-mode-map
  "C-c C-c" #'rmail-cease-edit
  "C-c C-]" #'rmail-abort-edit)

(declare-function rmail-summary-disable "rmailsum" ())

;; We can't straightforwardly make this derive from text-mode, because
;; we need to bind (rmail-buffer-swapped) around the text-mode call.  :(
(defun rmail-edit-mode ()
  "Major mode for editing the contents of an Rmail message.
The editing commands are the same as in Text mode, together with
two commands to return to regular Rmail:
  *  \\[rmail-abort-edit] cancels any changes and returns to Rmail
  *  \\[rmail-cease-edit] makes them permanent.
This function runs the hooks `text-mode-hook' and `rmail-edit-mode-hook'.
\\{rmail-edit-map}"
  (if (rmail-summary-exists)
      (with-current-buffer rmail-summary-buffer
	(rmail-summary-disable)))
  ;; Prevent change-major-mode-hook from unswapping the buffers.
  (let ((rmail-buffer-swapped nil))
    (delay-mode-hooks (text-mode))
    (use-local-map rmail-edit-map)
    (setq major-mode 'rmail-edit-mode)
    (setq mode-name "RMAIL Edit")
    (setq mode-line-modified (default-value 'mode-line-modified))
    ;; Don't turn off auto-saving based on the size of the buffer
    ;; because that code does not understand buffer-swapping.
    (setq-local auto-save-include-big-deletions t)
    ;; If someone uses C-x C-s, don't clobber the rmail file (bug#2625).
    (add-hook 'write-region-annotate-functions
	      #'rmail-write-region-annotate nil t)
    (run-mode-hooks 'rmail-edit-mode-hook)))

;; Rmail Edit mode is suitable only for specially formatted data.
(put 'rmail-edit-mode 'mode-class 'special)


(defvar rmail-old-text)
(defvar rmail-old-mime-state)
(defvar rmail-old-pruned nil
  "Non-nil means the message being edited originally had pruned headers.")
(put 'rmail-old-pruned 'permanent-local t)

(defvar rmail-old-headers nil
  "Holds the headers of this message before editing started.")
(put 'rmail-old-headers 'permanent-local t)

;; Everything we use from here is a defsubst.
(eval-when-compile
  (require 'rmailmm))

;;;###autoload
(defun rmail-edit-current-message ()
  "Edit the contents of this message."
  (interactive)
  (if (zerop rmail-total-messages)
      (error "No messages in this buffer"))
  (rmail-modify-format)
  (setq-local rmail-old-pruned (rmail-msg-is-pruned))
  (rmail-edit-mode)
  (setq-local rmail-old-mime-state
       (and rmail-enable-mime
	    ;; If you use something else, you are on your own.
	    (eq rmail-mime-feature 'rmailmm)
	    (rmail-mime-message-p)
	    (let ((entity (get-text-property (point-min) 'rmail-mime-entity)))
	      ;; rmailmm has got its hands on the message.
	      ;; Even if the message is in `raw' state, boundaries etc
	      ;; are still missing.  All we can do is insert the real
	      ;; raw message.  (Bug#9840)
	      ;; FIXME?  Since the 2012-09-17 changes to rmail-mime,
	      ;; can we just use that function now?
	      (when (and entity
			 (not (equal "text/plain"
				     (car (rmail-mime-entity-type entity)))))
		(let ((inhibit-read-only t))
		  (erase-buffer)
		  (insert-buffer-substring
		   rmail-view-buffer
		   (aref (rmail-mime-entity-header entity) 0)
		   (aref (rmail-mime-entity-body entity) 1)))
		(goto-char (point-min))
		;; t = decoded; raw = raw.
		(aref (aref (rmail-mime-entity-display entity) 0) 0)))))
  (setq-local rmail-old-text
              (save-restriction
                (widen)
                (buffer-substring (point-min) (point-max))))
  (setq-local rmail-old-headers (rmail-edit-headers-alist t))
  (setq buffer-read-only nil)
  (setq buffer-undo-list nil)
  ;; Whether the buffer is initially marked as modified or not
  ;; depends on whether or not the underlying rmail buffer was so marked.
  ;; Given the way this works, it has to.
  ;; If you kill the edit buffer, you've killed your rmail buffer.
  (force-mode-line-update)
  (if (and (eq (key-binding "\C-c\C-c") 'rmail-cease-edit)
	   (eq (key-binding "\C-c\C-]") 'rmail-abort-edit))
      (message "Editing: Type C-c C-c to return to Rmail, C-c C-] to abort")
    (message "%s" (substitute-command-keys
		   "Editing: Type \\[rmail-cease-edit] to return to Rmail, \\[rmail-abort-edit] to abort"))))


(declare-function rmail-summary-enable "rmailsum" ())
(declare-function rmail-summary-update-line "rmailsum" (n))

(defun rmail-cease-edit (&optional abort)
  "Finish editing message; switch back to Rmail proper.
If ABORT, this is the result of aborting an edit."
  (interactive)
  (if (rmail-summary-exists)
      (with-current-buffer rmail-summary-buffer
	(rmail-summary-enable)))
  (widen)
  (goto-char (point-min))
  ;; This is far from ideal.  The edit may have inadvertently
  ;; removed the blank line at the end of the headers, but there
  ;; are almost certainly other blank lines.
  (or (search-forward "\n\n" nil t)
      (error "There must be a blank line at the end of the headers"))
  ;; Disguise any "From " lines so they don't start a new message.
  (goto-char (point-min))
  ;; This tries to skip the mbox From.  FIXME less fragile to go to EOH?
  (if (or rmail-old-mime-state
	  (not rmail-old-pruned))
      (forward-line 1))
  ;; When editing a non-MIME message, rmail-show-message-1 has unescaped
  ;; ^>*From lines according to rmail-mbox-format.  We are editing
  ;; the message as it was displayed, and need to put the escapes when done.
  ;; When editing a MIME message, we are editing the "raw" message.
  ;; ^>*From lines have not been escaped, but we still need to ensure
  ;; a "^From " line is escaped so as not to break later parsing (?).
  ;; With ^>+From lines, we have no way of knowing whether the person
  ;; doing the editing escaped them or not, so it seems best to leave
  ;; them alone.  (This all assumes you are using rmailmm rather than
  ;; something else that behaves differently.)
  (let ((fromline (if (or (eq 'mboxo rmail-mbox-format)
			  rmail-mime-decoded)
		      "^From "
		    "^>*From "))
	case-fold-search)
    (while (re-search-forward fromline nil t)
      (beginning-of-line)
      (insert ">")
      (forward-line)))
  (let ((old rmail-old-text)
	(pruned rmail-old-pruned)
	(mime-state rmail-old-mime-state)
	;; People who know what they are doing might have modified the
	;; buffer's encoding if editing the message included inserting
	;; characters that were unencodable by the original message's
	;; encoding.  Make note of the new encoding and use it for
	;; encoding the edited message.
	(edited-coding buffer-file-coding-system)
	new-headers
	character-coding is-text-message coding-system
	headers-end limit)
    ;; Make sure `edited-coding' can safely encode the edited message.
    (setq edited-coding
	  (select-safe-coding-system (point-min) (point-max) edited-coding))
    ;; Go back to Rmail mode, but carefully.
    (force-mode-line-update)
    (let ((rmail-buffer-swapped nil)) ; Prevent change-major-mode-hook
                                      ; from unswapping the buffers.
      (kill-all-local-variables)
      (rmail-mode-1)
      (if (boundp 'tool-bar-map)
          (setq-local tool-bar-map rmail-tool-bar-map))
      (setq buffer-undo-list t)
      (rmail-variables))
    ;; If text has really changed, mark message as edited.
    ;; FIXME we should do the comparison before escaping From lines.
    (unless (and (= (length old) (- (point-max) (point-min)))
		 (string= old (buffer-substring (point-min) (point-max))))
      (setq old nil)
      (goto-char (point-min))
      (search-forward "\n\n")
      (setq headers-end (point-marker)) ; first character of body
      (save-restriction
	(narrow-to-region (point-min) headers-end)
	;; If they changed the message's encoding, rewrite the charset=
	;; header for them, so that subsequent rmail-show-message
	;; decodes it correctly.
	(let* ((buffer-read-only nil)
	       (new-coding (coding-system-base edited-coding))
	       (mime-charset (symbol-name
			      (or (coding-system-get new-coding :mime-charset)
				  (if (coding-system-equal new-coding
							   'undecided)
				      'us-ascii
				    new-coding))))
	       old-coding mime-beg mime-end content-type)
          ;; If there's no content-type in the edited headers, look for one
          ;; in the original headers and add it to the edited headers
          ;; (Bug #26918)
          (unless (mail-fetch-field "Content-Type")
            (let (old-content-type
                  (msgbeg (rmail-msgbeg rmail-current-message))
                  (msgend (rmail-msgend rmail-current-message)))
              (with-current-buffer rmail-view-buffer ; really the mbox buffer
                (save-restriction
                  (narrow-to-region msgbeg msgend)
                  (goto-char (point-min))
                  (setq limit (search-forward "\n\n"))
                  (narrow-to-region (point-min) limit)
                  (goto-char (point-min))
                  (when (re-search-forward "^content-type:" limit t)
                    (forward-line)
                    (setq old-content-type (buffer-substring
                                            (match-beginning 0) (point))))))
              (when old-content-type
                (save-excursion
                  (goto-char headers-end) ; first char of body
                  (backward-char)         ; add header before second newline
                  (insert old-content-type)
                  ;;Add it to rmail-old-headers as though it had been
                  ;;there originally, to avoid rmail-edit-update-headers
                  ;;an extra copy
                  (let ((header (substring old-content-type 0
                                           (length "content-type"))))
                    (unless (assoc header rmail-old-headers)
                      (push (cons header old-content-type) rmail-old-headers)))
                  ))))
          (goto-char (point-min))
	  (if (re-search-forward rmail-mime-charset-pattern nil 'move)
	      (setq mime-beg (match-beginning 1)
		    mime-end (match-end 1)
		    old-coding (coding-system-from-name (match-string 1)))
	    (setq content-type (mail-fetch-field "Content-Type")))
	  (cond
	   ;; No match for rmail-mime-charset-pattern, but there was some
	   ;; other Content-Type.  We should not insert another.  (Bug#4624)
	   (content-type)
           ;; Don't insert anything if aborting.
           (abort)
	   ((null old-coding)
	    ;; If there was no charset= spec, insert one.
	    (backward-char 1)
	    (insert "Content-type: text/plain; charset=" mime-charset "\n"))
	   ((not (coding-system-equal (coding-system-base old-coding)
				      new-coding))
	    (goto-char mime-end)
	    (delete-region mime-beg mime-end)
	    (insert mime-charset)))))
      (setq new-headers (rmail-edit-headers-alist t))
      (rmail-swap-buffers-maybe)
      (narrow-to-region (rmail-msgbeg rmail-current-message)
			(rmail-msgend rmail-current-message))
      (goto-char (point-min))
      (setq limit (search-forward "\n\n"))
      (save-restriction
	;; All 3 of the functions we call below assume the buffer was
	;; narrowed to just the headers of the message.
	(narrow-to-region (point-min) limit)
	(setq character-coding
	      (mail-fetch-field "content-transfer-encoding")
	      is-text-message (rmail-is-text-p)
	      coding-system (if (and edited-coding
				     (not (coding-system-equal
					   (coding-system-base edited-coding)
					   'undecided)))
				edited-coding
			      (rmail-get-coding-system))))
      (if character-coding
	  (setq character-coding (downcase character-coding)))

      (goto-char limit)
      (let ((inhibit-read-only t)
            (data-buffer (current-buffer))
            (start (copy-marker (point) nil)) ; new body will be between
            (end (copy-marker (point) t)))    ; these two markers
        (if mime-state
            ;; Message is already in encoded state
            (insert-buffer-substring rmail-view-buffer headers-end
                                     (with-current-buffer rmail-view-buffer
                                       (point-max)))
          (with-current-buffer rmail-view-buffer
            (encode-coding-region headers-end (point-max) coding-system
                                  data-buffer)))
	;; Apply to the mbox buffer any changes in header fields
	;; that the user made while editing in the view buffer.
        (rmail-edit-update-headers (rmail-edit-diff-headers
				    rmail-old-headers new-headers))
	;; Re-apply content-transfer-encoding, if any, on the message body.
	(cond
	 (mime-state)		    ; if set, already transfer-encoded
	 ((string= character-coding "quoted-printable")
	  (mail-quote-printable-region start end))
	 ((and (string= character-coding "base64") is-text-message)
	  (base64-encode-region start end))
	 ((and (eq character-coding 'uuencode) is-text-message)
	  (error "uuencoded messages are not supported")))
        ;; After encoding, make sure buffer ends with a blank line so as not to
        ;; run this message together with the following one.
        (goto-char end)
        (rmail-ensure-blank-line)
        ;; Delete previous body.  This must be after all insertions at the end,
        ;; so the marker for the beginning of the next message isn't messed up.
        (delete-region end (point-max)))
      (rmail-set-attribute rmail-edited-attr-index t)
      (if (rmail-summary-exists)
          (let ((msgnum rmail-current-message))
            (with-current-buffer rmail-summary-buffer
              (rmail-summary-update-line msgnum)))))
    (rmail-show-message)
    (rmail-toggle-header (if pruned 1 0))
    ;; Restore mime display state.
    (and mime-state (rmail-mime nil mime-state)))
  (run-hooks 'rmail-mode-hook))

(defun rmail-abort-edit ()
  "Abort edit of current message; restore original contents."
  (interactive)
  (widen)
  (delete-region (point-min) (point-max))
  (insert rmail-old-text)
  (rmail-cease-edit t)
  (rmail-highlight-headers))

(defun rmail-edit-headers-alist (&optional widen markers)
  "Return an alist of the headers of the message in the current buffer.
Each element has the form (HEADER-NAME . ENTIRE-STRING).
ENTIRE-STRING includes the name of the header field (which is HEADER-NAME)
and has a final newline.
If part of the text is not valid as a header field, HEADER-NAME
is an integer and we use consecutive integers.

If WIDEN is non-nil, operate on the entire buffer.

If MARKERS is non-nil, the value looks like
 \(HEADER-NAME ENTIRE-STRING BEG-MARKER END-MARKER)."
  (let (header-alist (no-good-header-count 1))
    (save-excursion
      (save-restriction
	(if widen (widen))
	(goto-char (point-min))
	(search-forward "\n\n")
	(narrow-to-region (point-min) (1- (point)))
	(goto-char (point-min))
	(while (not (eobp))
	  (let ((start (point))
		name header)
	    ;; Match the name.
	    (if (looking-at "[ \t]*\\([^:\n \t]\\(\\|[^:\n]*[^:\n \t]\\)\\)[ \t]*:")
		(setq name (match-string-no-properties 1))
	      (setq name no-good-header-count
		    no-good-header-count (1+ no-good-header-count)))
	    (forward-line 1)
	    (while (looking-at "[ \t]")
	      (forward-line 1))
	    (setq header (buffer-substring-no-properties start (point)))
	    (if markers
		(push (list header (copy-marker start) (point-marker))
		      header-alist)
	      (push (cons name header) header-alist))))))
    (nreverse header-alist)))


(defun rmail-edit-diff-headers (old-headers new-headers)
  "Compare OLD-HEADERS and NEW-HEADERS and return field differences.
The value is a list of three lists, (INSERTED DELETED CHANGED).

INSERTED's elements describe inserted header fields
and each looks like (AFTER-WHAT INSERT-WHAT)
INSERT-WHAT is the header field to insert (a member of NEW-HEADERS).
AFTER-WHAT is the field to insert it after (a member of NEW-HEADERS)
or else nil to insert it at the beginning.

DELETED's elements are elements of OLD-HEADERS.
CHANGED's elements have the form (OLD . NEW)
where OLD is an element of OLD-HEADERS and NEW is an element of NEW-HEADERS."

  (let ((reverse-new (reverse new-headers))
	inserted deleted changed)
    (dolist (old old-headers)
      (let ((new (assoc (car old) new-headers)))
	;; If it's in OLD-HEADERS and has no new counterpart,
	;; it is a deletion.
	(if (null new)
	    (push old deleted)
	  ;; If it has a new counterpart, maybe it was changed.
	  (unless (equal (cdr old) (cdr new))
	    (push (cons old new) changed))
	  ;; Remove the new counterpart, since it has been spoken for.
	  (setq new-headers (remq new new-headers)))))
    ;; Look at the new headers with no old counterpart.
    (dolist (new new-headers)
      (let ((prev (cadr (member new reverse-new))))
	;; Mark each one as an insertion.
	;; Record the previous new header, to insert it after that.
	(push (list prev new) inserted)))
    ;; It is crucial to return the insertions in buffer order
    ;; so that `rmail-edit-update-headers' can insert a field
    ;; after a new field.
    (list (nreverse inserted)
	  (nreverse deleted)
	  (nreverse changed))))

(defun rmail-edit-update-headers (header-diff)
  "Edit the mail headers in the buffer based on HEADER-DIFF.
HEADER-DIFF should be a return value from `rmail-edit-diff-headers'."
  (let ((buf-headers (rmail-edit-headers-alist nil t)))
    ;; Change all the fields scheduled for being changed.
    (dolist (chg (nth 2 header-diff))
      (let* ((match (assoc (cdar chg) buf-headers))
	     (end (marker-position (nth 2 match))))
	(goto-char end)
	;; Insert the new, then delete the old.
	;; That avoids collapsing markers.
	(insert-before-markers (cddr chg))
	(delete-region (nth 1 match) end)
	;; Remove the old field from BUF-HEADERS.
	(setq buf-headers (delq match buf-headers))
	;; Update BUF-HEADERS to show the changed field.
	(push (list (cddr chg) (point-marker)
		    (copy-marker (- (point) (length (cddr chg))))
		    (point-marker))
	      buf-headers)))
    ;; Delete all the fields scheduled for deletion.
    ;; We do deletion after changes
    ;; because when two fields look alike and get replaced by one,
    ;; the first of them is considered changed
    ;; and the second is considered deleted.
    (dolist (del (nth 1 header-diff))
      (let ((match (assoc (cdr del) buf-headers)))
	(delete-region (nth 1 match) (nth 2 match))))
    ;; Insert all the fields scheduled for insertion.
    (dolist (ins (nth 0 header-diff))
      (let* ((new (cadr ins))
	     (after (car ins))
	     (match (assoc (cdr after) buf-headers)))
	(goto-char (if match (nth 2 match) (point-min)))
	(insert (cdr new))
	;; Update BUF-HEADERS to show the inserted field.
	(push (list (cdr new)
		    (copy-marker (- (point) (length (cdr new))))
		    (point-marker))
	      buf-headers)))
    ;; Disconnect the markers
    (dolist (hdr buf-headers)
      (set-marker (nth 1 hdr) nil)
      (set-marker (nth 2 hdr) nil))))

(provide 'rmailedit)

;;; rmailedit.el ends here
