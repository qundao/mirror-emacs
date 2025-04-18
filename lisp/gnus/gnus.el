;;; gnus.el --- a newsreader for GNU Emacs  -*- lexical-binding:t -*-

;; Copyright (C) 1987-1990, 1993-1998, 2000-2025 Free Software
;; Foundation, Inc.

;; Author: Masanobu UMEDA <umerin@flab.flab.fujitsu.junet>
;;	Lars Magne Ingebrigtsen <larsi@gnus.org>
;; Keywords: news, mail
;; Version: 5.13

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

(run-hooks 'gnus-load-hook)

(eval-when-compile (require 'cl-lib)
		   (require 'subr-x))
(require 'wid-edit)
(require 'mm-util)
(require 'nnheader)
(require 'seq)

;; These are defined afterwards with gnus-define-group-parameter
(defvar gnus-ham-process-destinations)
(defvar gnus-parameter-ham-marks-alist)
(defvar gnus-parameter-spam-marks-alist)
(defvar gnus-spam-autodetect)
(defvar gnus-spam-autodetect-methods)
(defvar gnus-spam-newsgroup-contents)
(defvar gnus-spam-process-destinations)
(defvar gnus-spam-resend-to)
(defvar gnus-ham-resend-to)
(defvar gnus-spam-process-newsgroups)


(defgroup gnus nil
  "The coffee-brewing, all singing, all dancing, kitchen sink newsreader."
  :group 'news
  :group 'mail)

(defgroup gnus-start nil
  "Starting your favorite newsreader."
  :group 'gnus)

(defgroup gnus-format nil
  "Dealing with formatting issues."
  :group 'gnus)

(defgroup gnus-charset nil
  "Group character set issues."
  :link '(custom-manual "(gnus)Charsets")
  :version "21.1"
  :group 'gnus)

(defgroup gnus-cache nil
  "Cache interface."
  :link '(custom-manual "(gnus)Article Caching")
  :group 'gnus)

(defgroup gnus-registry nil
  "Article Registry."
  :group 'gnus)

(defgroup gnus-start-server nil
  "Server options at startup."
  :group 'gnus-start)

;; These belong to gnus-group.el.
(defgroup gnus-group nil
  "Group buffers."
  :link '(custom-manual "(gnus)Group Buffer")
  :group 'gnus)

(defgroup gnus-group-foreign nil
  "Foreign groups."
  :link '(custom-manual "(gnus)Foreign Groups")
  :group 'gnus-group)

(defgroup gnus-group-new nil
  "Automatic subscription of new groups."
  :group 'gnus-group)

(defgroup gnus-group-levels nil
  "Group levels."
  :link '(custom-manual "(gnus)Group Levels")
  :group 'gnus-group)

(defgroup gnus-group-select nil
  "Selecting a Group."
  :link '(custom-manual "(gnus)Selecting a Group")
  :group 'gnus-group)

(defgroup gnus-group-listing nil
  "Showing slices of the group list."
  :link '(custom-manual "(gnus)Listing Groups")
  :group 'gnus-group)

(defgroup gnus-group-visual nil
  "Sorting the group buffer."
  :link '(custom-manual "(gnus)Group Buffer Format")
  :group 'gnus-group
  :group 'gnus-visual)

(defgroup gnus-group-various nil
  "Various group options."
  :link '(custom-manual "(gnus)Scanning New Messages")
  :group 'gnus-group)

;; These belong to gnus-sum.el.
(defgroup gnus-summary nil
  "Summary buffers."
  :link '(custom-manual "(gnus)Summary Buffer")
  :group 'gnus)

(defgroup gnus-summary-exit nil
  "Leaving summary buffers."
  :link '(custom-manual "(gnus)Exiting the Summary Buffer")
  :group 'gnus-summary)

(defgroup gnus-summary-marks nil
  "Marks used in summary buffers."
  :link '(custom-manual "(gnus)Marking Articles")
  :group 'gnus-summary)

(defgroup gnus-thread nil
  "Ordering articles according to replies."
  :link '(custom-manual "(gnus)Threading")
  :group 'gnus-summary)

(defgroup gnus-summary-format nil
  "Formatting of the summary buffer."
  :link '(custom-manual "(gnus)Summary Buffer Format")
  :group 'gnus-summary)

(defgroup gnus-summary-choose nil
  "Choosing Articles."
  :link '(custom-manual "(gnus)Choosing Articles")
  :group 'gnus-summary)

(defgroup gnus-summary-maneuvering nil
  "Summary movement commands."
  :link '(custom-manual "(gnus)Summary Maneuvering")
  :group 'gnus-summary)

(defgroup gnus-picon nil
  "Show pictures of people, domains, and newsgroups."
  :group 'gnus-visual)

(defgroup gnus-summary-mail nil
  "Mail group commands."
  :link '(custom-manual "(gnus)Mail Group Commands")
  :group 'gnus-summary)

(defgroup gnus-summary-sort nil
  "Sorting the summary buffer."
  :link '(custom-manual "(gnus)Sorting the Summary Buffer")
  :group 'gnus-summary)

(defgroup gnus-summary-visual nil
  "Highlighting and menus in the summary buffer."
  :link '(custom-manual "(gnus)Summary Highlighting")
  :group 'gnus-visual
  :group 'gnus-summary)

(defgroup gnus-summary-various nil
  "Various summary buffer options."
  :link '(custom-manual "(gnus)Various Summary Stuff")
  :group 'gnus-summary)

(defgroup gnus-summary-pick nil
  "Pick mode in the summary buffer."
  :link '(custom-manual "(gnus)Pick and Read")
  :prefix "gnus-pick-"
  :group 'gnus-summary)

(defgroup gnus-summary-tree nil
  "Tree display of threads in the summary buffer."
  :link '(custom-manual "(gnus)Tree Display")
  :prefix "gnus-tree-"
  :group 'gnus-summary)

;; Belongs to gnus-uu.el
(defgroup gnus-extract-view nil
  "Viewing extracted files."
  :link '(custom-manual "(gnus)Viewing Files")
  :group 'gnus-extract)

;; Belongs to gnus-score.el
(defgroup gnus-score nil
  "Score and kill file handling."
  :group 'gnus)

(defgroup gnus-score-kill nil
  "Kill files."
  :group 'gnus-score)

(defgroup gnus-score-adapt nil
  "Adaptive score files."
  :group 'gnus-score)

(defgroup gnus-score-default nil
  "Default values for score files."
  :group 'gnus-score)

(defgroup gnus-score-expire nil
  "Expiring score rules."
  :group 'gnus-score)

(defgroup gnus-score-decay nil
  "Decaying score rules."
  :group 'gnus-score)

(defgroup gnus-score-files nil
  "Score and kill file names."
  :group 'gnus-score
  :group 'gnus-files)

(defgroup gnus-score-various nil
  "Various scoring and killing options."
  :group 'gnus-score)

;; Other
(defgroup gnus-visual nil
  "Options controlling the visual fluff."
  :group 'gnus
  :group 'faces)

(defgroup gnus-agent nil
  "Offline support for Gnus."
  :group 'gnus)

(defgroup gnus-files nil
  "Files used by Gnus."
  :group 'gnus)

(defgroup gnus-dribble-file nil
  "Auto save file."
  :link '(custom-manual "(gnus)Auto Save")
  :group 'gnus-files)

(defgroup gnus-newsrc nil
  "Storing Gnus state."
  :group 'gnus-files)

(defgroup gnus-server nil
  "Options related to newsservers and other servers used by Gnus."
  :group 'gnus)

(defgroup gnus-server-visual nil
  "Highlighting and menus in the server buffer."
  :group 'gnus-visual
  :group 'gnus-server)

(defgroup gnus-message '((message custom-group))
  "Composing replies and followups in Gnus."
  :group 'gnus)

(defgroup gnus-meta nil
  "Meta variables controlling major portions of Gnus.
In general, modifying these variables does not take effect until Gnus
is restarted, and sometimes reloaded."
  :group 'gnus)

(defgroup gnus-various nil
  "Other Gnus options."
  :link '(custom-manual "(gnus)Various Various")
  :group 'gnus)

(defgroup gnus-exit nil
  "Exiting Gnus."
  :link '(custom-manual "(gnus)Exiting Gnus")
  :group 'gnus)

(defgroup gnus-fun nil
  "Frivolous Gnus extensions."
  :link '(custom-manual "(gnus)Exiting Gnus")
  :group 'gnus)

(defgroup gnus-dbus nil
  "D-Bus integration for Gnus."
  :group 'gnus)

(defconst gnus-version-number "5.13"
  "Version number for this version of Gnus.")

(defconst gnus-version (format "Gnus v%s" gnus-version-number)
  "Version string for this version of Gnus.")

(defcustom gnus-inhibit-startup-message nil
  "If non-nil, the startup message will not be displayed.
This variable is used before `.gnus.el' is loaded, so it should
be set in `.emacs' instead."
  :group 'gnus-start
  :type 'boolean)

(defcustom gnus-mode-line-logo
  '((:type svg :file "gnus-pointer.svg" :ascent center)
     (:type xpm :file "gnus-pointer.xpm" :ascent center)
     (:type xbm :file "gnus-pointer.xbm" :ascent center))
  "Image spec for the Gnus logo to be displayed in mode-line.

If non-nil, it should be a list of image specifications to be passed
as the first argument to `find-image', which see.  Then, if the display
is capable of showing images, the Gnus logo will be displayed as part of
the buffer-identification in the mode-line of Gnus-buffers.

If nil, there will be no Gnus logo in the mode-line."
  :group 'gnus-visual
  :type '(choice
           (repeat :tag "List of Gnus logo image specifications" (plist))
           (const :tag "Don't display Gnus logo" nil))
  :version "30.1")

(defun gnus-mode-line-buffer-identification (line)
  (let* ((str (car-safe line))
         (str (if (stringp str)
                  (car (propertized-buffer-identification str))
                str)))
    (if (or (not gnus-mode-line-logo)
            (not (fboundp 'find-image))
	    (not (display-graphic-p))
	    (not (stringp str))
	    (not (string-match "^Gnus:" str)))
	(list str)
      (let ((load-path (append (mm-image-load-path) load-path))
            (gnus-emacs-version (gnus-emacs-version)))
	;; Add the Gnus logo.
	(add-text-properties
	 0 5
	 (list 'display
	       (find-image gnus-mode-line-logo t)
	       'help-echo (if gnus-emacs-version
                              (format
			       "This is %s, %s."
			       gnus-version gnus-emacs-version)
                            (format "This is %s." gnus-version)))
	 str)
	(list str)))))

;; We define these group faces here to avoid the display
;; update forced when creating new faces.

(defface gnus-group-news-1-empty
  '((((class color)
      (background dark))
     (:foreground "PaleTurquoise"))
    (((class color)
      (background light))
     (:foreground "ForestGreen"))
    (t
     ()))
  "Level 1 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-1
  '((t (:inherit gnus-group-news-1-empty :weight bold)))
  "Level 1 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-2-empty
  '((((class color)
      (background dark))
     (:foreground "turquoise"))
    (((class color)
      (background light))
     (:foreground "CadetBlue4"))
    (t
     ()))
  "Level 2 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-2
  '((t (:inherit gnus-group-news-2-empty :weight bold)))
  "Level 2 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-3-empty
  '((((class color)
      (background dark))
     ())
    (((class color)
      (background light))
     ())
    (t
     ()))
  "Level 3 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-3
  '((t (:inherit gnus-group-news-3-empty :weight bold)))
  "Level 3 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-4-empty
  '((((class color)
      (background dark))
     ())
    (((class color)
      (background light))
     ())
    (t
     ()))
  "Level 4 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-4
  '((t (:inherit gnus-group-news-4-empty :weight bold)))
  "Level 4 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-5-empty
  '((((class color)
      (background dark))
     ())
    (((class color)
      (background light))
     ())
    (t
     ()))
  "Level 5 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-5
  '((t (:inherit gnus-group-news-5-empty :weight bold)))
  "Level 5 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-6-empty
  '((((class color)
      (background dark))
     ())
    (((class color)
      (background light))
     ())
    (t
     ()))
  "Level 6 empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-6
  '((t (:inherit gnus-group-news-6-empty :weight bold)))
  "Level 6 newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-low-empty
  '((((class color)
      (background dark))
     (:foreground "DarkTurquoise"))
    (((class color)
      (background light))
     (:foreground "DarkGreen"))
    (t
     ()))
  "Low level empty newsgroup face."
  :group 'gnus-group)

(defface gnus-group-news-low
  '((t (:inherit gnus-group-news-low-empty :weight bold)))
  "Low level newsgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-1-empty
  '((((class color)
      (background dark))
     (:foreground "#e1ffe1"))
    (((class color)
      (background light))
     (:foreground "DeepPink3"))
    (t
     (:slant italic)))
  "Level 1 empty mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-1
  '((t (:inherit gnus-group-mail-1-empty :weight bold)))
  "Level 1 mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-2-empty
  '((((class color)
      (background dark))
     (:foreground "DarkSeaGreen1"))
    (((class color)
      (background light))
     (:foreground "HotPink3"))
    (t
     (:slant italic)))
  "Level 2 empty mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-2
  '((t (:inherit gnus-group-mail-2-empty :weight bold)))
  "Level 2 mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-3-empty
  '((((class color)
      (background dark))
     (:foreground "aquamarine1"))
    (((class color)
      (background light))
     (:foreground "magenta4"))
    (t
     ()))
  "Level 3 empty mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-3
  '((t (:inherit gnus-group-mail-3-empty :weight bold)))
  "Level 3 mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-low-empty
  '((((class color)
      (background dark))
     (:foreground "aquamarine2"))
    (((class color)
      (background light))
     (:foreground "DeepPink4"))
    (t
     (:weight bold)))
  "Low level empty mailgroup face."
  :group 'gnus-group)

(defface gnus-group-mail-low
  '((t (:inherit gnus-group-mail-low-empty :weight bold)))
  "Low level mailgroup face."
  :group 'gnus-group)

;; Summary mode faces.

(defface gnus-summary-selected '((t (:underline t :extend t)))
  "Face used for selected articles."
  :group 'gnus-summary)

(defface gnus-summary-cancelled
  '((((class color))
     (:foreground "yellow" :background "black" :extend t))
    (t (:extend t)))
  "Face used for canceled articles."
  :group 'gnus-summary)

(defface gnus-summary-normal-ticked
  '((((class color)
      (background dark))
     (:foreground "pink" :extend t))
    (((class color)
      (background light))
     (:foreground "firebrick" :extend t))
    (t
     (:extend t)))
  "Face used for normal interest ticked articles."
  :group 'gnus-summary)

(defface gnus-summary-high-ticked
  '((t (:inherit gnus-summary-normal-ticked :weight bold)))
  "Face used for high interest ticked articles."
  :group 'gnus-summary)

(defface gnus-summary-low-ticked
  '((t (:inherit gnus-summary-normal-ticked :slant italic)))
  "Face used for low interest ticked articles."
  :group 'gnus-summary)

(defface gnus-summary-normal-ancient
  '((((class color)
      (background dark))
     (:foreground "SkyBlue" :extend t))
    (((class color)
      (background light))
     (:foreground "RoyalBlue" :extend t))
    (t
     (:extend t)))
  "Face used for normal interest ancient articles."
  :group 'gnus-summary)

(defface gnus-summary-high-ancient
  '((t (:inherit gnus-summary-normal-ancient :weight bold)))
  "Face used for high interest ancient articles."
  :group 'gnus-summary)

(defface gnus-summary-low-ancient
  '((t (:inherit gnus-summary-normal-ancient :slant italic)))
  "Face used for low interest ancient articles."
  :group 'gnus-summary)

(defface gnus-summary-normal-undownloaded
   '((((class color)
       (background light))
      (:foreground "cyan4" :bold nil :extend t))
     (((class color) (background dark))
      (:foreground "LightGray" :bold nil :extend t))
     (t (:inverse-video t :extend t)))
  "Face used for normal interest uncached articles."
  :group 'gnus-summary)

(defface gnus-summary-high-undownloaded
  '((t (:inherit gnus-summary-normal-undownloaded :weight bold)))
  "Face used for high interest uncached articles."
  :group 'gnus-summary)

(defface gnus-summary-low-undownloaded
  '((t (:inherit gnus-summary-normal-undownloaded :slant italic)))
  "Face used for low interest uncached articles."
  :group 'gnus-summary)

(defface gnus-summary-normal-unread
  '((t
     (:extend t)))
  "Face used for normal interest unread articles."
  :group 'gnus-summary)

(defface gnus-summary-high-unread
  '((t (:inherit gnus-summary-normal-unread :weight bold)))
  "Face used for high interest unread articles."
  :group 'gnus-summary)

(defface gnus-summary-low-unread
  '((t (:inherit gnus-summary-normal-unread :slant italic)))
  "Face used for low interest unread articles."
  :group 'gnus-summary)

(defface gnus-summary-normal-read
  '((((class color)
      (background dark))
     (:foreground "PaleGreen" :extend t))
    (((class color)
      (background light))
     (:foreground "DarkGreen" :extend t))
    (t
     (:extend t)))
  "Face used for normal interest read articles."
  :group 'gnus-summary)

(defface gnus-summary-high-read
  '((t (:inherit gnus-summary-normal-read :weight bold)))
  "Face used for high interest read articles."
  :group 'gnus-summary)

(defface gnus-summary-low-read
  '((t (:inherit gnus-summary-normal-read :slant italic)))
  "Face used for low interest read articles."
  :group 'gnus-summary)

;;; Base gnus-mode

(define-derived-mode gnus-mode special-mode nil
  "Base mode from which all other gnus modes derive.
This does nothing but derive from `special-mode', and should not
be used directly.")

;;;
;;; Gnus buffers
;;;

(defvar gnus-buffers nil
  "List of buffers handled by Gnus.")

(defun gnus-get-buffer-create (name)
  "Do the same as `get-buffer-create', but store the created buffer."
  (or (get-buffer name)
      (car (push (get-buffer-create name) gnus-buffers))))

(defun gnus-add-buffer ()
  "Add the current buffer to the list of Gnus buffers."
  (gnus-prune-buffers)
  (cl-pushnew (current-buffer) gnus-buffers))

(defun gnus-kill-buffer (buffer)
  "Kill BUFFER and remove from the list of Gnus buffers."
  (when (gnus-buffer-live-p buffer)
    (kill-buffer buffer)
    (gnus-prune-buffers)))

(defun gnus-buffers ()
  "Return a list of live Gnus buffers."
  (setq gnus-buffers (seq-filter #'buffer-live-p gnus-buffers)))

(defalias 'gnus-prune-buffers #'gnus-buffers)

;;; Splash screen.

(defvar gnus-group-buffer "*Group*"
  "Name of the Gnus group buffer.")

(defface gnus-splash
  '((((class color)
      (background dark))
     (:foreground "#cccccc"))
    (((class color)
      (background light))
     (:foreground "#888888"))
    (t
     ()))
  "Face for the splash screen."
  :group 'gnus-start)

(defun gnus-splash ()
  (save-excursion
    (switch-to-buffer (gnus-get-buffer-create gnus-group-buffer))
    (let ((buffer-read-only nil))
      (erase-buffer)
      (unless gnus-inhibit-startup-message
	(gnus-group-startup-message)
	(sit-for 0)))))

(defun gnus-indent-rigidly (start end arg)
  "Indent rigidly using only spaces and no tabs."
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (let ((tab-width 8))
	(indent-rigidly start end arg)
	;; We translate tabs into spaces -- not everybody uses
	;; an 8-character tab.
	(goto-char (point-min))
	(while (search-forward "\t" nil t)
	  (replace-match "        " t t))))))

;;(format "%02x%02x%02x" 114 66 20) "724214"

(defvar gnus-logo-color-alist
  '((flame "#cc3300" "#ff2200")
    (pine "#c0cc93" "#f8ffb8")
    (moss "#a1cc93" "#d2ffb8")
    (irish "#04cc90" "#05ff97")
    (sky "#049acc" "#05deff")
    (tin "#6886cc" "#82b6ff")
    (velvet "#7c68cc" "#8c82ff")
    (grape "#b264cc" "#cf7df")
    (labia "#cc64c2" "#fd7dff")
    (berry "#cc6485" "#ff7db5")
    (dino "#724214" "#1e3f03")
    (oort "#cccccc" "#888888")
    (storm "#666699" "#99ccff")
    (pdino "#9999cc" "#99ccff")
    (purp "#9999cc" "#666699")
    (no "#ff0000" "#ffff00")
    (neutral "#b4b4b4" "#878787")
    (ma "#2020e0" "#8080ff")
    (september "#bf9900" "#ffcc00"))
  "Color alist used for the Gnus logo.")

(defcustom gnus-logo-colors nil
  "Colors used for the Gnus logo."
  :set-after '(gnus-logo-color-style)
  :type '(choice (const :tag "Use default" nil)
                 (list color color))
  :group 'gnus-xmas)

(defcustom gnus-logo-color-style 'ma
  "Color styles used for the Gnus logo."
  :type `(choice ,@(mapcar (lambda (elem) (list 'const (car elem)))
			   gnus-logo-color-alist))
  :set (lambda (sym val)
         (set-default-toplevel-value sym val)
         (set-default-toplevel-value 'gnus-logo-colors
                                     (cdr (assq val gnus-logo-color-alist))))
  :group 'gnus-xmas)

(defvar image-load-path)
(declare-function image-size "image.c" (spec &optional pixels frame))

(defun gnus-group-startup-message (&optional x y)
  "Insert startup message in current buffer."
  ;; Insert the message.
  (erase-buffer)
  (unless (and
           (fboundp 'find-image)
           (display-graphic-p)
           ;; Make sure the library defining `image-load-path' is
           ;; loaded (`find-image' is autoloaded) (and discard the
           ;; result).  Else, we may get "defvar ignored because
           ;; image-load-path is let-bound" when calling `find-image'
           ;; below.
           (or (find-image '(nil (:type xpm :file "gnus.xpm"))) t)
           (let* ((data-directory (nnheader-find-etc-directory "images/gnus"))
                  (image-load-path (cond (data-directory
                                          (list data-directory))
                                         ((boundp 'image-load-path)
                                          (symbol-value 'image-load-path))
                                         (t load-path)))
                  (image (gnus-splash-svg-color-symbols (find-image
                          `((:type svg :file "gnus.svg"
                                   :color-symbols
                                   (("#bf9900" . ,(car gnus-logo-colors))
                                    ("#ffcc00" . ,(cadr gnus-logo-colors))))
                            (:type xpm :file "gnus.xpm"
                                   :color-symbols
                                   (("thing" . ,(car gnus-logo-colors))
                                    ("shadow" . ,(cadr gnus-logo-colors))))
                            (:type png :file "gnus.png")
                            (:type pbm :file "gnus.pbm"
                                   ;; Account for the pbm's background.
                                   :background ,(face-foreground 'gnus-splash)
                                   :foreground ,(face-background 'default))
                            (:type xbm :file "gnus.xbm"
                                   ;; Account for the xbm's background.
                                   :background ,(face-foreground 'gnus-splash)
                                   :foreground ,(face-background 'default)))))))
             (when image
               (let ((size (image-size image)))
                 (insert-char ?\n (max 0 (round (- (window-height)
                                                   (or y (cdr size)) 1) 2)))
                 (insert-char ?\  (max 0 (round (- (window-width)
                                                   (or x (car size))) 2)))
                 (insert-image image))
	       (goto-char (point-min))
               t)))
    (insert
     "
	  _    ___ _             _
	  _ ___ __ ___  __    _ ___
	  __   _     ___    __  ___
	      _           ___     _
	     _  _ __             _
	     ___   __            _
		   __           _
		    _      _   _
		   _      _    _
		      _  _    _
		  __  ___
		 _   _ _     _
		_   _
	      _    _
	     _    _
	    _
	  __

")
    ;; And then hack it.
    (gnus-indent-rigidly (point-min) (point-max)
			 (/ (max (- (window-width) (or x 46)) 0) 2))
    (goto-char (point-min))
    (forward-line 1)
    (let* ((pheight (count-lines (point-min) (point-max)))
	   (wheight (window-height))
	   (rest (- wheight pheight)))
      (insert (make-string (max 0 (* 2 (/ rest 3))) ?\n)))
    ;; Fontify some.
    (put-text-property (point-min) (point-max) 'face 'gnus-splash)
    (goto-char (point-min))
    (setq mode-line-buffer-identification (concat " " gnus-version))
    (set-buffer-modified-p t)))

(defun gnus-splash-svg-color-symbols (list)
  "Do color-symbol search-and-replace in svg file."
  (let ((type (plist-get (cdr list) :type))
        (file (plist-get (cdr list) :file))
        (color-symbols (plist-get (cdr list) :color-symbols)))
    (if (string= type "svg")
        (let ((data (with-temp-buffer (insert-file-contents file)
                                      (buffer-string))))
          (mapc (lambda (rule)
                  (setq data (replace-regexp-in-string
                              (concat "fill:" (car rule))
                              (concat "fill:" (cdr rule)) data)))
                color-symbols)
          (cons (car list) (list :type type :data data)))
       list)))

;;; Do the rest.

(require 'gnus-util)
(require 'nnheader)

(defcustom gnus-parameters nil
  "Alist of group parameters.

For example:
   ((\"mail\\\\..*\"  (gnus-show-threads nil)
		  (gnus-use-scoring nil)
		  (gnus-summary-line-format
			\"%U%R%z%I%(%[%d:%ub%-23,23f%]%) %s\\n\")
		  (gcc-self . t)
		  (display . all))
     (\"mail\\\\.me\" (gnus-use-scoring  t))
     (\"list\\\\..*\" (total-expire . t)
		  (broken-reply-to . t)))"
  :version "22.1"
  :group 'gnus-group-various
  :type '(repeat (cons regexp
		       (repeat sexp))))

(defcustom gnus-parameters-case-fold-search 'default
  "If it is t, ignore case of group names specified in `gnus-parameters'.
If it is nil, don't ignore case.  If it is `default', which is for the
backward compatibility, use the value of `case-fold-search'."
  :version "22.1"
  :group 'gnus-group-various
  :type '(choice :format "%{%t%}:\n %[Value Menu%] %v"
		 (const :tag "Use `case-fold-search'" default)
		 (const nil)
		 (const t)))

(defvar gnus-group-parameters-more nil)

(defmacro gnus-define-group-parameter (param &rest rest)
  "Define a group parameter PARAM.
REST is a plist of following:
:type               One of `bool', `list' or nil.
:function           The name of the function.
:function-document  The documentation of the function.
:parameter-type     The type for customizing the parameter.
:parameter-document The documentation for the parameter.
:variable           The name of the variable.
:variable-document  The documentation for the variable.
:variable-group     The group for customizing the variable.
:variable-type      The type for customizing the variable.
:variable-default   The default value of the variable."
  (let* ((type (plist-get rest :type))
	 (parameter-type (plist-get rest :parameter-type))
	 (parameter-document (plist-get rest :parameter-document))
	 (function (or (plist-get rest :function)
		       (intern (format "gnus-parameter-%s" param))))
	 (function-document (or (plist-get rest :function-document) ""))
	 (variable (or (plist-get rest :variable)
		       (intern (format "gnus-parameter-%s-alist" param))))
	 (variable-document (or (plist-get rest :variable-document) ""))
	 (variable-group (plist-get rest :variable-group))
	 (variable-type (or (plist-get rest :variable-type)
			    `(quote (repeat
				     (list (regexp :tag "Group")
					   ,(car (cdr parameter-type)))))))
	 (variable-default (plist-get rest :variable-default)))
    (list
     'progn
     `(defcustom ,variable ,variable-default
	,variable-document
	:group 'gnus-group-parameter
	:group ',variable-group
	:type ,variable-type)
     `(setq gnus-group-parameters-more
	    (delq (assq ',param gnus-group-parameters-more)
		  gnus-group-parameters-more))
     `(add-to-list 'gnus-group-parameters-more
		   (list ',param
			 ,parameter-type
			 ,parameter-document))
     (if (eq type 'bool)
	 `(defun ,function (name)
	    ,function-document
	    (let ((params (gnus-group-find-parameter name))
		  val)
	      (cond
	       ((memq ',param params)
		t)
	       ((setq val (assq ',param params))
		(cdr val))
	       ((stringp ,variable)
		(string-match ,variable name))
	       (,variable
		(let ((alist ,variable)
		      elem value)
		  (while (setq elem (pop alist))
		    (when (and name
			       (string-match (car elem) name))
		      (setq alist nil
			    value (cdr elem))))
		  (if (consp value) (car value) value))))))
       `(defun ,function (name)
	  ,function-document
	  (and name
	       (or (gnus-group-find-parameter name ',param ,(and type t))
		   (let ((alist ,variable)
			 elem value)
		     (while (setq elem (pop alist))
		       (when (and name
				  (string-match (car elem) name))
			 (setq alist nil
			       value (cdr elem))))
		     ,(if type
			  'value
			'(if (consp value) (car value) value))))))))))

(defcustom gnus-home-directory "~/"
  "Directory variable that specifies the \"home\" directory.
All other Gnus file and directory variables are initialized from this variable.

Note that Gnus is mostly loaded when the `.gnus.el' file is read.
This means that other directory variables that are initialized
from this variable won't be set properly if you set this variable
in `.gnus.el'.  Set this variable in `.emacs' instead."
  :group 'gnus-files
  :type 'directory)

(defcustom gnus-directory (or (getenv "SAVEDIR")
			      (nnheader-concat gnus-home-directory "News/"))
  "Directory variable from which all other Gnus file variables are derived.

Note that Gnus is mostly loaded when the `.gnus.el' file is read.
This means that other directory variables that are initialized from
this variable won't be set properly if you set this variable in `.gnus.el'.
Set this variable in `.emacs' instead."
  :group 'gnus-files
  :type 'directory)

(defcustom gnus-default-directory nil
  "Default directory for all Gnus buffers."
  :group 'gnus-files
  :type '(choice (const :tag "current" nil)
		 directory))

;; Site dependent variables.

;; Should this be obsolete?
(defcustom gnus-default-nntp-server nil
  "The hostname of the default NNTP server.
The empty string, or nil, means to use the local host.
You may wish to set this on a site-wide basis.

If you want to change servers, you should use `gnus-select-method'."
  :group 'gnus-server
  :type '(choice (const :tag "local host" nil)
                 (string :tag "host name")))

(defcustom gnus-nntpserver-file "/etc/nntpserver"
  "A file with only the name of the nntp server in it."
  :group 'gnus-files
  :group 'gnus-server
  :type 'file)

(defun gnus-getenv-nntpserver ()
  "Find default nntp server.
Check the NNTPSERVER environment variable and the
`gnus-nntpserver-file' file."
  (or (getenv "NNTPSERVER")
      (and (file-readable-p gnus-nntpserver-file)
	   (with-temp-buffer
	     (insert-file-contents gnus-nntpserver-file)
	     (when (re-search-forward "[^ \t\n\r]+" nil t)
	       (match-string 0))))))

;; `M-x customize-variable RET gnus-select-method RET' should work without
;; starting or even loading Gnus.
;;;###autoload(custom-autoload 'gnus-select-method "gnus")

(defcustom gnus-select-method
  (list 'nntp (or (gnus-getenv-nntpserver)
                  (when (and gnus-default-nntp-server
                             (not (string= gnus-default-nntp-server "")))
                    gnus-default-nntp-server)
                  "news"))
  "Default method for selecting a newsgroup.
This variable should be a list, where the first element is how the
news is to be fetched, the second is the address.

For instance, if you want to get your news via \"flab.flab.edu\" using
NNTP, you could say:

\(setq gnus-select-method \\='(nntp \"flab.flab.edu\"))

If you want to use your local spool, say:

\(setq gnus-select-method (list \\='nnspool (system-name)))

If you use this variable, you must set `gnus-nntp-server' to nil.

There is a lot more to know about select methods and virtual servers -
see the manual for details."
  ;; Emacs has set-after since 22.1.
  ;set-after '(gnus-default-nntp-server)
  :group 'gnus-server
  :group 'gnus-start
  :initialize 'custom-initialize-default
  :type 'gnus-select-method)

(defcustom gnus-message-archive-method "archive"
  "Method used for archiving messages you've sent.
This should be a mail method.

See also `gnus-update-message-archive-method'."
  :group 'gnus-server
  :group 'gnus-message
  :type '(choice (const :tag "Default archive method" "archive")
		 gnus-select-method))

(defcustom gnus-update-message-archive-method nil
  "Non-nil means always update the saved \"archive\" method.

The archive method is initially set according to the value of
`gnus-message-archive-method' and is saved in the \"~/.newsrc.eld\" file
so that it may be used as a real method of the server which is named
\"archive\" ever since.  If it once has been saved, it will never be
updated if the value of this variable is nil, even if you change the
value of `gnus-message-archive-method' afterward.  If you want the
saved \"archive\" method to be updated whenever you change the value of
`gnus-message-archive-method', set this variable to a non-nil value."
  :version "23.1"
  :group 'gnus-server
  :group 'gnus-message
  :type 'boolean)

(defcustom gnus-message-archive-group '((format-time-string "sent.%Y-%m"))
  "Name of the group in which to save the messages you've written.
This can either be a string; a list of strings; or an alist
of regexps/functions/forms to be evaluated to return a string (or a list
of strings).  The functions are called with the name of the current
group (or nil) as a parameter.

If you want to save your mail in one group and the news articles you
write in another group, you could say something like:

  (setq gnus-message-archive-group
	\\='((if (message-news-p)
	      \"misc-news\"
	    \"misc-mail\")))

Normally the group names returned by this variable should be
unprefixed -- which implicitly means \"store on the archive server\".
However, you may wish to store the message on some other server.  In
that case, just return a fully prefixed name of the group --
\"nnml+private:mail.misc\", for instance."
  :version "24.1"
  :group 'gnus-message
  :type '(choice (const :tag "none" nil)
		 (const :tag "Weekly" ((format-time-string "sent.%Yw%U")))
		 (const :tag "Monthly" ((format-time-string "sent.%Y-%m")))
		 (const :tag "Yearly" ((format-time-string "sent.%Y")))
		 function
		 sexp
		 string))

(defcustom gnus-secondary-select-methods nil
  "A list of secondary methods that will be used for reading news.
This is a list where each element is a complete select method (see
`gnus-select-method').

If, for instance, you want to read your mail with the nnml back end,
you could set this variable:

\(setq gnus-secondary-select-methods \\='((nnml \"\")))"
  :group 'gnus-server
  :type '(repeat gnus-select-method))

;; Customization variables

(defcustom gnus-refer-article-method 'current
  "Preferred method for fetching an article by Message-ID.
The value of this variable must be a valid select method as discussed
in the documentation of `gnus-select-method'.

It can also be a list of select methods, as well as the special symbol
`current', which means to use the current select method.  If it is a
list, Gnus will try all the methods in the list until it finds a match."
  :version "24.1"
  :group 'gnus-server
  :type '(choice (const :tag "default" nil)
		 (const current)
		 (const :tag "Google" (nnweb "refer" (nnweb-type google)))
		 gnus-select-method
		 sexp
		 (repeat :menu-tag "Try multiple"
			 :tag "Multiple"
			 :value (current (nnweb "refer" (nnweb-type google)))
			 (choice :tag "Method"
				 (const current)
				 (const :tag "Google"
					(nnweb "refer" (nnweb-type google)))
				 gnus-select-method))))

(defcustom gnus-use-cross-reference t
  "Non-nil means that cross referenced articles will be marked as read.
If nil, ignore cross references.  If t, mark articles as read in
subscribed newsgroups.  If neither t nor nil, mark as read in all
newsgroups."
  :group 'gnus-server
  :type '(choice (const :tag "off" nil)
		 (const :tag "subscribed" t)
		 (sexp :format "all"
		       :value always)))

(defcustom gnus-process-mark ?#
  "Process mark."
  :group 'gnus-group-visual
  :group 'gnus-summary-marks
  :type 'character)

(defcustom gnus-process-mark-toggle t
  "If nil the process mark command only sets the process mark."
  :version "28.1"
  :group 'gnus-summary
  :group 'gnus-group-various
  :group 'gnus-group-topic
  :type 'boolean)

(defcustom gnus-large-newsgroup 200
  "The number of articles which indicates a large newsgroup.
If the number of articles in a newsgroup is greater than this value,
confirmation is required for selecting the newsgroup.
If it is nil, no confirmation is required.

Also see `gnus-large-ephemeral-newsgroup'."
  :group 'gnus-group-select
  :type '(choice (const :tag "No limit" nil)
		 integer))

(defcustom gnus-use-long-file-name (not (memq system-type '(usg-unix-v)))
  "Non-nil means that the default file name to save articles in is the group name.
If it's nil, the directory form of the group name is used instead.

If this variable is a list, and the list contains the element
`not-score', long file names will not be used for score files; if it
contains the element `not-save', long file names will not be used for
saving; and if it contains the element `not-kill', long file names
will not be used for kill files.

Note that the default for this variable varies according to what system
type you're using.  On `usg-unix-v' this variable defaults to nil while
on all other systems it defaults to t."
  :group 'gnus-start
  :type '(radio (sexp :format "Non-nil\n"
		      :match (lambda (widget value)
			       (and value (not (listp value))))
		      :value t)
		(const nil)
		(checklist (const :format "%v " not-score)
			   (const :format "%v " not-save)
			   (const not-kill))))

(defcustom gnus-kill-files-directory gnus-directory
  "Name of the directory where kill files will be stored (default \"~/News\")."
  :group 'gnus-score-files
  :group 'gnus-score-kill
  :type 'directory)

(defcustom gnus-save-score nil
  "If non-nil, save group scoring info."
  :group 'gnus-score-various
  :group 'gnus-start
  :type 'boolean)

(defcustom gnus-use-undo t
  "If non-nil, allow undoing in Gnus group mode buffers."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-use-adaptive-scoring nil
  "If non-nil, use some adaptive scoring scheme.
If a list, then the values `word' and `line' are meaningful.  The
former will perform adaption on individual words in the subject
header while `line' will perform adaption on several headers."
  :group 'gnus-meta
  :group 'gnus-score-adapt
  :type '(set (const word) (const line)))

(defcustom gnus-use-cache 'passive
  "If nil, Gnus will ignore the article cache.
If `passive', it will allow entering (and reading) articles
explicitly entered into the cache.  If anything else, use the
cache to the full extent of the law."
  :group 'gnus-meta
  :group 'gnus-cache
  :type '(choice (const :tag "off" nil)
		 (const :tag "passive" passive)
		 (const :tag "active" t)))

(defcustom gnus-use-trees nil
  "If non-nil, display a thread tree buffer."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-keep-backlog 20
  "If non-nil, Gnus will keep read articles for later re-retrieval.
If it is a number N, then Gnus will only keep the last N articles
read.  If it is neither nil nor a number, Gnus will keep all read
articles.  This is not a good idea."
  :group 'gnus-meta
  :type '(choice (const :tag "off" nil)
		 integer
		 (sexp :format "all"
		       :value t)))

(defcustom gnus-suppress-duplicates nil
  "If non-nil, Gnus will mark duplicate copies of the same article as read."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-use-scoring t
  "If non-nil, enable scoring."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-summary-prepare-exit-hook
  '(gnus-summary-expire-articles)
  "A hook called when preparing to exit from the summary buffer.
It calls `gnus-summary-expire-articles' by default."
  :group 'gnus-summary-exit
  :type 'hook)

(defcustom gnus-novice-user t
  "Non-nil means that you are a Usenet novice.
If non-nil, verbose messages may be displayed and confirmations may be
required."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-expert-user nil
  "Non-nil means that you will never be asked for confirmation about anything.
That doesn't mean *anything* anything; particularly destructive
commands will still require prompting."
  :group 'gnus-meta
  :type 'boolean)

(defcustom gnus-interactive-catchup t
  "If non-nil, require your confirmation when catching up a group."
  :group 'gnus-group-select
  :type 'boolean)

(defcustom gnus-interactive-exit t
  "If non-nil, require your confirmation when exiting Gnus.
If `quiet', update any active summary buffers automatically
first before exiting."
  :group 'gnus-exit
  :type '(choice boolean
		 (const quiet)))

(defcustom gnus-extract-address-components 'gnus-extract-address-components
  "Function for extracting address components from a From header.
Two pre-defined function exist: `gnus-extract-address-components',
which is the default, quite fast, and too simplistic solution, and
`mail-extract-address-components', which works much better, but is
slower."
  :group 'gnus-summary-format
  :type '(radio (function-item gnus-extract-address-components)
		(function-item mail-extract-address-components)
		(function :tag "Other")))

(defcustom gnus-shell-command-separator ";"
  "String used to separate shell commands."
  :group 'gnus-files
  :type 'string)

(defcustom gnus-valid-select-methods
  '(("nntp" post address prompt-address physical-address cloud)
    ("nnspool" post address)
    ("nnvirtual" post-mail virtual prompt-address)
    ("nnmbox" mail respool address)
    ("nnml" post-mail respool address)
    ("nnmh" mail respool address)
    ("nndir" post-mail prompt-address physical-address)
    ("nneething" none address prompt-address physical-address)
    ("nndoc" none address prompt-address)
    ("nnbabyl" mail address respool)
    ("nndraft" post-mail)
    ("nnfolder" mail respool address)
    ("nngateway" post-mail address prompt-address physical-address)
    ("nnweb" none)
    ("nnrss" none global)
    ("nnagent" post-mail)
    ("nnimap" post-mail address prompt-address physical-address respool
     server-marks cloud)
    ("nnmaildir" mail respool address server-marks)
    ("nnatom" none address)
    ("nnnil" none))
  "An alist of valid select methods.
The first element of each list lists should be a string with the name
of the select method.  The other elements may be the category of
this method (i. e., `post', `mail', `none' or whatever) or other
properties that this method has (like being respoolable).
If you implement a new select method, all you should have to change is
this variable.  I think."
  :group 'gnus-server
  :type '(repeat (group (string :tag "Name")
			(radio-button-choice (const :format "%v " post)
					     (const :format "%v " mail)
					     (const :format "%v " none)
					     (const post-mail))
			(checklist :inline t :greedy t
				   (const :format "%v " address)
				   (const cloud)
				   (const global)
				   (const :format "%v " prompt-address)
				   (const :format "%v " physical-address)
				   (const virtual)
				   (const :format "%v " respool)
				   (const server-marks))))
  :version "24.1")

(defun gnus-redefine-select-method-widget ()
  "Recomputes the select-method widget based on the value of
`gnus-valid-select-methods'."
  (define-widget 'gnus-select-method 'list
    "Widget for entering a select method."
    :value '(nntp "")
    :tag "Select Method"
    :args `((choice :tag "Method"
		    ,@(mapcar (lambda (entry)
				(list 'const :format "%v\n"
				      (intern (car entry))))
			      gnus-valid-select-methods)
		    (symbol :tag "other"))
	    (string :tag "Address")
	    (repeat :tag "Options"
		    :inline t
                    (radio
		     (list :tag "Single var" :format "%v"
			   variable
			   (sexp :tag "Value"))
                     (list :tag "Multiple var" :format "%v"
			   variable
                           variable
			   (sexp :tag "Value")))))))

(gnus-redefine-select-method-widget)

(defcustom gnus-updated-mode-lines '(group article summary tree)
  "List of buffers that should update their mode lines.
The list may contain the symbols `group', `article', `tree' and
`summary'.  If the corresponding symbol is present, Gnus will keep
that mode line updated with information that may be pertinent.
If this variable is nil, screen refresh may be quicker."
  :group 'gnus-various
  :type '(set (const group)
	      (const article)
	      (const summary)
	      (const tree)))

(defcustom gnus-mode-non-string-length 30
  "Max length of mode-line non-string contents.
If this is nil, Gnus will take space as is needed, leaving the rest
of the mode line intact."
  :version "24.1"
  :group 'gnus-various
  :type '(choice (const nil)
		 integer))

;; There should be special validation for this.
(define-widget 'gnus-email-address 'string
  "An email address.")

(gnus-define-group-parameter
 to-address
 :function-document
 "Return GROUP's to-address."
 :variable-document
 "Alist of group regexps and correspondent to-addresses."
 :variable-group gnus-group-parameter
 :parameter-type '(gnus-email-address :tag "To Address")
 :parameter-document "\
This will be used when doing followups and posts.

This is primarily useful in mail groups that represent closed
mailing lists--mailing lists where it's expected that everybody that
writes to the mailing list is subscribed to it.  Since using this
parameter ensures that the mail only goes to the mailing list itself,
it means that members won't receive two copies of your followups.

Using `to-address' will actually work whether the group is foreign or
not.  Let's say there's a group on the server that is called
`fa.4ad-l'.  This is a real newsgroup, but the server has gotten the
articles from a mail-to-news gateway.  Posting directly to this group
is therefore impossible--you have to send mail to the mailing list
address instead.

The gnus-group-split mail splitting mechanism will behave as if this
address was listed in gnus-group-split Addresses (see below).")

(gnus-define-group-parameter
 to-list
 :function-document
 "Return GROUP's to-list."
 :variable-document
 "Alist of group regexps and correspondent to-lists."
 :variable-group gnus-group-parameter
 :parameter-type '(gnus-email-address :tag "To List")
 :parameter-document "\
This address will be used when doing a \\`a' in the group.

It is totally ignored when doing a followup--except that if it is
present in a news group, you'll get mail group semantics when doing
\\`f'.

The gnus-group-split mail splitting mechanism will behave as if this
address was listed in gnus-group-split Addresses (see below).")

(gnus-define-group-parameter
 subscribed
 :type bool
 :function-document
 "Return GROUP's subscription status."
 :variable-document
 "Groups which are automatically considered subscribed."
 :variable-group gnus-group-parameter
 :parameter-type '(const :tag "Subscribed" t)
 :parameter-document "\
Gnus assumed that you are subscribed to the To/List address.

When constructing a list of subscribed groups using
`gnus-find-subscribed-addresses', Gnus includes the To address given
above, or the list address (if the To address has not been set).")

(gnus-define-group-parameter
 auto-expire
 :type bool
 :function gnus-group-auto-expirable-p
 :function-document
 "Check whether GROUP is auto-expirable or not."
 :variable gnus-auto-expirable-newsgroups
 :variable-default nil
 :variable-document
 "Groups in which to automatically mark read articles as expirable.
If non-nil, this should be a regexp that should match all groups in
which to perform auto-expiry.  This only makes sense for mail groups."
 :variable-group nnmail-expire
 :variable-type '(choice (const nil)
			 regexp)
 :parameter-type '(const :tag "Automatic Expire" t)
 :parameter-document
 "All articles that are read will be marked as expirable.")

(gnus-define-group-parameter
 total-expire
 :type bool
 :function gnus-group-total-expirable-p
 :function-document
 "Check whether GROUP is total-expirable or not."
 :variable gnus-total-expirable-newsgroups
 :variable-default nil
 :variable-document
 "Groups in which to perform expiry of all read articles.
Use with extreme caution.  All groups that match this regexp will be
expiring - which means that all read articles will be deleted after
\(say) one week.  (This only goes for mail groups and the like, of
course.)"
 :variable-group nnmail-expire
 :variable-type '(choice (const nil)
			 regexp)
 :parameter-type '(const :tag "Total Expire" t)
 :parameter-document
 "All read articles will be put through the expiry process

This happens even if they are not marked as expirable.
Use with caution.")

(gnus-define-group-parameter
 charset
 :function-document
 "Return the default charset of GROUP."
 :variable gnus-group-charset-alist
 :variable-default
 '(("\\(^\\|:\\)hk\\>\\|\\(^\\|:\\)tw\\>\\|\\<big5\\>" cn-big5)
   ("\\(^\\|:\\)cn\\>\\|\\<chinese\\>" cn-gb-2312)
   ("\\(^\\|:\\)fj\\>\\|\\(^\\|:\\)japan\\>" iso-2022-jp-2)
   ("\\(^\\|:\\)tnn\\>\\|\\(^\\|:\\)pin\\>\\|\\(^\\|:\\)sci.lang.japan" iso-2022-7bit)
   ("\\(^\\|:\\)relcom\\>" koi8-r)
   ("\\(^\\|:\\)fido7\\>" koi8-r)
   ("\\(^\\|:\\)\\(cz\\|hun\\|pl\\|sk\\|hr\\)\\>" iso-8859-2)
   ("\\(^\\|:\\)israel\\>" iso-8859-1)
   ("\\(^\\|:\\)han\\>" euc-kr)
   ("\\(^\\|:\\)alt.chinese.text.big5\\>" chinese-big5)
   ("\\(^\\|:\\)soc.culture.vietnamese\\>" vietnamese-viqr)
   ("\\(^\\|:\\)\\(comp\\|rec\\|alt\\|sci\\|soc\\|news\\|gnu\\|bofh\\)\\>" iso-8859-1))
 :variable-document
 "Alist of regexps (to match group names) and charsets to be used when reading."
 :variable-group gnus-charset
 :variable-type '(repeat (list (regexp :tag "Group")
			       (symbol :tag "Charset")))
 :parameter-type '(symbol :tag "Charset")
 :parameter-document "\
The default charset to use in the group.")

(gnus-define-group-parameter
 post-method
 :type list
 :function-document
 "Return a posting method for GROUP."
 :variable gnus-post-method-alist
 :variable-document
 "Alist of regexps (to match group names) and method to be used when
posting an article."
 :variable-group gnus-group-foreign
 :parameter-type
 '(choice :tag "Posting Method"
	  (const :tag "Use native server" native)
	  (const :tag "Use current server" current)
	  (list :convert-widget
		(lambda (widget)
		  (list 'sexp :tag "Methods"
			:value gnus-select-method))))
 :parameter-document
 "Posting method for this group.")

(gnus-define-group-parameter
 large-newsgroup-initial
 :type integer
 :function-document
 "Return GROUP's initial input of the number of articles."
 :variable-document
 "Alist of group regexps and its initial input of the number of articles."
 :variable-group gnus-group-parameter
 :parameter-type '(choice :tag "Initial Input for Large Newsgroup"
			  (const :tag "All" all)
			  (integer))
 :parameter-document "\

This number will be prompted as the initial value of the number of
articles to list when the group is a large newsgroup (see
`gnus-large-newsgroup').  If it is nil, the default value is the
total number of articles in the group.")

;; The Gnus registry's ignored groups
(gnus-define-group-parameter
 registry-ignore
 :type list
 :function-document
 "Whether this group should be ignored by the registry."
 :variable gnus-registry-ignored-groups
 :variable-default (mapcar
                    (lambda (g) (list g t))
                    '("delayed$" "drafts$" "queue$" "INBOX$"
                      "^nnmairix:" "^nnselect:" "archive"))
 :variable-document
 "Groups in which the registry should be turned off."
 :variable-group gnus-registry
 :variable-type '(repeat
		  (list
		   (regexp :tag "Group Name Regular Expression")
		   (boolean :tag "Ignored")))

 :parameter-type '(boolean :tag "Group Ignored by the Registry")
 :parameter-document
 "Whether the Gnus Registry should ignore this group.")

;; group parameters for spam processing added by Ted Zlatanov <tzz@lifelogs.com>
(defcustom gnus-install-group-spam-parameters t
  "Disable the group parameters for spam detection.
Enable if `G c' in XEmacs is giving you trouble, and make sure to
submit a bug report."
  :version "22.1"
  :type 'boolean
  :group 'gnus-start)

(when gnus-install-group-spam-parameters
  (defvar gnus-group-spam-classification-spam t
    "Spam group classification (requires spam.el).
This group contains spam messages.  On summary entry, unread messages
will be marked as spam.  On summary exit, the specified spam
processors will be invoked on spam-marked messages, then those
messages will be expired, so the spam processor will only see a
spam-marked message once.")

  (defvar gnus-group-spam-classification-ham 'ask
    "The ham value for the spam group parameter (requires spam.el).
On summary exit, the specified ham processors will be invoked on
ham-marked messages.  Exercise caution, since the ham processor will
see the same message more than once because there is no ham message
registry.")

  (gnus-define-group-parameter
   spam-contents
   :type list
   :function-document
   "The spam type (spam, ham, or neither) of the group."
   :variable gnus-spam-newsgroup-contents
   :variable-default nil
   :variable-document
   "Group classification (spam, ham, or neither).  Only
meaningful when spam.el is loaded.  If non-nil, this should be a
list of group name regexps associated with a classification for
each one.  In spam groups, new articles are marked as spam on
summary entry.  There is other behavior associated with ham and
no classification when spam.el is loaded - see the manual."
   :variable-group spam
   :variable-type '(repeat
		    (list :tag "Group contents spam/ham classification"
			  (regexp :tag "Group")
			  (choice
			   (variable-item gnus-group-spam-classification-spam)
			   (variable-item gnus-group-spam-classification-ham)
			   (const :tag "Unclassified" nil))))

   :parameter-type '(list :tag "Group contents spam/ham classification"
			  (choice :tag "Group contents classification for spam sorting"
				  (variable-item gnus-group-spam-classification-spam)
				  (variable-item gnus-group-spam-classification-ham)
				  (const :tag "Unclassified" nil)))
   :parameter-document
   "The spam classification (spam, ham, or neither) of this group.
When a spam group is entered, all unread articles are marked as
spam.  There is other behavior associated with ham and no
classification when spam.el is loaded - see the manual.")

  (gnus-define-group-parameter
   spam-resend-to
   :type list
   :function-document
   "The address to get spam resent (through spam-report-resend)."
   :variable gnus-spam-resend-to
   :variable-default nil
   :variable-document
   "The address to get spam resent (through spam-report-resend)."
   :variable-group spam
   :variable-type '(repeat
		    (list :tag "Group address for resending spam"
			  (regexp :tag "Group")
			  (string :tag "E-mail address for resending spam (requires the spam-use-resend exit processor)")))
   :parameter-type 'string :tag "E-mail address for resending spam (requires the spam-use-resend exit processor)"
   :parameter-document
   "The address to get spam resent (through spam-report-resend).")

  (gnus-define-group-parameter
   ham-resend-to
   :type list
   :function-document
   "The address to get ham resent (through spam-report-resend)."
   :variable gnus-ham-resend-to
   :variable-default nil
   :variable-document
   "The address to get ham resent (through spam-report-resend)."
   :variable-group spam
   :variable-type '(repeat
		    (list :tag "Group address for resending ham"
			  (regexp :tag "Group")
			  (string :tag "E-mail address for resending ham (requires the spam-use-resend exit processor)")))
   :parameter-type 'string :tag "E-mail address for resending ham (requires the spam-use-resend exit processor)"
   :parameter-document
   "The address to get ham resent (through spam-report-resend).")

  (defvar gnus-group-spam-exit-processor-ifile "ifile"
    "OBSOLETE: The ifile summary exit spam processor.")

  (defvar gnus-group-spam-exit-processor-stat "stat"
    "OBSOLETE: The spam-stat summary exit spam processor.")

  (defvar gnus-group-spam-exit-processor-bogofilter "bogofilter"
    "OBSOLETE: The Bogofilter summary exit spam processor.")

  (defvar gnus-group-spam-exit-processor-blacklist "blacklist"
    "OBSOLETE: The Blacklist summary exit spam processor.")

  (defvar gnus-group-spam-exit-processor-report-gmane "report-gmane"
    "OBSOLETE: The Gmane reporting summary exit spam processor.
Only applicable to NNTP groups with articles from Gmane.  See spam-report.el")

  (defvar gnus-group-spam-exit-processor-spamoracle "spamoracle-spam"
    "OBSOLETE: The spamoracle summary exit spam processor.")

  (defvar gnus-group-ham-exit-processor-ifile "ifile-ham"
    "OBSOLETE: The ifile summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-bogofilter "bogofilter-ham"
    "OBSOLETE: The Bogofilter summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-stat "stat-ham"
    "OBSOLETE: The spam-stat summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-whitelist "whitelist"
    "OBSOLETE: The whitelist summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-BBDB "bbdb"
    "OBSOLETE: The BBDB summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-copy "copy"
    "OBSOLETE: The ham copy exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (defvar gnus-group-ham-exit-processor-spamoracle "spamoracle-ham"
    "OBSOLETE: The spamoracle summary exit ham processor.
Only applicable to non-spam (unclassified and ham) groups.")

  (gnus-define-group-parameter
   spam-process
   :type list
   :parameter-type
   '(choice
     :tag "Spam Summary Exit Processor"
     :value nil
     (list :tag "Spam Summary Exit Processor Choices"
	   (set
	    (const :tag "Spam: Bogofilter"    (spam spam-use-bogofilter))
	    (const :tag "Spam: Blacklist"     (spam spam-use-blacklist))
	    (const :tag "Spam: Bsfilter"      (spam spam-use-bsfilter))
	    (const :tag "Spam: Gmane Report"  (spam spam-use-gmane))
	    (const :tag "Spam: Resend Message"(spam spam-use-resend))
	    (const :tag "Spam: ifile"	      (spam spam-use-ifile))
	    (const :tag "Spam: Spam Oracle"   (spam spam-use-spamoracle))
	    (const :tag "Spam: Spam-stat"     (spam spam-use-stat))
	    (const :tag "Spam: SpamAssassin"  (spam spam-use-spamassassin))
	    (const :tag "Spam: CRM114"        (spam spam-use-crm114))
	    (const :tag "Ham: BBDB"	      (ham spam-use-BBDB))
	    (const :tag "Ham: Bogofilter"     (ham spam-use-bogofilter))
	    (const :tag "Ham: Bsfilter"       (ham spam-use-bsfilter))
	    (const :tag "Ham: Copy"	      (ham spam-use-ham-copy))
	    (const :tag "Ham: Resend Message" (ham spam-use-resend))
	    (const :tag "Ham: ifile"	      (ham spam-use-ifile))
	    (const :tag "Ham: Spam Oracle"    (ham spam-use-spamoracle))
	    (const :tag "Ham: Spam-stat"      (ham spam-use-stat))
	    (const :tag "Ham: SpamAssassin"   (ham spam-use-spamassassin))
	    (const :tag "Ham: CRM114"         (ham spam-use-crm114))
	    (const :tag "Ham: Whitelist"      (ham spam-use-whitelist))
	    (variable-item gnus-group-spam-exit-processor-ifile)
	    (variable-item gnus-group-spam-exit-processor-stat)
	    (variable-item gnus-group-spam-exit-processor-bogofilter)
	    (variable-item gnus-group-spam-exit-processor-blacklist)
	    (variable-item gnus-group-spam-exit-processor-spamoracle)
	    (variable-item gnus-group-spam-exit-processor-report-gmane)
	    (variable-item gnus-group-ham-exit-processor-bogofilter)
	    (variable-item gnus-group-ham-exit-processor-ifile)
	    (variable-item gnus-group-ham-exit-processor-stat)
	    (variable-item gnus-group-ham-exit-processor-whitelist)
	    (variable-item gnus-group-ham-exit-processor-BBDB)
	    (variable-item gnus-group-ham-exit-processor-spamoracle)
	    (variable-item gnus-group-ham-exit-processor-copy))))
   :function-document
   "Which spam or ham processors will be applied when the summary is exited."
   :variable gnus-spam-process-newsgroups
   :variable-default nil
   :variable-document
   "Groups in which to automatically process spam or ham articles with
a backend on summary exit.  If non-nil, this should be a list of group
name regexps that should match all groups in which to do automatic
spam processing, associated with the appropriate processor."
   :variable-group spam
   :variable-type
   '(repeat :tag "Spam/Ham Processors"
	    (list :tag "Spam Summary Exit Processor Choices"
		  (regexp :tag "Group Regexp")
		  (set
		   :tag "Spam/Ham Summary Exit Processor"
		   (const :tag "Spam: Bogofilter"    (spam spam-use-bogofilter))
		   (const :tag "Spam: Blacklist"     (spam spam-use-blacklist))
		   (const :tag "Spam: Bsfilter"	     (spam spam-use-bsfilter))
		   (const :tag "Spam: Gmane Report"  (spam spam-use-gmane))
		   (const :tag "Spam: Resend Message"(spam spam-use-resend))
		   (const :tag "Spam: ifile"	     (spam spam-use-ifile))
		   (const :tag "Spam: Spam-stat"     (spam spam-use-stat))
		   (const :tag "Spam: Spam Oracle"   (spam spam-use-spamoracle))
		   (const :tag "Spam: SpamAssassin"  (spam spam-use-spamassassin))
		   (const :tag "Spam: CRM114"        (spam spam-use-crm114))
		   (const :tag "Ham: BBDB"	     (ham spam-use-BBDB))
		   (const :tag "Ham: Bogofilter"     (ham spam-use-bogofilter))
		   (const :tag "Ham: Bsfilter"	     (ham spam-use-bsfilter))
		   (const :tag "Ham: Copy"	     (ham spam-use-ham-copy))
		   (const :tag "Ham: Resend Message" (ham spam-use-resend))
		   (const :tag "Ham: ifile"	     (ham spam-use-ifile))
		   (const :tag "Ham: Spam-stat"	     (ham spam-use-stat))
		   (const :tag "Ham: Spam Oracle"    (ham spam-use-spamoracle))
		   (const :tag "Ham: SpamAssassin"   (ham spam-use-spamassassin))
		   (const :tag "Ham: CRM114"         (ham spam-use-crm114))
		   (const :tag "Ham: Whitelist"	     (ham spam-use-whitelist))
		   (variable-item gnus-group-spam-exit-processor-ifile)
		   (variable-item gnus-group-spam-exit-processor-stat)
		   (variable-item gnus-group-spam-exit-processor-bogofilter)
		   (variable-item gnus-group-spam-exit-processor-blacklist)
		   (variable-item gnus-group-spam-exit-processor-spamoracle)
		   (variable-item gnus-group-spam-exit-processor-report-gmane)
		   (variable-item gnus-group-ham-exit-processor-bogofilter)
		   (variable-item gnus-group-ham-exit-processor-ifile)
		   (variable-item gnus-group-ham-exit-processor-stat)
		   (variable-item gnus-group-ham-exit-processor-whitelist)
		   (variable-item gnus-group-ham-exit-processor-BBDB)
		   (variable-item gnus-group-ham-exit-processor-spamoracle)
		   (variable-item gnus-group-ham-exit-processor-copy))))

   :parameter-document
   "Which spam or ham processors will be applied when the summary is exited.")

  (gnus-define-group-parameter
   spam-autodetect
   :type list
   :parameter-type
   '(boolean :tag "Spam autodetection")
   :function-document
   "Should spam be autodetected (with spam-split) in this group?"
   :variable gnus-spam-autodetect
   :variable-default nil
   :variable-document
   "Groups in which spam should be autodetected when they are entered.
   Only unseen articles will be examined, unless
   spam-autodetect-recheck-messages is set."
   :variable-group spam
   :variable-type
   '(repeat
     :tag "Autodetection setting"
     (list
      (regexp :tag "Group Regexp")
      boolean))
   :parameter-document
   "Spam autodetection.
Only unseen articles will be examined, unless
spam-autodetect-recheck-messages is set.")

  (gnus-define-group-parameter
   spam-autodetect-methods
   :type list
   :parameter-type
   '(choice :tag "Spam autodetection-specific methods"
     (const none)
     (const default)
     (set :tag "Use specific methods"
	  (variable-item spam-use-blacklist)
	  (variable-item spam-use-gmane-xref)
	  (variable-item spam-use-regex-headers)
	  (variable-item spam-use-regex-body)
	  (variable-item spam-use-whitelist)
	  (variable-item spam-use-BBDB)
	  (variable-item spam-use-ifile)
	  (variable-item spam-use-spamoracle)
	  (variable-item spam-use-crm114)
	  (variable-item spam-use-spamassassin)
	  (variable-item spam-use-spamassassin-headers)
	  (variable-item spam-use-bsfilter)
	  (variable-item spam-use-bsfilter-headers)
	  (variable-item spam-use-stat)
	  (variable-item spam-use-blackholes)
	  (variable-item spam-use-bogofilter-headers)
	  (variable-item spam-use-bogofilter)))
   :function-document
   "Methods to be used for autodetection in each group"
   :variable gnus-spam-autodetect-methods
   :variable-default nil
   :variable-document
   "Methods for autodetecting spam per group.
Requires the spam-autodetect parameter.  Only unseen articles
will be examined, unless spam-autodetect-recheck-messages is
set."
   :variable-group spam
   :variable-type
   '(repeat
     :tag "Autodetection methods"
     (list
      (regexp :tag "Group Regexp")
      (choice
       (const none)
       (const default)
       (set :tag "Use specific methods"
	(variable-item spam-use-blacklist)
	(variable-item spam-use-gmane-xref)
	(variable-item spam-use-regex-headers)
	(variable-item spam-use-regex-body)
	(variable-item spam-use-whitelist)
	(variable-item spam-use-BBDB)
	(variable-item spam-use-ifile)
	(variable-item spam-use-spamoracle)
	(variable-item spam-use-crm114)
	(variable-item spam-use-stat)
	(variable-item spam-use-blackholes)
	(variable-item spam-use-spamassassin)
	(variable-item spam-use-spamassassin-headers)
	(variable-item spam-use-bsfilter)
	(variable-item spam-use-bsfilter-headers)
	(variable-item spam-use-bogofilter-headers)
	(variable-item spam-use-bogofilter)))))
     :parameter-document
   "Spam autodetection methods.
Requires the spam-autodetect parameter.  Only unseen articles
will be examined, unless spam-autodetect-recheck-messages is
set.")

  (gnus-define-group-parameter
   spam-process-destination
   :type list
   :parameter-type
   '(choice :tag "Destination for spam-processed articles at summary exit"
	    (string :tag "Move to a group")
	    (repeat :tag "Move to multiple groups"
		    (string :tag "Destination group"))
	    (const :tag "Expire" nil))
   :function-document
   "Where spam-processed articles will go at summary exit."
   :variable gnus-spam-process-destinations
   :variable-default nil
   :variable-document
   "Groups in which to explicitly send spam-processed articles to
another group, or expire them (the default).  If non-nil, this should
be a list of group name regexps that should match all groups in which
to do spam-processed article moving, associated with the destination
group or nil for explicit expiration.  This only makes sense for
mail groups."
   :variable-group spam
   :variable-type
   '(repeat
     :tag "Spam-processed articles destination"
     (list
      (regexp :tag "Group Regexp")
      (choice
       :tag "Destination for spam-processed articles at summary exit"
       (string :tag "Move to a group")
       (repeat :tag "Move to multiple groups"
	       (string :tag "Destination group"))
       (const :tag "Expire" nil))))
   :parameter-document
   "Where spam-processed articles will go at summary exit.")

  (gnus-define-group-parameter
   ham-process-destination
   :type list
   :parameter-type
   '(choice
     :tag "Destination for ham articles at summary exit from a spam group"
     (string :tag "Move to a group")
     (repeat :tag "Move to multiple groups"
	     (string :tag "Destination group"))
     (const :tag "Respool" respool)
     (const :tag "Do nothing" nil))
   :function-document
   "Where ham articles will go at summary exit from a spam group."
   :variable gnus-ham-process-destinations
   :variable-default nil
   :variable-document
   "Groups in which to explicitly send ham articles to
another group, or do nothing (the default).  If non-nil, this should
be a list of group name regexps that should match all groups in which
to do ham article moving, associated with the destination
group or nil for explicit ignoring.  This only makes sense for
mail groups, and only works in spam groups."
   :variable-group spam
   :variable-type
   '(repeat
     :tag "Ham articles destination"
     (list
      (regexp :tag "Group Regexp")
      (choice
       :tag "Destination for ham articles at summary exit from spam group"
       (string :tag "Move to a group")
       (repeat :tag "Move to multiple groups"
		(string :tag "Destination group"))
       (const :tag "Respool" respool)
       (const :tag "Expire" nil))))
   :parameter-document
   "Where ham articles will go at summary exit from a spam group.")

  (gnus-define-group-parameter
   ham-marks
   :type 'list
   :parameter-type '(list :tag "Ham mark choices"
			  (set
			   (variable-item gnus-del-mark)
			   (variable-item gnus-read-mark)
			   (variable-item gnus-ticked-mark)
			   (variable-item gnus-killed-mark)
			   (variable-item gnus-kill-file-mark)
			   (variable-item gnus-low-score-mark)))

   :parameter-document
   "Marks considered ham (positively not spam).  Such articles will be
processed as ham (non-spam) on group exit.  When nil, the global
spam-ham-marks variable takes precedence."
   :variable-default '((".*" ((gnus-del-mark
			       gnus-read-mark
			       gnus-killed-mark
			       gnus-kill-file-mark
			       gnus-low-score-mark))))
   :variable-group spam
   :variable-document
   "Groups in which to explicitly set the ham marks to some value.")

  (gnus-define-group-parameter
   spam-marks
   :type 'list
   :parameter-type '(list :tag "Spam mark choices"
			  (set
			   (variable-item gnus-spam-mark)
			   (variable-item gnus-killed-mark)
			   (variable-item gnus-kill-file-mark)
			   (variable-item gnus-low-score-mark)))

   :parameter-document
   "Marks considered spam.
Such articles will be processed as spam on group exit.  When nil, the global
spam-spam-marks variable takes precedence."
   :variable-default '((".*" ((gnus-spam-mark))))
   :variable-group spam
   :variable-document
   "Groups in which to explicitly set the spam marks to some value."))

(defcustom gnus-group-uncollapsed-levels 1
  "Number of group name elements to leave alone when making a short group name."
  :group 'gnus-group-visual
  :type 'integer)

(defcustom gnus-group-use-permanent-levels nil
  "If non-nil, once you set a level, Gnus will use this level."
  :group 'gnus-group-levels
  :type 'boolean)

;; Hooks.

(defcustom gnus-load-hook nil
  "A hook run while Gnus is loaded."
  :group 'gnus-start
  :type 'hook)

(defcustom gnus-apply-kill-hook '(gnus-apply-kill-file)
  "A hook called to apply kill files to a group.
This hook is intended to apply a kill file to the selected newsgroup.
The function `gnus-apply-kill-file' is called by default.

Since a general kill file is too heavy to use only for a few
newsgroups, I recommend you to use a lighter hook function.  For
example, if you'd like to apply a kill file to articles which contains
a string `rmgroup' in subject in newsgroup `control', you can use the
following hook:

 (setq gnus-apply-kill-hook
      (list
	(lambda ()
	  (cond ((string-match \"control\" gnus-newsgroup-name)
		 (gnus-kill \"Subject\" \"rmgroup\")
		 (gnus-expunge \"X\"))))))"
  :group 'gnus-score-kill
  :options '(gnus-apply-kill-file)
  :type 'hook)

(defcustom gnus-group-change-level-function nil
  "Function run when a group level is changed.
It is called with three parameters -- GROUP, LEVEL and OLDLEVEL."
  :group 'gnus-group-levels
  :type '(choice (const nil)
		 function))

;;; Face thingies.

(defcustom gnus-visual
  '(summary-highlight group-highlight article-highlight
		      mouse-face
		      summary-menu group-menu article-menu
		      tree-highlight menu highlight
		      browse-menu server-menu
		      page-marker tree-menu binary-menu pick-menu)
  "Enable visual features.
If `visual' is disabled, there will be no menus and few faces.  Most of
the visual customization options below will be ignored.  Gnus will use
less space and be faster as a result.

This variable can also be a list of visual elements to switch on.  For
instance, to switch off all visual things except menus, you can say:

   (setq gnus-visual \\='(menu))

Valid elements include `summary-highlight', `group-highlight',
`article-highlight', `mouse-face', `summary-menu', `group-menu',
`article-menu', `tree-highlight', `menu', `highlight',
`browse-menu', `server-menu', `page-marker', `tree-menu',
`binary-menu', and `pick-menu'."
  :group 'gnus-meta
  :group 'gnus-visual
  :type '(set (const summary-highlight)
	      (const group-highlight)
	      (const article-highlight)
	      (const mouse-face)
	      (const summary-menu)
	      (const group-menu)
	      (const article-menu)
	      (const tree-highlight)
	      (const menu)
	      (const highlight)
	      (const browse-menu)
	      (const server-menu)
	      (const page-marker)
	      (const tree-menu)
	      (const binary-menu)
	      (const pick-menu)))

;; Byte-compiler warning.
(defvar gnus-visual)
;; Find out whether the gnus-visual TYPE is wanted.
(defun gnus-visual-p (&optional type class)
  (and gnus-visual			; Has to be non-nil, at least.
       (if (not type)			; We don't care about type.
	   gnus-visual
	 (if (listp gnus-visual)	; It's a list, so we check it.
	     (or (memq type gnus-visual)
		 (memq class gnus-visual))
	   t))))

(defcustom gnus-mouse-face
  (condition-case ()
      (if (gnus-visual-p 'mouse-face 'highlight)
	  (if (boundp 'gnus-mouse-face)
	      (or gnus-mouse-face 'highlight)
	    'highlight)
	'default)
    (error 'highlight))
  "Face used for group or summary buffer mouse highlighting.
The line beneath the mouse pointer will be highlighted with this
face."
  :group 'gnus-visual
  :type 'face)

(defcustom gnus-article-save-directory gnus-directory
  "Name of the directory articles will be saved in (default \"~/News\")."
  :group 'gnus-article-saving
  :type 'directory)

(defvar gnus-plugged t
  "Whether Gnus is plugged or not.")

(defcustom gnus-agent-cache t
  "Controls use of the agent cache while plugged.
When set, Gnus will prefer using the locally stored content rather
than re-fetching it from the server.  You also need to enable
`gnus-agent' for this to have any affect."
  :version "22.1"
  :group 'gnus-agent
  :type 'boolean)

(defcustom gnus-default-charset 'undecided
  "Default charset assumed to be used when viewing non-ASCII characters.
This variable is overridden on a group-to-group basis by the
`gnus-group-charset-alist' variable and is only used on groups not
covered by that variable."
  :type 'symbol
  :group 'gnus-charset)

;; Fixme: Doc reference to agent.
(defcustom gnus-agent t
  "Whether we want to use the Gnus agent or not.

You may customize `gnus-agent' to disable its use.  However, some
back ends have started to use the agent as a client-side cache.
Disabling the agent may result in noticeable loss of performance."
  :version "22.1"
  :group 'gnus-agent
  :type 'boolean)

(defcustom gnus-other-frame-function #'gnus
  "Function called by the command `gnus-other-frame' when starting Gnus."
  :group 'gnus-start
  :type '(choice (function-item gnus)
		 (function-item gnus-no-server)
		 (function-item gnus-child)
		 (function-item gnus-child-no-server)))

(declare-function gnus-group-get-new-news "gnus-group")

(defcustom gnus-other-frame-resume-function #'gnus-group-get-new-news
  "Function called by the command `gnus-other-frame' when resuming Gnus."
  :version "24.4"
  :group 'gnus-start
  :type '(choice (function-item gnus)
		 (function-item gnus-group-get-new-news)
		 (function-item gnus-no-server)
		 (function-item gnus-child)
		 (function-item gnus-child-no-server)))

(defcustom gnus-other-frame-parameters nil
  "Frame parameters used by `gnus-other-frame' to create a Gnus frame."
  :group 'gnus-start
  :type '(repeat (cons :format "%v"
		       (symbol :tag "Parameter")
		       (sexp :tag "Value"))))

(defcustom gnus-user-agent '(gnus)
  "Which information should be exposed in the User-Agent header.

Can be a list of symbols or a string.  Valid symbols are `gnus'
(show Gnus version) and `emacs' (show Emacs version).  In
addition to the Emacs version, you can add `config' (show system
configuration) or `type' (show system type).  If you set it to a
string, be sure to use a valid format, see RFC 2616."
  :version "29.1"
  :group 'gnus-message
  :type '(choice (list (set :inline t
                            (const :value gnus  :tag "Gnus version")
                            (const :value emacs :tag "Emacs version")
			    (choice :tag "system"
                                    (const :value type   :tag "system type")
                                    (const :value config :tag "system configuration"))))
		 (string)))

(defcustom gnus-agent-eagerly-store-articles t
  "If non-nil, cache articles eagerly.

When using the Gnus Agent and reading an agentized newsgroup,
automatically cache the article in the agent cache."
  :type 'boolean
  :version "28.1")


;;; Internal variables

(defvar gnus-agent-gcc-header "X-Gnus-Agent-Gcc")
(defvar gnus-agent-meta-information-header "X-Gnus-Agent-Meta-Information")
(defvar gnus-agent-method-p-cache nil
  ; Reset each time gnus-agent-covered-methods is changed else
  ; gnus-agent-method-p may mis-report a methods status.
  )
(defvar gnus-agent-target-move-group-header "X-Gnus-Agent-Move-To")
(defvar gnus-draft-meta-information-header "X-Draft-From")
(defvar gnus-group-get-parameter-function #'gnus-group-get-parameter)
(defvar gnus-original-article-buffer " *Original Article*")
(defvar gnus-newsgroup-name nil)
(defvar gnus-ephemeral-servers nil)
(defvar gnus-server-method-cache nil)
(defvar gnus-extended-servers nil)

(defvar gnus-agent-fetching nil
  "Whether Gnus agent is in fetching mode.")

(defvar gnus-agent-covered-methods nil
  "A list of servers, NOT methods, showing which servers are covered by the agent.")

(defvar gnus-command-method nil
  "Dynamically bound variable that says what the current back end is.")

(defvar gnus-current-select-method nil
  "The current method for selecting a newsgroup.")

(defvar gnus-tree-buffer "*Tree*"
  "Buffer where Gnus thread trees are displayed.")

;; Variable holding the user answers to all method prompts.
(defvar gnus-method-history nil)

;; Variable holding the user answers to all mail method prompts.
(defvar gnus-mail-method-history nil)

;; Variable holding the user answers to all group prompts.
(defvar gnus-group-history nil)

(defvar gnus-server-alist nil
  "Servers created by Gnus, or via the server buffer.
Servers defined in the user's config files do not appear here.
This variable is persisted in the user's .newsrc.eld file.")

(defcustom gnus-cache-directory
  (nnheader-concat gnus-directory "cache/")
  "The directory where cached articles will be stored."
  :group 'gnus-cache
  :type 'directory)

(defvar gnus-predefined-server-alist
  `(("cache"
     nnspool "cache"
     (nnspool-spool-directory ,gnus-cache-directory)
     (nnspool-nov-directory ,gnus-cache-directory)
     (nnspool-active-file
      ,(nnheader-concat gnus-cache-directory "active"))))
  "List of predefined (convenience) servers.")

(defconst gnus-article-mark-lists
  '((marked . tick) (replied . reply)
    (expirable . expire) (killed . killed)
    (bookmarks . bookmark) (dormant . dormant)
    (scored . score) (saved . save)
    (cached . cache) (downloadable . download)
    (unsendable . unsend) (forwarded . forward)
    (seen . seen) (unexist . unexist)))

(defconst gnus-article-special-mark-lists
  '((seen range)
    (unexist range)
    (killed range)
    (bookmark tuple)
    (uid tuple)
    (active tuple)
    (score tuple)))

;; Propagate flags to server, with the following exceptions:
;; `seen' is private to each gnus installation
;; `cache' is an internal gnus flag for each gnus installation
;; `download' is an agent flag private to each gnus installation
;; `unsend' are for nndraft groups only
;; `score' is not a proper mark
;; `bookmark': don't propagate it, or fix the bug in update-mark.
(defconst gnus-article-unpropagated-mark-lists
  '(seen cache download unsend score bookmark unexist)
  "Marks that shouldn't be propagated to back ends.
Typical marks are those that make no sense in a standalone back end,
such as a mark that says whether an article is stored in the cache
\(which doesn't make sense in a standalone back end).")

(defvar gnus-headers-retrieved-by nil)
(defvar gnus-article-reply nil)
(defvar gnus-override-method nil)
(defvar gnus-opened-servers nil)

(defvar gnus-current-kill-article nil)

(defvar gnus-have-read-active-file nil)

(defconst gnus-maintainer
  "submit@debbugs.gnu.org (The Gnus Bugfixing Girls + Boys)"
  "The mail address of the Gnus maintainers.")

(defconst gnus-bug-package
  "emacs,gnus"
  "The package to use in the bug submission.")

(defvar gnus-info-nodes
  '((gnus-group-mode "(gnus)Group Buffer")
    (gnus-summary-mode "(gnus)Summary Buffer")
    (gnus-article-mode "(gnus)Article Buffer")
    (gnus-server-mode "(gnus)Server Buffer")
    (gnus-browse-mode "(gnus)Browse Foreign Server")
    (gnus-tree-mode "(gnus)Tree Display"))
  "Alist of major modes and related Info nodes.")

(defvar gnus-summary-buffer "*Summary*")
(defvar gnus-article-buffer "*Article*")
(defvar gnus-server-buffer "*Server*")

(defvar gnus-child nil
  "Whether this Gnus is a child or not.")

(defvar gnus-batch-mode nil
  "Whether this Gnus is running in batch mode or not.")

(defvar gnus-variable-list
  '(gnus-newsrc-options gnus-newsrc-options-n
			gnus-newsrc-last-checked-date
			gnus-newsrc-alist gnus-server-alist
			gnus-killed-list gnus-zombie-list
			gnus-topic-topology gnus-topic-alist
			gnus-cloud-sequence
			gnus-cloud-covered-servers
			gnus-cloud-file-timestamps)
  "Gnus variables saved in the quick startup file.")

(defvar gnus-newsrc-alist nil
  "Assoc list of read articles.
`gnus-newsrc-hashtb' should be kept so that both hold the same information.")

(defvar gnus-registry-alist nil
  "Assoc list of registry data.
gnus-registry.el will populate this if it's loaded.")

(defvar gnus-newsrc-hashtb nil
  "Hash table of `gnus-newsrc-alist'.")

(defvar gnus-group-list nil
  "Ordered list of group names as strings.
This variable only exists to provide easy access to the ordering
of `gnus-newsrc-alist'.")

(defvar gnus-killed-list nil
  "List of killed newsgroups.")

(defvar gnus-killed-hashtb nil
  "Hash table equivalent of `gnus-killed-list'.
This is a hash table purely for the fast membership test: values
are always t.")

(defvar gnus-zombie-list nil
  "List of almost dead newsgroups.")

(defvar gnus-description-hashtb nil
  "Hash table mapping group names to their descriptions.")

(defvar gnus-list-of-killed-groups nil
  "List of newsgroups that have recently been killed by the user.")

(defvar gnus-active-hashtb nil
  "Hash table mapping group names to their active entry.")

(defvar gnus-moderated-hashtb nil
  "Hash table of moderated groups.
This is a hash table purely for the fast membership test: values
are always t.")

;; Save window configuration.
(defvar gnus-prev-winconf nil)
(defvar gnus-prev-cwc nil)

(defvar gnus-reffed-article-number nil)

(defvar gnus-dead-summary nil)

(defvar gnus-invalid-group-regexp "[: `'\"/]\\|^$"
  "Regexp matching invalid groups.")

(defvar gnus-other-frame-object nil
  "A frame object which will be created by `gnus-other-frame'.")

;;; End of variables.

;; Define some autoload functions Gnus might use.
(eval-and-compile

  ;; This little mapcar goes through the list below and marks the
  ;; symbols in question as autoloaded functions.
  (mapc
   (lambda (package)
     (let ((interactive (nth 1 (memq ':interactive package))))
       (mapcar
	(lambda (function)
	  (let (type)
	    (when (consp function)
	      (setq type (cadr function))
	      (setq function (car function)))
	    (unless (fboundp function)
	      (autoload function (car package) nil interactive type))))
	(if (eq (nth 1 package) ':interactive)
	    (nthcdr 3 package)
	  (cdr package)))))
   '(("info" :interactive t Info-goto-node)
     ("qp" quoted-printable-decode-region quoted-printable-decode-string)
     ("ps-print" ps-print-preprint)
     ("message" :interactive (message-mode)
      message-send-and-exit message-yank-original)
     ("babel" babel-as-string)
     ("nnmail" nnmail-split-fancy nnmail-article-group)
     ("nnvirtual" nnvirtual-catchup-group nnvirtual-convert-headers)
     ("gnus-xmas" gnus-xmas-splash)
     ("score-mode" :interactive t gnus-score-mode)
     ("gnus-score" :interactive t gnus-score-edit-all-score)
     ("gnus-mh" gnus-summary-save-article-folder
      gnus-Folder-save-name gnus-folder-save-name)
     ("gnus-mh" :interactive (gnus-summary-mode) gnus-summary-save-in-folder)
     ("gnus-demon" gnus-demon-add-scanmail
      gnus-demon-add-rescan gnus-demon-add-scan-timestamps
      gnus-demon-add-disconnection gnus-demon-add-handler
      gnus-demon-remove-handler)
     ("gnus-demon" :interactive t
      gnus-demon-init gnus-demon-cancel)
     ("gnus-fun" gnus-convert-gray-x-face-to-xpm gnus-display-x-face-in-from
      gnus-convert-image-to-gray-x-face gnus-convert-face-to-png
      gnus-face-from-file)
     ("gnus-salt" gnus-highlight-selected-tree gnus-possibly-generate-tree
      gnus-tree-open gnus-tree-close)
     ("gnus-srvr" gnus-enter-server-buffer gnus-server-set-info
      gnus-server-server-name)
     ("gnus-srvr" gnus-browse-foreign-server)
     ("gnus-cite" :interactive (gnus-article-mode gnus-summary-mode)
      gnus-article-highlight-citation gnus-article-hide-citation-maybe
      gnus-article-hide-citation gnus-article-fill-cited-article
      gnus-article-hide-citation-in-followups
      gnus-article-fill-cited-long-lines)
     ("gnus-kill" gnus-kill gnus-apply-kill-file-internal
      gnus-kill-file-edit-file gnus-kill-file-raise-followups-to-author
      gnus-execute gnus-expunge gnus-batch-kill gnus-batch-score)
     ("gnus-registry" gnus-try-warping-via-registry
      gnus-registry-handle-action)
     ("gnus-cache" gnus-cache-possibly-enter-article gnus-cache-save-buffers
      gnus-cache-possibly-remove-articles gnus-cache-request-article
      gnus-cache-retrieve-headers gnus-cache-possibly-alter-active
      gnus-cache-enter-remove-article gnus-cached-article-p
      gnus-cache-open gnus-cache-close gnus-cache-update-article
      gnus-cache-articles-in-group)
     ("gnus-cache" :interactive (gnus-summary-mode)
      gnus-summary-insert-cached-articles gnus-cache-enter-article
      gnus-cache-remove-article gnus-summary-insert-cached-articles)
     ("gnus-cache" :interactive t gnus-jog-cache)
     ("gnus-score" :interactive t
      gnus-score-flush-cache gnus-score-close)
     ("gnus-score" :interactive (gnus-summary-mode)
      gnus-summary-increase-score gnus-summary-set-score
      gnus-summary-raise-thread gnus-summary-raise-same-subject
      gnus-summary-raise-score gnus-summary-raise-same-subject-and-select
      gnus-summary-lower-thread gnus-summary-lower-same-subject
      gnus-summary-lower-score gnus-summary-lower-same-subject-and-select
      gnus-summary-current-score gnus-score-delta-default
      gnus-possibly-score-headers gnus-score-followup-article
      gnus-score-followup-thread)
     ("gnus-score"
      (gnus-summary-score-map keymap) gnus-score-save gnus-score-headers
      gnus-current-score-file-nondirectory gnus-score-adaptive
      gnus-score-find-trace gnus-score-file-name)
     ("gnus-cus" :interactive (gnus-group-mode) gnus-group-customize)
     ("gnus-cus" :interactive (gnus-summary-mode) gnus-score-customize)
     ("gnus-topic" :interactive (gnus-group-mode) gnus-topic-mode)
     ("gnus-topic" gnus-topic-remove-group gnus-topic-set-parameters
      gnus-subscribe-topics)
     ("gnus-salt" :interactive (gnus-summary-mode)
      gnus-pick-mode gnus-binary-mode)
     ("gnus-uu" (gnus-uu-extract-map keymap) (gnus-uu-mark-map keymap))
     ("gnus-uu" :interactive (gnus-article-mode gnus-summary-mode)
      gnus-uu-digest-mail-forward gnus-uu-digest-post-forward
      gnus-uu-mark-series gnus-uu-mark-region gnus-uu-mark-buffer
      gnus-uu-mark-by-regexp gnus-uu-mark-all
      gnus-uu-mark-sparse gnus-uu-mark-thread gnus-uu-decode-uu
      gnus-uu-decode-uu-and-save gnus-uu-decode-unshar
      gnus-uu-decode-unshar-and-save gnus-uu-decode-save
      gnus-uu-decode-binhex gnus-uu-decode-uu-view
      gnus-uu-decode-uu-and-save-view gnus-uu-decode-unshar-view
      gnus-uu-decode-unshar-and-save-view gnus-uu-decode-save-view
      gnus-uu-decode-binhex-view gnus-uu-unmark-thread
      gnus-uu-mark-over gnus-uu-post-news gnus-uu-invert-processable
      gnus-uu-decode-postscript-and-save-view
      gnus-uu-decode-postscript-view gnus-uu-decode-postscript-and-save
      gnus-uu-decode-yenc gnus-uu-unmark-by-regexp gnus-uu-unmark-region
      gnus-uu-decode-postscript)
     ("gnus-uu" gnus-uu-delete-work-dir gnus-uu-unmark-thread)
     ("gnus-msg" (gnus-summary-send-map keymap)
      gnus-article-mail gnus-copy-article-buffer gnus-extended-version)
     ("gnus-msg" :interactive (gnus-group-mode)
      gnus-group-post-news gnus-group-mail gnus-group-news)
     ("gnus-msg" :interactive (gnus-summary-mode)
      gnus-summary-post-news gnus-summary-news-other-window
      gnus-summary-followup gnus-summary-followup-with-original
      gnus-summary-cancel-article gnus-summary-supersede-article
      gnus-summary-reply gnus-summary-reply-with-original
      gnus-summary-mail-forward gnus-summary-mail-other-window
      gnus-summary-resend-message gnus-summary-resend-bounced-mail
      gnus-summary-wide-reply gnus-summary-followup-to-mail
      gnus-summary-followup-to-mail-with-original gnus-bug
      gnus-summary-wide-reply-with-original
      gnus-summary-post-forward gnus-summary-wide-reply-with-original
      gnus-summary-post-forward)
     ("gnus-msg" gnus-post-news)
     ("gnus-picon" :interactive (gnus-article-mode gnus-summary-mode)
      gnus-treat-from-picon)
     ("smiley" :interactive t smiley-region)
     ("gnus-win" gnus-configure-windows gnus-add-configuration)
     ("gnus-sum" gnus-summary-insert-line gnus-summary-read-group
      gnus-list-of-unread-articles gnus-list-of-read-articles
      gnus-offer-save-summaries gnus-make-thread-indent-array
      gnus-summary-exit gnus-update-read-articles gnus-summary-last-subject
      gnus-summary-skip-intangible gnus-summary-article-number
      gnus-data-header gnus-data-find)
     ("gnus-group" gnus-group-insert-group-line gnus-group-quit
      gnus-group-list-groups gnus-group-first-unread-group
      gnus-group-set-mode-line gnus-group-set-info gnus-group-save-newsrc
      gnus-group-setup-buffer gnus-group-get-new-news
      gnus-group-make-help-group gnus-group-update-group
      gnus-group-iterate gnus-group-group-name)
     ("gnus-bcklg" gnus-backlog-request-article gnus-backlog-enter-article
      gnus-backlog-remove-article)
     ("gnus-art" gnus-article-read-summary-keys gnus-article-save
      gnus-article-prepare gnus-article-set-window-start
      gnus-article-next-page gnus-article-prev-page
      gnus-request-article-this-buffer gnus-article-mode
      gnus-article-setup-buffer gnus-narrow-to-page
      gnus-article-delete-invisible-text gnus-treat-article)
     ("gnus-art" :interactive (gnus-summary-mode gnus-article-mode)
      gnus-article-hide-headers gnus-article-hide-boring-headers
      gnus-article-treat-overstrike
      gnus-article-remove-cr gnus-article-remove-trailing-blank-lines
      gnus-article-emojize-symbols
      gnus-article-display-x-face gnus-article-de-quoted-unreadable
      gnus-article-de-base64-unreadable
      gnus-article-decode-HZ
      gnus-article-wash-html
      gnus-article-unsplit-urls
      gnus-article-hide-pem gnus-article-hide-signature
      gnus-article-strip-leading-blank-lines gnus-article-date-local
      gnus-article-date-original gnus-article-date-lapsed
      gnus-article-edit-mode gnus-article-edit-article
      gnus-article-edit-done gnus-article-decode-encoded-words
      gnus-start-date-timer gnus-stop-date-timer
      gnus-mime-view-all-parts gnus-article-pipe-part
      gnus-article-inline-part gnus-article-encrypt-body
      gnus-article-browse-html-article gnus-article-view-part-externally
      gnus-article-view-part-as-charset gnus-article-copy-part
      gnus-article-jump-to-part gnus-article-view-part-as-type
      gnus-article-delete-part gnus-article-replace-part
      gnus-article-save-part-and-strip gnus-article-save-part
      gnus-article-remove-leading-whitespace gnus-article-strip-trailing-space
      gnus-article-strip-leading-space gnus-article-strip-all-blank-lines
      gnus-article-strip-blank-lines gnus-article-strip-multiple-blank-lines
      gnus-article-date-user gnus-article-date-iso8601
      gnus-article-date-english gnus-article-date-ut
      gnus-article-decode-charset gnus-article-decode-mime-words
      gnus-article-toggle-fonts gnus-article-show-images
      gnus-article-remove-images gnus-article-display-face
      gnus-article-treat-fold-newsgroups gnus-article-treat-unfold-headers
      gnus-article-treat-fold-headers gnus-article-highlight-signature
      gnus-article-highlight-headers gnus-article-highlight
      gnus-article-strip-banner gnus-article-hide-list-identifiers
      gnus-article-hide gnus-article-outlook-rearrange-citation
      gnus-article-treat-non-ascii gnus-article-treat-smartquotes
      gnus-article-verify-x-pgp-sig gnus-article-strip-headers-in-body
      gnus-treat-smiley gnus-article-treat-ansi-sequences
      gnus-article-capitalize-sentences gnus-article-toggle-truncate-lines
      gnus-article-fill-long-lines gnus-article-emphasize
      gnus-article-add-buttons-to-head gnus-article-add-button
      gnus-article-babel gnus-sticky-article gnus-article-view-part
      gnus-article-add-buttons)
     ("gnus-int" gnus-request-type)
     ("gnus-start" gnus-newsrc-parse-options gnus-1 gnus-no-server-1
      gnus-dribble-enter gnus-read-init-file gnus-dribble-touch
      gnus-check-reasonable-setup)
     ("gnus-dup" gnus-dup-suppress-articles gnus-dup-unsuppress-article
      gnus-dup-enter-articles)
     ("gnus-eform" gnus-edit-form)
     ("gnus-logic" gnus-score-advanced)
     ("gnus-undo" gnus-undo-mode gnus-undo-register)
     ("gnus-async" gnus-async-request-fetched-article gnus-async-prefetch-next
      gnus-async-prefetch-article gnus-async-prefetch-remove-group
      gnus-async-halt-prefetch)
     ("gnus-agent" gnus-open-agent gnus-agent-get-function
      gnus-agent-save-active gnus-agent-method-p
      gnus-agent-get-undownloaded-list gnus-agent-fetch-session
      gnus-summary-set-agent-mark gnus-agent-save-group-info
      gnus-agent-request-article gnus-agent-retrieve-headers
      gnus-agent-store-article gnus-agent-group-covered-p)
     ("gnus-agent" :interactive t
      gnus-unplugged gnus-agentize gnus-agent-batch)
     ("gnus-vm" :interactive (gnus-summary-mode) gnus-summary-save-in-vm
      gnus-summary-save-article-vm)
     ("compface" uncompface)
     ("gnus-draft" :interactive (gnus-summary-mode) gnus-draft-mode)
     ("gnus-draft" :interactive t gnus-group-send-queue)
     ("gnus-mlspl" gnus-group-split gnus-group-split-fancy)
     ("gnus-mlspl" :interactive (gnus-group-mode) gnus-group-split-setup
      gnus-group-split-update)
     ("gnus-delay" gnus-delay-initialize))))

;;; gnus-sum.el thingies


(defcustom gnus-summary-line-format "%U%R%z%I%(%[%4L: %-23,23f%]%) %s\n"
  "The format specification of the lines in the summary buffer.

It works along the same lines as a normal formatting string,
with some simple extensions.

%N          Article number, left padded with spaces (string)
%S          Subject (string)
%s          Subject if it is at the root of a thread, and \"\"
            otherwise (string)
%n          Name of the poster (string)
%a          Extracted name of the poster (string)
%A          Extracted address of the poster (string)
%F          Contents of the From: header (string)
%f          Contents of the From: or To: headers (string)
%x          Contents of the Xref: header (string)
%D          Contents of the Date: header article (string)
%d          Date of the article (string) in DD-MMM format
%o          Date of the article (string) in YYYYMMDD`T'HHMMSS
            format
%M          Message-id of the article (string)
%r          References of the article (string)
%c          Number of characters in the article (integer)
%k          Pretty-printed version of the above (string)
            For example, \"1.2k\" or \"0.4M\".
%L          Number of lines in the article (integer)
%Z          RSV of the article; nil if not in an nnselect group (integer)
%G          Originating group name for the article; nil if not
            in an nnselect group (string)
%g          Short from  of the originating group name for the article;
            nil if not in an nnselect group (string)
%I          Indentation based on thread level (a string of
            spaces)
%B          A complex trn-style thread tree (string)
            The variables `gnus-sum-thread-*' can be used for
            customization.
%T          A string with two possible values: 80 spaces if the
            article is on thread level two or larger and 0 spaces
            on level one
%R          \"A\" if this article has been replied to, \" \"
            otherwise (character)
%U          \"Read\" status of this article.
            See Info node `(gnus)Marking Articles'
%[          Opening bracket (character, \"[\" or \"<\")
%]          Closing bracket (character, \"]\" or \">\")
%>          Spaces of length thread-level (string)
%<          Spaces of length (- 20 thread-level) (string)
%i          Article score (number)
%z          Article zcore (character)
%t          Number of articles under the current thread (number).
%e          Whether the thread is empty or not (character).
%V          Total thread score (number).
%P          The line number (number).
%O          Download mark (character).
%*          If present, indicates desired cursor position
            (instead of after first colon).
%u          User defined specifier.  The next character in the
            format string should be a letter.  Gnus will call the
            function gnus-user-format-function-X, where X is the
            letter following %u.  The function will be passed the
            current header as argument.  The function should
            return a string, which will be inserted into the
            summary just like information from any other summary
            specifier.
&user-date; Age sensitive date format.  Various date format is
            defined in `gnus-user-date-format-alist'.


The %U (status), %R (replied) and %z (zcore) specs have to be handled
with care.  For reasons of efficiency, Gnus will compute what column
these characters will end up in, and \"hard-code\" that.  This means that
it is invalid to have these specs after a variable-length spec.  Well,
you might not be arrested, but your summary buffer will look strange,
which is bad enough.

The smart choice is to have these specs as far to the left as
possible.

This restriction may disappear in later versions of Gnus.

General format specifiers can also be used.
See Info node `(gnus)Formatting Variables'."
  :link '(custom-manual "(gnus)Formatting Variables")
  :type 'string
  :group 'gnus-summary-format)

;;;
;;; Skeleton keymaps
;;;

(defun gnus-suppress-keymap (keymap)
  (declare (obsolete nil "31.1"))
  (suppress-keymap keymap)
  (let ((keys '([delete] "\177" "\M-u"))) ;[mouse-2]
    (while keys
      (define-key keymap (pop keys) 'undefined))))

(defvar-keymap gnus-article-mode-map
  :suppress t
  "<delete>" #'undefined
  "DEL"      #'undefined
  "M-u"      #'undefined)
(defvar-keymap gnus-summary-mode-map
  :full t :suppress t
  "<delete>" #'undefined
  "DEL"      #'undefined
  "M-u"      #'undefined)
(defvar-keymap gnus-group-mode-map
  :full t :suppress t
  "<delete>" #'undefined
  "DEL"      #'undefined
  "M-u"      #'undefined)



;; Fix by Hallvard B Furuseth <h.b.furuseth@usit.uio.no>.
;; If you want the cursor to go somewhere else, set these two
;; functions in some startup hook to whatever you want.
(defalias 'gnus-summary-position-point 'gnus-goto-colon)
(defalias 'gnus-group-position-point 'gnus-goto-colon)

;;; Various macros and substs.

(defun gnus-header-from (header)
  (mail-header-from header))

(defmacro gnus-group-unread (group)
  "Get the currently computed number of unread articles in GROUP."
  `(car (gethash ,group gnus-newsrc-hashtb)))

(defmacro gnus-group-entry (group)
  "Get the newsrc entry for GROUP."
  `(gethash ,group gnus-newsrc-hashtb))

(defmacro gnus-active (group)
  "Get active info on GROUP."
  `(gethash ,group gnus-active-hashtb))

(defmacro gnus-set-active (group active)
  "Set GROUP's active info."
  `(puthash ,group ,active gnus-active-hashtb))

;; Info access macros.

(cl-defstruct (gnus-info
               (:constructor gnus-info-make
                (group rank read &optional marks method params))
               (:constructor nil)
	       ;; FIXME: gnus-newsrc-alist contains a list of those,
               ;; so changing them to a real struct will take more work!
               (:type list))
  group rank read marks method params)

(defsubst gnus-info-level (info)
  (declare (gv-setter gnus-info--set-level))
  (let ((rank (gnus-info-rank info)))
    (if (consp rank)
	(car rank)
      rank)))
(defsubst gnus-info-score (info)
  (declare (gv-setter gnus-info--set-score))
  (let ((rank (gnus-info-rank info)))
    (or (and (consp rank) (cdr rank)) 0)))

(defsubst gnus-info-set-marks (info marks &optional extend)
  (if extend (gnus-info--grow-entry info 3))
  (setf (gnus-info-marks info) marks))
(defsubst gnus-info-set-method (info method &optional extend)
  (if extend (gnus-info--grow-entry info 4))
  (setf (gnus-info-method info) method))
(defsubst gnus-info-set-params (info params &optional extend)
  (if extend (gnus-info--grow-entry info 5))
  (setf (gnus-info-params info) params))

(defun gnus-info--grow-entry (info number)
  ;; Extend the info until we have enough elements.
  (while (<= (length info) number)
    (nconc info (list nil))))

(defsubst gnus-info--set-level (info level)
  (let ((rank (gnus-info-rank info)))
    (if (consp rank)
        (setcar rank level)
      (setf (gnus-info-rank info) level))))
(defsubst gnus-info--set-score (info score)
  (let ((rank (gnus-info-rank info)))
     (if (consp rank)
	 (setcdr rank score)
       (setf (gnus-info-rank info) (cons rank score)))))

(defsubst gnus-get-info (group)
  (nth 1 (gethash group gnus-newsrc-hashtb)))

(defun gnus-set-info (group info)
  (setcdr (gethash group gnus-newsrc-hashtb)
	  (list info)))


;;;
;;; Shutdown
;;;

(defvar gnus-shutdown-alist nil)

(defun gnus-add-shutdown (function &rest symbols)
  "Run FUNCTION whenever one of SYMBOLS is shut down."
  (push (cons function symbols) gnus-shutdown-alist))

(defun gnus-shutdown (symbol)
  "Shut down everything that waits for SYMBOL."
  (dolist (entry gnus-shutdown-alist)
    (when (memq symbol (cdr entry))
      (funcall (car entry)))))


;;;
;;; Gnus Utility Functions
;;;

(defun gnus-find-subscribed-addresses ()
  "Return a regexp matching the addresses of all subscribed mail groups.
It consists of the `to-address' or `to-list' parameter of all groups
with a `subscribed' parameter."
  (let (group address addresses)
    (dolist (entry (cdr gnus-newsrc-alist))
      (setq group (car entry))
      (when (gnus-parameter-subscribed group)
	(setq address (mail-strip-quoted-names
		       (or (gnus-group-fast-parameter group 'to-address)
			   (gnus-group-fast-parameter group 'to-list))))
	(when address
	  (cl-pushnew address addresses :test #'equal))))
    (when addresses
      (list (mapconcat #'regexp-quote addresses "\\|")))))

(defmacro gnus-string-or (&rest strings)
  "Return the first element of STRINGS that is a non-blank string.
STRINGS will be evaluated in normal `or' order."
  `(gnus-string-or-1 (list ,@strings)))

(defun gnus-string-or-1 (strings)
  (let (string)
    (while strings
      (setq string (pop strings))
      (if (string-match "^[ \t]*$" string)
	  (setq string nil)
	(setq strings nil)))
    string))

(defun gnus-version (&optional arg)
  "Version number of this version of Gnus.
If ARG, insert string at point."
  (interactive "P")
  (if arg
      (insert (message gnus-version))
    (message gnus-version)))

(defun gnus-continuum-version (&optional version)
  "Return VERSION as a floating point number."
  (unless version
    (setq version gnus-version))
  (when (or (string-match "^\\([^ ]+\\)? ?Gnus v?\\([0-9.]+\\)$" version)
	    (string-match "^\\(.?\\)gnus-\\([0-9.]+\\)$" version))
    (let ((alpha (and (match-beginning 1) (match-string 1 version)))
	  (number (match-string 2 version))
	  major minor least)
      (unless (string-match
	       "\\([0-9]\\)\\.\\([0-9]+\\)\\.?\\([0-9]+\\)?" number)
	(error "Invalid version string: %s" version))
      (setq major (string-to-number (match-string 1 number))
	    minor (string-to-number (match-string 2 number))
	    least (if (match-beginning 3)
		      (string-to-number (match-string 3 number))
		    0))
      (string-to-number
       (if (zerop major)
	     (format "%1.2f00%02d%02d"
		     (if (member alpha '("(ding)" "d"))
			 4.99
		       (+ 5 (* 0.02
			       (abs
				(- (aref (downcase alpha) 0) ?t)))
			  -0.01))
		     minor least)
	 (format "%d.%02d%02d" major minor least))))))

(defvar gnus-info-buffer)

(defun gnus-info-find-node (&optional nodename)
  "Find Info documentation of Gnus."
  (interactive)
  ;; Enlarge info window if needed.
  (let (gnus-info-buffer)
    (Info-goto-node (or nodename (cadr (assq major-mode gnus-info-nodes))))
    (setq gnus-info-buffer (current-buffer))
    (gnus-configure-windows 'info)))

;;;
;;; gnus-interactive
;;;

(defvar gnus-current-prefix-symbol nil
  "Current prefix symbol.")

(defvar gnus-current-prefix-symbols nil
  "List of current prefix symbols.")

(defun gnus-interactive (string)
  "Return a list that can be fed to `interactive'.
See `interactive' for full documentation.

Adds the following specs:

y -- The current symbolic prefix.
Y -- A list of the current symbolic prefix(es).
A -- Article number.
H -- Article header.
g -- Group name."
  (let ((i 0)
	out c prompt)
    (while (< i (length string))
      (string-match ".\\([^\n]*\\)\n?" string i)
      (setq c (aref string i))
      (when (match-end 1)
	(setq prompt (match-string 1 string)))
      (setq i (match-end 0))
      ;; We basically emulate just about everything that
      ;; `interactive' does, but add the specs listed above.
      (push
       (cond
	((= c ?a)
	 (completing-read prompt obarray 'fboundp t))
	((= c ?b)
	 (read-buffer prompt (current-buffer) t))
	((= c ?B)
	 (read-buffer prompt (other-buffer (current-buffer))))
	((= c ?c)
	 (read-char))
	((= c ?C)
	 (completing-read prompt obarray 'commandp t))
	((= c ?d)
	 (point))
	((= c ?D)
	 (read-directory-name prompt nil default-directory 'lambda))
	((= c ?f)
	 (read-file-name prompt nil nil 'lambda))
	((= c ?F)
	 (read-file-name prompt))
	((= c ?k)
	 (read-key-sequence prompt))
	((= c ?K)
	 (error "Not implemented spec"))
	((= c ?e)
	 (error "Not implemented spec"))
	((= c ?m)
	 (mark))
	((= c ?N)
	 (error "Not implemented spec"))
	((= c ?n)
	 (string-to-number (read-from-minibuffer prompt)))
	((= c ?p)
	 (prefix-numeric-value current-prefix-arg))
	((= c ?P)
	 current-prefix-arg)
	((= c ?r)
	 'gnus-prefix-nil)
	((= c ?s)
	 (read-string prompt))
	((= c ?S)
	 (intern (read-string prompt)))
	((= c ?v)
	 (read-variable prompt))
	((= c ?x)
	 (read-minibuffer prompt))
	((= c ?x)
	 (eval-minibuffer prompt))
	;; And here the new specs come.
	((= c ?y)
	 gnus-current-prefix-symbol)
	((= c ?Y)
	 gnus-current-prefix-symbols)
	((= c ?g)
	 (gnus-group-group-name))
	((= c ?A)
	 (gnus-summary-skip-intangible)
	 (or (get-text-property (point) 'gnus-number)
	     (gnus-summary-last-subject)))
	((= c ?H)
	 (gnus-data-header (gnus-data-find (gnus-summary-article-number))))
	(t
	 (error "Non-implemented spec")))
       out)
      (cond
       ((= c ?r)
	(push (if (< (point) (mark)) (point) (mark)) out)
	(push (if (> (point) (mark)) (point) (mark)) out))))
    (setq out (delq 'gnus-prefix-nil out))
    (nreverse out)))

(defun gnus-symbolic-argument ()
  "Read a symbolic argument and a command, and then execute command."
  (interactive)
  (let* ((in-command (this-command-keys))
	 (command in-command)
	 gnus-current-prefix-symbols
	 gnus-current-prefix-symbol
	 syms)
    (while (equal in-command command)
      (message "%s-" (key-description (this-command-keys)))
      (push (intern (char-to-string (read-char))) syms)
      (setq command (read-key-sequence nil t)))
    (setq gnus-current-prefix-symbols (nreverse syms)
	  gnus-current-prefix-symbol (car gnus-current-prefix-symbols))
    (call-interactively (key-binding command t))))

;;; More various functions.

(defsubst gnus-check-backend-function (func group)
  "Check whether GROUP supports function FUNC.
GROUP can either be a string (a group name) or a select method."
  (ignore-errors
    (when-let* ((method (if (stringp group)
		            (car (gnus-find-method-for-group group))
		          group)))
      (unless (featurep method)
	(require method))
      (fboundp (intern (format "%s-%s" method func))))))

(defun gnus-group-read-only-p (&optional group)
  "Check whether GROUP supports editing or not.
If GROUP is nil, `gnus-newsgroup-name' will be checked instead.  Note
that that variable is buffer-local to the summary buffers."
  (let ((group (or group gnus-newsgroup-name)))
    (not (gnus-check-backend-function 'request-replace-article group))))

(defun gnus-virtual-group-p (group)
  "Say whether GROUP is virtual or not."
  (memq 'virtual (assoc (symbol-name (car (gnus-find-method-for-group group)))
			gnus-valid-select-methods)))

(defun gnus-news-group-p (group &optional article)
  "Return non-nil if GROUP (and ARTICLE) come from a news server."
  (cond ((gnus-member-of-valid 'post group) ;Ordinary news group
	 t)				    ;is news of course.
	((not (gnus-member-of-valid 'post-mail group)) ;Non-combined.
	 nil)				;must be mail then.
	((mail-header-p article)		;Has header info.
	 (eq (gnus-request-type group (mail-header-id article)) 'news))
	((null article)			       ;Hasn't header info
	 (eq (gnus-request-type group) 'news)) ;(unknown ==> mail)
	((< article 0)			       ;Virtual message
	 nil)				;we don't know, guess mail.
	(t				;Has positive number
	 (eq (gnus-request-type group article) 'news)))) ;use it.

;; Check whether to use long file names.
(defun gnus-use-long-file-name (symbol)
  ;; The variable has to be set...
  (and gnus-use-long-file-name
       ;; If it isn't a list, then we return t.
       (or (not (listp gnus-use-long-file-name))
	   ;; If it is a list, and the list contains `symbol', we
	   ;; return nil.
	   (not (memq symbol gnus-use-long-file-name)))))

;; Generate a unique new group name.
(defun gnus-generate-new-group-name (leaf)
  (let ((name leaf)
	(num 0))
    (while (gnus-group-entry name)
      (setq name (concat leaf "<" (int-to-string (setq num (1+ num))) ">")))
    name))

(defun gnus-ephemeral-group-p (group)
  "Say whether GROUP is ephemeral or not."
  (gnus-group-get-parameter group 'quit-config t))

(defun gnus-group-quit-config (group)
  "Return the quit-config of GROUP."
  (gnus-group-get-parameter group 'quit-config t))

(defun gnus-kill-ephemeral-group (group)
  "Remove ephemeral GROUP from relevant structures."
  (remhash group gnus-newsrc-hashtb)
  (setq gnus-newsrc-alist
	(delq (assoc group gnus-newsrc-alist)
              gnus-newsrc-alist)))

(defun gnus-simplify-mode-line ()
  "Make mode lines a bit simpler."
  (setq mode-line-modified "--")
  (when (listp mode-line-format)
    (setq-local mode-line-format (copy-sequence mode-line-format))
    (when (equal (nth 3 mode-line-format) "   ")
      (setcar (nthcdr 3 mode-line-format) " "))))

;;; Servers and groups.

(defsubst gnus-server-add-address (method)
  (let ((method-name (symbol-name (car method))))
    (if (and (memq 'address (assoc method-name gnus-valid-select-methods))
	     (not (assq (intern (concat method-name "-address")) method))
	     (memq 'physical-address (assq (car method)
					   gnus-valid-select-methods)))
	(append method (list (list (intern (concat method-name "-address"))
				   (nth 1 method))))
      method)))

(defsubst gnus-method-to-server (method &optional nocache no-enter-cache)
  (catch 'server-name
    (setq method (or method gnus-select-method))

    ;; Perhaps it is already in the cache.
    (unless nocache
      (mapc (lambda (name-method)
	      (if (equal (cdr name-method) method)
		  (throw 'server-name (car name-method))))
	    gnus-server-method-cache))

    (dolist (server-alist
             (list gnus-server-alist
	           gnus-predefined-server-alist))
      (mapc (lambda (name-method)
	      (when (gnus-methods-equal-p (cdr name-method) method)
		(unless (member name-method gnus-server-method-cache)
		  (push name-method gnus-server-method-cache))
		(throw 'server-name (car name-method))))
	    server-alist))

    (let* ((name (if (member (cadr method) '(nil ""))
		     (format "%s" (car method))
		   (format "%s:%s" (car method) (cadr method))))
	   (name-method (cons name method)))
      (unless (or no-enter-cache
		  (member name-method gnus-server-method-cache)
		  (assoc (car name-method) gnus-server-method-cache))
	(push name-method gnus-server-method-cache))
      name)))

(defsubst gnus-server-to-method (server)
  "Map virtual server names to select methods."
  (or (and server (listp server) server)
      (cdr (assoc server gnus-server-method-cache))
      (let ((result
	     (or
	      ;; Perhaps this is the native server?
	      (and (equal server "native") gnus-select-method)
	      ;; It should be in the server alist.
	      (cdr (assoc server gnus-server-alist))
	      ;; It could be in the predefined server alist.
	      (cdr (assoc server gnus-predefined-server-alist))
	      ;; If not, we look through all the opened server
	      ;; to see whether we can find it there.
	      (let ((opened gnus-opened-servers))
		(while (and opened
			    (not (equal server (format "%s:%s" (caaar opened)
						       (cadaar opened)))))
		  (pop opened))
		(caar opened))
	      ;; It could be a named method, search all servers
	      (let ((servers gnus-secondary-select-methods))
		(while (and servers
			    (not (equal server (format "%s:%s" (caar servers)
						       (cadar servers)))))
		  (pop servers))
		(car servers))
	      ;; This could be some sort of foreign server that I
	      ;; simply haven't opened (yet).  Do a brute-force scan
	      ;; of the entire gnus-newsrc-alist for the server name
	      ;; of every method.  As a side-effect, loads the
	      ;; gnus-server-method-cache so this only happens once,
	      ;; if at all.
	      (let ((alist (cdr gnus-newsrc-alist))
		    method match)
		(while alist
		  (setq method (gnus-info-method (pop alist)))
		  (when (and (not (stringp method))
			     (equal server
				    (gnus-method-to-server method nil t)))
		    (setq match method
			  alist nil)))
		match))))
	(when (and result
		   (not (assoc server gnus-server-method-cache)))
	  (push (cons server result) gnus-server-method-cache))
	result)))

(defsubst gnus-server-get-method (group method)
  ;; Input either a server name, and extended server name, or a
  ;; select method, and return a select method.
  (cond ((stringp method)
	 (gnus-server-to-method method))
	((equal method gnus-select-method)
	 gnus-select-method)
	((and group (stringp (car method)))
	 (gnus-server-extend-method group method))
	((and method
	      (not group)
	      (equal (cadr method) ""))
	 method)
	(t
	 (gnus-server-add-address method))))

(defmacro gnus-method-equal (ss1 ss2)
  "Say whether two servers are equal."
  `(let ((s1 ,ss1)
	 (s2 ,ss2))
     (or (equal s1 s2)
	 (and (= (length s1) (length s2))
	      (progn
		(while (and s1 (member (car s1) s2))
		  (setq s1 (cdr s1)))
		(null s1))))))

(defun gnus-methods-equal-p (m1 m2)
  (let ((m1 (or m1 gnus-select-method))
	(m2 (or m2 gnus-select-method)))
    (or (equal m1 m2)
	(and (eq (car m1) (car m2))
	     (or (not (memq 'address (assoc (symbol-name (car m1))
					    gnus-valid-select-methods)))
		 (equal (nth 1 m1) (nth 1 m2)))))))

(defsubst gnus-sloppily-equal-method-parameters (m1 m2)
  ;; Check parameters for sloppy equality.
  (let ((p1 (copy-sequence (cddr m1)))
	(p2 (copy-sequence (cddr m2)))
	e1 e2)
    (cl-block nil
      (while (setq e1 (pop p1))
	(unless (setq e2 (assq (car e1) p2))
	  ;; The parameter doesn't exist in p2.
	  (cl-return nil))
	(setq p2 (delq e2 p2))
	(unless (equal e1 e2)
	  (if (not (and (stringp (cadr e1))
			(stringp (cadr e2))))
	      (cl-return nil)
	    ;; Special-case string parameter comparison so that we
	    ;; can uniquify them.
	    (let ((s1 (cadr e1))
		  (s2 (cadr e2)))
	      (when (string-match "/\\'" s1)
		(setq s1 (directory-file-name s1)))
	      (when (string-match "/\\'" s2)
		(setq s2 (directory-file-name s2)))
	      (unless (equal s1 s2)
		(cl-return nil))))))
      ;; If p2 now is empty, they were equal.
      (null p2))))

(defun gnus-method-ephemeral-p (method)
  (let ((equal nil))
    (dolist (ephemeral gnus-ephemeral-servers)
      (when (gnus-sloppily-equal-method-parameters method ephemeral)
	(setq equal t)))
    equal))

(defun gnus-methods-sloppily-equal (m1 m2)
  ;; Same method.
  (or
   (eq m1 m2)
   ;; Type and name are equal.
   (and
    (eq (car m1) (car m2))
    (equal (cadr m1) (cadr m2))
    (gnus-sloppily-equal-method-parameters m1 m2))))

(defun gnus-server-equal (m1 m2)
  "Say whether two methods are equal."
  (let ((m1 (cond ((null m1) gnus-select-method)
		  ((stringp m1) (gnus-server-to-method m1))
		  (t m1)))
	(m2 (cond ((null m2) gnus-select-method)
		  ((stringp m2) (gnus-server-to-method m2))
		  (t m2))))
    (gnus-method-equal m1 m2)))

(defun gnus-servers-using-backend (backend)
  "Return a list of known servers using BACKEND."
  (let ((opened gnus-opened-servers)
	out)
    (while opened
      (when (eq backend (caaar opened))
	(push (caar opened) out))
      (pop opened))
    out))

(defun gnus-archive-server-wanted-p ()
  "Say whether the user wants to use the archive server."
  (cond
   ((or (not gnus-message-archive-method)
	(not gnus-message-archive-group))
    nil)
   ((and gnus-message-archive-method gnus-message-archive-group)
    t)
   (t
    (let ((active (cadr (assq 'nnfolder-active-file
			      gnus-message-archive-method))))
      (and active
	   (file-exists-p active))))))

(defsubst gnus-method-to-server-name (method)
  (concat
   (format "%s" (car method))
   (when (and
	  (or (assoc (format "%s" (car method))
		     (gnus-methods-using 'address))
	      (gnus-server-equal method gnus-message-archive-method))
	  (nth 1 method)
	  (not (string= (nth 1 method) "")))
     (concat "+" (nth 1 method)))))

(defsubst gnus-method-to-full-server-name (method)
  (format "%s+%s" (car method) (nth 1 method)))

(defun gnus-group-prefixed-name (group method &optional full)
  "Return the whole name from GROUP and METHOD.
Call with full set to get the fully qualified group name (even if the
server is native)."
  (when (stringp method)
    (setq method (gnus-server-to-method method)))
  (if (or (not method)
	  (and (not full) (gnus-server-equal method "native"))
	  ;;;!!! This might not be right.  We'll see...
	  ;(string-match ":" group)
	  )
      group
    (concat (gnus-method-to-server-name method) ":" group)))

(defun gnus-group-full-name (group method)
  "Return the full name from GROUP and METHOD, even if the method is native."
  (gnus-group-prefixed-name group method t))

(defun gnus-group-guess-full-name-from-command-method (group)
  "Guess the full name from GROUP, even if the method is native."
  (if (gnus-group-prefixed-p group)
      group
    (gnus-group-full-name group gnus-command-method)))

(defun gnus-group-real-prefix (group)
  "Return the prefix of the current group name."
  (if (stringp group)
      (if (string-match "^[^:]+:" group)
	  (substring group 0 (match-end 0))
	"")
    nil))

(defun gnus-group-short-name (group)
  "Return the short group name."
  (let ((prefix (gnus-group-real-prefix group)))
    (if (< 0 (length prefix))
	(substring group (length prefix) nil)
      group)))

(defun gnus-group-prefixed-p (group)
  "Return the prefix of the current group name."
  (< 0 (length (gnus-group-real-prefix group))))

(defun gnus-summary-buffer-name (group)
  "Return the summary buffer name of GROUP."
  (concat "*Summary " group "*"))

(defun gnus-group-method (group)
  "Return the server or method used for selecting GROUP.
You should probably use `gnus-find-method-for-group' instead."
  (let ((prefix (gnus-group-real-prefix group)))
    (if (equal prefix "")
	gnus-select-method
      (let ((servers gnus-opened-servers)
	    (server "")
	    backend possible found)
	(if (string-match "^[^\\+]+\\+" prefix)
	    (setq backend (intern (substring prefix 0 (1- (match-end 0))))
		  server (substring prefix (match-end 0) (1- (length prefix))))
	  (setq backend (intern (substring prefix 0 (1- (length prefix))))))
	(while servers
	  (when (eq (caaar servers) backend)
	    (setq possible (caar servers))
	    (when (equal (cadaar servers) server)
	      (setq found (caar servers))))
	  (pop servers))
	(or (car (rassoc found gnus-server-alist))
	    found
	    (car (rassoc possible gnus-server-alist))
	    possible
	    (list backend server))))))

(defsubst gnus-native-method-p (method)
  "Return whether METHOD is the native select method."
  (gnus-method-equal method gnus-select-method))

(defsubst gnus-secondary-method-p (method)
  "Return whether METHOD is a secondary select method."
  (let ((methods gnus-secondary-select-methods)
	(gmethod (inline (gnus-server-get-method nil method))))
    (while (and methods
		(not (gnus-method-equal
		      (inline (gnus-server-get-method nil (car methods)))
		      gmethod)))
      (setq methods (cdr methods)))
    methods))

(defun gnus-method-simplify (method)
  "Return the shortest uniquely identifying string or method for METHOD."
  (cond ((stringp method)
	 method)
	((gnus-native-method-p method)
	 nil)
	((gnus-secondary-method-p method)
	 (format "%s:%s" (nth 0 method) (nth 1 method)))
	(t
	 method)))

(defun gnus-groups-from-server (server)
  "Return a list of all groups that are fetched from SERVER."
  (let ((alist (cdr gnus-newsrc-alist))
	info groups)
    (while (setq info (pop alist))
      (when (gnus-server-equal (gnus-info-method info) server)
	(push (gnus-info-group info) groups)))
    (sort groups #'string<)))

(defun gnus-group-foreign-p (group)
  "Say whether a group is foreign or not."
  (and (not (gnus-group-native-p group))
       (not (gnus-group-secondary-p group))))

(defun gnus-group-native-p (group)
  "Say whether the group is native or not."
  (not (string-search ":" group)))

(defun gnus-group-secondary-p (group)
  "Say whether the group is secondary or not."
  (gnus-secondary-method-p (gnus-find-method-for-group group)))

(defun gnus-parameters-get-parameter (group)
  "Return the group parameters for GROUP from `gnus-parameters'."
  (let ((case-fold-search (if (eq gnus-parameters-case-fold-search 'default)
			      case-fold-search
			    gnus-parameters-case-fold-search))
	params-list)
    (dolist (elem gnus-parameters)
      (when (string-match (car elem) group)
	(setq params-list
	      (nconc (gnus-expand-group-parameters
		      (car elem) (cdr elem) group)
		     params-list))))
    params-list))

(defun gnus-expand-group-parameter (match value group)
  "Use MATCH to expand VALUE in GROUP."
  (let ((start (string-match match group)))
    (if start
        (let ((matched-string (substring group start (match-end 0))))
          ;; Build match groups
          (string-match match matched-string)
          (replace-match value nil nil matched-string))
      group)))

(defun gnus-expand-group-parameters (match parameters group)
  "Go through PARAMETERS and expand them according to the match data."
  (let (new)
    (dolist (elem parameters)
      (cond
       ((and (stringp (cdr elem))
             (string-match "\\\\[0-9&]" (cdr elem)))
        (push (cons (car elem)
                    (gnus-expand-group-parameter match (cdr elem) group))
              new))
       ;; For `sieve' group parameters, perform substitutions for every
       ;; string within the match rule.  This allows for parameters such
       ;; as:
       ;;  ("list\\.\\(.*\\)"
       ;;   (sieve header :is "list-id" "<\\1.domain.org>"))
       ((eq 'sieve (car elem))
        (push (mapcar (lambda (sieve-elem)
                        (if (and (stringp sieve-elem)
                                 (string-match "\\\\[0-9&]" sieve-elem))
                            (gnus-expand-group-parameter match sieve-elem
                                                         group)
                          sieve-elem))
                      (cdr elem))
              new))
       (t
	(push elem new))))
    new))

(defun gnus-group-fast-parameter (group symbol &optional allow-list)
  "For GROUP, return the value of SYMBOL.

You should call this in the `gnus-group-buffer' buffer.
The function `gnus-group-find-parameter' will do that for you."
  ;; The speed trick:  No cons'ing and quit early.
  (let* ((params (funcall gnus-group-get-parameter-function group))
	 ;; Start easy, check the "real" group parameters.
	 (simple-results
	  (gnus-group-parameter-value params symbol allow-list t)))
    (if simple-results
	;; Found results; return them.
	(car simple-results)
      ;; We didn't find it there, try `gnus-parameters'.
      (let ((result nil)
	    (head nil)
	    (tail gnus-parameters))
	;; A good old-fashioned non-cl loop.
	(while tail
	  (setq head (car tail)
		tail (cdr tail))
	  ;; The car is regexp matching for matching the group name.
	  (when (string-match (car head) group)
	    ;; The cdr is the parameters.
	    (let ((this-result
		   (gnus-group-parameter-value (cdr head) symbol allow-list t)))
	      (when this-result
		(setq result (car this-result))
		;; Expand if necessary.
		(cond
                 ((and (stringp result) (string-match "\\\\[0-9&]" result))
                  (setq result (gnus-expand-group-parameter
                                (car head) result group)))
                 ;; For `sieve' group parameters, perform substitutions
                 ;; for every string within the match rule (see above).
                 ((eq symbol 'sieve)
                  (setq result
                        (mapcar (lambda (elem)
                                  (if (stringp elem)
                                      (gnus-expand-group-parameter (car head)
                                                                   elem group)
                                    elem))
                                result))))))))
	;; Done.
	result))))

(defun gnus-group-find-parameter (group &optional symbol allow-list)
  "Return the group parameters for GROUP.
If SYMBOL, return the value of that symbol in the group parameters.

If you call this function inside a loop, consider using the faster
`gnus-group-fast-parameter' instead."
  (with-current-buffer (or (gnus-buffer-live-p gnus-group-buffer)
                           (current-buffer))
    (if symbol
	(gnus-group-fast-parameter group symbol allow-list)
      (nconc
       (copy-sequence
	(funcall gnus-group-get-parameter-function group))
       (gnus-parameters-get-parameter group)))))

(defun gnus-group-get-parameter (group &optional symbol allow-list)
  "Return the group parameters for GROUP.
If SYMBOL, return the value of that symbol in the group
parameters.  If ALLOW-LIST, also allow list as a result.  Most
functions should use `gnus-group-find-parameter', which also
examines the topic parameters.  GROUP can also be an info structure."
  (let ((params (gnus-info-params (if (listp group) group
				    (gnus-get-info group)))))
    (if symbol
	(gnus-group-parameter-value params symbol allow-list)
      params)))

(defun gnus-group-parameter-value (params symbol &optional
					  allow-list present-p)
  "Return the value of SYMBOL in group PARAMS.
If ALLOW-LIST, also allow list as a result."
  ;; We only wish to return group parameters (dotted lists) and
  ;; not local variables, which may have the same names.
  ;; But first we handle single elements...
  (or (car (memq symbol params))
      ;; Handle alist.
      (let (elem)
	(catch 'found
	  (while (setq elem (pop params))
	    (when (and (consp elem)
		       (eq (car elem) symbol)
		       (or allow-list
			   (atom (cdr elem))))
	      (throw 'found (if present-p (list (cdr elem))
			      (cdr elem)))))))))

(defun gnus-group-add-parameter (group param)
  "Add parameter PARAM to GROUP."
  (let ((info (gnus-get-info group)))
    (when info
      (gnus-group-remove-parameter group (if (consp param) (car param) param))
      ;; Cons the new param to the old one and update.
      (gnus-group-set-info (cons param (gnus-info-params info))
			   group 'params))))

(defun gnus-group-set-parameter (group name value)
  "Set parameter NAME to VALUE in GROUP.
GROUP can also be an INFO structure."
  (let ((info (if (listp group)
		  group
		(gnus-get-info group))))
    (when info
      (gnus-group-remove-parameter group name)
      (let ((old-params (gnus-info-params info))
	    (new-params (list (cons name value))))
	(while old-params
	  (when (or (not (listp (car old-params)))
		    (not (eq (caar old-params) name)))
	    (setq new-params (append new-params (list (car old-params)))))
	  (setq old-params (cdr old-params)))
	(if (listp group)
	    (gnus-info-set-params info new-params t)
	  (gnus-group-set-info new-params (gnus-info-group info) 'params))))))

(defun gnus-group-remove-parameter (group name)
  "Remove parameter NAME from GROUP.
GROUP can also be an INFO structure."
  (let ((info (if (listp group)
		  group
		(gnus-get-info group))))
    (when info
      (let ((params (gnus-info-params info)))
	(when params
	  (setq params (delq name params))
	  (while (assq name params)
	    (gnus-alist-pull name params))
	  (setf (gnus-info-params info) params))))))

(defun gnus-group-add-score (group &optional score)
  "Add SCORE to the GROUP score.
If SCORE is nil, add 1 to the score of GROUP."
  (let ((info (gnus-get-info group)))
    (when info
      (setf (gnus-info-score info) (+ (gnus-info-score info) (or score 1))))))

(defun gnus-short-group-name (group &optional levels)
  "Collapse GROUP name LEVELS.
Select methods are stripped and any remote host name is stripped down to
just the host name."
  (let* ((foreign "")
	 (depth 0)
	 (skip 1)
	 (levels (or levels
		     gnus-group-uncollapsed-levels
		     (progn
		       (while (string-match "\\." group skip)
			 (setq skip (match-end 0)
			       depth (+ depth 1)))
		       depth))))
    ;; Separate foreign select method from group name and collapse.
    ;; If method contains a server, collapse to non-domain server name,
    ;; otherwise collapse to select method.
    (let* ((colon (string-search ":" group))
	   (server (and colon (substring group 0 colon)))
	   (plus (and server (string-search "+" server))))
      (when server
	(if plus
	    (setq foreign (substring server (+ 1 plus)
				     (string-search "." server))
		  group (substring group (+ 1 colon)))
	  (setq foreign server
		group (substring group (+ 1 colon))))
	(setq foreign (concat foreign ":")))
      ;; Remove braces from name (common in IMAP groups).
      (setq group (replace-regexp-in-string "[][]+" "" group))
      ;; Collapse group name leaving LEVELS uncollapsed elements
      (let* ((slist (split-string group "/"))
	     (slen (length slist))
	     (dlist (split-string group "\\."))
	     (dlen (length dlist))
	     glist
	     glen
	     gsep
	     res)
	(if (> slen dlen)
	    (setq glist slist
		  glen slen
		  gsep "/")
	  (setq glist dlist
		glen dlen
		gsep "."))
	(setq levels (- glen levels))
	(dolist (g glist)
          (push (if (>= (decf levels) 0)
		    (if (zerop (length g))
			""
		      (substring g 0 1))
		  g)
		res))
	(concat foreign (mapconcat #'identity (nreverse res) gsep))))))

(defun gnus-narrow-to-body ()
  "Narrow to the body of an article."
  (narrow-to-region
   (progn
     (goto-char (point-min))
     (or (search-forward "\n\n" nil t)
	 (point-max)))
   (point-max)))


;;;
;;; Kill file handling.
;;;

(defun gnus-apply-kill-file ()
  "Apply a kill file to the current newsgroup.
Returns the number of articles marked as read."
  (if (or (file-exists-p (gnus-newsgroup-kill-file nil))
	  (file-exists-p (gnus-newsgroup-kill-file gnus-newsgroup-name)))
      (gnus-apply-kill-file-internal)
    0))

(defun gnus-kill-save-kill-buffer ()
  (let ((file (gnus-newsgroup-kill-file gnus-newsgroup-name)))
    (when (get-file-buffer file)
      (with-current-buffer (get-file-buffer file)
	(when (buffer-modified-p)
	  (save-buffer))
	(kill-buffer (current-buffer))))))

(defcustom gnus-kill-file-name "KILL"
  "Suffix of the kill files."
  :group 'gnus-score-kill
  :group 'gnus-score-files
  :type 'string)

(defun gnus-newsgroup-kill-file (newsgroup)
  "Return the name of a kill file name for NEWSGROUP.
If NEWSGROUP is nil, return the global kill file name instead."
  (cond
   ;; The global KILL file is placed at top of the directory.
   ((or (null newsgroup)
	(string-equal newsgroup ""))
    (expand-file-name gnus-kill-file-name
		      gnus-kill-files-directory))
   ;; Append ".KILL" to newsgroup name.
   ((gnus-use-long-file-name 'not-kill)
    (expand-file-name (concat (gnus-newsgroup-savable-name newsgroup)
			      "." gnus-kill-file-name)
		      gnus-kill-files-directory))
   ;; Place "KILL" under the hierarchical directory.
   (t
    (expand-file-name (concat (gnus-newsgroup-directory-form newsgroup)
			      "/" gnus-kill-file-name)
		      gnus-kill-files-directory))))

;;; Server things.

(defun gnus-member-of-valid (symbol group)
  "Find out if GROUP has SYMBOL as part of its \"valid\" spec."
  (memq symbol (assoc
		(symbol-name (car (gnus-find-method-for-group group)))
		gnus-valid-select-methods)))

(defun gnus-method-option-p (method option)
  "Return non-nil if select METHOD has OPTION as a parameter."
  (when (stringp method)
    (setq method (gnus-server-to-method method)))
  (memq option (assoc (format "%s" (car method))
		      gnus-valid-select-methods)))

(defun gnus-similar-server-opened (method)
  "Return non-nil if we have a similar server opened.
This is defined as a server with the same name, but different
parameters."
  (let ((opened gnus-opened-servers)
	open)
    (while (and method opened)
      (setq open (car (pop opened)))
      ;; Type and name are the same...
      (when (and (equal (car method) (car open))
		 (equal (cadr method) (cadr open))
		 ;; ... but the rest of the parameters differ.
		 (not (gnus-methods-sloppily-equal method open)))
	(setq method nil)))
    (not method)))

(defun gnus-server-extend-method (group method)
  ;; This function "extends" a virtual server.  If the server is
  ;; "hello", and the select method is ("hello" (my-var "something"))
  ;; in the group "alt.alt", this will result in a new virtual server
  ;; called "hello+alt.alt".
  (if (or (not (inline (gnus-similar-server-opened method)))
	  (not (cddr method)))
      method
    (let ((address-slot
	   (intern (format "%s-address" (car method)))))
      (setq method
	    (if (assq address-slot (cddr method))
		`(,(car method) ,(concat (cadr method) "+" group)
		  ,@(cddr method))
	      `(,(car method) ,(concat (cadr method) "+" group)
		(,address-slot ,(cadr method))
		,@(cddr method))))
      (push method gnus-extended-servers)
      method)))

(defun gnus-server-status (method)
  "Return the status of METHOD."
  (nth 1 (assoc method gnus-opened-servers)))

(defun gnus-group-name-to-method (group)
  "Guess a select method based on GROUP."
  (if (string-match ":" group)
      (let ((server (substring group 0 (match-beginning 0))))
	(if (string-match "\\+" server)
	    (list (intern (substring server 0 (match-beginning 0)))
		  (substring server (match-end 0)))
	  (list (intern server) "")))
    gnus-select-method))

(defun gnus-server-string (server)
  "Return a readable string that describes SERVER."
  (let* ((server (gnus-server-to-method server))
	 (address (nth 1 server)))
    (if (and address
	     (not (zerop (length address))))
	(format "%s using %s" address (car server))
      (format "%s" (car server)))))

(defun gnus-same-method-different-name (method)
  (let ((slot (intern (concat (symbol-name (car method)) "-address"))))
    (unless (assq slot (cddr method))
      (setq method
	    (append method (list (list slot (nth 1 method)))))))
  (let ((methods gnus-extended-servers)
	open found)
    (while (and (not found)
		(setq open (pop methods)))
      (when (and (eq (car method) (car open))
		 (gnus-sloppily-equal-method-parameters method open))
	(setq found open)))
    found))

(defun gnus-find-method-for-group (group &optional info)
  "Find the select method that GROUP uses."
  (or gnus-override-method
      (and (not group)
	   gnus-select-method)
      (and (not (gnus-group-entry group))
	   ;; Killed or otherwise unknown group.
	   (or
	    ;; If we know a virtual server by that name, return its method.
	    (gnus-server-to-method (gnus-group-server group))
	    ;; Guess a new method as last resort.
	    (gnus-group-name-to-method group)))
      (let ((info (or info (gnus-get-info group)))
	    method)
	(if (or (not info)
		(not (setq method (gnus-info-method info)))
		(equal method "native"))
	    gnus-select-method
	  (setq method
		(cond ((stringp method)
		       (inline (gnus-server-to-method method)))
		      ((stringp (cadr method))
		       (or
			(inline
			 (gnus-same-method-different-name method))
			(inline (gnus-server-extend-method group method))))
		      (t
		       method)))
	  (cond ((equal (cadr method) "")
		 method)
		((null (cadr method))
		 (list (car method) ""))
		(t
		 (gnus-server-add-address method)))))))

(defun gnus-methods-using (feature)
  "Find all methods that have FEATURE."
  (let ((valids gnus-valid-select-methods)
	outs)
    (while valids
      (when (memq feature (car valids))
	(push (car valids) outs))
      (setq valids (cdr valids)))
    outs))

(autoload 'message-y-or-n-p "message" nil nil 'macro)

(defun gnus-read-group (prompt &optional default)
  "Prompt the user for a group name.
Disallow invalid group names."
  (let ((prefix "")
	group)
    (while (not group)
      (when (string-match
	     gnus-invalid-group-regexp
	     (setq group (read-string (concat prefix prompt)
				      (cons (or default "") 0)
				      'gnus-group-history)))
	(let ((match (match-string 0 group)))
	  ;; Might be okay (e.g. for nnimap), so ask the user:
	  (unless (and (not (string-match "^$\\|:" match))
		       (message-y-or-n-p
			"Proceed and create group anyway? " t
"The group name \"" group "\" contains a forbidden character: \"" match "\".

Usually, it's dangerous to create a group with this name, because it's not
supported by all back ends and servers.  On IMAP servers it should work,
though.  If you are really sure, you can proceed anyway and create the group.

You may customize the variable `gnus-invalid-group-regexp', which currently is
set to \"" gnus-invalid-group-regexp
"\", if you want to get rid of this query permanently."))
	    (setq prefix (format "Invalid group name: \"%s\".  " group)
		  group nil)))))
    group))

(defun gnus-read-method (prompt)
  "Prompt the user for a method.
Allow completion over sensible values."
  (let* ((open-servers
	  (mapcar (lambda (i) (cons (format "%s:%s" (caar i) (cadar i)) i))
		  gnus-opened-servers))
	 (valid-methods
	  (let (methods)
	    (dolist (method gnus-valid-select-methods)
	      (if (or (memq 'prompt-address method)
		      (not (assoc (format "%s:" (car method)) open-servers)))
		  (push method methods)))
	    methods))
	 (servers
	  (append valid-methods
		  open-servers
		  gnus-predefined-server-alist
		  gnus-server-alist))
	 (method
	  (gnus-completing-read
	   prompt (mapcar #'car servers)
	   t nil 'gnus-method-history)))
    (cond
     ((equal method "")
      (setq method gnus-select-method))
     ((assoc method gnus-valid-select-methods)
      (let ((address (if (memq 'prompt-address
			       (assoc method gnus-valid-select-methods))
			 (read-string "Address: ")
		       "")))
	(or (cadr (assoc (format "%s:%s" method address) open-servers))
	    (list (intern method) address))))
     ((assoc method servers)
      method)
     (t
      (list (intern method) "")))))

;;; Agent functions

(defun gnus-agent-method-p (method-or-server)
  "Say whether METHOD is covered by the agent."
  (or (eq (car gnus-agent-method-p-cache) method-or-server)
      (let* ((method (if (stringp method-or-server)
			 (gnus-server-to-method method-or-server)
		       method-or-server))
	     (server (gnus-method-to-server method t)))
	(setq gnus-agent-method-p-cache
	      (cons method-or-server
		    (member server gnus-agent-covered-methods)))))
  (cdr gnus-agent-method-p-cache))

(defun gnus-online (method)
  (not
   (if gnus-plugged
       (eq (cadr (assoc method gnus-opened-servers)) 'offline)
     (gnus-agent-method-p method))))

;;; User-level commands.

;;;###autoload
(defun gnus-child-no-server (&optional arg)
  "Read network news as a child, without connecting to the local server."
  (interactive "P")
  (gnus-no-server arg t))

;;;###autoload
(defun gnus-slave-no-server (&optional arg)
  "Read network news as a child, without connecting to the local server."
  (interactive "P")
  (gnus-no-server arg t))
(make-obsolete 'gnus-slave-no-server 'gnus-child-no-server "28.1")

;;;###autoload
(defun gnus-no-server (&optional arg child)
  "Read network news.
If ARG is a positive number, Gnus will use that as the startup level.
If ARG is nil, Gnus will be started at level 2.  If ARG is non-nil
and not a positive number, Gnus will prompt the user for the name of
an NNTP server to use.
As opposed to `gnus', this command will not connect to the local
server."
  (interactive "P")
  (gnus-no-server-1 arg child))

;;;###autoload
(defun gnus-child (&optional arg)
  "Read news as a child."
  (interactive "P")
  (gnus arg nil 'child))

;;;###autoload
(defun gnus-slave (&optional arg)
  "Read news as a child."
  (interactive "P")
  (gnus arg nil 'child))
(make-obsolete 'gnus-slave 'gnus-child "28.1")

(defun gnus-delete-gnus-frame ()
  "Delete gnus frame unless it is the only one.
Used for `gnus-exit-gnus-hook' in `gnus-other-frame'."
  (when (and (frame-live-p gnus-other-frame-object)
             (cdr (frame-list)))
    (delete-frame gnus-other-frame-object))
  (setq gnus-other-frame-object nil))

;;;###autoload
(defun gnus-other-frame (&optional arg display)
  "Pop up a frame to read news.
This will call one of the Gnus commands which is specified by the user
option `gnus-other-frame-function' (default `gnus') with the argument
ARG if Gnus is not running, otherwise pop up a Gnus frame and run the
command specified by `gnus-other-frame-resume-function'.
The optional second argument DISPLAY should be a standard display string
such as \"unix:0\" to specify where to pop up a frame.  If DISPLAY is
omitted or the function `make-frame-on-display' is not available, the
current display is used."
  (interactive "P")
  (if (fboundp 'make-frame-on-display)
      (unless display
	(setq display (gnus-frame-or-window-display-name (selected-frame))))
    (setq display nil))
  (let ((alive (gnus-alive-p)))
    (unless (and alive
		 (catch 'found
		   (walk-windows
		    (lambda (window)
		      (when (and (or (not display)
				     (equal display
					    (gnus-frame-or-window-display-name
					     window)))
				 (with-current-buffer (window-buffer window)
				   (string-match "\\`gnus-"
						 (symbol-name major-mode))))
			(select-frame-set-input-focus
			 (setq gnus-other-frame-object (window-frame window)))
			(select-window window)
			(throw 'found t)))
		    'ignore t)))
      (select-frame-set-input-focus
       (setq gnus-other-frame-object
	     (if display
		 (make-frame-on-display display gnus-other-frame-parameters)
	       (make-frame gnus-other-frame-parameters))))
      (if alive
	  (progn (switch-to-buffer gnus-group-buffer)
		 (funcall gnus-other-frame-resume-function arg))
	(funcall gnus-other-frame-function arg)
	(add-hook 'gnus-exit-gnus-hook #'gnus-delete-gnus-frame)
  ;; One might argue that `gnus-delete-gnus-frame' should not be called
  ;; from `gnus-suspend-gnus-hook', but, on the other hand, one might
  ;; argue that it should.  No matter what you think, for the sake of
  ;; those who want it to be called from it, please keep (defun
  ;; gnus-delete-gnus-frame) even if you remove the next `add-hook'.
  (add-hook 'gnus-suspend-gnus-hook #'gnus-delete-gnus-frame)))))

;;;###autoload
(defun gnus (&optional arg dont-connect child)
  "Read network news.
If ARG is non-nil and a positive number, Gnus will use that as the
startup level.  If ARG is non-nil and not a positive number, Gnus will
prompt the user for the name of an NNTP server to use."
  (interactive "P")
  ;; When using the development version of Gnus, load the gnus-load
  ;; file.
  (unless (string-match "^Gnus" gnus-version)
    (load "gnus-load" nil t))
  (unless (compiled-function-p (symbol-function 'gnus))
    (message "You should compile Gnus")
    (sit-for 2))
  (let ((gnus-action-message-log (list nil)))
    (gnus-1 arg dont-connect child)
    (gnus-final-warning)))

(declare-function debbugs-gnu "ext:debbugs-gnu"
		  (severities &optional packages archivedp suppress tags))

(defun gnus-list-debbugs ()
  "List all open Gnus bug reports."
  (interactive)
  (require 'debbugs-gnu)
  (debbugs-gnu nil "gnus"))

(provide 'gnus)

;;; gnus.el ends here
