
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
pro jwj_freq_spectrum_HHT
!P.background='ffffff'x
!P.color='000000'x

;print, query_wav( "K:\Programs - Data Reduction Class\arpeggio5.wav", info )
wav = READ_WAV( "M:\Programs - Data Reduction Class\arpeggio5.wav", rate )
;wav = READ_WAV( DIALOG_PICKFILE(), rate )
wav_length = N_ELEMENTS(wav) & print, wav_length


window, 7, xsize=1200, ysize=500, title='FFT spectrum of wav'
plot, wav, yrange=[0,0.05], /nodata
x = lindgen(wav_length)
sample_interval = 16000
plot_interval = 10000

for i=0ul, wav_length-1-sample_interval, plot_interval do begin
   sample_wav = wav[i:i+sample_interval-1]
   f=fft(sample_wav)
   dt=1
   F1=freq(N_ELEMENTS(sample_wav), dt)
   for j=0l, N_ELEMENTS(f1)/2 do begin
      plots, [x[i],x[i+plot_interval-1]], [f1[j],f1[j]], color=abs(f[j])
   endfor
endfor

;HILBERT HUANG TRANSFORM
interval = 2000
segments = wav_length/interval
window, 0, title='audio wav file'
plot, x, wav
window, 1, title='HHT of wav: 5th IMF'
plot, x, wav, /NODATA
for i=0l, segments-1 do begin
   wav_hht = eemd(wav[interval * i:interval * i + interval-1],0,1)
;   help, wav_hht
   stt = i*interval
   oplot, x[stt:stt + interval-1], wav_hht[*, 5]
;   res = HILBERT(wav_hht)
;   help, res
;   for j=0l, N_ELEMENTS(res[*,0])/2 do begin
;      plots, x[i], res[j,0], color=abs(res[j,0])
;   endfor
end






;TRYING CWT
;stop
;window,8, xsize=1600, ysize=800 & plot, wav, yrange=[0,0.05], /nodata
;
;for i=0ul, wav_length-1-sample_interval, plot_interval do begin
;   sample_wav = WV_CWT(wav[i:i+sample_interval-1], 'Morlet', 4, /PAD, SCALE=scales)
;   dt=1
;   F1=freq(N_ELEMENTS(sample_wav), dt)
;   for j=0l, N_ELEMENTS(f1)/32 do begin
;      plots, [x[i],x[i+plot_interval-1]], [f1[j],f1[j]], color=abs(sample_wav[j])
;   endfor
;endfor



end