pro desktop_fun
im_xsize = 1920
im_ysize = 1080
image = fltarr(3,im_xsize,im_ysize)
;drawthis = 1
drawthis = [[ 5,10, 5],$
            [10,20,10],$
            [ 5,10, 5]]
;drawthis = [[0,2,3,2,0],$
;            [2,5,10,5,2],$
;            [3,10,20,10,3],$
;            [2,5,10,5,2],$
;            [0,2,3,2,0]]
drawsize = N_ELEMENTS(drawthis[0,*,0])-1
print, drawsize

seed = systime(/seconds)

;HEADING
xrdir = 0   ;-1 or +1 values
yrdir = 0   ;-1 or +1 values
xgdir = 0   ;-1 or +1 values
ygdir = 0   ;-1 or +1 values
xbdir = 0   ;-1 or +1 values
ybdir = 0   ;-1 or +1 values
zdir = 0
;STARTING POSITION
xrpos = UINT(0);N_ELEMENTS(image[0,*,0])/2)   
yrpos = UINT(N_ELEMENTS(image[0,0,*])/2)
xgpos = UINT(N_ELEMENTS(image[0,*,0])/2)   
ygpos = UINT(N_ELEMENTS(image[0,0,*])/2)
xbpos = UINT(N_ELEMENTS(image[0,*,0])/1)-2
ybpos = UINT(N_ELEMENTS(image[0,0,*])/1)-2
zpos = 0.0  
;OUTPUT WINDOW
window, 1, xsize=im_xsize, ysize=im_ysize


for i=0ul, 2e8 do begin
   ;GET RANDOM NEW HEADINGS
   xrdir = FIX(RANDOMU(seed)*3)-1
   yrdir = FIX(RANDOMU(seed)*3)-1
   xgdir = FIX(RANDOMU(seed)*3)-1
   ygdir = FIX(RANDOMU(seed)*3)-1
   xbdir = FIX(RANDOMU(seed)*3)-1
   ybdir = FIX(RANDOMU(seed)*3)-1
   zdir = (FLOAT(FIX(RANDOMU(seed)*3)-1))/10.0

   ;SET NEW POSITION
   mod_xsize = UINT(im_xsize-drawsize)
   mod_ysize = UINT(im_ysize-drawsize)
   xrpos = UINT((xrpos + mod_xsize + xrdir) mod mod_xsize)
   yrpos = UINT((yrpos + mod_ysize + yrdir) mod mod_ysize)
   xgpos = UINT((xgpos + mod_xsize + xgdir) mod mod_xsize)
   ygpos = UINT((ygpos + mod_ysize + ygdir) mod mod_ysize)
   xbpos = UINT((xbpos + mod_xsize + xbdir) mod mod_xsize)
   ybpos = UINT((ybpos + mod_ysize + ybdir) mod mod_ysize)
   zpos = (zpos + zdir)
   
   ;REDUCE OLD VALUES OF ARRAY (THIS TAKES TOO LONG)
;   selection = where(image gt 0.0)
;   if i mod 10000 eq 0 and N_ELEMENTS(selection) gt 2 then for j=0, N_ELEMENTS(selection)-1 do image[selection[j]] -= 0.01

   ;DRAW POINT
   image[0,xrpos:xrpos+drawsize,yrpos:yrpos+drawsize] += drawthis
   image[1,xgpos:xgpos+drawsize,ygpos:ygpos+drawsize] += drawthis
   image[2,xbpos:xbpos+drawsize,ybpos:ybpos+drawsize] += drawthis
   
   ;DISPLAY IMAGE
   if i mod 10000 eq 0 then image = SHIFT(image, 0, xrdir, yrdir)
   if i mod 10000 eq 0 then tvscl, image, /true
end

;SAVE RESULT
;bytimage = bytscl(image)
;write_jpeg, 'K:\brownian2.jpg', bytimage, true=1
;BMP LOOKS MOST LIKE ORIGINAL OUTPUT
;write_bmp, 'K:\brownian2.bmp', reverse(bytimage, 1)

end