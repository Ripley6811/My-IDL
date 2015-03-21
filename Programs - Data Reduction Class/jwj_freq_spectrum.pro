
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
pro jwj_freq_spectrum
!P.background='ffffff'x
!P.color='000000'x

;print, query_wav( "K:\Programs - Data Reduction Class\arpeggio5.wav", info )
;wav = READ_WAV( "D:\Programs - Data Reduction Class\arpeggio5.wav", rate )
wav = READ_WAV( DIALOG_PICKFILE(), rate )
wav_length = N_ELEMENTS(wav) & print, wav_length


;window, 7, xsize=1600, ysize=800 & plot, wav, yrange=[0,0.05], /nodata
x = lindgen(wav_length)
sample_interval = 16000
plot_interval = 5000
;
for i=0ul, wav_length-1-sample_interval, plot_interval do begin
   sample_wav = wav[i:i+sample_interval-1]
   f=fft(sample_wav)
   dt=1
   F1=freq(N_ELEMENTS(sample_wav), dt)
   for j=0l, N_ELEMENTS(f1)/2 do begin
      plots, [x[i],x[i+plot_interval-1]], [f1[j],f1[j]], color=abs(f[j])
   endfor
endfor


;TRYING CWT
;stop
;window,8, xsize=1600, ysize=800 & plot, wav, yrange=[0,100000], /nodata
;sample_interval = 20000
;plot_interval = 10000
;;   sample_wav = WV_CWT(wav[0:sample_interval-1], 'Morlet', 4, /PAD, SCALE=scales)
;;   help, sample_wav
;;   help, scales
;;   plot, abs(sample_wav)
;;   print, 'st'
;;   print, abs(sample_wav)
;;stop
;for i=0ul, wav_length-1-sample_interval, plot_interval do begin
;   sample_wav = WV_CWT(wav[i:i+sample_interval-1], 'Morlet', 6, /PAD, SCALE=scales)
;;   print, max(abs(sample_wav))
;   sample_wav = (abs(sample_wav))^2
;;   plot, abs(sample_wav)
;;   print, sample_wav
;;   dt=1
;;   F1=freq(N_ELEMENTS(scales), dt)
;   for j=0l, 100000 do begin
;      plots, [x[i],x[i+plot_interval-1]], [j,j], color=abs(sample_wav[j])
;   endfor
;endfor

;      cwt = WV_CWT(wav[0:0+sample_interval-1], 'Morlet', 6, SCALE=scale)
;      LOADCT, 39
;      CONTOUR, cwt, x[0:0+sample_interval-1], scale, /YLOG, /FILL, XSTYLE=1, YSTYLE=1, $
;          XTITLE='Time', YTITLE='Scale'




end;pro