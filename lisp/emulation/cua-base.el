;;; cua-base.el --- emulate CUA key bindings  -*- lexical-binding: t; -*-

;; Copyright (C) 1997-2025 Free Software Foundation, Inc.

;; Author: Kim F. Storm <storm@cua.dk>
;; Keywords: keyboard emulations convenience cua

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

;; This is the CUA package which provides a complete emulation of the
;; standard CUA key bindings (Motif/Windows/Mac GUI) for selecting and
;; manipulating the region where S-<movement> is used to highlight &
;; extend the region.

;; CUA style key bindings for cut and paste
;; ----------------------------------------

;; This package allows the C-z, C-x, C-c, and C-v keys to be
;; bound appropriately according to the Motif/Windows GUI, i.e.
;;	C-z	-> undo
;;	C-x	-> cut
;;	C-c	-> copy
;;	C-v	-> paste
;;
;; The tricky part is the handling of the C-x and C-c keys which
;; are normally used as prefix keys for most of Emacs's built-in
;; commands.  With CUA they still do!!!
;;
;; Only when the region is currently active (and highlighted since
;; transient-mark-mode is used), the C-x and C-c keys will work as CUA
;; keys
;; 	C-x -> cut
;; 	C-c -> copy
;; When the region is not active, C-x and C-c works as prefix keys!
;;
;; This probably sounds strange and difficult to get used to - but
;; based on my own experience and the feedback from many users of
;; this package, it actually works very well and users adapt to it
;; instantly - or at least very quickly.  So give it a try!
;; ... and in the few cases where you make a mistake and accidentally
;; delete the region - you just undo the mistake (with C-z).
;;
;; If you really need to perform a command which starts with one of
;; the prefix keys even when the region is active, you have three options:
;; - press the prefix key twice very quickly (within 0.2 seconds),
;; - press the prefix key and the following key within 0.2 seconds, or
;; - use the SHIFT key with the prefix key, i.e. C-X or C-C
;;
;; This behavior can be customized via the
;; cua-prefix-override-inhibit-delay variable.

;; In addition to using the shifted movement keys, you can also use
;; [C-space] to start the region and use unshifted movement keys to extend
;; it.  To cancel the region, use [C-space] or [C-g].

;; If you prefer to use the standard Emacs cut, copy, paste, and undo
;; bindings, customize cua-enable-cua-keys to nil.


;; Typing text replaces the region
;; -------------------------------

;; When the region is active, i.e. highlighted, the text in region is
;; replaced by the text you type.

;; The replaced text is saved in register 0 which can be inserted using
;; the key sequence M-0 C-v (see the section on register support below).

;; If you have just replaced a highlighted region with typed text,
;; you can repeat the replace with M-v.  This will search forward
;; for a stretch of text identical to the previous contents of the
;; region (i.e. the contents of register 0) and replace it with the
;; text you typed to replace the original region.  Repeating M-v will
;; replace the next matching region and so on.
;;
;; Example:  Suppose you have a line like this
;;   The redo operation will redo the last redoable command
;; which you want to change into
;;   The repeat operation will repeat the last repeatable command
;; This is done by highlighting the first occurrence of "redo"
;; and type "repeat" M-v M-v.


;; CUA mode indications
;; --------------------
;; You can choose to let CUA use different cursor colors to indicate
;; overwrite mode and read-only buffers.  For example, the following
;; setting will use a RED cursor in normal (insertion) mode in
;; read-write buffers, a YELLOW cursor in overwrite mode in read-write
;; buffers, and a GREEN cursor read-only buffers:
;;
;;  (setq cua-normal-cursor-color "red")
;;  (setq cua-overwrite-cursor-color "yellow")
;;  (setq cua-read-only-cursor-color "green")
;;

;; CUA register support
;; --------------------
;; Emacs's standard register support is also based on a separate set of
;; "register commands".
;;
;; CUA's register support is activated by providing a numeric
;; prefix argument to the C-x, C-c, and C-v commands.  For example,
;; to copy the selected region to register 2, enter [M-2 C-c].
;; Or if you have activated the keypad prefix mode, enter [kp-2 C-c].
;;
;; And CUA will copy and paste normal region as well as rectangles
;; into the registers, i.e. you use exactly the same command for both.
;;
;; In addition, the last highlighted text that is deleted (not
;; copied), e.g. by [delete] or by typing text over a highlighted
;; region, is automatically saved in register 0, so you can insert it
;; using [M-0 C-v].

;; CUA rectangle support
;; ---------------------
;; Emacs's normal rectangle support is based on interpreting the region
;; between the mark and point as a "virtual rectangle", and using a
;; completely separate set of "rectangle commands" [C-x r ...] on the
;; region to copy, kill, fill, and so on the virtual rectangle.
;;
;; cua-mode's superior rectangle support uses a true visual
;; representation of the selected rectangle, i.e. it highlights the
;; actual part of the buffer that is currently selected as part of the
;; rectangle.  Unlike Emacs's traditional rectangle commands, the
;; selected rectangle always as straight left and right edges, even
;; when those are in the middle of a TAB character or beyond the end
;; of the current line.  And it does this without actually modifying
;; the buffer contents (it uses display overlays to visualize the
;; virtual dimensions of the rectangle).
;;
;; This means that cua-mode's rectangles are not limited to the actual
;; contents of the buffer, so if the cursor is currently at the end of a
;; short line, you can still extend the rectangle to include more columns
;; of longer lines in the same rectangle.  And you can also have the
;; left edge of a rectangle start in the middle of a TAB character.
;; Sounds strange? Try it!
;;
;; To start a rectangle, use [C-return] and extend it using the normal
;; movement keys (up, down, left, right, home, end, C-home,
;; C-end).  Once the rectangle has the desired size, you can cut or
;; copy it using C-x and C-c (or C-w and M-w), and you can
;; subsequently insert it - as a rectangle - using C-v (or C-y).  So
;; the only new command you need to know to work with cua-mode
;; rectangles is C-return!
;;
;; Normally, when you paste a rectangle using C-v (C-y), each line of
;; the rectangle is inserted into the existing lines in the buffer.
;; If overwrite-mode is active when you paste a rectangle, it is
;; inserted as normal (multi-line) text.
;;
;; If you prefer the traditional rectangle marking (i.e. don't want
;; straight edges), [M-p] toggles this for the current rectangle,
;; or you can customize cua-virtual-rectangle-edges.

;; And there's more: If you want to extend or reduce the size of the
;; rectangle in one of the other corners of the rectangle, just use
;; [return] to move the cursor to the "next" corner.  Or you can use
;; the [M-up], [M-down], [M-left], and [M-right] keys to move the
;; entire rectangle overlay (but not the contents) in the given
;; direction.
;;
;; [C-return] cancels the rectangle
;; [C-space] activates the region bounded by the rectangle

;; If you type a normal (self-inserting) character when the rectangle is
;; active, the character is inserted on the "current side" of every line
;; of the rectangle.  The "current side" is the side on which the cursor
;; is currently located.  If the rectangle is only 1 column wide,
;; insertion will be performed to the left when the cursor is at the
;; bottom of the rectangle.  So, for example, to comment out an entire
;; paragraph like this one, just place the cursor on the first character
;; of the first line, and enter the following:
;;     C-return M-} ; ; <space>  C-return

