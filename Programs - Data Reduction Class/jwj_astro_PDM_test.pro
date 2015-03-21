;--------------------------------------------------------------------------------------
;THIS FUNCTION WAS COPIED FROM PROFESSOR ALFRED CHEN'S DEMONSTRATION CODE
function freq, n, dt
    ; Midpoint+1 is the most negative frequency subscript:
  N21 = N/2 + 1
  F = FINDGEN(N)
  ; Insert negative frequencies in elements F(N/2 +1), ..., F(N-1):
  F[N21] = N21 -N + FINDGEN(N21-2)
  ; Compute T0 frequency:
  F = F/(N*dT)
return, f
end
;--------------------------------------------------------------------------------------
;THIS PROCESS OUTPUTS A FFT HISTOGRAM FOR AN INPUTTED WAVE ARRAY
;INPUTS: w = OUTPUT WINDOW
;        x = X AXIS VALUES (ABSCISSA)
;        wave = Y AXIS VALUES (ORDINATE)
;        title = STRING FOR WINDOW NAME AND GRAPH TITLE
;        f = set this to a variable that will hold the result from the FFT function
pro show_fft, w, x, wave, title, f=f
  f=fft(wave)
  dt=x[1]-x[0]
  F1=freq(N_ELEMENTS(wave), dt)
  window, w, title=title, ysize=800
  plot, f1, abs(f), title=title, xrange=[0,10];, psym=3
end
;--------------------------------------------------------------------------------------
function request_data, title

; filename = dialog_pickfile(title=title)
 filename = "E:\Class - Data Reduction\HW9\HW09.txt"

 lines = file_lines(filename) 
 print, strtrim(lines,1), " lines of data found in ", filename, "."
 x = fltarr(lines)
 y = fltarr(lines)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    
    x[count] = strmid(str[0],0,7)
    y[count] = strmid(str[0],7)
         
    count = count + 1
 ENDWHILE    
 FREE_LUN, unit 

 data = {  $
    x:x, $
    y:y  $
 }
 return, data
end

;----------------------------------------------------------------
pro JWJ_astro_PDM_test
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 

data = request_data("Select the data file.")
   ;data.x  data.y

plot, data.x, data.y, psym=3;, xrange=[0.5,9.5]



;print, theta
show_fft, 1, data.x mod 4.552, data.y, "Chart", f=f

;~~~~~MANUAL FOLDING STEP BY STEP~~~~~
;can see that there is a period around 2.76 and a smaller one about 0.3
window, 0
for i=7730, 7730 do begin
  plot, data.x mod (10.0 - i/1000.0), data.y, psym=3, $
      title='Folded step by step until a pattern emerged.'
  xyouts, 0.1, 2, "per: " + strtrim((10.0 - i/1000.0),2)
;  stop
end
xyouts, 0.5, 0, 'Period is close to 2.27'
xyouts, 0.5, -0.5, 'And a smaller period of about 0.3 (hanging rungs)'

