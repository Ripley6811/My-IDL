;Program by: Jay Johnson
;   2/26/2011
;
;FileName: JWJ_Blackbody_Plot
;
;Program Description: Creates a 3000x3000 array of rho intensity data that spans
;   3000-5999 kelvin and 0-3 micrometer wavelengths.  Outputs all data as a
;   multi-color plot.  Also denotes the visible spectrum.
;
;Input: None
;
;Output: a plot of blackbody curves for 3000 to 5999 Kelvin
;
;
;------------------------------------------------
pro JWJ_Blackbody_Plot

;SET CONSTANTS
h = double(6.6260755E-34)
c = double(2.99792458E8)
k = double(1.380658E-23)
help, h, c, k

;STARTING VALUE OF TEMPERATURE (KELVIN)
T = 3000

;SET RANGE OF WAVELENGTH AS 0.0 TO 3.0e-6 (MICROMETERS)
Lambda = dindgen(3000) * 1.0E-9

;CREATE AN INTENSITY ARRAY TO HOLD ALL VALUES OVER THE RANGE OF TEMP AND WAVELENGTH
rhoSurface = fltarr(3000,3000)

;FILL THE RHO ARRAY
for i = 0, 2999 do begin
  rhoSurface[*,i] = (8 * !pi * h * c) / ((lambda^5)*(EXP(h*c/(k*Lambda*(T+i)))-1))
endfor

;DISPLAY ALL RHO DATA AND SUBDIVIDE INTO 5 SECTIONS USING GREEN
WINDOW, 0, XSIZE=1000 , YSIZE=800
DEVICE, DECOMPOSED = 1
plot, Lambda, rhoSurface[*,2999], $
      TITLE='Blackbody Radiation', XTITLE='Lambda', YTITLE='Intensity', $
      XTICKS=6, XTICKLAYOUT=2
;loadct, 5   ;STD Gamma-II color table.  Change decompose to 0 to use this
for i = 0L, 2999 do begin
   if (i mod 1 eq 0) then oplot, Lambda, rhoSurface[*,2999-i], $
         color = (i*255/2999)*256*256 + (i*1280/2999)*256 + (255-(i*255/2999))
endfor; Increase the mod value to output less data and speed up the display

;DISPLAY THE VISIBLE SPECTRUM USING THE RAINBOW COLORTABLE
DEVICE, DECOMPOSED = 0
loadct,13   ;Rainbow color table
for i=0, 7 do begin
   oplot, [4.0E-7 + i*0.375E-7, 4.0E-7 + i*0.375E-7], $
          [0, 1.5E6], color=255-i*32
endfor


end;pro