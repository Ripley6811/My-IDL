pro randomdotpractice
   ;READ DEPTHMAP/DEM IMAGE

;   read_jpeg, 'C:\Users\Jay\Desktop\taiwan_depth.jpg', dem
;   read_png, 'C:\Users\Jay\Desktop\file.png', dem
   read_png, 'H:\Class_ENVI_IDL\randomdotpractice\Shark_Depthmap.png', depthmap
;   read_png, 'D:\Class_ENVI_IDL\Shark_Depthmap.png', dem
;   read_png, 'D:\Class_ENVI_IDL\randomdotpractice\depthgirls.png', dem
;   read_png, 'C:\Users\tutu\Desktop\depthmaid.png', dem
;   read_jpeg, 'C:\Users\tutu\Desktop\depthdress.jpg', dem
;   read_jpeg, 'C:\Users\tutu\Desktop\depthwall.jpg', dem
;   read_jpeg, 'C:\Users\tutu\Desktop\17929_carlsson7thDepthmap.jpg', dem
;   read_jpeg, 'C:\Users\tutu\Desktop\17929_carlsson8thDephtmap.jpg', dem
   
   if size(depthmap[*,0], /N_ELEMENTS) lt 10 then begin
      dem = bytarr(size(depthmap[0,*,0], /N_ELEMENTS),size(depthmap[0,0,*], /N_ELEMENTS))
      dem[*,*] = depthmap[0,*,*] 
   endif
   
   
   print, 'x=', size(dem[*,0], /N_ELEMENTS)
   print, 'y=', size(dem[0,*], /N_ELEMENTS)
   print, 'max=', max(dem[*,*])
   help, dem

   ;MAKE BASE IMAGE FROM RANDOM BYTES
   image = bytarr(133 * 10, 700)
   image[0:132,0:699] = (byte(randomu(6,133,700) * 256))
   for i = 1, 10 - 1 do begin
      image[i * 133:i*133 + 132,0:699] = image[0:133-1,0:699] 
   endfor

   ;MAKE BLACK REFERENCE DOTS
   image[130:139,10:19] = bytarr(10,10)
   image[263:272,10:19] = bytarr(10,10)
   

   ;CREATE OUTPUT WINDOW
   window, 1, xsize=133*10, ysize=700
   ;OFFSET THE DEPTHMAP FROM THE CORNER
   xoffset = 200
   yoffset = 100
   imageMax = max(dem[*,*])
   
   ;ADJUST ALL PIXELS BASED ON DEPTHMAP
   for i = xoffset, xoffset + size(dem[*,0], /N_ELEMENTS)-1 do begin
      for j = yoffset, yoffset + size(dem[0,*], /N_ELEMENTS)-1 do begin
         if dem[i-xoffset,j-yoffset] ne 0 then begin
            shiftrow, image, i, dem[i-xoffset,j-yoffset]/7, j
         endif
      endfor
      tv, image
   endfor

   ;DISPLAY BASE IMAGE
   tv, image
   print, size(image,  /DIMENSIONS)
   
   ;WRITE IMAGE TO FILE
   write_jpeg, 'D:\Class_ENVI_IDL\shark.JPG', image
end

pro shiftrow, image, i, diffx, j
   x = i & y = j & dx = diffx
;   print, 'shift=',dx
;   print, 'moving ', x, ' by ', dx, ' pixels. y=', y
   xmax = (size(image, /DIMENSIONS))[0]
   while x + dx le xmax -1 do begin
      image[x,y] = image[x + dx,y]
      x = x + 133 ;go to next panel
   endwhile
end
