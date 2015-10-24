;+
; :Description:
;    Determines if ENVI is currently running by checking the text of the IDL prompt
;
;    Returns 1 if ENVI is running, 0 if ENVI is not running
;
; :Author: Robin Wilson (robin@rtwilson.com)
;-
FUNCTION IS_ENVI_RUNNING
  IF STRPOS("ENVI", !PROMPT) GE 0 THEN return, 1 ELSE return, 0
END
