pro JWJ_deconvol2D

convol2D_test

img1 = TVRD()

help, img1


k=fltarr(50,50)
k=gauss2D(k,2.0)
img2=fltarr(512,512)
img2[231:280,231:280] = k
print, max(k)
print, total(k)
print, 100/3.97887


;img1fft=fft(img1, -1)
;help, img1fft
;;print, real_part(img1fft)*1000
;tvscl, shift(( (abs(real_part(img1fft)*1000))<10),256,256)
;img2fft=fft(img2, -1)
;
;tvscl, shift(( (abs(real_part(img2fft)*1000))<1),256,256)
;
;cimgfft=conj(img1fft)*img2fft
;
;cimg=rotate(shift(real_part(fft(cimgfft, 1)), 256, 256), 2)
;
;
;;stop
;;window, 0, xsize=512, ysize=512
;;wset,0
;tvscl,img1
;;window, 1, xsize=512, ysize=512
;;wset,1
;window, 3
;tvscl, cimg;>0.01
;stop

imgCpeak = fltarr(512,512)
curr = 0.0
up = 1
for i=1, 511 do for j=1, 511 do begin
   if img1[i,j] gt curr then begin
      up = 1
   endif else if img1[i,j] lt curr and up then begin 
      imgCpeak[i,j-1] = img1[i,j-1] * 25.1328
      up = 0
   end
   curr = img1[i,j] 
end

imgRpeak = fltarr(512,512)
curr = 0.0
up = 1
for j=1, 511 do for i=1, 511 do begin
   if img1[i,j] gt curr then begin
      up = 1
   endif else if img1[i,j] lt curr and up then begin 
      imgRpeak[i-1,j] = img1[i-1,j] * 25.1328
      up = 0
   end
   curr = img1[i,j] 
end

imgout = fltarr(512,512)
index = where(imgCpeak ne 0 and imgRpeak ne 0)
imgout[index] = imgCpeak[index]


window, 2, xsize=N_ELEMENTS(img1[*,0]), ysize=N_ELEMENTS(img1[0,*]), $
   title='Column and Row peaks'
tvscl, imgCpeak + imgRpeak


window, 3, xsize=N_ELEMENTS(img1[*,0]), ysize=N_ELEMENTS(img1[0,*]), $
   title='Intersection of Column and Row peaks'
tvscl, imgout




end