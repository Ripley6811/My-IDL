pro jwj_population_test

 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 
;stddev(x)^2 = variance(x)
window, 1, xsize=1100, title='HW6.2 - Parts 1 through 4'

;PART 1
ppopM = double(randomn(seed, 6000000)*6.5) + 169.5
binsize = 1
xval = fltarr(size(histogram(ppopM, binsize=binsize),/N_ELEMENTS))
for i=0, size(xval,/N_ELEMENTS)-1 do xval[i] = min(ppopM)+binsize*i
plot, xval, histogram(ppopM, binsize=binsize), xrange=[140,200], /NODATA, $
    title='Red: histogram of mens heights.  Black: histogram of sample means.', xtitle='Height', ytitle='count'
oplot, xval, histogram(ppopM, binsize=binsize), color=255
pMean = mean(ppopM)
oplot, [pMean,pMean], [0, 3E6], color=255


;PART 2
spopMMean = fltarr(10000)
spopMStd  = fltarr(10000)
for i=0L, 10000-1 do begin 
  spopMMean[i] = mean(ppopM[100*i:100*i+99])
  spopMStd[i]  = stddev(ppopM[100*i:100*i+99])
end
binsize = 0.1
xval2 = fltarr(size(histogram(spopMMean, binsize=binsize),/N_ELEMENTS))
for i=0, size(xval2,/N_ELEMENTS)-1 do xval2[i] = min(spopMMean)+binsize*i
oplot, xval2, 800*histogram(spopMMean, binsize=binsize)

;print, pMean, mean(spopMMean)
;print, stddev(ppop)
;print, mean(spopStd)
;print, stddev(spopMean)


;PART 3
na = where(abs(spopMMean - mean(ppopM)) lt 1.0, count)
print, 'Percentage of sample means (100 ea.) that deviate less than 1.0 from population mean is:'
print, 100*count/10000.0, '%'
na = where(abs(spopMMean - mean(ppopM)) lt 1.3, count)
print, 'Percentage of sample means (100 ea.) that deviate less than 1.3 from population mean is:'
print, 100*count/10000.0, '%'


;PART 4
for i=0L, 10000-1 do begin 
  spopMMean[i] = mean(ppopM[163*i:163*i+162])
  spopMStd[i]  = stddev(ppopM[163*i:163*i+162])
end
binsize = 0.1
xval2 = fltarr(size(histogram(spopMMean, binsize=binsize),/N_ELEMENTS))
for i=0, size(xval2,/N_ELEMENTS)-1 do xval2[i] = min(spopMMean)+binsize*i
oplot, xval2, 800*histogram(spopMMean, binsize=binsize)
sMean_Mean = mean(spopMMean)
oplot, [sMean_Mean,sMean_Mean], [0, 2E6], linestyle=1;, color=255

na = where(abs(spopMMean - mean(ppopM)) lt 1.0, count)
print, 'Percentage of sample means (163 ea.) that deviate less than 1.0 from population mean is:'
print, 100*count/10000.0, '%'
na = where(abs(spopMMean - mean(ppopM)) lt 1.3, count)
print, 'Percentage of sample means (163 ea.) that deviate less than 1.3 from population mean is:'
print, 100*count/10000.0, '%'
print, 'The results are very close to the predicted values.  Larger samples have more accurate mean'
print, 'values.'


;PART 5
window, 3, xsize=1100, title='HW6.2 - Part 5'
binsize = 0.1
xvalV = fltarr(size(histogram(spopMStd^2, binsize=binsize),/N_ELEMENTS))
for i=0, size(xvalV,/N_ELEMENTS)-1 do xvalV[i] = min(spopMStd^2)+binsize*i
plot, xvalV, histogram(spopMStd^2, binsize=binsize), $
    title='Histogram of variance from all sample groups: Not gaussian', xtitle='Variance', ytitle='count'
pVar = stddev(ppopM)^2
oplot, [pVar,pVar], [0, 3E6], color=255
sVar_Mean = mean(spopMStd^2)
oplot, [sVar_Mean,sVar_Mean], [0, 1.5E6], linestyle=1;, color=255


;PART 6
window, 5, xsize=1100, title='HW6.2 - Parts 6 through 7'
ppopF = double(randomn(seed, 6100000)*5.2) + 159.0
;Plot the merged group
binsize = 1
xvalAll = fltarr(size(histogram([ppopM,ppopF], binsize=binsize),/N_ELEMENTS))
for i=0, size(xvalAll,/N_ELEMENTS)-1 do xvalAll[i] = min([ppopM,ppopF])+binsize*i
plot, xvalAll, histogram([ppopM,ppopF], binsize=binsize), xrange=[130,200], /NODATA, $
    title='Red: histogram of all heights.  Black: men and women heights.  Green: sample means.', xtitle='Height', ytitle='count'
oplot, xvalAll, histogram([ppopM,ppopF], binsize=binsize), color=255
pMeanAll = mean([ppopM,ppopF])
oplot, [pMeanAll,pMeanAll], [0, 3E6], color=255
;Plot the female pop
xvalF = fltarr(size(histogram(ppopF, binsize=binsize),/N_ELEMENTS))
for i=0, size(xvalF,/N_ELEMENTS)-1 do xvalF[i] = min(ppopF)+binsize*i
oplot, xvalF, histogram(ppopF, binsize=binsize)
pMeanF = mean(ppopF)
oplot, [pMeanF,pMeanF], [0, 3E6], linestyle=1
;Plot the male pop
oplot, xval, histogram(ppopM, binsize=binsize)
oplot, [pMean,pMean], [0, 3E6], linestyle=1

print, ''
print, 'Average of merged group is ', strtrim(pMeanAll,1)
print, 'Standard Dev. of merged group is ', strtrim(stddev([ppopM,ppopF]),1)


;PART 7
mixedMF_array = [ppopM,ppopF]
mixedMF_array = mixedMF_array(sort(randomu(seed,n_elements(mixedMF_array))))
print, mixedMF_array[0:19]
spopAllMean = fltarr(10000)
spopAllStd  = fltarr(10000)
for i=0L, 10000-1 do begin 
  spopAllMean[i] = mean(mixedMF_array[100*i:100*i+99])
  spopAllStd[i]  = stddev(mixedMF_array[100*i:100*i+99])
end
binsize = 0.1
xval3 = fltarr(size(histogram(spopAllMean, binsize=binsize),/N_ELEMENTS))
for i=0, size(xval3,/N_ELEMENTS)-1 do xval3[i] = min(spopAllMean)+binsize*i
oplot, xval3, 1000*histogram(spopAllMean, binsize=binsize), color='00FF00'x, linestyle=2

print, 'Average St. Dev. of subgroups from merged group is ', strtrim(mean(spopAllStd),1)

end