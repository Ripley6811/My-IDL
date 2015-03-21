;Programmed by Jay W. Johnson
;L46997017


   ;This function adds one day to the date in the filename
   ;INPUT: current filename, current julian data
   ;OUTPUT: next filename with new date
function get_next_filename, filename, juldate
;ADD ONE TO JULIAN DATE
juldate += 1

;CONVERT JULIAN DATE TO MONTH, DAY, YEAR STRINGS
caldat, juldate, month, day, year
STRPUT, filename, strtrim(year,1), strlen(filename) - 12

;PUT THE NEW DATE BACK INTO FILENAME
if month lt 10 then begin 
   STRPUT, filename, '0', strlen(filename) - 8
   STRPUT, filename, strtrim(month,1), strlen(filename) - 7
endif else begin
   STRPUT, filename, strtrim(month,1), strlen(filename) -8
endelse
if day lt 10 then begin 
   STRPUT, filename, '0', strlen(filename) - 6
   STRPUT, filename, strtrim(day,1), strlen(filename) - 5
endif else begin
   STRPUT, filename, strtrim(day,1), strlen(filename) -6
endelse

;RETURN NEW FILENAME STRING
return, filename
end;function get_next_filename
;--------------------------------------------------------


pro WWLLN_reader
;SELECT FIRST FILE.  ASSUME ALL FILES ARE IN THE SAME DIRECTORY.
filename=dialog_pickfile(title='Select first file of series to process.')

;EXTRACT DATE FROM FIRST FILENAME AND CREATE A JULIAN DATE.
strEnd = strlen(filename)
year=strmid(filename,strEnd - 12, 4)
month=strmid(filename,strEnd - 8, 2)
day=strmid(filename,strEnd - 6, 2)
juldate= JULDAY(month,day,year)

;CREATE ARRAYS TO STORE DATE AND DAILY TOTALS
dateArr = STRARR(100)
dailyShandianArr = LONARR(100)

;OPEN EACH FILE AND SAVE TOTAL DAILY LIGHTNING TO ARRAY
daycount = 0
WHILE FILE_TEST(filename) DO BEGIN
   CALDAT, juldate, month, day, year
   dateArr[daycount] = STRCOMPRESS(STRING(month, '/', day))
   dailyShandianArr[daycount] = FILE_LINES(filename)
   daycount += 1
   filename = get_next_filename(filename, juldate)
endwhile

;REDUCE SIZE OF DATE AND LIGHTNING COUNT ARRAYS
dateArr = dateArr[0:daycount-1]
dailyShandianArr = dailyShandianArr[0:daycount-1]

;CREATE HISTOGRAM AND FIND MODE
histo = histogram(dailyShandianArr, OMIN=min)
;help, histo
maxcount = max(histo,pos)
modeArr = WHERE(histo eq maxcount) + min
histoXTICKNAME = BYTARR(min+size(histo,/N_ELEMENTS))
histoXTICKNAME[min:*] = histo

;DISPLAY GRAPH AND HISTOGRAM
window,0
plot, dailyShandianArr, /YNOZERO, $
      TITLE = 'Daily Total of Lightning Occurence', $
      XTITLE = 'Daily Total beginning from 7/01/2010', YTITLE = 'Total Lightning', $
      XMINOR=1
window,1
plot, histoXTICKNAME,  $
      TITLE = 'Histogram of Totals from Each Day', $
      XTITLE = 'Daily Totals', YTITLE = 'Occurrence', $
      XRANGE = [MIN(dailyShandianArr),MAX(dailyShandianArr)], $
      PSYM=10  ;For block shaped histogram

;PRINT OUT STATISTICS
;print, dailyShandianArr[0:daycount-1]
print, 'Mean = ', strtrim(mean(dailyShandianArr),1)
if maxcount le 1 then print, 'Mode does not exist!' else begin
   print, 'Mode = ', strtrim(modeArr,1), '        (found ', strtrim( maxcount,1), ' time(s))'
endelse
print, 'Median = ', strtrim(MEDIAN(dailyShandianArr),1)
print, 'Standard Deviation = ', strtrim(STDDEV(dailyShandianArr),1)
print, 'Maximum = ', strtrim(MAX(dailyShandianArr),1)
print, 'Minimum = ', strtrim(MIN(dailyShandianArr),1)
end;pro WWLLN_reader