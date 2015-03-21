;THIS FUNCTION RETURNS A SQUARE WAVE WITH A PERIOD OF 2
function sq_wave, x
  return, fix(x mod 2) 
end;sq_wave
;--------------------------------------------------------------------------------------
;THIS FUNCTION RETURNS A TRIANGLE WAVE WITH A PERIOD OF 2
function tr_wave, x
  output = x
  for i = 0, N_ELEMENTS(x)-1 do begin
    if fix(x[i] mod 2.0) eq 0.0 then output[i] = output[i] - fix(output[i])
    if fix(x[i] mod 2.0) eq 1.0 then output[i] = - output[i] + fix(output[i]) + 1
  end
  return, output 
end;tr_wave
;--------------------------------------------------------------------------------------
;THIS FUNCTION RETURNS A SAWTOOTH WAVE WITH A PERIOD OF 2
function saw_wave, x
  return, (0.5*x + 0.5) mod 1.0
end;saw_wave
;--------------------------------------------------------------------------------------
;THIS FUNCTION RETURNS A DELTA WAVE WITH A PERIOD OF 2
;THREE RANDOMLY GENERATED PEAKS WITH RANDOM HEIGHTS BETWEEN 0 AND 1
function dt_wave, x
  period = where(x eq 2.0)
  output = x
  seed = systime(1)
  pos = fix(randomu(seed, 3) * period[0])
  pk = randomu(seed, 3)
  for i = 0, N_ELEMENTS(x)-1 do begin
    output[i] = 0.0
    if i mod period eq pos[0] then output[i] = pk[0]
;    if i mod period eq pos[1] then output[i] = pk[1]
;    if i mod period eq pos[2] then output[i] = pk[2]
  end
  return, output
end;dt_wave
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
;THIS PROCESS OUTPUT A FFT HISTOGRAM FOR AN INPUTTED WAVE ARRAY
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
  plot, f1, abs(f), title=title
end
;--------------------------------------------------------------------------------------
;THIS FUNCTION RETURNS AN WAVE ARRAY FROM THE FOURIER SERIES
;INPUTS: x = X AXIS VALUES (ABSCISSA)
;        iteration = SET THE HIGHEST SUMMATION ITERATION TO CALCULATE
;        /SUM = WHEN THIS KEYWORD IS SET, THE OUTPUT IS A SUM OF ALL WAVES UP TO THE PRESET iteration
;               IF NOT SET, THE OUTPUT ONLY RETURNS THE WAVE FROM THE HIGHEST iteration
function fourier, x, iteration, SUM=sum
  output = (4/!dpi)* sin(!dpi*x)
  
  if KEYWORD_SET(sum) then begin
    for i=1, iteration-1 do output += (4/!dpi)*sin(!dpi*x*(1+2*i))/(1+2*i)
  endif else return, (4/!dpi)*sin(!dpi*x*(1+2*(iteration-1)))/(1+2*(iteration-1))

  return, output
end
;--------------------------------------------------------------------------------------
pro JWJ_waves
!P.background='ffffff'x
!P.color='000000'x

;CREATE FOUR WAVE ARRAYS.  SEE INDIVIDUAL FUNCTIONS.
x = findgen(1000) / 100
sq_w = sq_wave(x)
tr_w = tr_wave(x)
saw_w = saw_wave(x)
dt_w = dt_wave(x)

;PLOT THE FOUR WAVES
window, 0, Title='From bottom to top: Square, Triangle, Sawtooth, Delta waves'
plot, x, sq_w, yrange=[-4,4], /NODATA
oplot, x, sq_w - 3
oplot, x, tr_w - 1
oplot, x, saw_w + 1
oplot, x, dt_w + 3

;PLOT THE FFT HISTOGRAM. PAUSE BETWEEN EACH DISPLAY.  (.cont)
show_fft, 1, x, dt_w, 'Delta wave FFT'
stop
show_fft, 1, x, saw_w, 'Sawtooth wave FFT'
stop
show_fft, 1, x, tr_w, 'Triangle wave FFT', f=fw
stop
show_fft, 1, x, sq_w, 'Square wave FFT'
stop
;print, fw

;DISPLAY THE FIRST 10 COMPONENT SINE WAVES OF FOURIER SERIES
window, 2, title='Demonstration of Fourier series'
plot, x, fourier(x,1), /NODATA, TITLE='The first ten individual sine waves from the fourier series'
for i=1, 10 do oplot, x, fourier(x, i)

;DISPLAY THE CONVERGING SERIES
window, 3, title='Demonstration of Fourier series'
plot, x, fourier(x, 1, /SUM), linestyle=1, title='The summation of 1, 5, 20, and 1000 sine waves'
oplot, x, fourier(x, 5, /SUM), color='FF0000'x
oplot, x, fourier(x, 20, /SUM), color='00BB10'x
oplot, x, fourier(x, 1000, /SUM), color='0000FF'x


end