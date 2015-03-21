pro class_practice
;linear_fit example


;demonstrating error within measurement
;first part simulates measurements collection
;  error bar also plotted
    ;ERRPLOT, X, Y-dy, Y+dy
    
coef1=LINFIT(x,y, yfit=yfit1, sigma=s1)    
coef2=LINFIT(x,y, yfit=yfit2, sigma=s2, MEASURE_ERROR=dy)
;this second one takes account for measurement error

print, correlate(x,y)

;Random_dependency
;100 x and y random numbers
;use yfit=yfit1 in the LINFIT function









end