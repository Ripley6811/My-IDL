pro RandomuTest
 print,''
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 


seed = systime(1)
arrayLength = ulong(10e7)

randArr = byte(randomu(seed,arrayLength)*10)

;print, randArr
;print, arrayLength -3, randArr[arrayLength-3], '=number'
;print, arrayLength -2, randArr[arrayLength-2], '=number'
;print, arrayLength -1, randArr[arrayLength-1], '=number'

window,0
histArr = HISTOGRAM( randArr, min=0, max=9) 
plot, histArr
print, 'Histogram array=', histArr 
print, 'Total numbers=', total(histarr)
print, 'Total Max and Min difference is ', max(histArr)-min(histArr)

subHist = HISTOGRAM( randArr[0:arrayLength/10], min=0, max=9)
oplot, subHist, COLOR='FF0000'x 
oplot, HISTOGRAM( randArr[arrayLength/10:arrayLength-1], min=0, max=9), COLOR='FF0000'x
print, 'Subgroup Total numbers=', total(subHist)
print, 'Subgroup Max and Min difference is ', max(subHist)-min(subHist)
oplot, HISTOGRAM( randArr[0:arrayLength/4], min=0, max=9), COLOR='0000FF'x 
oplot, HISTOGRAM( randArr[arrayLength/4:arrayLength-1], min=0, max=9), COLOR='0000FF'x 

oplot, HISTOGRAM( randArr[0:arrayLength/3], min=0, max=9), COLOR='FF00FF'x 
oplot, HISTOGRAM( randArr[arrayLength/3:arrayLength-1], min=0, max=9), COLOR='FF00FF'x 


window,1
plot, HISTOGRAM( randArr, min=0, max=9, binsize=2), title='binsize=2'


Print, 'As seen in the graphs and the relatively small difference between', $
       'max and min totals, the results of the random generator are very', $
       'evenly distributed.'





end