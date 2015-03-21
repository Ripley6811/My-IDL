PRO JWJ_linear_fit
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 
print, ''
filename = dialog_pickfile(title='select data file')

lineCount = FILE_LINES(filename)

OPENR, 1, filename

setArray = dblarr(2,lineCount)

for i=0, lineCount-1 do begin
  line = ''
  READF, 1, line
  setArray[0,i] = DOUBLE(STRMID(line, 0, 6))
  setArray[1,i] = DOUBLE(STRMID(line, 6, 10))
endfor

CLOSE, 1

;window, 0
;plot, setArray
window, 0
plot, setArray[0,*], setArray[1,*];, psym=4
help, setArray
result = linfit(setArray[0,*], setArray[1,*])
x = indgen(150)
oplot, result[0] + result[1]*x

normArray = dblarr(lineCount)

normArray = setArray[1,*] - (result[0] + result[1]*setArray[0,*])

sdev = stddev(normArray)
print, 'Slope=', strtrim(result[1],1), '  Intercept=', strtrim(result[0],1)
print, 'StdDev=', strtrim(sdev,1)
outlier = where(abs(normArray) le (sdev*2), count)

print, ''
print, strtrim(count,1), ' values within 2 stddev'
print, ''

constrainArray = setArray[*,outlier]
help, constrainArray

oplot, constrainArray[0,*], constrainArray[1,*], color='0000FF'x, linestyle=2, thick=2
result2 = linfit(constrainArray[0,*], constrainArray[1,*])
oplot, result2[0] + result2[1]*x, color='0000FF'x
normArray2 = constrainArray[1,*] - (result2[0] + result2[1]*constrainArray[0,*])

sdev2 = stddev(normArray2)
print, 'Slope=', strtrim(result2[1],1), '  Intercept=', strtrim(result2[0],1)
print, 'StdDev=', strtrim(sdev2,1)

window, 1
plot, setArray[0,*], normArray, title='Centered using slope'
oplot, 0*x
oplot, constrainArray[0,*], normArray2, color='0000FF'x, linestyle=2, thick=2

print, ''
print, 'Slope Diff = ', strtrim(abs(result[1]-result2[1]),1)
print, 'Intercept Diff = ', strtrim(abs(result[0]-result2[0]),1)
print, 'STDDEV Diff = ', strtrim(abs(sdev-sdev2),1)
print, 'From the 2nd window, you can see that the real data (red line) lies', $
        'closer to the fitted line.'
end;pro