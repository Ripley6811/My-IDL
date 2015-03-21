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
  window, w, title=title, ysize=500
  plot, f1, abs(f), title=title, xrange=[-0.2,0.2], yrange=[0,4];, psym=3
end
;--------------------------------------------------------------------------------------
pro JWJ_temp_hum_diff
!P.background = 'FFFFFF'x
!P.COLOR = '000000'x 

;filename = dialog_pickfile(title='Select data file')
filename = 'J:\Class - Data Reduction\HW10\TH.txt'

lines = file_lines(filename) 
print, strtrim(lines,1), " lines of data found in ", filename, "."

t = fltarr(lines)  ;temperature
h = fltarr(lines)  ;humidity

OPENR, unit, filename, /GET_LUN 
str = '' 
count = 0ll

WHILE ~ EOF(unit) DO BEGIN 
   READF, unit, str
   strtok = strsplit(str, ' ', /EXTRACT)
   t[count] = float(strtok[0])  
   h[count] = float(strtok[1])  
        
   count = count + 1
ENDWHILE    
FREE_LUN, unit 

x = indgen(lines)
Window, 0
plot, x, h, title='Plot of humidity over temperature'
oplot, t


show_fft, 2, x, t, 'Temperature FFT', f=t_f
show_fft, 3, x, h, 'Humidity FFT', f=h_f
print, where(t_f gt 0.25)
print, abs(t_f[where(t_f gt 0.25)])
print, (freq(N_ELEMENTS(t), x[1]-x[0]))[where(t_f gt 0.25)]
print, where(h_f gt 1.4)
print, abs(h_f[where(h_f gt 1.4)])
print, (freq(N_ELEMENTS(h), x[1]-x[0]))[where(h_f gt 1.4)]
print, 'The frequency peaks are the same for both temperature and humidity.'
print, 'Peaks at frequency of 0.042'


end