;;; characters.el --- set syntax and category for multibyte characters  -*- lexical-binding: t; -*-

;; Copyright (C) 1997, 2000-2025 Free Software Foundation, Inc.
;; Copyright (C) 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004,
;;   2005, 2006, 2007, 2008, 2009, 2010, 2011
;;   National Institute of Advanced Industrial Science and Technology (AIST)
;;   Registration Number H14PRO021
;; Copyright (C) 2003
;;   National Institute of Advanced Industrial Science and Technology (AIST)
;;   Registration Number H13PRO009

;; Keywords: multibyte character, character set, syntax, category

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

;;; Predefined categories.

;; For each character set.

(define-category ?a "ASCII
ASCII graphic characters 32-126 (ISO646 IRV:1983[4/0])")
(define-category ?l "Latin")
(define-category ?t "Thai")
(define-category ?g "Greek")
(define-category ?b "Arabic")
(define-category ?w "Hebrew")
(define-category ?y "Cyrillic")
(define-category ?k "Katakana
Japanese katakana")
(define-category ?r "Roman
Japanese roman")
(define-category ?c "Chinese")
(define-category ?j "Japanese")
(define-category ?h "Korean")
(define-category ?e "Ethiopic
Ethiopic (Ge'ez)")
(define-category ?v "Viet
Vietnamese")
(define-category ?i "Indian")
(define-category ?o "Lao")
(define-category ?q "Tibetan")

;; For each group (row) of 2-byte character sets.

(define-category ?A "2-byte alnum
Alphanumeric characters of 2-byte character sets")
(define-category ?C "2-byte han
Chinese (Han) characters of 2-byte character sets")
(define-category ?G "2-byte Greek
Greek characters of 2-byte character sets")
(define-category ?H "2-byte Hiragana
Japanese Hiragana characters of 2-byte character sets")
(define-category ?K "2-byte Katakana
Japanese Katakana characters of 2-byte character sets")
(define-category ?N "2-byte Korean
Korean Hangul characters of 2-byte character sets")
(define-category ?Y "2-byte Cyrillic
Cyrillic characters of 2-byte character sets")
(define-category ?I "Indian Glyphs")

;; For phonetic classifications.

(define-category ?0 "consonant")
(define-category ?1 "base vowel
Base (independent) vowel")
(define-category ?2 "upper diacritic
Upper diacritical mark (including upper vowel)")
(define-category ?3 "lower diacritic
Lower diacritical mark (including lower vowel)")
(define-category ?4 "combining tone
Combining tone mark")
(define-category ?5 "symbol")
(define-category ?6 "digit")
(define-category ?7 "vowel diacritic
Vowel-modifying diacritical mark")
(define-category ?8 "vowel-signs")
(define-category ?9 "semivowel lower")

;; For filling.
(define-category ?| "line breakable
While filling, we can break a line at this character.")

;; For indentation calculation.
(define-category ?\s
  "space for indent
This character counts as a space for indentation purposes.")

;; Keep the following for `kinsoku' processing.  See comments in
;; kinsoku.el.
(define-category ?> "Not at bol
A character which can't be placed at beginning of line.")
(define-category ?< "Not at eol
A character which can't be placed at end of line.")

;; Base and Combining
(define-category ?. "Base
Base characters (Unicode General Category L,N,P,S,Zs)")
(define-category ?^ "Combining
Combining diacritic or mark (Unicode General Category M)")

;; bidi types
(define-category ?R "Strong R2L
Characters with \"strong\" right-to-left directionality, i.e.
with R, AL, RLE, or RLO Unicode bidi character type.")

(define-category ?L "Strong L2R
Characters with \"strong\" left-to-right directionality, i.e.
with L, LRE, or LRO Unicode bidi character type.")


;;; Setting syntax and category.

;; ASCII

;; All ASCII characters have the category `a' (ASCII) and `l' (Latin).
(modify-category-entry '(32 . 127) ?a)
(modify-category-entry '(32 . 127) ?l)

;; Deal with the CJK charsets first.  Since the syntax of blocks is
;; defined per charset, and the charsets may contain e.g. Latin
;; characters, we end up with the wrong syntax definitions if we're
;; not careful.

;; Chinese characters (Unicode)
(modify-category-entry '(#x2E80 . #x312F) ?|)
(modify-category-entry '(#x3190 . #x33FF) ?|)
(modify-category-entry '(#x3400 . #x4DBF) ?C)
(modify-category-entry '(#x4E00 . #x9FFF) ?C)
(modify-category-entry '(#x3400 . #x9FFF) ?c)
(modify-category-entry '(#x3400 . #x9FFF) ?|)
(modify-category-entry '(#xF900 . #xFAFF) ?C)
(modify-category-entry '(#xF900 . #xFAFF) ?c)
(modify-category-entry '(#xF900 . #xFAFF) ?|)
(modify-category-entry '(#x1B170 . #x1B2FF) ?c)
(modify-category-entry '(#x20000 . #x2FFFF) ?|)
(modify-category-entry '(#x20000 . #x2FFFF) ?C)
(modify-category-entry '(#x20000 . #x2FFFF) ?c)
(modify-category-entry '(#x30000 . #x323AF) ?|)
(modify-category-entry '(#x30000 . #x323AF) ?C)
(modify-category-entry '(#x30000 . #x323AF) ?c)


;; Chinese character set (GB2312)

(map-charset-chars #'modify-syntax-entry 'chinese-gb2312 "_" #x2121 #x217E)
(map-charset-chars #'modify-syntax-entry 'chinese-gb2312 "_" #x2221 #x227E)
(map-charset-chars #'modify-syntax-entry 'chinese-gb2312 "_" #x2921 #x297E)

(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?c)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?A #x2330 #x2339)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?A #x2341 #x235A)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?A #x2361 #x237A)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?H #x2421 #x247E)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?K #x2521 #x257E)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?G #x2621 #x267E)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?Y #x2721 #x277E)
(map-charset-chars #'modify-category-entry 'chinese-gb2312 ?C #x3021 #x7E7E)

;; Chinese character set (BIG5)

(map-charset-chars #'modify-category-entry 'big5 ?c)
(map-charset-chars #'modify-category-entry 'big5 ?C #xA259 #xA261)
(map-charset-chars #'modify-category-entry 'big5 ?C #xA440 #xC67E)
(map-charset-chars #'modify-category-entry 'big5 ?C #xC940 #xF9DC)

;; Chinese character set (CNS11643)

(dolist (c '(chinese-cns11643-1 chinese-cns11643-2 chinese-cns11643-3
	     chinese-cns11643-4 chinese-cns11643-5 chinese-cns11643-6
	     chinese-cns11643-7 chinese-cns11643-15))
  (map-charset-chars #'modify-category-entry c ?c)
  (if (eq c 'chinese-cns11643-1)
      (map-charset-chars #'modify-category-entry c ?C #x4421 #x7E7E)
    (map-charset-chars #'modify-category-entry c ?C)))

;; Japanese character set (JISX0201, JISX0208, JISX0212, JISX0213)

(map-charset-chars #'modify-category-entry 'katakana-jisx0201 ?k)

(map-charset-chars #'modify-category-entry 'latin-jisx0201 ?r)

(dolist (l '(katakana-jisx0201 japanese-jisx0208 japanese-jisx0212
			       japanese-jisx0213-1 japanese-jisx0213-2
                               japanese-jisx0213.2004-1
			       cp932-2-byte))
  (map-charset-chars #'modify-category-entry l ?j))

;; Fullwidth characters
(modify-category-entry '(#xff01 . #xff60) ?\|)

;; Unicode equivalents of JISX0201-kana
(let ((range '(#xff61 . #xff9f)))
  (modify-category-entry range  ?k)
  (modify-category-entry range ?j)
  (modify-category-entry range ?\|))

;; Katakana block
(modify-category-entry '(#x3099 . #x309C) ?K)
(modify-category-entry '(#x30A0 . #x30FF) ?K)
(modify-category-entry '(#x31F0 . #x31FF) ?K)
(modify-category-entry '(#x30A0 . #x30FA) ?\|)
(modify-category-entry #x30FF ?\|)
(modify-category-entry '(#x1AFF0 . #x1B000) ?K)
(modify-category-entry '(#x1B120 . #x1B122) ?K)
(modify-category-entry '(#x1B164 . #x1B167) ?K)

;; Hiragana block
(modify-category-entry '(#x3040 . #x309F) ?H)
(modify-category-entry '(#x3040 . #x3096) ?\|)
(modify-category-entry #x309F ?\|)
(modify-category-entry #x30A0 ?H)
(modify-category-entry #x30FC ?H)
(modify-category-entry #x1B001 ?H)
(modify-category-entry #x1B11F ?H)
(modify-category-entry '(#x1B150 . #x1B152) ?H)
(modify-category-entry '(#x1B002 . #x1B11E) ?H) ; Hentaigana

(modify-category-entry '(#x1AFF0 . #x1B1FF) ?j)


;; JISX0208
;; Note: Some of these have their syntax updated later below.
(map-charset-chars #'modify-syntax-entry 'japanese-jisx0208 "_" #x2121 #x227E)
(map-charset-chars #'modify-syntax-entry 'japanese-jisx0208 "_" #x2821 #x287E)
(let ((chars '(?ー ?゛ ?゜ ?ヽ ?ヾ ?ゝ ?ゞ ?〃 ?仝 ?々 ?〆 ?〇)))
  (dolist (elt chars)
    (modify-syntax-entry elt "w")))

(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?A #x2321 #x237E)
(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?H #x2421 #x247E)
(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?K #x2521 #x257E)
(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?G #x2621 #x267E)
(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?Y #x2721 #x277E)
(map-charset-chars #'modify-category-entry 'japanese-jisx0208 ?C #x3021 #x7E7E)
(let ((chars '(?仝 ?々 ?〆 ?〇)))
  (while chars
    (modify-category-entry (car chars) ?C)
    (setq chars (cdr chars))))

;; JISX0212

(map-charset-chars #'modify-syntax-entry 'japanese-jisx0212 "_" #x2121 #x237E)

;; JISX0201-Kana

(let ((chars '(?｡ ?､ ?･)))
  (while chars
    (modify-syntax-entry (car chars) ".")
    (setq chars (cdr chars))))

(modify-syntax-entry ?\｢ "(｣")
(modify-syntax-entry ?\｣ "(｢")

;; Korean character set (KSC5601)

(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?h)

(map-charset-chars #'modify-syntax-entry 'korean-ksc5601 "_" #x2121 #x227E)
(map-charset-chars #'modify-syntax-entry 'korean-ksc5601 "_" #x2621 #x277E)
(map-charset-chars #'modify-syntax-entry 'korean-ksc5601 "_" #x2830 #x287E)
(map-charset-chars #'modify-syntax-entry 'korean-ksc5601 "_" #x2930 #x2975)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?A #x2330 #x2339)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?A #x2341 #x235A)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?A #x2361 #x237A)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?G #x2521 #x257E)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?H #x2A21 #x2A7E)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?K #x2B21 #x2B7E)
(map-charset-chars #'modify-category-entry 'korean-ksc5601 ?Y #x2C21 #x2C7E)

;; These are in more than one charset.
(let ((parens (concat "〈〉《》「」『』【】〔〕〖〗〘〙〚〛"
		      "︵︶︷︸︹︺︻︼︽︾︿﹀﹁﹂﹃﹄"
		      "（）［］｛｝"))
      open close)
  (dotimes (i (/ (length parens) 2))
    (setq open (aref parens (* i 2))
	  close (aref parens (1+ (* i 2))))
    (modify-syntax-entry open (format "(%c" close))
    (modify-syntax-entry close (format ")%c" open))))

;; Arabic character set

(let ((charsets '(arabic-iso8859-6
		  arabic-digit
		  arabic-1-column
		  arabic-2-column)))
  (while charsets
    (map-charset-chars #'modify-category-entry (car charsets) ?b)
    (setq charsets (cdr charsets))))
(modify-category-entry '(#x600 . #x6ff) ?b)
(modify-category-entry '(#x870 . #x8ff) ?b)
(modify-category-entry '(#xfb50 . #xfdcf) ?b)
(modify-category-entry '(#xfdf0 . #xfdff) ?b)
(modify-category-entry '(#xfe70 . #xfefe) ?b)
(modify-category-entry '(#x10ec0 . #x10eff) ?b)

;; Cyrillic character set (ISO-8859-5)

(modify-syntax-entry ?№ ".")

;; Ethiopic character set

(modify-category-entry '(#x1200 . #x1399) ?e)
(modify-category-entry '(#X2D80 . #X2DDE) ?e)
(modify-category-entry '(#xAB01 . #xAB2E) ?e)
(modify-category-entry '(#x1E7E0 . #x1E7FE) ?e)
(let ((chars '(?፡ ?። ?፣ ?፤ ?፥ ?፦ ?፧ ?፨)))
  (while chars
    (modify-syntax-entry (car chars) ".")
    (setq chars (cdr chars))))
(map-charset-chars #'modify-category-entry 'ethiopic ?e)

;; Hebrew character set (ISO-8859-8)

(modify-syntax-entry #x5be ".") ; MAQAF
(modify-syntax-entry #x5c0 ".") ; PASEQ
(modify-syntax-entry #x5c3 ".") ; SOF PASUQ
(modify-syntax-entry #x5c6 ".") ; NUN HAFUKHA
(modify-syntax-entry #x5f3 ".") ; GERESH
(modify-syntax-entry #x5f4 ".") ; GERSHAYIM

;; Indian character set (IS 13194 and other Emacs original Indian charsets)

(modify-category-entry '(#x901 . #x970) ?i)
(map-charset-chars #'modify-category-entry 'indian-is13194 ?i)
(map-charset-chars #'modify-category-entry 'indian-2-column ?i)

;; Lao character set

(modify-category-entry '(#xe80 . #xeff) ?o)
(map-charset-chars #'modify-category-entry 'lao ?o)

(let ((deflist	'(("ກ-ຮ"	"w"	?0) ; consonant
		  ("ະາຳຽເ-ໄ"	"w"	?1) ; vowel base
		  ("ັິ-ືົໍ"	"w"	?2) ; vowel upper
		  ("ຸູ"	"w"	?3) ; vowel lower
		  ("່-໋"	"w"	?4) ; tone mark
		  ("ຼຽ"	"w"	?9) ; semivowel lower
		  ("໐-໙"	"w"	?6) ; digit
		  ("ຯໆ"	"_"	?5) ; symbol
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(unless (string-equal syntax "w")
	  (modify-syntax-entry ch syntax))
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Thai character set (TIS620)

(modify-category-entry '(#xe00 . #xe7f) ?t)
(map-charset-chars #'modify-category-entry 'thai-tis620 ?t)

(let ((deflist	'(;; chars	syntax	category
		  ("ก-รลว-ฮ"	"w"	?0) ; consonant
		  ("ฤฦะาำเ-ๅ"	"w"	?1) ; vowel base
		  ("ัิ-ื็๎"	"w"	?2) ; vowel upper
		  ("ุ-ฺ"	"w"	?3) ; vowel lower
		  ("่-ํ"	"w"	?4) ; tone mark
		  ("๐-๙"	"w"	?6) ; digit
		  ("ฯๆ฿๏๚๛"	"_"	?5) ; symbol
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(unless (string-equal syntax "w")
	  (modify-syntax-entry ch syntax))
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Tibetan character set

(modify-category-entry '(#xf00 . #xfff) ?q)
(map-charset-chars #'modify-category-entry 'tibetan ?q)
(map-charset-chars #'modify-category-entry 'tibetan-1-column ?q)

(let ((deflist	'(;; chars             syntax category
		  ("ཀ-ཀྵཪ"        	"w"	?0) ; consonant
		  ("ྐ-ྐྵྺྻྼ"       "w"     ?0) ;
		  ("ིེཻོཽྀ"       "w"	?2) ; upper vowel
		  ("ཾྂྃ྆྇ྈྉྊྋ" "w"	?2) ; upper modifier
		  ("྄ཱུ༙༵༷"       "w"	?3) ; lower vowel/modifier
		  ("཰"		"w" ?3)		    ; invisible vowel a
		  ("༠-༩༪-༳"	        "w"	?6) ; digit
		  ("་།-༒༔ཿ"        "."     ?|) ; line-break char
		  ("་།༏༐༑༔ཿ"            "."     ?|) ;
		  ("༈་།-༒༔ཿ༽༴"  "."     ?>) ; prohibition
		  ("་།༏༐༑༔ཿ"            "."     ?>) ;
		  ("ༀ-༊༼࿁࿂྅"      "."     ?<) ; prohibition
		  ("༓༕-༘༚-༟༶༸-༻༾༿྾྿-࿏" "." ?q) ; others
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(unless (string-equal syntax "w")
	  (modify-syntax-entry ch syntax))
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Vietnamese character set

;; To make a word with Latin characters
(map-charset-chars #'modify-category-entry 'vietnamese-viscii-lower ?l)
(map-charset-chars #'modify-category-entry 'vietnamese-viscii-lower ?v)

(map-charset-chars #'modify-category-entry 'vietnamese-viscii-upper ?l)
(map-charset-chars #'modify-category-entry 'vietnamese-viscii-upper ?v)

(let ((tbl (standard-case-table))
      (i 32))
  (while (< i 128)
    (let* ((char (decode-char 'vietnamese-viscii-upper i))
	   (charl (decode-char 'vietnamese-viscii-lower i))
	   (uc (encode-char char 'ucs))
	   (lc (encode-char charl 'ucs)))
      (set-case-syntax-pair char (decode-char 'vietnamese-viscii-lower i)
			    tbl)
      (if uc (modify-category-entry uc ?v))
      (if lc (modify-category-entry lc ?v)))
    (setq i (1+ i))))

;; Tai Viet
(let ((deflist '(;; chars	syntax	category
		 ((?ꪀ.  ?ꪯ)	"w"	?0) ; consonant
		 ("ꪱꪵꪶ"		"w"	?1) ; vowel base
		 ((?ꪹ . ?ꪽ)	"w"	?1) ; vowel base
		 ("ꪰꪲꪳꪷꪸꪾ"	"w"	?2) ; vowel upper
		 ("ꪴ"		"w"	?3) ; vowel lower
		 ("ꫀꫂ"		"w"	?1) ; non-combining tone-mark
		 ("꪿꫁"		"w"	?4) ; combining tone-mark
		 ((?ꫛ . ?꫟)	"_"	?5) ; symbol
		 )))
  (dolist (elm deflist)
    (let ((chars (car elm))
	  (syntax (nth 1 elm))
	  (category (nth 2 elm)))
      (if (consp chars)
	  (progn
	    (modify-syntax-entry chars syntax)
	    (modify-category-entry chars category))
        (mapc (lambda (x)
                (modify-syntax-entry x syntax)
                (modify-category-entry x category))
	      chars)))))

;; Bidi categories

;; If bootstrapping without generated uni-*.el files, table not defined.
(let ((table (unicode-property-table-internal 'bidi-class)))
  (when table
    (map-char-table (lambda (key val)
		      (cond
		       ((memq val '(R AL RLO RLE))
			(modify-category-entry key ?R))
		       ((memq val '(L LRE LRO))
			(modify-category-entry key ?L))))
		    table)))

;; Load uni-mirrored.el and uni-brackets.el if available, so that they
;; get dumped into Emacs.  This allows starting Emacs with
;; force-load-messages in ~/.emacs, and avoid infinite recursion in
;; bidi_initialize, which needs to load uni-mirrored.el and
;; uni-brackets.el in order to display the "Loading" messages.
(unicode-property-table-internal 'mirroring)
(unicode-property-table-internal 'bracket-type)

;; Latin

(modify-category-entry '(#x80 . #x024F) ?l)

(let ((tbl (standard-case-table)) c)

  ;; Latin-1

  ;; Fixme: Some of the non-word syntaxes here perhaps should be
  ;; reviewed.  (Note that the following all implicitly have word
  ;; syntax: ¢£¤¥¨ª¯²³´¶¸¹º.)  There should be a well-defined way of
  ;; relating Unicode categories to Emacs syntax codes.

  ;; FIXME: We should probably just use the Unicode properties to set
  ;; up the syntax table.

  (set-case-syntax ?¡ "." tbl)
  (set-case-syntax ?¦ "_" tbl)
  (set-case-syntax ?§ "." tbl)
  (set-case-syntax ?© "_" tbl)
  ;; French wants
  ;;   (set-case-syntax-delims ?« ?» tbl)
  ;; And German wants
  ;;   (set-case-syntax-delims ?» ?« tbl)
  ;; So let's stay neutral and let users set these up if/when they want to.
  (set-case-syntax ?« "." tbl)
  (set-case-syntax ?» "." tbl)
  (set-case-syntax ?¬ "_" tbl)
  (set-case-syntax ?­ "_" tbl)
  (set-case-syntax ?® "_" tbl)
  (set-case-syntax ?° "_" tbl)
  (set-case-syntax ?± "_" tbl)
  (set-case-syntax ?µ "_" tbl)
  (set-case-syntax ?· "_" tbl)
  (set-case-syntax ?¼ "_" tbl)
  (set-case-syntax ?½ "_" tbl)
  (set-case-syntax ?¾ "_" tbl)
  (set-case-syntax ?¿ "." tbl)
  (set-case-syntax ?× "_" tbl)
  (set-case-syntax ?ß "w" tbl)
  (set-case-syntax ?÷ "_" tbl)
  ;; See below for ÿ.

  ;; Latin Extended-A, Latin Extended-B
  (setq c #x0100)
  (while (<= c #x02B8)
    (modify-category-entry c ?l)
    (setq c (1+ c)))

  ;; Latin Extended Additional
  (modify-category-entry '(#x1E00 . #x1EF9) ?l)

  ;; Latin Extended-C
  (setq c #x2C60)
  (while (<= c #x2C7F)
    (modify-category-entry c ?l)
    (setq c (1+ c)))

  ;; Latin Extended-D
  (setq c #xA720)
  (while (<= c #xA7FF)
    (modify-category-entry c ?l)
    (setq c (1+ c)))

  ;; Latin Extended-E
  (setq c #xAB30)
  (while (<= c #xAB64)
    (modify-category-entry c ?l)
    (setq c (1+ c)))

  ;; Latin Extended-G
  (setq c #x1DF00)
  (while (<= c #x1DFFF)
    (modify-category-entry c ?l)
    (setq c (1+ c)))

  ;; Greek
  (modify-category-entry '(#x0370 . #x03FF) ?g)

  ;; Armenian
  (setq c #x531)

  ;; Greek Extended
  (modify-category-entry '(#x1F00 . #x1FFF) ?g)

  ;; cyrillic
  (modify-category-entry '(#x0400 . #x04FF) ?y)
  (modify-category-entry '(#xA640 . #xA69F) ?y)

  ;; Georgian
  (setq c #x10A0)

  ;; Cyrillic Extended-C
  (modify-category-entry '(#x1C80 . #x1C8F) ?y)

  ;; Cyrillic Extended-D
  (modify-category-entry '(#x1E030 . #x1E08F) ?y)

  ;; space characters (see section 6.2 in the Unicode Standard)
  (set-case-syntax ?  " " tbl)
  (setq c #x2000)
  (while (<= c #x200b)
    (set-case-syntax c " " tbl)
    (setq c (1+ c)))
  (let ((chars '(#x202F #x205F #x3000)))
    (while chars
      (set-case-syntax (car chars) " " tbl)
      (setq chars (cdr chars))))
  ;; general punctuation
  (while (<= c #x200F)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (setq c #x2010)
  ;; Fixme: What to do with characters that have Pi and Pf
  ;; Unicode properties?
  (while (<= c #x2017)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  ;; Punctuation syntax for quotation marks (like `)
  (while (<= c #x201F)
    (set-case-syntax  c "." tbl)
    (setq c (1+ c)))
  (while (<= c #x2027)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (setq c #x2030)
  (while (<= c #x205E)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (let ((chars '(?‹ ?› ?⁄ ?⁒)))
    (while chars
      (modify-syntax-entry (car chars) "_")
      (setq chars (cdr chars))))

  ;; Arrows
  (setq c #x2190)
  (while (<= c #x21FF)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))
  ;; Mathematical Operators
  (while (<= c #x22FF)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))
  ;; Miscellaneous Technical
  (while (<= c #x23FF)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))
  ;; Control Pictures
  (while (<= c #x244F)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))

  ;; Circled Latin
  (setq c #x24B6)
  (while (<= c #x24CF)
    (modify-category-entry c ?l)
    (modify-category-entry (+ c 26) ?l)
    (setq c (1+ c)))

  ;; Supplemental Mathematical Operators
  (setq c #x2A00)
  (while (<= c #x2AFF)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))

  ;; Miscellaneous Symbols and Arrows
  (setq c #x2B00)
  (while (<= c #x2BFF)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))

  ;; Traditional Mongolian
  (setq c #x1800)
  (while (<= c #x180A)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (setq c #x11660)
  (while (<= c #x1166C)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))

  ;; Coptic
  ;; There's no Coptic category.  However, Coptic letters that are
  ;; part of the Greek block above get the Greek category, and those
  ;; in this block are derived from Greek letters, so let's be
  ;; consistent about their category.
  (modify-category-entry '(#x2C80 . #x2CFF) ?g)

  ;; Supplemental Punctuation
  (setq c #x2E00)
  (while (<= c #x2E7F)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))

  ;; Ideographic punctuation
  (setq c #x3001)
  (while (<= c #x3003)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (set-case-syntax #x30FB "." tbl)

  ;; Symbols for Legacy Computing
  (setq c #x1FB00)
  (while (<= c #x1FBCA)
    (set-case-syntax c "_" tbl)
    (setq c (1+ c)))
  ;; FIXME: Should these be digits?
  (while (<= c #x1FBFF)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))

  ;; Fullwidth Latin
  (setq c #xFF01)
  (while (<= c #xFF0F)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (set-case-syntax #xFF04 "_" tbl)
  (set-case-syntax #xFF0B "_" tbl)
  (set-case-syntax #xFF1A "." tbl)
  (set-case-syntax #xFF1B "." tbl)
  (set-case-syntax #xFF1F "." tbl)
  (set-case-syntax #xFF20 "." tbl)
  (setq c #xFF21)
  (while (<= c #xFF3A)
    (modify-category-entry c ?l)
    (modify-category-entry (+ c #x20) ?l)
    (setq c (1+ c)))

  ;; Halfwidth Latin
  (setq c #xFF64)
  (while (<= c #xFF65)
    (set-case-syntax c "." tbl)
    (setq c (1+ c)))
  (set-case-syntax #xFF61 "." tbl)

  ;; Combining diacritics
  (modify-category-entry '(#x300 . #x362) ?^)
  ;; Combining marks
  (modify-category-entry '(#x20d0 . #x20ff) ?^)

  (let ((gc (unicode-property-table-internal 'general-category))
        (syn-table (standard-syntax-table)))
    ;; In early bootstrapping Unicode tables are not available so we need to
    ;; skip this step in those cases.
    (when gc
      ;; Set all Letter, uppercase; Letter, lowercase and Letter,
      ;; titlecase syntax to word.
      (map-char-table
       (lambda (ch cat)
         (when (memq cat '(Lu Ll Lt))
           (modify-syntax-entry ch "w   " syn-table)))
       gc)
      ;; Ⅰ through Ⅻ had word syntax in the past so set it here as well.
      ;; The general category of those characters is Number, Letter.
      (modify-syntax-entry '(#x2160 . #x216b) "w   " syn-table)

      ;; ⓐ through ⓩ are symbols, other according to Unicode but Emacs set
      ;; their syntax to word in the past so keep backwards compatibility.
      (modify-syntax-entry '(#x24D0 . #x24E9) "w   " syn-table)

      ;; Set downcase and upcase from Unicode properties

      ;; In some languages, such as Turkish, U+0049 LATIN CAPITAL LETTER I and
      ;; U+0131 LATIN SMALL LETTER DOTLESS I make a case pair, and so do U+0130
      ;; LATIN CAPITAL LETTER I WITH DOT ABOVE and U+0069 LATIN SMALL LETTER I.

      ;; We used to set up half of those correspondence unconditionally, but
      ;; that makes searches slow.  So now we don't set up either half of these
      ;; correspondences by default.

      ;; (set-downcase-syntax  ?İ ?i tbl)
      ;; (set-upcase-syntax    ?I ?ı tbl)

      (let ((map-unicode-property
             (lambda (property func)
               (map-char-table
                (lambda (ch cased)
                  ;; ASCII characters skipped due to reasons outlined above.  As
                  ;; of Unicode 9.0, this exception affects the following:
                  ;;   lc(U+0130 İ) = i
                  ;;   uc(U+0131 ı) = I
                  ;;   uc(U+017F ſ) = S
                  ;;   uc(U+212A K) = k
                  (when (> cased 127)
                    (let ((end (if (consp ch) (cdr ch) ch)))
                      (setq ch (max 128 (if (consp ch) (car ch) ch)))
                      (while (<= ch end)
                        (funcall func ch cased)
                        (setq ch (1+ ch))))))
                (unicode-property-table-internal property))))
            (down tbl)
            (up (case-table-get-table tbl 'up)))

        ;; This works on an assumption that if toUpper(x) != x then toLower(x)
        ;; == x (and the opposite for toLower/toUpper).  This doesn’t hold for
        ;; title case characters but those incorrect mappings will be
        ;; overwritten later.
        (funcall map-unicode-property 'uppercase
                 (lambda (lc uc) (aset down lc lc) (aset up uc uc)))
        (funcall map-unicode-property 'lowercase
                 (lambda (uc lc) (aset down lc lc) (aset up uc uc)))

        ;; Now deal with the actual mapping.  This will correctly assign casing
        ;; for title-case characters.
        (funcall map-unicode-property 'uppercase
                 (lambda (lc uc) (aset up lc uc) (aset up uc uc)))
        (funcall map-unicode-property 'lowercase
                 (lambda (uc lc) (aset down uc lc) (aset down lc lc)))

        ;; Override the Unicode uppercase property for ß, since we are
        ;; using our case tables for determining the case of a
        ;; character (see uppercasep and lowercasep in buffer.h).
        ;; The special-uppercase property of ß ensures that it is
        ;; still upcased to SS per the usual convention.
        (aset up ?ß ?ẞ))))

  ;; Clear out the extra slots so that they will be recomputed from the main
  ;; (downcase) table and upcase table.  Since we’re side-stepping the usual
  ;; set-case-syntax-* functions, we need to do it explicitly.
  (set-char-table-extra-slot tbl 1 nil)
  (set-char-table-extra-slot tbl 2 nil)

  ;; Fixme: syntax for symbols &c
  )


;; Symbols and digits
;;; Each character whose script is 'symbol' gets the symbol category,
;;; see charscript.el.
;;; Each character whose Unicode general-category is Nd gets the digit
;;; category:
(let ((table (unicode-property-table-internal 'general-category)))
  (when table
    (map-char-table (lambda (key val)
                      (if (eq val 'Nd)
			  (modify-category-entry key ?6)))
		    table)))

(let ((pairs
       '("⁅⁆"				; U+2045 U+2046
	 "⁽⁾"				; U+207D U+207E
	 "₍₎"				; U+208D U+208E
	 "〈〉"				; U+2329 U+232A
	 "⎴⎵"				; U+23B4 U+23B5
	 "❨❩"				; U+2768 U+2769
	 "❪❫"				; U+276A U+276B
	 "❬❭"				; U+276C U+276D
	 "❰❱"				; U+2770 U+2771
	 "❲❳"				; U+2772 U+2773
	 "❴❵"				; U+2774 U+2775
	 "⟦⟧"				; U+27E6 U+27E7
	 "⟨⟩"				; U+27E8 U+27E9
	 "⟪⟫"				; U+27EA U+27EB
	 "⦃⦄"				; U+2983 U+2984
	 "⦅⦆"				; U+2985 U+2986
	 "⦇⦈"				; U+2987 U+2988
	 "⦉⦊"				; U+2989 U+298A
	 "⦋⦌"				; U+298B U+298C
	 "⦍⦎"				; U+298D U+298E
	 "⦏⦐"				; U+298F U+2990
	 "⦑⦒"				; U+2991 U+2992
	 "⦓⦔"				; U+2993 U+2994
	 "⦕⦖"				; U+2995 U+2996
	 "⦗⦘"				; U+2997 U+2998
	 "⧼⧽"				; U+29FC U+29FD
	 "〈〉"				; U+3008 U+3009
	 "《》"				; U+300A U+300B
	 "「」"				; U+300C U+300D
	 "『』"				; U+300E U+300F
	 "【】"				; U+3010 U+3011
	 "〔〕"				; U+3014 U+3015
	 "〖〗"				; U+3016 U+3017
	 "〘〙"				; U+3018 U+3019
	 "〚〛"				; U+301A U+301B
	 "﴾﴿"				; U+FD3E U+FD3F
	 "︵︶"				; U+FE35 U+FE36
	 "︷︸"				; U+FE37 U+FE38
	 "︹︺"				; U+FE39 U+FE3A
	 "︻︼"				; U+FE3B U+FE3C
	 "︽︾"				; U+FE3D U+FE3E
	 "︿﹀"				; U+FE3F U+FE40
	 "﹁﹂"				; U+FE41 U+FE42
	 "﹃﹄"				; U+FE43 U+FE44
	 "﹙﹚"				; U+FE59 U+FE5A
	 "﹛﹜"				; U+FE5B U+FE5C
	 "﹝﹞"				; U+FE5D U+FE5E
	 "（）"				; U+FF08 U+FF09
	 "［］"				; U+FF3B U+FF3D
	 "｛｝"				; U+FF5B U+FF5D
	 "｟｠"				; U+FF5F U+FF60
	 "｢｣"				; U+FF62 U+FF63
	 )))
  (dolist (elt pairs)
    (modify-syntax-entry (aref elt 0) (string ?\( (aref elt 1)))
    (modify-syntax-entry (aref elt 1) (string ?\) (aref elt 0)))))


;; For each character set, put the information of the most proper
;; coding system to encode it by `preferred-coding-system' property.

;; Fixme: should this be junked?
(let ((l '((latin-iso8859-1	. iso-latin-1)
	   (latin-iso8859-2	. iso-latin-2)
	   (latin-iso8859-3	. iso-latin-3)
	   (latin-iso8859-4	. iso-latin-4)
	   (thai-tis620		. thai-tis620)
	   (greek-iso8859-7	. greek-iso-8bit)
	   (arabic-iso8859-6	. iso-2022-7bit)
	   (hebrew-iso8859-8	. hebrew-iso-8bit)
	   (katakana-jisx0201	. japanese-shift-jis)
	   (latin-jisx0201	. japanese-shift-jis)
	   (cyrillic-iso8859-5	. cyrillic-iso-8bit)
	   (latin-iso8859-9	. iso-latin-5)
	   (japanese-jisx0208-1978 . iso-2022-jp)
	   (chinese-gb2312	. chinese-iso-8bit)
	   (chinese-gbk		. chinese-gbk)
	   (gb18030-2-byte	. chinese-gb18030)
	   (gb18030-4-byte-bmp	. chinese-gb18030)
	   (gb18030-4-byte-smp	. chinese-gb18030)
	   (gb18030-4-byte-ext-1 . chinese-gb18030)
	   (gb18030-4-byte-ext-2 . chinese-gb18030)
	   (japanese-jisx0208	. iso-2022-jp)
	   (korean-ksc5601	. iso-2022-kr)
	   (japanese-jisx0212	. iso-2022-jp)
	   (chinese-big5-1	. chinese-big5)
	   (chinese-big5-2	. chinese-big5)
	   (chinese-sisheng	. iso-2022-7bit)
	   (ipa			. iso-2022-7bit)
	   (vietnamese-viscii-lower . vietnamese-viscii)
	   (vietnamese-viscii-upper . vietnamese-viscii)
	   (arabic-digit	. iso-2022-7bit)
	   (arabic-1-column	. iso-2022-7bit)
	   (lao			. lao)
	   (arabic-2-column	. iso-2022-7bit)
	   (indian-is13194	. devanagari)
	   (indian-glyph	. devanagari)
	   (tibetan-1-column	. tibetan)
	   (ethiopic		. iso-2022-7bit)
	   (chinese-cns11643-1	. iso-2022-cn)
	   (chinese-cns11643-2	. iso-2022-cn)
	   (chinese-cns11643-3	. iso-2022-cn)
	   (chinese-cns11643-4	. iso-2022-cn)
	   (chinese-cns11643-5	. iso-2022-cn)
	   (chinese-cns11643-6	. iso-2022-cn)
	   (chinese-cns11643-7	. iso-2022-cn)
	   (indian-2-column	. devanagari)
	   (tibetan		. tibetan)
	   (latin-iso8859-14	. iso-latin-8)
	   (latin-iso8859-15	. iso-latin-9))))
  (while l
    (put-charset-property (car (car l)) 'preferred-coding-system (cdr (car l)))
    (setq l (cdr l))))


;; Setup auto-fill-chars for charsets that should invoke auto-filling.
;; SPACE and NEWLINE are already set.

(set-char-table-range auto-fill-chars '(#x3041 . #x30FF) t)
(set-char-table-range auto-fill-chars '(#x3400 . #x4DB5) t)
(set-char-table-range auto-fill-chars '(#x4e00 . #x9fbb) t)
(set-char-table-range auto-fill-chars '(#xF900 . #xFAFF) t)
(set-char-table-range auto-fill-chars '(#xFF00 . #xFF9F) t)
(set-char-table-range auto-fill-chars '(#x20000 . #x2FFFF) t)


;;; Setting char-width-table.  The default is 1.

;; 0: non-spacing, enclosing combining, formatting, Hangul Jamo medial
;;    and final characters.
(let ((l '((#x0300 . #x036F)
	   (#x0483 . #x0489)
	   (#x0591 . #x05BD)
	   (#x05BF . #x05BF)
	   (#x05C1 . #x05C2)
	   (#x05C4 . #x05C5)
	   (#x05C7 . #x05C7)
	   (#x0600 . #x0605)
	   (#x0610 . #x061C)
	   (#x064B . #x065F)
	   (#x0670 . #x0670)
	   (#x06D6 . #x06E4)
	   (#x06E7 . #x06E8)
	   (#x06EA . #x06ED)
	   (#x070F . #x070F)
	   (#x0711 . #x0711)
	   (#x0730 . #x074A)
	   (#x07A6 . #x07B0)
	   (#x07EB . #x07F3)
	   (#x0816 . #x0823)
	   (#x0825 . #x082D)
	   (#x0859 . #x085B)
	   (#x08D4 . #x0902)
	   (#x093A . #x093A)
	   (#x093C . #x093C)
	   (#x0941 . #x0948)
	   (#x094D . #x094D)
	   (#x0951 . #x0957)
	   (#x0962 . #x0963)
	   (#x0981 . #x0981)
	   (#x09BC . #x09BC)
	   (#x09C1 . #x09C4)
	   (#x09CD . #x09CD)
	   (#x09E2 . #x09E3)
	   (#x0A01 . #x0A02)
	   (#x0A3C . #x0A3C)
	   (#x0A41 . #x0A4D)
	   (#x0A41 . #x0A42)
	   (#x0A47 . #x0A48)
	   (#x0A4B . #x0A4D)
	   (#x0A51 . #x0A51)
	   (#x0A70 . #x0A71)
	   (#x0A75 . #x0A75)
	   (#x0A81 . #x0A82)
	   (#x0ABC . #x0ABC)
	   (#x0AC1 . #x0AC8)
	   (#x0ACD . #x0ACD)
	   (#x0AE2 . #x0AE3)
	   (#x0B01 . #x0B01)
	   (#x0B3C . #x0B3C)
	   (#x0B3F . #x0B3F)
	   (#x0B41 . #x0B44)
	   (#x0B4D . #x0B56)
	   (#x0B62 . #x0B63)
	   (#x0B82 . #x0B82)
	   (#x0BC0 . #x0BC0)
	   (#x0BCD . #x0BCD)
	   (#x0C00 . #x0C00)
	   (#x0C3E . #x0C40)
	   (#x0C46 . #x0C56)
	   (#x0C62 . #x0C63)
	   (#x0C81 . #x0C81)
	   (#x0CBC . #x0CBC)
	   (#x0CCC . #x0CCD)
	   (#x0CE2 . #x0CE3)
	   (#x0D01 . #x0D01)
	   (#x0D41 . #x0D44)
	   (#x0D4D . #x0D4D)
	   (#x0D62 . #x0D63)
	   (#x0D81 . #x0D81)
	   (#x0DCA . #x0DCA)
	   (#x0DD2 . #x0DD6)
	   (#x0E31 . #x0E31)
	   (#x0E34 . #x0E3A)
	   (#x0E47 . #x0E4E)
	   (#x0EB1 . #x0EB1)
	   (#x0EB4 . #x0EBC)
	   (#x0EC8 . #x0ECD)
	   (#x0F18 . #x0F19)
	   (#x0F35 . #x0F35)
	   (#x0F37 . #x0F37)
	   (#x0F39 . #x0F39)
	   (#x0F71 . #x0F7E)
	   (#x0F80 . #x0F84)
	   (#x0F86 . #x0F87)
	   (#x0F8D . #x0FBC)
	   (#x0FC6 . #x0FC6)
	   (#x102D . #x1030)
	   (#x1032 . #x1037)
	   (#x1039 . #x103A)
	   (#x103D . #x103E)
	   (#x1058 . #x1059)
	   (#x105E . #x1060)
	   (#x1071 . #x1074)
	   (#x1082 . #x1082)
	   (#x1085 . #x1086)
	   (#x108D . #x108D)
	   (#x109D . #x109D)
	   (#x1160 . #x11FF)
	   (#x135D . #x135F)
	   (#x1712 . #x1714)
	   (#x1732 . #x1734)
	   (#x1752 . #x1753)
	   (#x1772 . #x1773)
	   (#x17B4 . #x17B5)
	   (#x17B7 . #x17BD)
	   (#x17C6 . #x17C6)
	   (#x17C9 . #x17D3)
	   (#x17DD . #x17DD)
	   (#x180B . #x180E)
	   (#x18A9 . #x18A9)
	   (#x1885 . #x1886)
	   (#x18A9 . #x18A9)
	   (#x1920 . #x1922)
	   (#x1927 . #x1928)
	   (#x1932 . #x1932)
	   (#x1939 . #x193B)
	   (#x1A17 . #x1A18)
	   (#x1A1B . #x1A1B)
	   (#x1A56 . #x1A56)
	   (#x1A58 . #x1A5E)
	   (#x1A60 . #x1A60)
	   (#x1A62 . #x1A62)
	   (#x1A65 . #x1A6C)
	   (#x1A73 . #x1A7C)
	   (#x1A7F . #x1A7F)
	   (#x1AB0 . #x1AC0)
	   (#x1B00 . #x1B03)
	   (#x1B34 . #x1B34)
	   (#x1B36 . #x1B3A)
	   (#x1B3C . #x1B3C)
	   (#x1B42 . #x1B42)
	   (#x1B6B . #x1B73)
	   (#x1B80 . #x1B81)
	   (#x1BA2 . #x1BA5)
	   (#x1BA8 . #x1BA9)
	   (#x1BAB . #x1BAD)
	   (#x1BE6 . #x1BE6)
	   (#x1BE8 . #x1BE9)
	   (#x1BED . #x1BED)
	   (#x1BEF . #x1BF1)
	   (#x1C2C . #x1C33)
	   (#x1C36 . #x1C37)
	   (#x1CD0 . #x1CD2)
	   (#x1CD4 . #x1CE0)
	   (#x1CE2 . #x1CE8)
	   (#x1CED . #x1CED)
	   (#x1CF4 . #x1CF4)
	   (#x1CF8 . #x1CF9)
	   (#x1DC0 . #x1DFF)
	   (#x200B . #x200F)
	   (#x202A . #x202E)
	   (#x2060 . #x206F)
	   (#x20D0 . #x20F0)
	   (#x2CEF . #x2CF1)
	   (#x2D7F . #x2D7F)
	   (#x2DE0 . #x2DFF)
	   (#xA66F . #xA672)
	   (#xA674 . #xA69F)
	   (#xA6F0 . #xA6F1)
	   (#xA802 . #xA802)
	   (#xA806 . #xA806)
	   (#xA80B . #xA80B)
	   (#xA825 . #xA826)
	   (#xA82C . #xA82C)
	   (#xA8C4 . #xA8C5)
	   (#xA8E0 . #xA8F1)
	   (#xA926 . #xA92D)
	   (#xA947 . #xA951)
	   (#xA980 . #xA9B3)
	   (#xA9B6 . #xA9B9)
	   (#xA9BC . #xA9BC)
	   (#xA9E5 . #xA9E5)
	   (#xAA29 . #xAA2E)
	   (#xAA31 . #xAA32)
	   (#xAA35 . #xAA36)
	   (#xAA43 . #xAA43)
	   (#xAA4C . #xAA4C)
	   (#xAA7C . #xAA7C)
	   (#xAAB0 . #xAAB0)
	   (#xAAB2 . #xAAB4)
	   (#xAAB7 . #xAAB8)
	   (#xAABE . #xAABF)
	   (#xAAC1 . #xAAC1)
	   (#xAAEC . #xAAED)
	   (#xAAF6 . #xAAF6)
	   (#xABE5 . #xABE5)
	   (#xABE8 . #xABE8)
	   (#xABED . #xABED)
	   (#xD7B0 . #xD7FB)
	   (#xFB1E . #xFB1E)
	   (#xFE00 . #xFE0F)
	   (#xFE20 . #xFE2F)
	   (#xFEFF . #xFEFF)
	   (#xFFF9 . #xFFFB)
	   (#x101FD . #x101FD)
	   (#x102E0 . #x102E0)
	   (#x10376 . #x1037A)
	   (#x10A01 . #x10A0F)
	   (#x10A38 . #x10A3F)
	   (#x10AE5 . #x10AE6)
           (#x10D69 . #x10D6D)
	   (#x10EAB . #x10EAC)
           (#x10EFC . #x10EFF)
	   (#x11001 . #x11001)
	   (#x11038 . #x11046)
	   (#x1107F . #x11081)
	   (#x110B3 . #x110B6)
	   (#x110B9 . #x110BA)
	   (#x110BD . #x110BD)
	   (#x11100 . #x11102)
	   (#x11127 . #x1112B)
	   (#x1112D . #x11134)
	   (#x11173 . #x11173)
	   (#x11180 . #x11181)
	   (#x111B6 . #x111BE)
	   (#x111CA . #x111CC)
	   (#x111CF . #x111CF)
	   (#x1122F . #x11231)
	   (#x11234 . #x11234)
	   (#x11236 . #x11237)
	   (#x1123E . #x1123E)
	   (#x112DF . #x112DF)
	   (#x112E3 . #x112EA)
	   (#x11300 . #x11301)
	   (#x1133C . #x1133C)
	   (#x11340 . #x11340)
	   (#x11366 . #x1136C)
	   (#x11370 . #x11374)
           (#x113BB . #x113C0)
           (#x113CE . #x113CE)
           (#x113D0 . #x113D0)
           (#x113D2 . #x113D2)
           (#x113E1 . #x113E2)
	   (#x11438 . #x1143F)
	   (#x11442 . #x11444)
	   (#x11446 . #x11446)
	   (#x114B3 . #x114B8)
	   (#x114BA . #x114C0)
	   (#x114C2 . #x114C3)
	   (#x115B2 . #x115B5)
	   (#x115BC . #x115BD)
	   (#x115BF . #x115C0)
	   (#x115DC . #x115DD)
	   (#x11633 . #x1163A)
	   (#x1163D . #x1163D)
	   (#x1163F . #x11640)
	   (#x116AB . #x116AB)
	   (#x116AD . #x116AD)
	   (#x116B0 . #x116B5)
	   (#x116B7 . #x116B7)
	   (#x1171D . #x1171F)
	   (#x11722 . #x11725)
	   (#x11727 . #x1172B)
	   (#x1193B . #x1193C)
	   (#x1193E . #x1193E)
	   (#x11943 . #x11943)
	   (#x11C30 . #x11C36)
	   (#x11C38 . #x11C3D)
	   (#x11C92 . #x11CA7)
	   (#x11CAA . #x11CB0)
	   (#x11CB2 . #x11CB3)
	   (#x11CB5 . #x11CB6)
           (#x11F5A . #x11F5A)
           (#x13430 . #x13440)
           (#x13447 . #x13455)
           (#x1611E . #x16129)
           (#x1612D . #x1612F)
	   (#x16AF0 . #x16AF4)
	   (#x16B30 . #x16B36)
	   (#x16F8F . #x16F92)
	   (#x16FE4 . #x16FE4)
	   (#x1BC9D . #x1BC9E)
	   (#x1BCA0 . #x1BCA3)
           (#x1CF00 . #x1CF02)
	   (#x1D167 . #x1D169)
	   (#x1D173 . #x1D182)
	   (#x1D185 . #x1D18B)
	   (#x1D1AA . #x1D1AD)
	   (#x1D242 . #x1D244)
	   (#x1DA00 . #x1DA36)
	   (#x1DA3B . #x1DA6C)
	   (#x1DA75 . #x1DA75)
	   (#x1DA84 . #x1DA84)
	   (#x1DA9B . #x1DA9F)
	   (#x1DAA1 . #x1DAAF)
	   (#x1E000 . #x1E006)
	   (#x1E008 . #x1E018)
	   (#x1E01B . #x1E021)
	   (#x1E023 . #x1E024)
	   (#x1E026 . #x1E02A)
           (#x1E5EE . #x1E5EF)
	   (#x1E8D0 . #x1E8D6)
	   (#x1E944 . #x1E94A)
	   (#xE0001 . #xE01EF))))
  (dolist (elt l)
    (set-char-table-range char-width-table elt 0)))

;; 2: East Asian Wide and Full-width characters.
(let ((l '((#x1100 . #x115F)
	   (#x231A . #x231B)
	   (#x2329 . #x232A)
	   (#x23E9 . #x23EC)
	   (#x23F0 . #x23F0)
	   (#x23F3 . #x23F3)
	   (#x25FD . #x25FE)
	   (#x2614 . #x2615)
           (#x2630 . #x2637)
	   (#x2648 . #x2653)
	   (#x267F . #x267F)
           (#x268A . #x268F)
	   (#x2693 . #x2693)
	   (#x26A1 . #x26A1)
	   (#x26AA . #x26AB)
	   (#x26BD . #x26BE)
	   (#x26C4 . #x26C5)
	   (#x26CE . #x26CE)
	   (#x26D4 . #x26D4)
	   (#x26EA . #x26EA)
	   (#x26F2 . #x26F3)
	   (#x26F5 . #x26F5)
	   (#x26FA . #x26FA)
	   (#x26FD . #x26FD)
	   (#x2705 . #x2705)
	   (#x270A . #x270B)
	   (#x2728 . #x2728)
	   (#x274C . #x274C)
	   (#x274E . #x274E)
	   (#x2753 . #x2755)
	   (#x2757 . #x2757)
	   (#x2795 . #x2797)
	   (#x27B0 . #x27B0)
	   (#x27BF . #x27BF)
	   (#x2B1B . #x2B1C)
	   (#x2B50 . #x2B50)
	   (#x2B55 . #x2B55)
	   (#x2E80 . #x2E99)
           (#x2E9B . #x2EF3)
           (#x2F00 . #x2FD5)
           (#x2FF0 . #x2FFF)
           (#x3000 . #x303E)
	   (#x3041 . #x3096)
           (#x3099 . #x30FF)
           (#x3105 . #x312F)
           (#x3131 . #x31E5)
           (#x31EF . #x31EF)
           (#x31F0 . #x3247)
	   (#x3250 . #x4DBF)
	   (#x4E00 . #xA48C)
	   (#xA490 . #xA4C6)
	   (#xA960 . #xA97C)
	   (#xAC00 . #xD7A3)
	   (#xF900 . #xFAFF)
	   (#xFE10 . #xFE19)
	   (#xFE30 . #xFE6B)
	   (#xFF01 . #xFF60)
	   (#xFFE0 . #xFFE6)
	   (#x16FE0 . #x16FE4)
	   (#x16FF0 . #x16FF1)
	   (#x17000 . #x187F7)
	   (#x18800 . #x18AFF)
	   (#x18B00 . #x18CD5)
           (#x18CFF . #x18CFF)
           (#x18D00 . #x18D08)
	   (#x1AFF0 . #x1AFF3)
           (#x1AFF5 . #x1AFFB)
           (#x1AFFD . #x1AFFE)
	   (#x1B000 . #x1B122)
           (#x1B132 . #x1B132)
           (#x1B150 . #x1B152)
           (#x1B155 . #x1B155)
	   (#x1B164 . #x1B167)
	   (#x1B170 . #x1B2FB)
           (#x1D300 . #x1D356)
           (#x1D360 . #x1D376)
	   (#x1F004 . #x1F004)
	   (#x1F0CF . #x1F0CF)
	   (#x1F18E . #x1F18E)
	   (#x1F191 . #x1F19A)
	   (#x1F1AD . #x1F1AD)
	   (#x1F200 . #x1F202)
           (#x1F210 . #x1F23B)
           (#x1F240 . #x1F248)
           (#x1F250 . #x1F251)
           (#x1F260 . #x1F265)
           (#x1F300 . #x1F320)
	   (#x1F32D . #x1F335)
	   (#x1F337 . #x1F37C)
	   (#x1F37E . #x1F393)
	   (#x1F3A0 . #x1F3CA)
	   (#x1F3CF . #x1F3D3)
	   (#x1F3E0 . #x1F3F0)
	   (#x1F3F4 . #x1F3F4)
	   (#x1F3F8 . #x1F3FA)
	   (#x1F3FB . #x1F3FF)
	   (#x1F400 . #x1F43E)
	   (#x1F440 . #x1F440)
	   (#x1F442 . #x1F4FC)
	   (#x1F4FF . #x1F53D)
	   (#x1F54B . #x1F54E)
	   (#x1F550 . #x1F567)
	   (#x1F57A . #x1F57A)
	   (#x1F595 . #x1F596)
	   (#x1F5A4 . #x1F5A4)
	   (#x1F5FB . #x1F5FF)
	   (#x1F600 . #x1F64F)
	   (#x1F680 . #x1F6C5)
	   (#x1F6CC . #x1F6CC)
	   (#x1F6D0 . #x1F6D2)
	   (#x1F6D5 . #x1F6D7)
	   (#x1F6DC . #x1F6DF)
	   (#x1F6EB . #x1F6EC)
	   (#x1F6F4 . #x1F6FC)
	   (#x1F7E0 . #x1F7EB)
           (#x1F7F0 . #x1F7F0)
	   (#x1F90C . #x1F93A)
	   (#x1F93C . #x1F945)
	   (#x1F947 . #x1F9FF)
	   (#x1FA00 . #x1FA53)
	   (#x1FA60 . #x1FA6D)
	   (#x1FA70 . #x1FA74)
	   (#x1FA78 . #x1FA7C)
	   (#x1FA80 . #x1FA89)
	   (#x1FA8F . #x1FAC6)
	   (#x1FACE . #x1FADC)
	   (#x1FADF . #x1FAE9)
	   (#x1FAF0 . #x1FAF8)
	   (#x1FB00 . #x1FB92)
	   (#x20000 . #x2FFFF)
	   (#x30000 . #x3FFFF))))
  (dolist (elt l)
    (set-char-table-range char-width-table elt 2)))

;; A: East Asian "Ambiguous" characters.
(let ((l '((#x00A1 . #x00A1)
	   ; (#x00A4 . #x00A4) whitespace-mode uses this
	   (#x00A7 . #x00A8)
	   (#x00AA . #x00AA)
	   (#x00AD . #x00AE)
	   (#x00B0 . #x00B4)
	   ; (#x00B6 . #x00BA)  whitespace-mode uses U+00B7
           (#x00B6 . #x00B6)
           (#x00B8 . #x00BA)
	   (#x00BC . #x00BF)
	   (#x00C6 . #x00C6)
	   (#x00D0 . #x00D0)
	   (#x00D7 . #x00D8)
	   (#x00E0 . #x00E1)
	   (#x00E6 . #x00E6)
	   (#x00E8 . #x00EA)
	   (#x00EC . #x00ED)
	   (#x00F0 . #x00F0)
	   (#x00F2 . #x00F3)
	   (#x00F7 . #x00FA)
	   (#x00FC . #x00FC)
	   (#x00FE . #x00FE)
	   (#x0101 . #x0101)
	   (#x0111 . #x0111)
	   (#x0113 . #x0113)
	   (#x011B . #x011B)
	   (#x0126 . #x0127)
	   (#x012B . #x012B)
	   (#x0131 . #x0133)
	   (#x0138 . #x0138)
	   (#x013F . #x0142)
	   (#x0144 . #x0144)
	   (#x0148 . #x014B)
	   (#x014D . #x014D)
	   (#x0152 . #x0153)
	   (#x0166 . #x0167)
	   (#x016B . #x016B)
	   (#x01CE . #x01CE)
	   (#x01D0 . #x01D0)
	   (#x01D2 . #x01D2)
	   (#x01D4 . #x01D4)
	   (#x01D6 . #x01D6)
	   (#x01D8 . #x01D8)
	   (#x01DA . #x01DA)
	   (#x01DC . #x01DC)
	   (#x0251 . #x0251)
	   (#x0261 . #x0261)
	   (#x02C4 . #x02C4)
	   (#x02C7 . #x02C7)
	   (#x02C9 . #x02CB)
	   (#x02CD . #x02CD)
	   (#x02D0 . #x02D0)
	   (#x02D8 . #x02DB)
	   (#x02DD . #x02DD)
	   (#x02DF . #x02DF)
	   (#x0300 . #x036F)
	   (#x0391 . #x03A1)
	   (#x03A3 . #x03A9)
	   (#x03B1 . #x03C1)
	   (#x03C3 . #x03C9)
	   (#x0401 . #x0401)
	   (#x0410 . #x044F)
	   (#x0451 . #x0451)
	   (#x2010 . #x2010)
	   (#x2013 . #x2016)
	   (#x2018 . #x2019)
	   (#x201C . #x201D)
	   (#x2020 . #x2022)
	   (#x2024 . #x2027)
	   (#x2030 . #x2030)
	   (#x2032 . #x2033)
	   (#x2035 . #x2035)
	   (#x203E . #x203E)
	   (#x2074 . #x2074)
	   (#x207F . #x207F)
	   (#x2081 . #x2084)
	   (#x20AC . #x20AC)
	   (#x2103 . #x2103)
	   (#x2105 . #x2105)
	   (#x2109 . #x2109)
	   (#x2113 . #x2113)
	   (#x2116 . #x2116)
	   (#x2121 . #x2122)
	   (#x2126 . #x2126)
	   (#x212B . #x212B)
	   (#x2153 . #x2154)
	   (#x215B . #x215E)
	   (#x2160 . #x216B)
	   (#x2170 . #x2179)
	   (#x2189 . #x2189)
	   (#x2190 . #x2199)
	   (#x21B8 . #x21B9)
	   (#x21D2 . #x21D2)
	   (#x21D4 . #x21D4)
	   (#x21E7 . #x21E7)
	   (#x2200 . #x2200)
	   (#x2202 . #x2203)
	   (#x2207 . #x2208)
	   (#x220B . #x220B)
	   (#x220F . #x220F)
	   (#x2211 . #x2211)
	   (#x2215 . #x2215)
	   (#x221A . #x221A)
	   (#x221D . #x2220)
	   (#x2223 . #x2223)
	   (#x2225 . #x2225)
	   (#x2227 . #x222C)
	   (#x222E . #x222E)
	   (#x2234 . #x2237)
	   (#x223C . #x223D)
	   (#x2248 . #x2248)
	   (#x224C . #x224C)
	   (#x2252 . #x2252)
	   (#x2260 . #x2261)
	   (#x2264 . #x2267)
	   (#x226A . #x226B)
	   (#x226E . #x226F)
	   (#x2282 . #x2283)
	   (#x2286 . #x2287)
	   (#x2295 . #x2295)
	   (#x2299 . #x2299)
	   (#x22A5 . #x22A5)
	   (#x22BF . #x22BF)
	   (#x2312 . #x2312)
	   (#x2460 . #x24E9)
	   (#x24EB . #x254B)
	   (#x2550 . #x2573)
	   (#x2580 . #x258F)
	   (#x2592 . #x2595)
	   (#x25A0 . #x25A1)
	   (#x25A3 . #x25A9)
	   (#x25B2 . #x25B3)
	   (#x25B6 . #x25B7)
	   (#x25BC . #x25BD)
	   (#x25C0 . #x25C1)
	   (#x25C6 . #x25C8)
	   (#x25CE . #x25D1)
	   (#x25E2 . #x25E5)
	   (#x25EF . #x25EF)
	   (#x2605 . #x2606)
	   (#x260E . #x260F)
	   (#x261C . #x261C)
	   (#x261E . #x261E)
	   (#x2640 . #x2640)
	   (#x2642 . #x2642)
	   (#x2660 . #x2661)
	   (#x2663 . #x2665)
	   (#x2667 . #x266A)
	   (#x266C . #x266D)
	   (#x266F . #x266F)
	   (#x269E . #x269F)
	   (#x26BF . #x26BF)
	   (#x26C6 . #x26CD)
	   (#x26CF . #x26D3)
	   (#x26D5 . #x26E1)
	   (#x26E3 . #x26E3)
	   (#x26E8 . #x26E9)
	   (#x26EB . #x26F1)
	   (#x26F4 . #x26F4)
	   (#x26F6 . #x26F9)
	   (#x26FB . #x26FC)
	   (#x26FE . #x26FF)
	   (#x273D . #x273D)
	   (#x2776 . #x277F)
	   (#x2B56 . #x2B59)
	   (#x3248 . #x324F))))
  (dolist (elt l)
    (set-char-table-range ambiguous-width-chars elt t)))

;; Other double width
;;(map-charset-chars
;; (lambda (range ignore) (set-char-table-range char-width-table range 2))
;; 'ethiopic)
;; (map-charset-chars
;;  (lambda (range ignore) (set-char-table-range char-width-table range 2))
;; 'tibetan)
(map-charset-chars
 (lambda (range _ignore) (set-char-table-range char-width-table range 2))
 'indian-2-column)
(map-charset-chars
 (lambda (range _ignore) (set-char-table-range char-width-table range 2))
 'arabic-2-column)


;;; Setting printable-chars.  The default is nil for control characters,
;;; otherwise t.
;;; The table is initialized in character.c with a crude approximation,
;;; which considers any non-ASCII character above U+009F to be printable.
;;; Note: this should be consistent with [:print:] character class,
;;; see character.c:printablep.
(let ((table (unicode-property-table-internal 'general-category)))
    (when table
      (map-char-table (lambda (key val)
                        ;; Cs: Surrogates
                        ;; Cn: Unassigned
                        (when (memq val '(Cs Cn))
                          (set-char-table-range printable-chars key nil)))
                      table)))

;; Internal use only.
;; Alist of locale symbol vs charsets.  In a language environment
;; corresponding to the locale, width of characters in the charsets is
;; set to 2.  Each element has the form:
;;   (LOCALE TABLE (CHARSET (FROM-CODE . TO-CODE) ...) ...)
;; LOCALE: locale symbol
;; TABLE: char-table used for char-width-table, initially nil.
;; CHARSET: character set
;; FROM-CODE, TO-CODE: range of code-points in CHARSET

(defvar cjk-char-width-table-list
  '((ja_JP nil (japanese-jisx0208 (#x2121 . #x287E))
	       (cp932-2-byte (#x8140 . #x879F)))
    (zh_CN nil (chinese-gb2312 (#x2121 . #x297E)))
    (zh_HK nil (big5-hkscs (#xA140 . #xA3FE) (#xC6A0 . #xC8FE)))
    (zh_TW nil (big5 (#xA140 . #xA3FE))
	       (chinese-cns11643-1 (#x2121 . #x427E)))
    (ko_KR nil (korean-ksc5601 (#x2121 . #x2C7E)))))

(defun update-cjk-ambiguous-char-widths (locale-name)
  "Update character widths for LOCALE-NAME using `ambiguous-width-chars'.
LOCALE-NAME is the symbol of a CJK locale, such as \\='zh_CN."
  (let ((slot (assq locale-name cjk-char-width-table-list)))
    (or slot (error "Unknown locale for CJK language environment: %s"
		    locale-name))
    ;; Force recomputation of child table in 'use-cjk-char-width-table'.
    (setcar (cdr slot) nil)
    (use-cjk-char-width-table locale-name)))


(defcustom cjk-ambiguous-chars-are-wide t
  "Whether the \"ambiguous-width\" characters take 2 columns on display.

Some of the characters are defined by Unicode as being of \"ambiguous\"
width: the actual width, either 1 column or 2 columns, should be
determined at display time, depending on the language context.
If this variable is non-nil, Emacs will consider these characters as
full-width, i.e. taking 2 columns; otherwise they are narrow characters
taking 1 column on display.  Which value is correct depends on the
fonts being used.  In some CJK locales the fonts are set so that
these characters are displayed as full-width.  This setting is most
important for text-mode frames, because there Emacs cannot access the
metrics of the fonts used by the console or the terminal emulator.
You should configure the terminal emulator to behave consistently
with the value of this option, by making sure it dispays ambiguous-width
characters as half-width or full-width, depending on the value of this
option.

Do not set this directly via `setq'; instead, use `setopt' or the
Customize commands.  Alternatively, call `update-cjk-ambiguous-char-widths'
passing it the symbol of the current locale environment, after changing
the value of the variable with `setq'."
  :type 'boolean
  :set (lambda (symbol value)
         (set-default symbol value)
         (let ((locsym (get-language-info current-language-environment
                                          'cjk-locale-symbol)))
           (when locsym
             (update-cjk-ambiguous-char-widths locsym))))
  :version "30.1"
  :group 'display)

;; Internal use only.
;; Setup char-width-table appropriate for a language environment
;; corresponding to LOCALE-NAME (symbol).

(defun use-cjk-char-width-table (locale-name)
  (while (char-table-parent char-width-table)
    (setq char-width-table (char-table-parent char-width-table)))
  (let ((slot (assq locale-name cjk-char-width-table-list)))
    (or slot (error "Unknown locale for CJK language environment: %s"
		    locale-name))
    (unless (nth 1 slot)
      (let ((table (make-char-table nil)))
	(dolist (charset-info (nthcdr 2 slot))
	  (let ((charset (car charset-info)))
	    (dolist (code-range (cdr charset-info))
              (map-charset-chars (lambda (range _arg)
                                   (set-char-table-range table range 2))
				 charset nil
				 (car code-range) (cdr code-range)))))
	(optimize-char-table table)
	(set-char-table-parent table char-width-table)
        (let ((tbl (make-char-table nil)))
          (map-char-table
           (lambda (range _val)
             (set-char-table-range tbl range
                                   (if cjk-ambiguous-chars-are-wide 2 1)))
           ambiguous-width-chars)
          (optimize-char-table tbl)
          (set-char-table-parent tbl table)
	  (setcar (cdr slot) tbl))))
    (setq char-width-table (nth 1 slot))))

(defun use-default-char-width-table ()
  "Internal use only.
Setup `char-width-table' appropriate for non-CJK language environment."
  (while (char-table-parent char-width-table)
    (setq char-width-table (char-table-parent char-width-table))))

(optimize-char-table (standard-case-table))
(optimize-char-table (standard-syntax-table))


;; Setting char-script-table.
(if dump-mode
    ;; While dumping, we can't use require, and international is not
    ;; in load-path.
    (progn
      (load "international/charscript")
      (load "international/emoji-zwj"))
  (progn
    (require 'charscript)
    (require 'emoji-zwj)))

(map-charset-chars
 (lambda (range _ignore)
   (set-char-table-range char-script-table range 'tibetan))
 'tibetan)

;; Fix some exceptions that blocks.awk/Blocks.txt couldn't get right.
(set-char-table-range char-script-table '(#x2ea . #x2eb) 'bopomofo)
(set-char-table-range char-script-table #xab65 'greek)
(set-char-table-range char-script-table #x16fe0 'tangut)
(set-char-table-range char-script-table #x16fe1 'nushu)



;;; Setting unicode-category-table.

(when (setq unicode-category-table
	    (unicode-property-table-internal 'general-category))
  (map-char-table (lambda (key val)
                    (if val
                        (cond ((or (and (/= (aref (symbol-name val) 0) ?M)
                                        (/= (aref (symbol-name val) 0) ?C))
                                   (eq val 'Zs))
                               (modify-category-entry key ?.))
                              ((eq val 'Mn)
                               (modify-category-entry key ?^)))))
		  unicode-category-table))

(optimize-char-table (standard-category-table))


;; Display of glyphless characters.

(defvar char-acronym-table
  (make-char-table 'char-acronym-table nil)
  "Char table of acronyms for non-graphic characters.")

(let ((c0-acronyms '("NUL" "SOH" "STX" "ETX" "EOT" "ENQ" "ACK" "BEL"
		     "BS"   nil   nil  "VT"  "FF"  "CR"  "SO"  "SI"
		     "DLE" "DC1" "DC2" "DC3" "DC4" "NAK" "SYN" "ETB"
		     "CAN" "EM"  "SUB" "ESC" "FC"  "GS"  "RS"  "US")))
  (dotimes (i 32)
    (aset char-acronym-table i (car c0-acronyms))
    (setq c0-acronyms (cdr c0-acronyms))))

(let ((c1-acronyms '("PAD" "HOP" "BPH" "NBH" "IND" "NEL" "SSA" "ESA"
		     "HTS" "HTJ" "VTS" "PLD" "PLU" "R1"  "SS2" "SS1"
		     "DCS" "PU1" "PU2" "STS" "CCH" "MW"  "SPA" "EPA"
		     "SOS" "SGCI" "SC1" "CSI" "ST"  "OSC" "PM"  "APC")))
  (dotimes (i 32)
    (aset char-acronym-table (+ #x0080 i) (car c1-acronyms))
    (setq c1-acronyms (cdr c1-acronyms))))

(aset char-acronym-table #x17B4 "KIVAQ")   ; KHMER VOWEL INHERENT AQ
(aset char-acronym-table #x17B5 "KIVAA")   ; KHMER VOWEL INHERENT AA
(aset char-acronym-table #x200B "ZWSP")    ; ZERO WIDTH SPACE
(aset char-acronym-table #x200C "ZWNJ")    ; ZERO WIDTH NON-JOINER
(aset char-acronym-table #x200D "ZWJ")	   ; ZERO WIDTH JOINER
(aset char-acronym-table #x200E "LRM")	   ; LEFT-TO-RIGHT MARK
(aset char-acronym-table #x200F "RLM")	   ; RIGHT-TO-LEFT MARK
(aset char-acronym-table #x202A "LRE")	   ; LEFT-TO-RIGHT EMBEDDING
(aset char-acronym-table #x202B "RLE")	   ; RIGHT-TO-LEFT EMBEDDING
(aset char-acronym-table #x202C "PDF")	   ; POP DIRECTIONAL FORMATTING
(aset char-acronym-table #x202D "LRO")	   ; LEFT-TO-RIGHT OVERRIDE
(aset char-acronym-table #x202E "RLO")	   ; RIGHT-TO-LEFT OVERRIDE
(aset char-acronym-table #x2060 "WJ")	   ; WORD JOINER
(aset char-acronym-table #x2066 "LRI")	   ; LEFT-TO-RIGHT ISOLATE
(aset char-acronym-table #x2067 "RLI")	   ; RIGHT-TO-LEFT ISOLATE
(aset char-acronym-table #x2069 "PDI")	   ; POP DIRECTIONAL ISOLATE
(aset char-acronym-table #x206A "ISS")	   ; INHIBIT SYMMETRIC SWAPPING
(aset char-acronym-table #x206B "ASS")	   ; ACTIVATE SYMMETRIC SWAPPING
(aset char-acronym-table #x206C "IAFS")    ; INHIBIT ARABIC FORM SHAPING
(aset char-acronym-table #x206D "AAFS")    ; ACTIVATE ARABIC FORM SHAPING
(aset char-acronym-table #x206E "NADS")    ; NATIONAL DIGIT SHAPES
(aset char-acronym-table #x206F "NODS")    ; NOMINAL DIGIT SHAPES
(aset char-acronym-table #xFEFF "ZWNBSP")  ; ZERO WIDTH NO-BREAK SPACE
(aset char-acronym-table #xFFF9 "IAA")	   ; INTERLINEAR ANNOTATION ANCHOR
(aset char-acronym-table #xFFFA "IAS")     ; INTERLINEAR ANNOTATION SEPARATOR
(aset char-acronym-table #xFFFB "IAT")     ; INTERLINEAR ANNOTATION TERMINATOR
(aset char-acronym-table #x1D173 "BEGBM")  ; MUSICAL SYMBOL BEGIN BEAM
(aset char-acronym-table #x1D174 "ENDBM")  ; MUSICAL SYMBOL END BEAM
(aset char-acronym-table #x1D175 "BEGTIE") ; MUSICAL SYMBOL BEGIN TIE
(aset char-acronym-table #x1D176 "END")	   ; MUSICAL SYMBOL END TIE
(aset char-acronym-table #x1D177 "BEGSLR") ; MUSICAL SYMBOL BEGIN SLUR
(aset char-acronym-table #x1D178 "ENDSLR") ; MUSICAL SYMBOL END SLUR
(aset char-acronym-table #x1D179 "BEGPHR") ; MUSICAL SYMBOL BEGIN PHRASE
(aset char-acronym-table #x1D17A "ENDPHR") ; MUSICAL SYMBOL END PHRASE
(aset char-acronym-table #xE0001 "|->TAG") ; LANGUAGE TAG
(aset char-acronym-table #xE0020 "SP TAG") ; TAG SPACE
(dotimes (i 94)
  (aset char-acronym-table (+ #xE0021 i) (format " %c TAG" (+ 33 i))))
(aset char-acronym-table #xE007F "->|TAG") ; CANCEL TAG

(dotimes (i 256)
  (let* ((vs-number (1+ i))
         (codepoint (if (< i 16)
                        (+ #xfe00 i)
                      (+ #xe0100 i -16)))
         (delimiter (cond ((<= vs-number 9) "0")
                          ((<= vs-number 99) "")
                          (t " "))))
    (aset char-acronym-table codepoint
          (format "VS%s%s" delimiter vs-number))))

;; We can't use the \N{name} things here, because this file is used
;; too early in the build process.
(defvar bidi-control-characters
  '(#x200e                           ; ?\N{left-to-right mark}
    #x200f                           ; ?\N{right-to-left mark}
    #x061c                           ; ?\N{arabic letter mark}
    #x202a			     ; ?\N{left-to-right embedding}
    #x202b			     ; ?\N{right-to-left embedding}
    #x202d			     ; ?\N{left-to-right override}
    #x202e			     ; ?\N{right-to-left override}
    #x2066			     ; ?\N{left-to-right isolate}
    #x2067			     ; ?\N{right-to-left isolate}
    #x2068			     ; ?\N{first strong isolate}
    #x202c			     ; ?\N{pop directional formatting}
    #x2069)                          ; ?\N{pop directional isolate}
  "List of bidirectional control characters.")

(defun bidi-string-strip-control-characters (string)
  "Strip bidi control characters from STRING and return the result."
  (apply #'string (seq-filter (lambda (char)
                                (not (memq char bidi-control-characters)))
                              string)))

(defun update-glyphless-char-display (&optional variable value)
  "Make the setting of `glyphless-char-display-control' take effect.
This function updates the char-table `glyphless-char-display',
and is intended to be used in the `:set' attribute of the
option `glyphless-char-display'."
  (when variable
    (set-default variable value))
  (dolist (elt value)
    (let ((target (car elt))
	  (method (cdr elt)))
      (unless (memq method '( zero-width thin-space empty-box
                              acronym hex-code bidi-control))
	(error "Invalid glyphless character display method: %s" method))
      (cond ((eq target 'c0-control)
	     (glyphless-set-char-table-range glyphless-char-display
					     #x00 #x1F method)
	     ;; Users will not expect their newlines and TABs be
	     ;; displayed as anything but themselves, so exempt those
	     ;; two characters from c0-control.
	     (set-char-table-range glyphless-char-display #x9 nil)
	     (set-char-table-range glyphless-char-display #xa nil))
	    ((eq target 'c1-control)
	     (glyphless-set-char-table-range glyphless-char-display
					     #x80 #x9F method))
	    ((eq target 'variation-selectors)
	     (glyphless-set-char-table-range glyphless-char-display
					     #xFE00 #xFE0F method)
             (glyphless-set-char-table-range glyphless-char-display
					     #xE0100 #xE01EF method))
	    ((or (eq target 'format-control)
                 (eq target 'bidi-control))
	     (when unicode-category-table
	       (map-char-table
                (lambda (char category)
                  (when (eq category 'Cf)
                    (let ((this-method method)
                          from to)
                      (if (consp char)
                          (setq from (car char) to (cdr char))
                        (setq from char to char))
                      (while (<= from to)
                        (when (/= from #xAD)
                          (when (eq method 'acronym)
                            (setq this-method
                                  (or (aref char-acronym-table from)
                                      "UNK")))
                          (when (or (eq target 'format-control)
                                    (memq from bidi-control-characters))
                            (set-char-table-range glyphless-char-display
                                                  from this-method)))
                        (setq from (1+ from))))))
		unicode-category-table)))
	    ((eq target 'no-font)
	     (set-char-table-extra-slot glyphless-char-display 0 method))
	    (t
	     (error "Invalid glyphless character group: %s" target))))))

(defun glyphless-set-char-table-range (chartable from to method)
  (if (eq method 'acronym)
      (let ((i from))
	(while (<= i to)
	  (set-char-table-range chartable i (aref char-acronym-table i))
	  (setq i (1+ i))))
    (set-char-table-range chartable (cons from to) method)))

;;; Control of displaying glyphless characters.
(define-widget 'glyphless-char-display-method 'lazy
  "Display method for glyphless characters."
  :group 'mule
  :format "%v"
  :value 'thin-space
  :type
  '(choice
    (const :tag "Don't display" zero-width)
    (const :tag "Display as thin space" thin-space)
    (const :tag "Display as empty box" empty-box)
    (const :tag "Display acronym" acronym)
    (const :tag "Display hex code in a box" hex-code)))

(defcustom glyphless-char-display-control
  '((format-control . thin-space)
    (variation-selectors . thin-space)
    (no-font . hex-code))
  "List of directives to control display of glyphless characters.

Each element has the form (GROUP . METHOD), where GROUP is a
symbol specifying the character group, and METHOD is a symbol
specifying the method of displaying characters belonging to that
group.

GROUP must be one of these symbols:
  `c0-control':     U+0000..U+001F, but excluding newline and TAB.
  `c1-control':     U+0080..U+009F.
  `format-control': Characters of Unicode General Category `Cf',
                    such as U+200C (ZWNJ), U+200E (LRM), but
                    excluding characters that have graphic images,
                    such as U+00AD (SHY).
  `bidi-control':   A subset of `format-control', but only characters
                    that are relevant for bidirectional formatting control,
                    like U+2069 (PDI) and U+202B (RLE).
  `variation-selectors':
                    Characters in the range U+FE00..U+FE0F and
                    U+E0100..U+E01EF, used for choosing between
                    glyph variations, such as Emoji vs Text
                    presentation, of the preceding character(s).
  `no-font':        For GUI frames, characters for which no
                    suitable font is found; for text-mode frames,
                    characters that cannot be encoded by
                    `terminal-coding-system' or those for which
                    the terminal has no glyphs.

METHOD must be one of these symbols:
  `zero-width': don't display.
  `thin-space': display a thin (1-pixel width) space.  On character
                terminals, display as 1-character space.
  `empty-box':  display an empty box.
  `acronym':    display an acronym of the character in a box.  The
                acronym is taken from `char-acronym-table', which see.
  `hex-code':   display the hexadecimal character code in a box.

Do not set its value directly from Lisp; the value takes effect
only via a custom `:set'
function (`update-glyphless-char-display'), which updates
`glyphless-char-display'.

See also the `glyphless-char' face, which is used to display the
visual representation of these characters."
  :version "28.1"
  :type '(alist :key-type (symbol :tag "Character Group")
		:value-type (symbol :tag "Display Method"))
  :options '((c0-control glyphless-char-display-method)
	     (c1-control glyphless-char-display-method)
	     (format-control glyphless-char-display-method)
	     (bidi-control glyphless-char-display-method)
	     (variation-selectors glyphless-char-display-method)
	     (no-font (glyphless-char-display-method :value hex-code)))
  :set 'update-glyphless-char-display
  :group 'display)


;;; Setting word boundary.

(setq word-combining-categories
      '((nil . ?^)
	(?^ . nil)
	(?C . ?H)
	(?C . ?K)))

(setq word-separating-categories	;  (2-byte character sets)
      '((?H . ?K)			; Hiragana - Katakana
	))

;; Local Variables:
;; coding: utf-8
;; End:

;;; characters.el ends here