;; cua-mode's rectangle support also includes all the normal rectangle
;; functions with easy access:
;;
;; [M-a] aligns all words at the left edge of the rectangle
;; [M-b] fills the rectangle with blanks (tabs and spaces)
;; [M-c] closes the rectangle by removing all blanks at the left edge
;;       of the rectangle
;; [M-f] fills the rectangle with a single character (prompt)
;; [M-i] increases the first number found on each line of the rectangle
;;       by the amount given by the numeric prefix argument (default 1)
;;       It recognizes 0x... as hexadecimal numbers
;; [M-k] kills the rectangle as normal multi-line text (for paste)
;; [M-l] downcases the rectangle
;; [M-m] copies the rectangle as normal multi-line text (for paste)
;; [M-n] fills each line of the rectangle with increasing numbers using
;;       a supplied format string (prompt)
;; [M-o] opens the rectangle by moving the highlighted text to the
;;       right of the rectangle and filling the rectangle with blanks.
;; [M-p] toggles virtual straight rectangle edges
;; [M-P] inserts tabs and spaces (padding) to make real straight edges
;; [M-q] performs text filling on the rectangle
;; [M-r] replaces REGEXP (prompt) by STRING (prompt) in rectangle
;; [M-R] reverse the lines in the rectangle
;; [M-s] fills each line of the rectangle with the same STRING (prompt)
;; [M-t] performs text fill of the rectangle with TEXT (prompt)
;; [M-u] upcases the rectangle
;; [M-|] runs shell command on rectangle
;; [M-'] restricts rectangle to lines with CHAR (prompt) at left column
;; [M-/] restricts rectangle to lines matching REGEXP (prompt)
;; [C-?] Shows a brief list of the above commands.

;; [M-C-up] and [M-C-down] scrolls the lines INSIDE the rectangle up
;; and down; lines scrolled outside the top or bottom of the rectangle
;; are lost, but can be recovered using [C-z].

;; CUA Global Mark
;; ---------------
;; The final feature provided by CUA is the "global mark", which
;; makes it very easy to copy bits and pieces from the same and other
;; files into the current text.  To enable and cancel the global mark,
;; use [S-C-space].  The cursor will blink when the global mark
;; is active.  The following commands behave differently when the global
;; mark is set:
;; <ch>  All characters (including newlines) you type are inserted
;;       at the global mark!
;; [C-x] If you cut a region or rectangle, it is automatically inserted
;;       at the global mark, and the global mark is advanced.
;; [C-c] If you copy a region or rectangle, it is immediately inserted
;;       at the global mark, and the global mark is advanced.
;; [C-v] Copies a single character to the global mark.
;; [C-d] Moves (i.e. deletes and inserts) a single character to the
;;       global mark.
;; [backspace] deletes the character before the global mark, while
;; [delete] deletes the character after the global mark.

;; [S-C-space] Jumps to and cancels the global mark.
;; [C-u S-C-space] Cancels the global mark (stays in current buffer).

;; [TAB] Indents the current line or rectangle to the column of the
;;       global mark.

;;; Code:

;;; Customization

(defgroup cua nil
  "Emulate CUA key bindings including C-x and C-c."
  :prefix "cua"
  :group 'editing-basics
  :group 'convenience
  :group 'emulations
  :version "22.1"
  :link '(emacs-commentary-link :tag "Commentary" "cua-base.el")
  :link '(emacs-library-link :tag "Lisp File" "cua-base.el"))

(defcustom cua-enable-cua-keys t
  "Enable using C-z, C-x, C-c, and C-v for undo, cut, copy, and paste.
If the value is t, these mappings are always enabled.  If the value is
`shift', these keys are only enabled if the last region was marked with
a shifted movement key.  If the value is nil, these keys are never
enabled."
  :type '(choice (const :tag "Disabled" nil)
		 (const :tag "Shift region only" shift)
		 (other :tag "Enabled" t)))

(defcustom cua-remap-control-v t
  "If non-nil, C-v binding is used for paste (yank).
Also, M-v is mapped to `delete-selection-repeat-replace-region'."
  :type 'boolean)

(defcustom cua-remap-control-z t
  "If non-nil, C-z binding is used for undo."
  :type 'boolean)

(defcustom cua-highlight-region-shift-only nil
  "If non-nil, only highlight region if marked with S-<move>.
When this is non-nil, CUA toggles `transient-mark-mode' on when the region
is marked using shifted movement keys, and off when the mark is cleared.
But when the mark was set using \\[cua-set-mark], Transient Mark mode
is not turned on."
  :type 'boolean)
(make-obsolete-variable 'cua-highlight-region-shift-only
                        'transient-mark-mode "24.4")

(defcustom cua-prefix-override-inhibit-delay 0.2
  "If non-nil, time in seconds to delay before overriding prefix key.
If there is additional input within this time, the prefix key is
used as a normal prefix key.  So typing a key sequence quickly will
inhibit overriding the prefix key.
As a special case, if the prefix key is repeated within this time, the
first prefix key is discarded, so typing a prefix key twice in quick
succession will also inhibit overriding the prefix key.
If the value is nil, use a shifted prefix key to inhibit the override."
  :type '(choice (number :tag "Inhibit delay")
		 (const :tag "No delay" nil)))

(defcustom cua-delete-selection t
  "If non-nil, typed text replaces text in the active selection."
  :type '(choice (const :tag "Disabled" nil)
		 (other :tag "Enabled" t)))

(defcustom cua-keep-region-after-copy nil
  "If non-nil, don't deselect the region after copying."
  :type 'boolean)

(defcustom cua-toggle-set-mark t
  "If non-nil, the `cua-set-mark' command toggles the mark."
  :type '(choice (const :tag "Disabled" nil)
		 (other :tag "Enabled" t)))

(defcustom cua-auto-mark-last-change nil
  "If non-nil, set implicit mark at position of last buffer change.
This means that \\[universal-argument] \\[cua-set-mark] will jump to the position
of the last buffer change before jumping to the explicit marks on the mark ring.
See `cua-set-mark' for details."
  :type 'boolean)

(defcustom cua-enable-register-prefix 'not-ctrl-u
  "If non-nil, registers are supported via numeric prefix arg.
If the value is t, any numeric prefix arg in the range 0 to 9 will be
interpreted as a register number.
If the value is `not-ctrl-u', using \\[universal-argument] to enter a numeric prefix is not
interpreted as a register number.
If the value is `ctrl-u-only', only numeric prefix entered with \\[universal-argument] is
interpreted as a register number."
  :type '(choice (const :tag "Disabled" nil)
		 (const :tag "Enabled, but C-u arg is not a register" not-ctrl-u)
		 (const :tag "Enabled, but only for C-u arg" ctrl-u-only)
		 (other :tag "Enabled" t)))

(defcustom cua-delete-copy-to-register-0 t
  ;; FIXME: Obey delete-selection-save-to-register rather than hardcoding
  ;; register 0.
  "If non-nil, save last deleted region or rectangle to register 0."
  :type 'boolean)

(defcustom cua-enable-region-auto-help nil
  "If non-nil, automatically show help for active region."
  :type 'boolean)

(defcustom cua-enable-modeline-indications nil
  "If non-nil, use minor-mode hook to show status in mode line."
  :type 'boolean)

(defcustom cua-check-pending-input t
  "If non-nil, don't override prefix key if input pending.
It is rumored that `input-pending-p' is unreliable under some window
managers, so try setting this to nil, if prefix override doesn't work."
  :type 'boolean)

(defcustom cua-paste-pop-rotate-temporarily nil
  "If non-nil, \\[cua-paste-pop] only rotates the kill ring temporarily.
This means that both \\[yank] and the first \\[yank-pop] in a sequence always
insert the most recently killed text.  Each immediately following \\[cua-paste-pop]
replaces the previous text with the next older element on the `kill-ring'.
With prefix arg, \\[universal-argument] \\[yank-pop] inserts the same text as the
most recent \\[yank-pop] (or \\[yank]) command."
  :type 'boolean)

;;; Rectangle Customization

(defcustom cua-virtual-rectangle-edges t
  "If non-nil, rectangles have virtual straight edges.
Note that although rectangles are always DISPLAYED with straight edges, the
buffer is NOT modified, until you execute a command that actually modifies it.
M-p toggles this feature when a rectangle is active."
  :type 'boolean)

(defcustom cua-auto-tabify-rectangles 1000
  "If non-nil, automatically tabify after rectangle commands.
This basically means that `tabify' is applied to all lines that
are modified by inserting or deleting a rectangle.  If value is
an integer, CUA will look for existing tabs in a region around
the rectangle, and only do the conversion if any tabs are already
present.  The number specifies then number of characters before
and after the region marked by the rectangle to search."
  :type '(choice (number :tag "Auto detect (limit)")
		 (const :tag "Disabled" nil)
		 (other :tag "Enabled" t)))

(defvar cua-global-keymap)		; forward
(defvar cua--region-keymap)		; forward
(declare-function cua-clear-rectangle-mark "cua-rect" ())
(declare-function cua-mouse-set-rectangle-mark "cua-rect" (event))

(defcustom cua-rectangle-mark-key [(control return)]
  "Global key used to toggle the cua rectangle mark."
  :set (lambda (symbol value)
         (set symbol value)
         (when (and (boundp 'cua--keymaps-initialized)
                    cua--keymaps-initialized)
           (define-key cua-global-keymap value
             #'cua-set-rectangle-mark)
           (when (boundp 'cua--rectangle-keymap)
             (define-key cua--rectangle-keymap value
               #'cua-clear-rectangle-mark)
             (define-key cua--region-keymap value
               #'cua-toggle-rectangle-mark))))
  :type 'key-sequence)

(defcustom cua-rectangle-modifier-key 'meta
  "Modifier key used for rectangle commands bindings.
On non-window systems, use `cua-rectangle-terminal-modifier-key'.
Must be set prior to enabling CUA."
  :type '(choice (const :tag "Meta key" meta)
		 (const :tag "Alt key" alt)
		 (const :tag "Hyper key" hyper)
		 (const :tag "Super key" super)))

(defcustom cua-rectangle-terminal-modifier-key 'meta
  "Modifier key used for rectangle commands bindings in terminals.
Must be set prior to enabling CUA."
  :type '(choice (const :tag "Meta key" meta)
		 (const :tag "Alt key" alt)
		 (const :tag "Hyper key" hyper)
		 (const :tag "Super key" super))
  :version "27.1")

(defcustom cua-enable-rectangle-auto-help t
  "If non-nil, automatically show help for region, rectangle and global mark."
  :type 'boolean)

(defface cua-rectangle
  '((default :inherit region)
    (((class color)) :foreground "white" :background "maroon"))
  "Font used by CUA for highlighting the rectangle.")

(defface cua-rectangle-noselect
  '((default :inherit region)
    (((class color)) :foreground "white" :background "dimgray"))
  "Font used by CUA for highlighting the non-selected rectangle lines.")


;;; Global Mark Customization

(defcustom cua-global-mark-keep-visible t
  "If non-nil, always keep global mark visible in other window."
  :type 'boolean)

(defface cua-global-mark
  '((((min-colors 88)(class color)) :foreground "black" :background "yellow1")
    (((class color)) :foreground "black" :background "yellow")
    (t :weight bold))
  "Font used by CUA for highlighting the global mark.")

(defcustom cua-global-mark-blink-cursor-interval 0.20
  "Blink cursor at this interval when global mark is active."
  :type '(choice (number :tag "Blink interval")
		 (const :tag "No blink" nil)))


;;; Cursor Indication Customization

(defcustom cua-enable-cursor-indications nil
  "If non-nil, use different cursor colors for indications."
  :type 'boolean)

(defcustom cua-normal-cursor-color (or (and (boundp 'initial-cursor-color) initial-cursor-color)
				       (and (boundp 'initial-frame-alist)
					    (assoc 'cursor-color initial-frame-alist)
					    (cdr (assoc 'cursor-color initial-frame-alist)))
				       (and (boundp 'default-frame-alist)
					    (assoc 'cursor-color default-frame-alist)
					    (cdr (assoc 'cursor-color default-frame-alist)))
				       (frame-parameter nil 'cursor-color)
				       "red")
  "Normal (non-overwrite) cursor color.
Default is to load cursor color from initial or default frame parameters.

If the value is a COLOR name, then only the `cursor-color' attribute will be
affected.  If the value is a cursor TYPE (one of: box, hollow, bar, or hbar),
then only the `cursor-type' property will be affected.  If the value is
a cons (TYPE . COLOR), then both properties are affected."
  :initialize #'custom-initialize-default
  :type '(choice
	  (color :tag "Color")
	  (choice :tag "Type"
		  (const :tag "Filled box" box)
		  (const :tag "Vertical bar" bar)
		  (const :tag "Horizontal bar" hbar)
		  (const :tag "Hollow box" hollow))
	  (cons :tag "Color and Type"
		(choice :tag "Type"
			(const :tag "Filled box" box)
			(const :tag "Vertical bar" bar)
			(const :tag "Horizontal bar" hbar)
			(const :tag "Hollow box" hollow))
		(color :tag "Color"))))

(defcustom cua-read-only-cursor-color "darkgreen"
  "Cursor color used in read-only buffers, if non-nil.
Only used when `cua-enable-cursor-indications' is non-nil.

If the value is a COLOR name, then only the `cursor-color' attribute will be
affected.  If the value is a cursor TYPE (one of: box, hollow, bar, or hbar),
then only the `cursor-type' property will be affected.  If the value is
a cons (TYPE . COLOR), then both properties are affected."
  :type '(choice
	  (color :tag "Color")
	  (choice :tag "Type"
		  (const :tag "Filled box" box)
		  (const :tag "Vertical bar" bar)
		  (const :tag "Horizontal bar" hbar)
		  (const :tag "Hollow box" hollow))
	  (cons :tag "Color and Type"
		(choice :tag "Type"
			(const :tag "Filled box" box)
			(const :tag "Vertical bar" bar)
			(const :tag "Horizontal bar" hbar)
			(const :tag "Hollow box" hollow))
		(color :tag "Color"))))

(defcustom cua-overwrite-cursor-color "yellow"
  "Cursor color used when overwrite mode is set, if non-nil.
Only used when `cua-enable-cursor-indications' is non-nil.

If the value is a COLOR name, then only the `cursor-color' attribute will be
affected.  If the value is a cursor TYPE (one of: box, hollow, bar, or hbar),
then only the `cursor-type' property will be affected.  If the value is
a cons (TYPE . COLOR), then both properties are affected."
  :type '(choice
	  (color :tag "Color")
	  (choice :tag "Type"
		  (const :tag "Filled box" box)
		  (const :tag "Vertical bar" bar)
		  (const :tag "Horizontal bar" hbar)
		  (const :tag "Hollow box" hollow))
	  (cons :tag "Color and Type"
		(choice :tag "Type"
			(const :tag "Filled box" box)
			(const :tag "Vertical bar" bar)
			(const :tag "Horizontal bar" hbar)
			(const :tag "Hollow box" hollow))
		(color :tag "Color"))))

(defcustom cua-global-mark-cursor-color "cyan"
  "Indication for active global mark.
Will change cursor color to specified color if string.
Only used when `cua-enable-cursor-indications' is non-nil.

If the value is a COLOR name, then only the `cursor-color' attribute will be
affected.  If the value is a cursor TYPE (one of: box, hollow, bar, or hbar),
then only the `cursor-type' property will be affected.  If the value is
a cons (TYPE . COLOR), then both properties are affected."
  :type '(choice
	  (color :tag "Color")
	  (choice :tag "Type"
		  (const :tag "Filled box" box)
		  (const :tag "Vertical bar" bar)
		  (const :tag "Horizontal bar" hbar)
		  (const :tag "Hollow box" hollow))
	  (cons :tag "Color and Type"
		(choice :tag "Type"
			(const :tag "Filled box" box)
			(const :tag "Vertical bar" bar)
			(const :tag "Horizontal bar" hbar)
			(const :tag "Hollow box" hollow))
		(color :tag "Color"))))


;;; Rectangle support is in cua-rect.el

(autoload 'cua-set-rectangle-mark "cua-rect"
  "Start rectangle at mouse click position." t nil)
(autoload 'cua-toggle-rectangle-mark "cua-rect" nil t)

;; Stub definitions until it is loaded
(defvar cua--rectangle)
(defvar cua--last-killed-rectangle)
(unless (featurep 'cua-rect)
  (setq cua--rectangle nil
        cua--last-killed-rectangle nil))

;; All behind cua--rectangle tests.
(declare-function cua--rectangle-left   "cua-rect" (&optional val))
(declare-function cua--delete-rectangle "cua-rect" ())
(declare-function cua--insert-rectangle "cua-rect"
                  (rect &optional below paste-column line-count))
(declare-function cua--rectangle-corner "cua-rect" (&optional advance))
(declare-function cua--rectangle-assert "cua-rect" ())

;;; Global Mark support is in cua-gmrk.el

(autoload 'cua-toggle-global-mark "cua-gmrk" nil t nil)

;; Stub definitions until cua-gmrk.el is loaded
(defvar cua--global-mark-active)
(unless (featurep 'cua-gmrk)
  (setq cua--global-mark-active nil))

(declare-function cua--insert-at-global-mark    "cua-gmrk" (str &optional msg))
(declare-function cua--global-mark-post-command "cua-gmrk" ())


;;; Low-level Interface

(defvar-local cua-inhibit-cua-keys nil
  "Buffer-local variable that may disable the CUA keymappings.")

;;; Aux. variables

;; buffer + point prior to current command when rectangle is active
;; checked in post-command hook to see if point was moved
(defvar cua--buffer-and-point-before-command nil)

(defvar-local cua--status-string nil
  "Status string for mode line indications.")

(defvar cua--debug nil)


;;; Prefix key override mechanism

;; The prefix override (when mark-active) operates in three substates:
;; [1] Before using a prefix key
;; [2] Immediately after using a prefix key
;; [3] A fraction of a second later

;; In state [1], the cua--prefix-override-keymap is active.
;; This keymap binds the C-x and C-c prefix keys to the
;; cua--prefix-override-handler function.

;; When a prefix key is typed in state [1], cua--prefix-override-handler
;; will push back the keys already read to the event queue.  If input is
;; pending, it changes directly to state [3].  Otherwise, a short timer [T]
;; is started, and it changes to state [2].

;; In state [2], the cua--prefix-override-keymap is inactive.  Instead the
;; cua--prefix-repeat-keymap is active.  This keymap binds C-c C-c and C-x
;; C-x to the cua--prefix-repeat-handler function.

;; If the prefix key is repeated in state [2], cua--prefix-repeat-handler
;; will cancel [T], back the keys already read (except for the second prefix
;; keys) to the event queue, and changes to state [3].

;; The basic cua--cua-keys-keymap binds [C-x timeout] to kill-region and
;; [C-c timeout] to copy-region-as-kill, so if [T] times out in state [2],
;; the cua--prefix-override-timeout function will push a `timeout' event on
;; the event queue, and changes to state [3].

;; In state [3] both cua--prefix-override-keymap and cua--prefix-repeat-keymap
;; are inactive, so the timeout in cua-global-keymap binding is used, or the
;; normal prefix key binding from the global or local map will be used.

;; The pre-command hook (executed as a consequence of the timeout or normal
;; prefix key binding) will cancel [T] and change from state [3] back to
;; state [1].  So cua--prefix-override-handler and cua--prefix-repeat-handler
;; are always called with state reset to [1]!

;; State [1] is recognized by cua--prefix-override-timer is nil,
;; state [2] is recognized by cua--prefix-override-timer is a timer, and
;; state [3] is recognized by cua--prefix-override-timer is t.

(defvar cua--prefix-override-timer nil)
(defvar cua--prefix-override-length nil)

(defun cua--prefix-override-replay (repeat)
  (let* ((keys (this-command-keys))
	 (i (length keys))
	 (key (aref keys (1- i))))
    (setq cua--prefix-override-length (- i repeat))
    (setq cua--prefix-override-timer
	  (or
	   ;; In state [2], change to state [3]
	   (> repeat 0)
	   ;; In state [1], change directly to state [3]
	   (and cua-check-pending-input (input-pending-p))
	   ;; In state [1], [T] disabled, so change to state [3]
	   (not (numberp cua-prefix-override-inhibit-delay))
	   (<= cua-prefix-override-inhibit-delay 0)
	   ;; In state [1], start [T] and change to state [2]
	   (run-with-timer cua-prefix-override-inhibit-delay nil
			   #'cua--prefix-override-timeout)))
    ;; Don't record this command
    (setq this-command last-command)
    ;; Restore the prefix arg
    ;; This should make it so that exchange-point-and-mark gets the prefix when
    ;; you do C-u C-x C-x C-x work (where the C-u is properly passed to the C-x
    ;; C-x binding after the first C-x C-x was rewritten to just C-x).
    (prefix-command-preserve-state)
    ;; Push the key back on the event queue
    (setq unread-command-events (cons (cons 'no-record key)
                                      unread-command-events))))

(defun cua--prefix-override-handler ()
  "Start timer waiting for prefix key to be followed by another key.
Repeating prefix key when region is active works as a single prefix key."
  (interactive)
  (cua--prefix-override-replay 0))

;; These two functions are so that we can look up the commands and find the
;; correct keys when generating menus.  Also, when cua--prefix-override-handler
;; is nil, allow C-x C-c to cut/copy immediately without waiting for
;; cua--prefix-override-timer to expire.
(declare-function cua-cut-to-global-mark "cua-gmrk")
(declare-function cua-copy-to-global-mark "cua-gmrk")
(defun cua--copy-or-cut-handler (&optional cut)
  (if (or (not (numberp cua-prefix-override-inhibit-delay))
          (<= cua-prefix-override-inhibit-delay 0))
      (cond ((and (bound-and-true-p cua--global-mark-active))
             (funcall (if cut #'cua-cut-to-global-mark
                        #'cua-copy-to-global-mark)))
            (t (call-interactively (if cut #'kill-region
                                     #'copy-region-as-kill))))
    (cua--prefix-override-handler)))

(defun cua-cut-handler ()
  (interactive)
  (cua--copy-or-cut-handler t))

(defun cua-copy-handler ()
  (interactive)
  (cua--copy-or-cut-handler))

(defun cua--prefix-repeat-handler ()
  "Repeating prefix key when region is active works as a single prefix key."
  (interactive)
  (cua--prefix-override-replay 1))

(defun cua--prefix-copy-handler (arg)
  "Copy region/rectangle, then replay last key."
  (interactive "P")
  (cua-copy-region arg)
  (let ((keys (this-single-command-keys)))
    (setq unread-command-events
	  (cons (aref keys (1- (length keys))) unread-command-events))))

(defun cua--prefix-cut-handler (arg)
  "Cut region/rectangle, then replay last key."
  (interactive "P")
  (cua-cut-region arg)
  (let ((keys (this-single-command-keys)))
    (setq unread-command-events
	  (cons (aref keys (1- (length keys))) unread-command-events))))

(defun cua--prefix-override-timeout ()
  (setq cua--prefix-override-timer t)
  (when (= (length (this-command-keys)) cua--prefix-override-length)
    (setq unread-command-events (cons 'timeout unread-command-events))
    (if prefix-arg
        nil
      ;; FIXME: Why?
      (setq overriding-terminal-local-map nil))
    (cua--select-keymaps)))


;;; Aux. functions

(defun cua--fallback ()
  ;; Execute original command
  (setq this-command this-original-command)
  (call-interactively this-command))

(defun cua--keep-active ()
  (when (mark t)
    (setq mark-active t
          deactivate-mark nil)))

(defun cua--deactivate (&optional now)
  (if (not now)
      (setq deactivate-mark t)
    (deactivate-mark)))

(defun cua--filter-buffer-noprops (start end)
  (let ((str (filter-buffer-substring start end)))
    (set-text-properties 0 (length str) nil str)
    str))

;; The current register prefix
(defvar cua--register nil)

(defun cua--prefix-arg (arg)
  (setq cua--register
	(and cua-enable-register-prefix
	     (integerp arg) (>= arg 0) (< arg 10)
	     (let* ((prefix (aref (this-command-keys) 0))
		    (ctrl-u-prefix (and (integerp prefix)
					(= prefix ?\C-u))))
	       (cond
		((eq cua-enable-register-prefix 'not-ctrl-u)
		 (not ctrl-u-prefix))
		((eq cua-enable-register-prefix 'ctrl-u-only)
		 ctrl-u-prefix)
		(t t)))
	     (+ arg ?0)))
  (if cua--register nil arg))


;;; Region specific commands

(declare-function delete-active-region "delsel" (&optional killp))

(defun cua-delete-region ()
  "Delete the active region.
Save a copy in register 0 if `cua-delete-copy-to-register-0' is non-nil."
  (interactive)
  (require 'delsel)
  (delete-active-region))

(defun cua-copy-region (arg)
  "Copy the region to the kill ring.
With numeric prefix arg, copy to register 0-9 instead."
  (interactive "P")
  (setq arg (cua--prefix-arg arg))
  (setq cua--last-killed-rectangle nil)
  (let ((start (mark)) (end (point)))
    (or (<= start end)
	(setq start (prog1 end (setq end start))))
    (cond
     (cua--register
      (copy-to-register cua--register start end nil 'region))
     ((eq this-original-command 'clipboard-kill-ring-save)
      (clipboard-kill-ring-save start end 'region))
     (t
      (copy-region-as-kill start end 'region)))
    (if cua-keep-region-after-copy
	(cua--keep-active)
      (cua--deactivate))))

(defun cua-cut-region (arg)
  "Cut the region and copy to the kill ring.
With numeric prefix arg, copy to register 0-9 instead."
  (interactive "P")
  (setq cua--last-killed-rectangle nil)
  (if buffer-read-only
      (cua-copy-region arg)
    (setq arg (cua--prefix-arg arg))
    (let ((start (mark)) (end (point)))
      (or (<= start end)
	  (setq start (prog1 end (setq end start))))
      (cond
       (cua--register
	(copy-to-register cua--register start end t 'region))
       ((eq this-original-command 'clipboard-kill-region)
	(clipboard-kill-region start end 'region))
       (t
	(kill-region start end 'region))))
    (cua--deactivate)))

;;; Generic commands for regions, rectangles, and global marks

(defun cua-cancel ()
  "Cancel the active region, rectangle, or global mark."
  (interactive)
  (deactivate-mark)
  (if (fboundp 'cua--cancel-rectangle)
      (cua--cancel-rectangle)))

(put 'cua-paste 'delete-selection 'yank)
(defun cua-paste (arg)
  "Paste last cut or copied region or rectangle.
An active region is deleted before executing the command.
With numeric prefix arg, paste from register 0-9 instead.
If global mark is active, copy from register or one character."
  (interactive "P")
  (setq arg (cua--prefix-arg arg))
  (let ((regtxt (and cua--register (get-register cua--register)))
	(count (prefix-numeric-value arg)))
    (cond
     ((and cua--register (not regtxt))
      (message "Nothing in register %c" cua--register))
     (cua--global-mark-active
      (if regtxt
	  (cua--insert-at-global-mark regtxt)
	(when (not (eobp))
	  (cua--insert-at-global-mark
           (filter-buffer-substring (point) (+ (point) count)))
	  (forward-char count))))
     (buffer-read-only
      (error "Cannot paste into a read-only buffer"))
     (t
      (cond
       (regtxt
	(cond
	 ;; This being a cons implies cua-rect is loaded?
	 ((consp regtxt) (cua--insert-rectangle regtxt))
	 ((stringp regtxt) (insert-for-yank regtxt))
	 (t (message "Unknown data in register %c" cua--register))))
       ((memq this-original-command '(clipboard-yank x-clipboard-yank))
        (funcall this-original-command))
       (t (yank arg)))))))


;; cua-paste-pop-rotate-temporarily == t mechanism:
;;
;; C-y M-y M-y => only rotates kill ring temporarily,
;;                so next C-y yanks what previous C-y yanked,
;;
;; M-y M-y M-y => equivalent to C-y M-y M-y
;;
;; But: After another command, C-u M-y remembers the temporary
;;      kill-ring position, so
;; C-u M-y     => yanks what the last M-y yanked
;;

(defvar cua-paste-pop-count nil)

(defun cua-paste-pop (arg)
  "Replace a just-pasted text or rectangle with a different text.
See `yank-pop' for details about the default behavior.  For an alternative
behavior, see `cua-paste-pop-rotate-temporarily'."
  (interactive "P")
  (cond
   ((eq last-command 'cua--paste-rectangle)
    (undo)
    (yank arg))
   ((not cua-paste-pop-rotate-temporarily)
    (yank-pop (prefix-numeric-value arg)))
   (t
    (let ((rotate (if (consp arg) 1 (prefix-numeric-value arg))))
      (cond
       ((or (null cua-paste-pop-count)
	    (eq last-command 'yank)
	    (eq last-command 'cua-paste))
	(setq cua-paste-pop-count rotate)
	(setq last-command 'yank)
	(yank-pop cua-paste-pop-count))
       ((and (eq last-command 'cua-paste-pop) (not (consp arg)))
	(setq cua-paste-pop-count (+ cua-paste-pop-count rotate))
	(setq last-command 'yank)
	(yank-pop cua-paste-pop-count))
       (t
	(setq cua-paste-pop-count
	      (if (consp arg) (+ cua-paste-pop-count rotate -1) 1))
	(yank (1+ cua-paste-pop-count)))))
    ;; Undo rotating the kill-ring, so next C-y will
    ;; yank the original head.
    (setq kill-ring-yank-pointer kill-ring)
    (setq this-command 'cua-paste-pop))))

(defun cua-exchange-point-and-mark (arg)
  "Exchange point and mark.
Don't activate the mark if `cua-enable-cua-keys' is non-nil.
Otherwise, just activate the mark if a prefix ARG is given.

See also `exchange-point-and-mark'."
  (interactive "P")
  (cond ((null cua-enable-cua-keys)
	 (exchange-point-and-mark arg))
	(arg
         (when (mark t) (setq mark-active t)))
	(t
	 (let (mark-active)
	   (exchange-point-and-mark)
       (if cua--rectangle
           (cua--rectangle-corner 0))))))

(defun cua-help-for-region (&optional help)
  "Show region specific help in echo area."
  (interactive)
  (message
   (concat (if help "C-?:help " "")
	   "C-z:undo C-x:cut C-c:copy C-v:paste S-ret:rect")))


;;; Shift activated / extended region

(defun cua-pop-to-last-change ()
  (let ((undo-list buffer-undo-list)
	pos elt)
    (while (and (not pos)
		(consp undo-list))
      (setq elt (car undo-list)
	    undo-list (cdr undo-list))
      (cond
       ((integerp elt)
	(setq pos elt))
       ((not (consp elt)))
       ((and (integerp (cdr elt))
	     (or (integerp (car elt)) (stringp (car elt))))
	(setq pos (cdr elt)))
       ((and (eq (car elt) 'apply) (consp (cdr elt)) (integerp (cadr elt)))
	(setq pos (nth 3 elt)))))
    (when (and pos
	       (/= pos (point))
	       (>= pos (point-min)) (<= pos (point-max)))
      (goto-char pos)
      t)))

(defun cua-set-mark (&optional arg)
  "Set mark at where point is, clear mark, or jump to mark.

With no prefix argument, clear mark if already set.  Otherwise, set
mark, and push old mark position on local mark ring; also push mark on
global mark ring if last mark was set in another buffer.

With argument, jump to mark, and pop a new position for mark off
the local mark ring (this does not affect the global mark ring).
Use \\[pop-global-mark] to jump to a mark off the global mark ring
\(see `pop-global-mark').

If `cua-auto-mark-last-change' is non-nil, this command behaves as if there
was an implicit mark at the position of the last buffer change.

Repeating the command without the prefix jumps to the next position
off the local (or global) mark ring.

With a double \\[universal-argument] prefix argument, unconditionally set mark."
  (interactive "P")
  (cond
   ((and (consp arg) (> (prefix-numeric-value arg) 4))
    (push-mark-command nil))
   ((eq last-command 'pop-to-mark-command)
    (setq this-command 'pop-to-mark-command)
    (pop-to-mark-command))
   ((and (eq last-command 'pop-global-mark) (not arg))
    (setq this-command 'pop-global-mark)
    (pop-global-mark))
   (arg
    (setq this-command 'pop-to-mark-command)
    (or (and cua-auto-mark-last-change
	     (cua-pop-to-last-change))
	(pop-to-mark-command)))
   ((and cua-toggle-set-mark (region-active-p))
    (cua--deactivate)
    (message "Mark cleared"))
   (t
    (push-mark-command nil nil)
    (if cua-enable-region-auto-help
	(cua-help-for-region t)))))

;; Scrolling commands which do not signal errors at top/bottom
;; of buffer at first key-press (instead moves to top/bottom
;; of buffer).

(defun cua-scroll-up (&optional arg)
  "Scroll text of current window upward ARG lines; or near full screen if no ARG.
If window cannot be scrolled further, move cursor to bottom line instead.
A near full screen is `next-screen-context-lines' less than a full screen.
Negative ARG means scroll downward.
If ARG is the atom `-', scroll downward by nearly full screen."
  (interactive "^P")
  (cond
   ((eq arg '-) (cua-scroll-down nil))
   ((< (prefix-numeric-value arg) 0)
    (cua-scroll-down (- (prefix-numeric-value arg))))
   ((eobp)
    (scroll-up arg))  ; signal error
   (t
    (condition-case nil
	(scroll-up arg)
      (end-of-buffer (goto-char (point-max)))))))

(put 'cua-scroll-up 'isearch-scroll t)

(defun cua-scroll-down (&optional arg)
  "Scroll text of current window downward ARG lines; or near full screen if no ARG.
If window cannot be scrolled further, move cursor to top line instead.
A near full screen is `next-screen-context-lines' less than a full screen.
Negative ARG means scroll upward.
If ARG is the atom `-', scroll upward by nearly full screen."
  (interactive "^P")
  (cond
   ((eq arg '-) (cua-scroll-up nil))
   ((< (prefix-numeric-value arg) 0)
    (cua-scroll-up (- (prefix-numeric-value arg))))
   ((bobp)
    (scroll-down arg))  ; signal error
   (t
    (condition-case nil
	(scroll-down arg)
      (beginning-of-buffer (goto-char (point-min)))))))

(put 'cua-scroll-down 'isearch-scroll t)

;;; Cursor indications

(defun cua--update-indications ()
  (let* ((cursor
	  (cond
	   ((and cua--global-mark-active
		 cua-global-mark-cursor-color)
	    cua-global-mark-cursor-color)
	   ((and buffer-read-only
		 cua-read-only-cursor-color)
	    cua-read-only-cursor-color)
	   ((and cua-overwrite-cursor-color overwrite-mode)
	    cua-overwrite-cursor-color)
	   (t cua-normal-cursor-color)))
	 (color (if (consp cursor) (cdr cursor) cursor))
	 (type (if (consp cursor) (car cursor) cursor)))
    (if (and color
	     (stringp color)
	     (not (equal color (frame-parameter nil 'cursor-color))))
	(set-cursor-color color))
    (if (and type
	     (symbolp type)
	     (not (eq type (default-value 'cursor-type))))
	(setq-default cursor-type type))))


;;; Pre-command hook

(defun cua--pre-command-handler-1 ()
  ;; Cancel prefix key timeout if user enters another key.
  (when cua--prefix-override-timer
    (if (timerp cua--prefix-override-timer)
	(cancel-timer cua--prefix-override-timer))
    (setq cua--prefix-override-timer nil))

  ;; Detect extension of rectangles by mouse or other movement
  (setq cua--buffer-and-point-before-command
	(if cua--rectangle (cons (current-buffer) (point)))))

(defun cua--pre-command-handler ()
  (when cua-mode
    (condition-case nil
	(cua--pre-command-handler-1)
    (error nil))))

;;; Post-command hook

(defun cua--post-command-handler-1 ()
  (when cua--global-mark-active
    (cua--global-mark-post-command))
  (when (fboundp 'cua--rectangle-post-command)
    (cua--rectangle-post-command))
  (setq cua--buffer-and-point-before-command nil)

  ;; Debugging
  (if cua--debug
      (cond
       (cua--rectangle (cua--rectangle-assert))
       ((region-active-p) (message "Mark=%d Point=%d" (mark t) (point)))))

  (if cua-enable-cursor-indications
      (cua--update-indications))

  (cua--select-keymaps))

(defun cua--post-command-handler ()
  (when cua-mode
    (condition-case nil
	(cua--post-command-handler-1)
      (error nil))))


;;; Keymaps

;; Cached value of actual cua-rectangle-modifier-key
(defvar cua--rectangle-modifier-key 'meta)

(defun cua--M/H-key (map key fct)
  ;; bind H-KEY or M-KEY to FCT in MAP
  (setq key (ensure-list key))
  (define-key map (vector (cons cua--rectangle-modifier-key key)) fct))

(defun cua--self-insert-char-p (def)
  ;; Return DEF if current key sequence is self-inserting in
  ;; global-map.
  (if (memq (global-key-binding (this-single-command-keys))
	    '(self-insert-command))
      def nil))

(defvar-keymap cua-global-keymap
  :doc "Global keymap for `cua-mode'; users may add to this keymap.")

(defvar-keymap cua--cua-keys-keymap)
(defvar-keymap cua--prefix-override-keymap)
(defvar-keymap cua--prefix-repeat-keymap)
(defvar-keymap cua--global-mark-keymap) ; Initialized when cua-gmrk.el is loaded
(defvar-keymap cua--rectangle-keymap)   ; Initialized when cua-rect.el is loaded
(defvar-keymap cua--region-keymap)

(defvar cua--ena-cua-keys-keymap nil)
(defvar cua--ena-prefix-override-keymap nil)
(defvar cua--ena-prefix-repeat-keymap nil)
(defvar cua--ena-region-keymap nil)
(defvar cua--ena-global-mark-keymap nil)

(defvar cua--keymap-alist
  `((cua--ena-prefix-override-keymap . ,cua--prefix-override-keymap)
    (cua--ena-prefix-repeat-keymap . ,cua--prefix-repeat-keymap)
    (cua--ena-cua-keys-keymap . ,cua--cua-keys-keymap)
    (cua--ena-global-mark-keymap . ,cua--global-mark-keymap)
    (cua--rectangle . ,cua--rectangle-keymap)
    (cua--ena-region-keymap . ,cua--region-keymap)
    (cua-mode . ,cua-global-keymap)))

(defun cua--select-keymaps ()
  ;; Setup conditions for selecting the proper keymaps in cua--keymap-alist.
  (setq cua--ena-region-keymap
	(and (region-active-p) (not deactivate-mark)))
  (setq cua--ena-prefix-override-keymap
	(and cua--ena-region-keymap
	     cua-enable-cua-keys
	     (not cua-inhibit-cua-keys)
	     (or (eq cua-enable-cua-keys t)
		 (region-active-p))
	     (not executing-kbd-macro)
	     (not cua--prefix-override-timer)))
  (setq cua--ena-prefix-repeat-keymap
	(and cua--ena-region-keymap
	     (or (timerp cua--prefix-override-timer)
		 (eq cua--prefix-override-timer 'shift))))
  (setq cua--ena-cua-keys-keymap
	(and cua-enable-cua-keys
	     (not cua-inhibit-cua-keys)
	     (or (eq cua-enable-cua-keys t)
		 (region-active-p))))
  (setq cua--ena-global-mark-keymap
	(and cua--global-mark-active
	     (not (window-minibuffer-p)))))

(defvar cua--keymaps-initialized nil)

(defun cua--shift-control-prefix (prefix)
  ;; handle S-C-x and S-C-c by emulating the fast double prefix function.
  ;; Don't record this command
  (setq this-command last-command)
  ;; Restore the prefix arg
  ;; This should make it so that exchange-point-and-mark gets the prefix when
  ;; you do C-u S-C-x C-x work (where the C-u is properly passed to the C-x
  ;; C-x binding after the first S-C-x was rewritten to just C-x).
  (prefix-command-preserve-state)
  ;; Activate the cua--prefix-repeat-keymap
  (setq cua--prefix-override-timer 'shift)
  ;; Push duplicate keys back on the event queue
  (setq unread-command-events
        (cons prefix (cons prefix unread-command-events))))

(defun cua--shift-control-c-prefix ()
  (interactive)
  (cua--shift-control-prefix ?\C-c))

(defun cua--shift-control-x-prefix ()
  (interactive)
  (cua--shift-control-prefix ?\C-x))

(declare-function delete-selection-repeat-replace-region "delsel" (arg))

(defun cua--init-keymaps ()
  ;; Cache actual rectangle modifier key.
  (setq cua--rectangle-modifier-key
	(if (eq (framep (selected-frame)) t)
	    cua-rectangle-terminal-modifier-key
	  cua-rectangle-modifier-key))
  ;; C-return always toggles rectangle mark
  (define-key cua-global-keymap cua-rectangle-mark-key #'cua-set-rectangle-mark)
  (unless (eq cua--rectangle-modifier-key 'meta)
    (cua--M/H-key cua-global-keymap ?\s		       #'cua-set-rectangle-mark)
    (define-key cua-global-keymap
      (vector (list cua--rectangle-modifier-key 'mouse-1))
      #'cua-mouse-set-rectangle-mark))

  (define-key cua-global-keymap [(shift control ?\s)]  #'cua-toggle-global-mark)

  ;; replace region with rectangle or element on kill ring
  (define-key cua-global-keymap [remap yank]		 #'cua-paste)
  (define-key cua-global-keymap [remap clipboard-yank]	 #'cua-paste)
  (define-key cua-global-keymap [remap x-clipboard-yank] #'cua-paste)
  ;; replace current yank with previous kill ring element
  (define-key cua-global-keymap [remap yank-pop]	       #'cua-paste-pop)
  ;; set mark
  (define-key cua-global-keymap [remap set-mark-command]       #'cua-set-mark)
  (define-key cua-global-keymap [remap exchange-point-and-mark]
    #'cua-exchange-point-and-mark)

  ;; scrolling
  (define-key cua-global-keymap [remap scroll-up]	#'cua-scroll-up)
  (define-key cua-global-keymap [remap scroll-down]	#'cua-scroll-down)
  (define-key cua-global-keymap [remap scroll-up-command]   #'cua-scroll-up)
  (define-key cua-global-keymap [remap scroll-down-command] #'cua-scroll-down)

  (define-key cua--cua-keys-keymap [(control x) timeout] #'kill-region)
  (define-key cua--cua-keys-keymap [(control c) timeout] #'copy-region-as-kill)
  (when cua-remap-control-z
    (define-key cua--cua-keys-keymap [(control z)] #'undo))
  (when cua-remap-control-v
    (define-key cua--cua-keys-keymap [(control v)] #'yank)
    (define-key cua--cua-keys-keymap [(meta v)]
      #'delete-selection-repeat-replace-region))

  (define-key cua--prefix-override-keymap [(control x)] #'cua-cut-handler)
  (define-key cua--prefix-override-keymap [(control c)] #'cua-copy-handler)

  (define-key cua--prefix-repeat-keymap [(control x) (control x)]
    #'cua--prefix-repeat-handler)
  (define-key cua--prefix-repeat-keymap [(control c) (control c)]
    #'cua--prefix-repeat-handler)
  (dolist (key '(up down left right home end next prior))
    (define-key cua--prefix-repeat-keymap (vector '(control x) key)
      #'cua--prefix-cut-handler)
    (define-key cua--prefix-repeat-keymap (vector '(control c) key)
      #'cua--prefix-copy-handler))

  ;; Enable shifted fallbacks for C-x and C-c when region is active
  (define-key cua--region-keymap [(shift control x)]
    #'cua--shift-control-x-prefix)
  (define-key cua--region-keymap [(shift control c)]
    #'cua--shift-control-c-prefix)

  ;; delete current region
  (define-key cua--region-keymap [remap delete-backward-char]
    #'cua-delete-region)
  (define-key cua--region-keymap [remap backward-delete-char]
    #'cua-delete-region)
  (define-key cua--region-keymap [remap backward-delete-char-untabify]
    #'cua-delete-region)
  (define-key cua--region-keymap [remap delete-char]
    #'cua-delete-region)
  (define-key cua--region-keymap [remap delete-forward-char]
    #'cua-delete-region)
  ;; kill region
  (define-key cua--region-keymap [remap kill-region]	       #'cua-cut-region)
  (define-key cua--region-keymap [remap clipboard-kill-region] #'cua-cut-region)
  ;; copy region
  (define-key cua--region-keymap [remap copy-region-as-kill]  #'cua-copy-region)
  (define-key cua--region-keymap [remap kill-ring-save]	      #'cua-copy-region)
  (define-key cua--region-keymap [remap clipboard-kill-ring-save]
    #'cua-copy-region)
  ;; cancel current region/rectangle
  (define-key cua--region-keymap [remap keyboard-escape-quit]	#'cua-cancel)
  (define-key cua--region-keymap [remap keyboard-quit]		#'cua-cancel)
  )


;; State prior to enabling cua-mode
;; Value is a list with the following elements:
;;   delete-selection-mode

(defvar cua--saved-state nil)
(defvar delete-selection-save-to-register)

;;;###autoload
(define-minor-mode cua-mode
  "Toggle Common User Access style editing (CUA mode).

CUA mode is a global minor mode.  When enabled, typed text
replaces the active selection, and you can use C-z, C-x, C-c, and
C-v to undo, cut, copy, and paste in addition to the normal Emacs
bindings.  The C-x and C-c keys only do cut and copy when the
region is active, so in most cases, they do not conflict with the
normal function of these prefix keys.

If you really need to perform a command which starts with one of
the prefix keys even when the region is active, you have three
options:
- press the prefix key twice very quickly (within 0.2 seconds),
- press the prefix key and the following key within 0.2 seconds, or
- use the SHIFT key with the prefix key, i.e. C-S-x or C-S-c.

You can customize `cua-enable-cua-keys' to completely disable the
CUA bindings, or `cua-prefix-override-inhibit-delay' to change
the prefix fallback behavior."
  :global t
  :set-after '(cua-enable-modeline-indications
	       cua-remap-control-v cua-remap-control-z
	       cua-rectangle-mark-key cua-rectangle-modifier-key)
  :link '(emacs-commentary-link "cua-base.el")
  (setq mark-even-if-inactive t)
  (setq highlight-nonselected-windows nil)

  (unless cua--keymaps-initialized
    (cua--init-keymaps)
    (setq cua--keymaps-initialized t))

  (if cua-mode
      (progn
	(add-hook 'pre-command-hook #'cua--pre-command-handler)
	(add-hook 'post-command-hook #'cua--post-command-handler)
	(if (and cua-enable-modeline-indications (not (assoc 'cua-mode minor-mode-alist)))
	    (setq minor-mode-alist (cons '(cua-mode cua--status-string) minor-mode-alist)))
	(if cua-enable-cursor-indications
	    (cua--update-indications)))

    (remove-hook 'pre-command-hook #'cua--pre-command-handler)
    (remove-hook 'post-command-hook #'cua--post-command-handler))

  (if (not cua-mode)
      (setq emulation-mode-map-alists
            (delq 'cua--keymap-alist emulation-mode-map-alists))
    (add-to-ordered-list 'emulation-mode-map-alists 'cua--keymap-alist 400)
    (cua--select-keymaps))

  (cond
   (cua-mode
    (unless cua--saved-state
      (setq cua--saved-state
	    (list
	     (and (boundp 'delete-selection-mode) delete-selection-mode))))
    (if cua-delete-selection
        (delete-selection-mode 1)
      (if (and (boundp 'delete-selection-mode) delete-selection-mode)
          (delete-selection-mode -1)))
    (if cua-highlight-region-shift-only (transient-mark-mode -1))
    (if cua-delete-copy-to-register-0
        (setq delete-selection-save-to-register ?0))
    (cua--deactivate))
   (cua--saved-state
    (if (nth 0 cua--saved-state)
	(delete-selection-mode 1)
      (if (and (boundp 'delete-selection-mode) delete-selection-mode)
          (delete-selection-mode -1)))
    (if (called-interactively-p 'interactive)
	(message "CUA mode disabled.%s"
		 (if (nth 0 cua--saved-state) " Delete-Selection enabled" "")))
    (setq cua--saved-state nil))))


;;;###autoload
(defun cua-selection-mode (arg)
  "Enable CUA selection mode without the C-z/C-x/C-c/C-v bindings."
  (interactive "P")
  (setq-default cua-enable-cua-keys nil)
  (if (not (called-interactively-p 'any))
      (cua-mode arg)
    ;; Use call-interactive to turn a nil prefix arg into `toggle'.
    (call-interactively 'cua-mode)
    (customize-mark-as-set 'cua-enable-cua-keys)))


(defun cua-debug ()
  "Toggle CUA debugging."
  (interactive)
  (setq cua--debug (not cua--debug)))


(provide 'cua-base)

;;; cua-base.el ends here