;;~~~~~PROGRAMMATIC FOLDING~~~~~
;data_span = max(data.x) - min(data.x) & print, data_span
;;assume period is less than half data_span. Start fold at half
;test_period = data_span / 2
;
;increment = -0.0005
;subgroups = 4
;cor_max = fltarr(subgroups) * 0.0
;period_cor_max = fltarr(subgroups) * 0.0
;cov_max = fltarr(subgroups) * 0.0
;period_cov_max = fltarr(subgroups) * 0.0
;
;array_length = long(((test_period) - 0.1)/abs(increment))
;count = 0L
;test_arrayx = fltarr(array_length)
;test_arrayycor = fltarr(subgroups, array_length)
;test_arrayycov = fltarr(subgroups, array_length)
;while test_period gt 0.1 do begin
;;   print, ""
;   for i=0, subgroups-1 do begin
;      selection = where( (data.x mod test_period) gt test_period*i/subgroups and (data.x mod test_period) lt test_period*(i+1)/subgroups )
;      if selection[0] ge 0 then begin
;         cor = correlate(data.x[selection], data.y[selection])
;         cov = correlate(data.x[selection], data.y[selection], /COVARIANCE)
;         if abs(cor) gt cor_max[i] then begin 
;            cor_max[i] = abs(cor) & period_cor_max[i] = test_period
;         end
;         if abs(cov) gt cov_max[i] then begin
;            cov_max[i] = abs(cov) & period_cov_max[i] = test_period
;         end
;         test_arrayx[count] = test_period
;         test_arrayycor[i, count] = cor
;         test_arrayycov[i, count] = cov
;      end
;;      print, "period: ", strtrim(test_period,2), "  correlation: ", strtrim(cor,2), "  covariance: ", strtrim(cov,2)
;   endfor
;
;
;   ;increment the loop condition
;   test_period = test_period + increment
;   count++ ;& print, count
;endwhile
;
;;print, "Correlates at period: ", period_cor_max
;;print, "Covariance at period: ", period_cov_max
;;print, mean(period_cor_max)
;
;;print, 'count ', count
;
;window, 2, xsize=1600
;plot, test_arrayx, (abs(test_arrayycov[0,*]))/4, /NODATA, yrange=[0,0.6], xtitle="Period", ytitle="Correlation and Covariance"
;cor_array = (abs(test_arrayycor[0,*]) + abs(test_arrayycor[1,*]) + abs(test_arrayycor[2,*]) + abs(test_arrayycor[3,*]))/4
;oplot, test_arrayx, cor_array
;cov_array = (abs(test_arrayycov[0,*]) + abs(test_arrayycov[1,*]) + abs(test_arrayycov[2,*]) + abs(test_arrayycov[3,*]))/4
;oplot, test_arrayx, cov_array/4, color='00FF00'x
;;oplot, test_arrayx, abs(test_arrayy[1,*]), color='FF0000'x
;;oplot, test_arrayx, abs(test_arrayy[2,*]), color='00FF00'x
;;oplot, test_arrayx, abs(test_arrayy[3,*]), color='0000FF'x
;
;newarr = (sort((abs(test_arrayycor[0,*]) + abs(test_arrayycor[1,*]) + abs(test_arrayycor[2,*]) + abs(test_arrayycor[3,*]))/4))
;newarr = test_arrayx[newarr]
;;print, (abs(test_arrayycor[0,newarr[0:20]]) + abs(test_arrayycor[1,newarr[0:20]]) + abs(test_arrayycor[2,newarr[0:20]]) + abs(test_arrayycor[3,newarr[0:20]]))/4
;;print, newarr
;per_at_cor_min = test_arrayx[where(cor_array eq min(cor_array[where(test_arrayx gt 0.1)]))]
;per_at_cor_min2 = test_arrayx[where(cor_array eq min(cor_array[where(test_arrayx gt 2.0)]))]
;print, 'CorCov minimum: ', per_at_cor_min
;print, 'CorCov minimum: ', per_at_cor_min2
;plots, per_at_cor_min, cor_array[where(cor_array eq min(cor_array[where(test_arrayx gt 0.1)]))], psym=2
;xyouts, per_at_cor_min + 0.2, cor_array[where(cor_array eq min(cor_array[where(test_arrayx gt 0.1)]))], $
;   strtrim(per_at_cor_min,2)
;plots, per_at_cor_min2, cor_array[where(cor_array eq min(cor_array[where(test_arrayx gt 2.0)]))], psym=2
;xyouts, per_at_cor_min2 + 0.2, cor_array[where(cor_array eq min(cor_array[where(test_arrayx gt 2.0)]))], $
;   strtrim(per_at_cor_min2,2)


;~~~~~PROGRAMMATIC FOLDING, 2ND ATTEMPT~~~~~
data_span = max(data.x) - min(data.x) & print, data_span
;assume period is less than half data_span. Start fold at half
test_period = data_span / 2

