;Programmed by Jay W. Johnson
;L46997017

;Homework 3 Part 1



pro NormDistTest
PRINT, ''
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 


;LISTS COPIED FROM DIRECTLY FROM SPREADSHEET.
;ORDER IS REVERSED HERE SO THAT INDEX CORRESPONDS TO SCORE (0-100)
literatureHisto = reverse([0,0,0,0,0,0,0,0,0,0,0,1,3,3,7,19,29,38,68,74,147,142, $
         264,296,390,466,596,741,935,1012,1195,1332,1460,1682,1829,1913,1998, $
         2138,2277,2264,2404,2418,2511,2519,2447,2371,2365,2354,2246,2173,2178, $
         2132,1936,1898,1709,1663,1590,1531,1449,1318,1212,1174,1102,982,946, $
         841,768,736,662,567,573,489,472,420,383,349,320,297,271,240,218,169, $
         196,158,147,114,93,90,98,78,73,55,58,51,34,27,41,19,17,3,29 ])
physicsHisto = reverse([1,1,0,1,1,3,6,4,4,6,9,16,14,19,24,21,29,37,40,56,70,61,71, $
         79,84,84,103,117,121,132,146,165,171,191,203,197,198,229,217,231,258, $
         264,281,314,295,294,331,309,343,341,352,354,369,352,378,377,345,387, $
         401,404,435,429,445,463,456,440,443,464,518,486,497,556,546,478,513, $
         588,559,629,607,697,658,719,699,711,701,778,832,814,869,842,802,796, $
         868,756,843,646,692,604,656,257,654 ])
;print, physicsHisto
;print, literatureHisto


;CONVERT HISTOGRAM TO INDIVIDUAL SCORES
literatureScores = intarr(total(literatureHisto))
physicsScores = intarr(total(physicsHisto))
litCount = 0L
phyCount = 0L
for i=0,100 do begin
  if i ne 0 and literatureHisto[i] ne 0 then begin
      literatureScores[litCount:(litCount + long(literatureHisto[i]) - 1)] = intarr(literatureHisto[i])+i
  endif
  if i ne 0 and physicsHisto[i] ne 0 then begin
      physicsScores[phyCount:(phyCount + long(physicsHisto[i]) - 1)] = intarr(physicsHisto[i])+i
  endif
  litCount += literatureHisto[i]
  phyCount += physicsHisto[i]
endfor


;CALCULATE MEAN AND STANDARD DEVIATION AND SKEWNESS
litMean = mean(literatureScores)
phyMean = mean(physicsScores)

litSD = stddev(literatureScores)
phySD = stddev(physicsScores)

litSkew = skewness(literatureScores)
phySkew = skewness(physicsScores)

print, 'Literature Average = ', strtrim(litMean,1), '  SD = ', strtrim(litSD,1), '  Skewness = ',  strtrim(litSkew,1)
print, '   1 Std Dev = ', strtrim( $
       100*total(literatureHisto[litMean - litSD:litMean + litSD])/total(literatureHisto), 1), $
       '%   2 Std Dev = ', strtrim( $
       100*total(literatureHisto[litMean - 2*litSD:litMean + 2*litSD])/total(literatureHisto), 1), '%'
print, 'Physics Average = ', strtrim(phyMean,1), '  SD = ', strtrim(phySD,1), '  Skewness = ',  strtrim(phySkew,1)
print, '   1 Std Dev = ', strtrim( $
       100*total(physicsHisto[phyMean - phySD:phyMean + phySD])/total(physicsHisto), 1), $
       '%   2 Std Dev = ', strtrim( $
       100*total(physicsHisto[0:phyMean + 2*phySD])/total(physicsHisto), 1), '%'
       
print, 'Literature z-test'
print, '88% z-test = ', (88.0 - litMean) / litSD, '  ', strtrim(fix(100*total(literatureHisto[0:litMean + litSD*((88.0 - litMean) / litSD)])/total(literatureHisto)),1), '% of students are below'
print, '75% z-test = ', (75.0 - litMean) / litSD, '  ', strtrim(fix(100*total(literatureHisto[0:litMean + litSD*((75.0 - litMean) / litSD)])/total(literatureHisto)),1), '% of students are below'
print, '50% z-test = ', (50.0 - litMean) / litSD, '  ', strtrim(fix(100*total(literatureHisto[0:litMean + litSD*((50.0 - litMean) / litSD)])/total(literatureHisto)),1), '% of students are below'
print, '25% z-test = ', (25.0 - litMean) / litSD, '  ', strtrim(fix(100*total(literatureHisto[0:litMean + litSD*((25.0 - litMean) / litSD)])/total(literatureHisto)),1), '% of students are below'
print, '12% z-test = ', (12.0 - litMean) / litSD, '  ', strtrim(fix(100*total(literatureHisto[0:litMean + litSD*((12.0 - litMean) / litSD)])/total(literatureHisto)),1), '% of students are below'
print, 'Physics z-test'
print, '88% z-test = ', (88.0 - phyMean) / phySD, '  ', strtrim(fix(100*total(physicsHisto[0:phyMean + phySD*((88.0 - phyMean) / phySD)])/total(physicsHisto)),1), '% of students are below'
print, '75% z-test = ', (75.0 - phyMean) / phySD, '  ', strtrim(fix(100*total(physicsHisto[0:phyMean + phySD*((75.0 - phyMean) / phySD)])/total(physicsHisto)),1), '% of students are below'
print, '50% z-test = ', (50.0 - phyMean) / phySD, '  ', strtrim(fix(100*total(physicsHisto[0:phyMean + phySD*((50.0 - phyMean) / phySD)])/total(physicsHisto)),1), '% of students are below'
print, '25% z-test = ', (25.0 - phyMean) / phySD, '  ', strtrim(fix(100*total(physicsHisto[0:phyMean + phySD*((25.0 - phyMean) / phySD)])/total(physicsHisto)),1), '% of students are below'
print, '12% z-test = ', (12.0 - phyMean) / phySD, '  ', strtrim(fix(100*total(physicsHisto[0:phyMean + phySD*((12.0 - phyMean) / phySD)])/total(physicsHisto)),1), '% of students are below'

