;+
; :Description:
;    Displays an image in a cgWindow automatically scaling it between the Max and Min values of the image
;
; :Params:
;    image - the image to display
;    _EXTRA - any further parameters to pass to cgImage
;
; :Author: Robin Wilson (robin@rtwilson.com)
;-
PRO cgImScale, image, _EXTRA
  cgImage, image, maxvalue=MAX(image), minvalue=MIN(image), /window, _EXTRA
END
