PRO READ_OO_DATA_FILE, filename, wavelengths=wavelengths, dns=dns, datetime=datetime
  openr, lun, filename, /GET_LUN
  
  line = ""
  
  ; Initialise arrays
  wavelengths = fltarr(2047) ; 2047 not 2048 because first value is always zero
  dns = fltarr(2047) ; 2047 not 2048 because first value is always zero
  
  junk = ""
  
  ; Read the first two lines of the file
  readf, lun, junk
  readf, lun, junk
  
  date_line = ""
  
  ; Read the next line in - which is in the following format "Date: 06-17-2006, 09:44:35". This is correct for
  ; SpectraSuite files, but not for OOIBase files. If this needs changing then change the format specifier below
  ; (the crazy looking bit in red). Information on all the date format specifiers is available in the IDL help.
  readf, lun, date_line
  ; Just get the actual date bit of it
  datetime_string = strmid(date_line, 6)
  
  j_datetime = double(0.0)
  
  reads, datetime_string, j_datetime, format='(C(CDwA, X, CMoA, X, CDI, X, CHI, X, CMI, X, CSI, 4X, CYI5))'
  
  
  ; Read the 19 comment lines at the beginning of the file
  FOR i=0,14 DO BEGIN
    readf, lun, line
  ENDFOR
  
  i = 0
  
  readf, lun, line
  
  WHILE line NE ">>>>>End Processed Spectral Data<<<<<" DO BEGIN
    
    splitted = STRSPLIT(line, /EXTRACT)
    wavelengths[i] = float(splitted[0])
    dns[i] = float(splitted[1])
    
    readf, lun, line
    i++
  ENDWHILE
  
  datetime = j_datetime
  
  FREE_LUN, lun
END