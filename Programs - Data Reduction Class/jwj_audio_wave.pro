function sq_wave, x
  return, fix(x mod 2) 
end;sq_wave
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
pro JWJ_audio_wave
!P.background='ffffff'x
!P.color='000000'x


;print, query_wav( "I:\ENVI-IDL\Data Reduction Class\arpeggio5.wav", info )
wav = READ_WAV( "M:\Programs - Data Reduction Class\arpeggio5.wav", rate )
;wav = READ_WAV( DIALOG_PICKFILE(), rate )
help, wav

window, 6, xsize=1600
;DOUBLE THE AMPLITUDE
dblwav = wav + wav
plot, dblwav, /nodata, title='Yellow wave is original. Blue is doubled amplitude. Purple is after augmenting.'
oplot, dblwav, color='FF0000'x
oplot, wav, color='00FFFF'x


f=fft(dblwav)
dt=1
F1=freq(N_ELEMENTS(dblwav), dt)
;window, 1, title=title, ysize=800
;plot, f1, abs(f), title=title, xrange=[-0.5,0.5]
;stop

;plot, f1, abs(f), title=title, xrange=[0,0.5]

help, f

;DOUBLE LOW FREQUENCY
for i=0L, N_ELEMENTS(f)/800 do begin
  f[i] += f[i]
  f[N_ELEMENTS(f) -1 -i] += f[N_ELEMENTS(f) -1 -i]
endfor

;LOW BAND PASS.  SET HIGHER FREQS TO 0.0
for i=N_ELEMENTS(f)/100L, N_ELEMENTS(f)*99/100L do begin
  f[i] = COMPLEX( 0.0, 0.0 )
endfor


newwav = fft(f, /INVERSE)

;wset, 6
oplot, newwav, color='AA0000'x

print, 'writing wave'
write_wav, "M:\Programs - Data Reduction Class\arpeggio5fi.wav", newwav, rate
  
  
;CREATE NOISE IN THE WAV FILE
noise = sq_wave(wav) ; creates a binary array
print, 'noise', noise[50000:50020]

newwavnoise = newwav + noise*1000
oplot, newwavnoise, color='AA0AFF'x
write_wav, "M:\Programs - Data Reduction Class\arpeggio5noise.wav", newwavnoise, rate

  
  
;PLOT THE FREQUENCY GRAPH FOR BEFORE AND AFTER ADDING NOISE
f2=fft(newwavnoise)
;dt=1
;F1=freq(N_ELEMENTS(newwavnoise), dt)
window, 3
plot, f1, abs(f2), xrange=[0,0.1], yrange=[0,80], title='Green is before adding noise, black is after'
oplot, f1, abs(f), color='00FF00'x
  



end         