print, 'Because the literature skewness is towards the left, it is expected to', $
       'have z-tests deviate towards the negative.  Likewise with physics.', $
       'The physics skewness is towards the right, therefore more positively skewed z-test.'

;PLOT RESULTS
PLOT, [0, 100], [0,3000], XTITLE='Score', YTITLE='Number of students', /NODATA, $
      Title='Histogram'
XYOUTS, 660, 420, 'Literature Test', COLOR='FF0000'x, /DEVICE
OPLOT, literatureHisto, COLOR='FF0000'x, PSYM=1
OPLOT, [litMean, litMean], [0,3000], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean-litSD, litMean-litSD], [0,1400], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean+litSD, litMean+litSD], [0,1400], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean-2*litSD, litMean-2*litSD], [0,700], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean+2*litSD, litMean+2*litSD], [0,700], COLOR='FF0000'x, LINESTYLE=4
XYOUTS, 150, 320, 'Physics Test', COLOR='0000FF'x, /DEVICE
OPLOT, physicsHisto, COLOR='0000FF'x, PSYM=4
OPLOT, [phyMean, phyMean], [0,3000], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean-phySD, phyMean-phySD], [0,1400], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean+phySD, phyMean+phySD], [0,1400], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean+2*phySD, phyMean+2*phySD], [0,700], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean-2*phySD, phyMean-2*phySD], [0,700], COLOR='0000FF'x, LINESTYLE=2

window, 1
PLOT, [0, 100], [0,total(literatureHisto) > total(physicsHisto)], $
      XTITLE='Score', YTITLE='Number of students', /NODATA, TITLE='Cumulative Histogram'
XYOUTS, 660, 420, 'Literature Test', COLOR='FF0000'x, /DEVICE
OPLOT, total(literatureHisto, /CUMULATIVE), COLOR='FF0000'x, PSYM=1
OPLOT, [litMean, litMean], [0,3000], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean-litSD, litMean-litSD], [0,1400], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean+litSD, litMean+litSD], [0,1400], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean-2*litSD, litMean-2*litSD], [0,700], COLOR='FF0000'x, LINESTYLE=4
OPLOT, [litMean+2*litSD, litMean+2*litSD], [0,700], COLOR='FF0000'x, LINESTYLE=4
XYOUTS, 150, 220, 'Physics Test', COLOR='0000FF'x, /DEVICE
OPLOT, total(physicsHisto, /CUMULATIVE), COLOR='0000FF'x, PSYM=4
OPLOT, [phyMean, phyMean], [0,3000], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean-phySD, phyMean-phySD], [0,1400], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean+phySD, phyMean+phySD], [0,1400], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean+2*phySD, phyMean+2*phySD], [0,700], COLOR='0000FF'x, LINESTYLE=2
OPLOT, [phyMean-2*phySD, phyMean-2*phySD], [0,700], COLOR='0000FF'x, LINESTYLE=2

print, ' ', $
       'Using a cumulative histogram is more convenient to calculate percentage of students.', $
       '  Literature test percentages'
print, strtrim(fix(100*(total(literatureHisto, /CUMULATIVE))[88]/total(literatureHisto)),1), '% below score of 88'
print, strtrim(fix(100*(total(literatureHisto, /CUMULATIVE))[75]/total(literatureHisto)),1), '% below score of 75'
print, strtrim(fix(100*(total(literatureHisto, /CUMULATIVE))[50]/total(literatureHisto)),1), '% below score of 50'
print, strtrim(fix(100*(total(literatureHisto, /CUMULATIVE))[25]/total(literatureHisto)),1), '% below score of 25'
print, strtrim(fix(100*(total(literatureHisto, /CUMULATIVE))[12]/total(literatureHisto)),1), '% below score of 12'

print, '  Physics test percentages'
print, strtrim(fix(100*(total(physicsHisto, /CUMULATIVE))[88]/total(physicsHisto)),1), '% below score of 88'
print, strtrim(fix(100*(total(physicsHisto, /CUMULATIVE))[75]/total(physicsHisto)),1), '% below score of 75'
print, strtrim(fix(100*(total(physicsHisto, /CUMULATIVE))[50]/total(physicsHisto)),1), '% below score of 50'
print, strtrim(fix(100*(total(physicsHisto, /CUMULATIVE))[25]/total(physicsHisto)),1), '% below score of 25'
print, strtrim(fix(100*(total(physicsHisto, /CUMULATIVE))[12]/total(physicsHisto)),1), '% below score of 12'
print, '  Same as derived from z-test'
end;pro