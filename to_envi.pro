PRO TO_ENVI, image, _EXTRA = ex
  IF IS_ENVI_RUNNING() EQ 0 THEN envi
  
  ENVI_ENTER_DATA, image, _EXTRA = ex
END