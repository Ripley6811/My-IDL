pro JWJ_gaussian_function

;filename = 'C:\Users\rs59\gauss_data.txt'
 filename = dialog_pickfile(title='select data file')

 lines = file_lines(filename) 
 x = dblarr(lines)
 y = dblarr(lines)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    
    strA = strsplit(str, ' ', /EXTRACT)
    
    x[count] = double(strA[0])
    y[count] = double(strA[1])
     
    count = count + 1
 ENDWHILE    
 FREE_LUN, unit 

 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 

 plot, x, y, yrange=[min(y),max(y)], psym=7, thick=2

 est = [1.0, 1.7, 1.0]
 yfit = GAUSSFIT( x, y, coef, ESTIMATES=est, NTERMS=3, SIGMA=sig)
; print, yfit 
 oplot, x, yfit, color='FF0000'x, linestyle=1, thick=2
 XYOUTS, 140, 120, '..... = GaussFit 1.0,1.7,1.0 and 1.0,3.3,0.1', /DEVICE, COLOR='FF0000'x
 
 est = [1.0, 3.3, 0.1]
 yfit = GAUSSFIT( x, y, coef, ESTIMATES=est, NTERMS=3, SIGMA=sig)
; print, yfit 
; oplot, x, yfit, color='FF0000'x, linestyle=1, thick=2
 est = [0.2, 1.7, 0.5, 0.0, 0.0]
 yfit = GAUSSFIT( x, y, coef, ESTIMATES=est, NTERMS=5, SIGMA=sig)
; print, yfit 
 oplot, x, yfit, color='00FF00'x, linestyle=2, thick=2
 XYOUTS, 140, 100, '--- = GaussFit 0.2,1.7,0.5,0.0,0.0', /DEVICE, COLOR='00FF00'x
 est = [1.0, 3.3, 0.1, 0.0, 0.0]
 yfit = GAUSSFIT( x, y, coef, ESTIMATES=est, NTERMS=5, SIGMA=sig)
 print, yfit 
 oplot, x, yfit, color='00FF00'x, linestyle=0, thick=2
 XYOUTS, 140, 80, '____ = GaussFit 1.0,3.3,0.1,0.0,0.0', /DEVICE, COLOR='00FF00'x
 print, coef


 est = [0.2, 1.7, 0.5, 1.0, 3.3, 0.1, 0.0, 0.0]
 yfit = DBLGAUSSFIT_JWJmod( x, y, coef, ESTIMATES=est, NTERMS=8, SIGMA=sig)
; print, yfit 
 oplot, x, yfit, color='0000FF'x, linestyle=3, thick=2
 XYOUTS, 140, 140, '.-.-. = Double Gauss', /DEVICE, COLOR='0000FF'x
 
end