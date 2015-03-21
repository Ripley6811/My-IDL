pro JWJ_error_propagation
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 
print, ''
;CALCULATION OF ERROR FROM FORMULA
print, 'Error propagation formula calculation'
print, strtrim(10*5*8,1), '(+-)', strtrim(400*((.5/10)+(.5/5)+(.5/8)),1)
print, ''



;MONTE CARLO METHOD
count = 1000000

meas_error = 1.0

seed=SYSTIME( 1, /SECONDS )

aaa = randomn(seed, count)

length = randomn(seed, count)*0.2 + 10.0
width = randomn(seed, count)*0.2 + 5.0
height = randomn(seed, count)*0.2 + 8.0

;print, length
plot, histogram(length)
volumeArray = length * width * height

;print, volumeArray
plot, volumeArray
print, 'calc min = ', strtrim(9.5 * 4.5 * 7.5,1), '    stat min = ', strtrim(min(volumeArray),1)
print, 'calc mid = ', strtrim(10.0 * 5.0 * 8.0,1),'    stat mid = ', strtrim(mean(volumeArray),1)
print, 'calc max = ', strtrim(10.5 * 5.5 * 8.5,1),'    stat max = ', strtrim(max(volumeArray),1)
print, 'Stddev = ', strtrim(stddev(volumeArray),1)
print, 'Skewness = ', strtrim(skewness(volumeArray),1)
histo = histogram(volumeArray, binsize=5, MIN=295)
;print, histo
x = (findgen(size(histo,/N_ELEMENTS))*5 + 295)
plot, x, histo, PSYM=10, $
         XTITLE='Volume', YTITLE='Count', TITLE='Histogram of volume values'

print,''
print, 'The histogram is skewed to the right.  Which is as predicted by the', $
        'calculated min and max values.  calc min = calc mid (400) minus 79.375', $
        'and calc max = calc mid plus 90.875.  A difference of 11.50 more is on the', $
        'positive side. The test also is about 10 more cubic meters to the right.
end;pro