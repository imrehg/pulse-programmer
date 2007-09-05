;; $Id: print.scm,v 1.3 2006/08/30 11:06:16 ahvezda Exp $
;;
;; This file may be used to print gschem schematics from the
;; command line.  Typical usage is:
;;
;;   gschem -p -o mysch.ps -s /path/to/this/file/print.scm mysch.sch
;;
;; The schematic in "mysch.sch" will be printed to the file "mysch.ps"

(output-orientation "landscape")
(output-type "limits")
(output-color "disabled")
(output-text "ps")

; You need call this after you call any rc file function
(gschem-use-rc-values)

; filename is specified on the command line
(gschem-postscript "dummyfilename")

(gschem-exit)
