FUNCTION STRIP_QUOTES, string
  new_string = STRMID(string, 1)
  new_string = STRMID(new_string, 0, STRLEN(new_string)-1)
  return, new_string
END

;+
; NAME:
; READ_DELTA_T_FILE
;
; PURPOSE:
; This routine reads data from a Delta-T logger output file.
;
; CALLING SEQUENCE:
;
; READ_DELTA_T_FILE, filename, year, header=header, ch_header=ch_header, datetimes=datetimes, data=data
;
; INPUTS:
; filename: The filepath of the file to read
; year: The year in which the data was acquired (as this is not stored in the timestamps)
;
; OUTPUTS:
; header: Structure containing header values
;
; ch_header: Structure containing channel header values
;
; datetimes: Array containing timestamps of the measurements
;
; data: Array containing the measured data itself
; :Author: Robin Wilson (robin@rtwilson.com)
;-
PRO READ_DELTA_T_FILE, filename, year, header=header, ch_header=ch_header, datetimes=datetimes, data=data
  ; Open the file
  openr, lun, filename, /GET_LUN

  device_string = ""
  program_name = ""
  start_date_string = ""
  start_date = double(0)
  end_date_string = ""
  end_date = double(0)
  mode = ""

  readf, lun, device_string
  readf, lun, program_name
  readf, lun, start_date_string
  readf, lun, end_date_string

  start_date_string = STRIP_QUOTES(start_date_string) + year

  reads, start_date_string, start_date, format="(C(CDI2, X, CMOI2, X, CHI2, X, CMI2, X, CSI2, X, CYI4))"

  end_date_string = STRIP_QUOTES(end_date_string) + year

  reads, end_date_string, end_date, format="(C(CDI2, X, CMOI2, X, CHI2, X, CMI2, X, CSI2, X, CYI4))"

  readf, lun, mode

  print, start_date, FORMAT="(C())"
  print, end_date, FORMAT="(C())"

  ; Put the header data into the structure
  header = {device_string:device_string,$
            program_name:program_name,$
            start_date:start_date,$
            end_date:end_date,$
            mode:mode}

  ch_numbers_string = ""
  sensor_codes_string = ""
  labels_string = ""
  units_string = ""
  min_values_string = ""
  max_values_string = ""

  readf, lun, ch_numbers_string
  readf, lun, sensor_codes_string
  readf, lun, labels_string
  readf, lun, units_string
  readf, lun, min_values_string
  readf, lun, max_values_string

  split_ch_numbers = STRSPLIT(ch_numbers_string, ",", /EXTRACT)
  split_sensor_codes = STRSPLIT(sensor_codes_string, ",", /EXTRACT)
  split_labels = STRSPLIT(labels_string, ",", /EXTRACT)
  split_units = STRSPLIT(units_string, ",", /EXTRACT)
  split_min_values = STRSPLIT(min_values_string, ",", /EXTRACT)
  split_max_values = STRSPLIT(max_values_string, ",", /EXTRACT)

  ; The second comma separated value has the number of channels in it
  num_channels = split_ch_numbers[1]

  ch_numbers = intarr(num_channels)
  sensor_codes = strarr(num_channels)
  labels = strarr(num_channels)
  units = strarr(num_channels)
  min_values = dblarr(num_channels)
  max_values = dblarr(num_channels)

  i=1

  FOR i = 3, N_ELEMENTS(split_ch_numbers)-1, 2 DO BEGIN
    index = (i/2)-1
    ch_numbers[index] = UINT(split_ch_numbers[i])
    sensor_codes[index] = STRCOMPRESS(split_sensor_codes[i])
    labels[index] = STRCOMPRESS(split_labels[i])
    units[index] = STRCOMPRESS(split_units[i])
    min_values[index] = DOUBLE(split_min_values[i])
    max_values[index] = DOUBLE(split_max_values[i])
  ENDFOR

  ; Put the channel header data into a structure
  ch_header = {channel_numbers:ch_numbers,$
               sensor_codes:sensor_codes,$
               labels:labels,$
               units:units,$
               min_values:min_values,$
               max_values:max_values}

  ;data = dblarr(10000, num_channels)
  datetimes = dblarr(10000)

  data = replicate(!VALUES.D_NAN, 1000, num_channels)

  i = 0

  WHILE NOT EOF(lun) DO BEGIN
    line = ""

    readf, lun, line

    split_line = STRSPLIT(line, ",", /EXTRACT)

    channels_in_line = split_line[1]

    ; Initialise the datetime variable
    datetime = double(0)

    ; Read from the split line into the datetime variable
    reads, STRIP_QUOTES(split_line[0]), datetime, format="(C(CDI2, X, CMOI2, X, CHI2, X, CMI2, X, CSI2))"

    split_line = split_line[3:N_ELEMENTS(split_line)-1]

    data_indices = WHERE(STREGEX(split_line, """.""" , /BOOLEAN) EQ 0)

    ;print, split_line[data_indices]

    datetimes[i] = datetime
    data[i, 0:channels_in_line-1] = split_line[data_indices]

    i++
  ENDWHILE

  data = data[0:i-1, *]
  datetimes = datetimes[0:i-1]

  FREE_LUN, lun

END