increment = -0.0005
subgroups = 3
pop_sig = stddev(data.y)
sample_sig = dblarr(subgroups)

cor_max = fltarr(subgroups) * 0.0
period_cor_max = fltarr(subgroups) * 0.0
cov_max = fltarr(subgroups) * 0.0
period_cov_max = fltarr(subgroups) * 0.0

array_length = long(((test_period) - 0.1)/abs(increment))
count = 0L
test_arrayx = fltarr(array_length)
test_arrayycor = fltarr(subgroups, array_length)
test_arrayycov = fltarr(subgroups, array_length)
theta = dblarr(array_length)
while test_period gt 0.1 do begin
;   print, ""
   for i=0, subgroups-1 do begin
      selection = where( (data.x mod test_period) gt test_period*i/subgroups and (data.x mod test_period) lt test_period*(i+1)/subgroups )
      if N_ELEMENTS(selection) ge 2 then begin
         sample_sig[i] = stddev(data.y[selection])
      end
;      print, "period: ", strtrim(test_period,2), "  correlation: ", strtrim(cor,2), "  covariance: ", strtrim(cov,2)
   endfor

   theta[count] = (mean(sample_sig))^2/ (pop_sig^2)
   test_arrayx[count] = test_period

   ;increment the loop condition
   test_period = test_period + increment
   count++ ;& print, count
endwhile

window, 3, xsize=1600
plot, test_arrayx, theta, xtitle='Period', ytitle='Theta (S^2/sig^2)'
;print, theta
;help, theta
;print, pop_sig
;PRINT THE MINIMUM POINT THAT IS GREATER THAN ZERO
print, 'The minimum point on graph is at a period of:'
theta_min = test_arrayx[where(theta eq min(theta[where(test_arrayx gt 0.01)]))]
print, theta_min
plots, theta_min, theta[where(theta eq min(theta[where(test_arrayx gt 0.01)]))], psym=2
xyouts, theta_min + 0.2, theta[where(theta eq min(theta[where(test_arrayx gt 0.01)]))], $
   strtrim(theta_min,2)


;~~~~~PDM testing~~~~~
;xsig = fltarr(N_ELEMENTS(data.x)) + 0.1
;pdm, data.x, data.y, xsig, 0.1, 7.0, 0.005, fre, per, the
;;print, the
;window, 4
;plot, per, the, ytitle='PDM Theta value', xtitle='period'
;print, 'The PDM algorithms minimum point is at period of:'
;per_from_PDM = per[where(the eq min(the[where(per gt 0.1)]))]
;print, per_from_PDM
;plots, per_from_PDM, min(the[where(per gt 0.1)]), psym=2
;xyouts, per_from_PDM + 0.2, min(the[where(per gt 0.1)]), $
;   strtrim(per_from_PDM,2)


;~~~~~Removing the larger period~~~~~
period = 2.276
xarray = lindgen(period * 10000)
singleperiod = fltarr(period * 10000) * 0.0
for i=0, N_ELEMENTS(data.x)-1 do begin
  singleperiod[(data.x[i] mod period) * 10000] = data.y[i]
end

singleperiod = [singleperiod[5000:9999],singleperiod,singleperiod[0:4999]]
xarray = lindgen

;singleperiod = SPL_INTERP(xarray[where(singleperiod ne 0.0)], $
;                          singleperiod[where(singleperiod ne 0.0)], $
;                          SPL_INIT(xarray[where(singleperiod ne 0.0)], $
;                                   singleperiod[where(singleperiod ne 0.0)]), $
;                          xarray)
selection = where(singleperiod ne 0.0)
singleperiod = SPLINE(xarray[selection], $
                      singleperiod[selection], $
                      xarray, $
                      2)

window, 1
plot, singleperiod;, yrange=[-2,4]



end 