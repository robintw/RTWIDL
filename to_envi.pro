;+
; :Description:
;    Wrapper around ENVI_ENTER_DATA to ensure that (a) ENVI is running
;    before the data is added to ENVI and (b) the array that is added to
;    ENVI is still available as a variable for use in the program afterwards
;    (ie. it is not 'stolen' by ENVI)
;
; :Params:
;    image - the data you want to give to ENVI
;
; :Keywords:
;    _EXTRA - Any other keywords you would normally pass to ENVI_ENTER_DATA
;
; :Author: rtw1v07
;-
PRO TO_ENVI, image, _EXTRA = ex
  IF IS_ENVI_RUNNING() EQ 0 THEN envi
  
  i = image
  ENVI_ENTER_DATA, i, _EXTRA = ex
END