pro JWJ_locate_meteor, filename

filename = 'F:\Class - Data Reduction\HW12\single_meteor.jpg'

if N_ELEMENTS(filename) eq 0 then filename = DIALOG_PICKFILE()
if FILE_TEST(filename) eq 0 then filename = DIALOG_PICKFILE()

READ_JPEG, filename, img, /grayscale

tvscl, img
help, img


imgf = smooth(img, 2) gt 128
imgf = MORPH_CLOSE(imgf, REPLICATE(1,3,3))
tvscl, imgf


imgfft = FFT(imgf,-1)
;tvscl, imgfft


count = where(imgf > 0, cc)

print, cc
x = intarr(cc)
y = intarr(cc)
index = 0l
for i=0l, N_ELEMENTS(imgf[*,0])-1 do for j=0l, N_ELEMENTS(imgf[0,*])-1 do begin
  if imgf[i,j] gt 0 then begin
    x[index] = i & y[index] = j & index++
  end
  
end
plot, x, y, psym=4, xrange=[0,256]
res = linfit(x,y, yfit=yfit)
print, res

xvals = indgen(300)
oplot, xvals, res[0] + res[1]*xvals







end