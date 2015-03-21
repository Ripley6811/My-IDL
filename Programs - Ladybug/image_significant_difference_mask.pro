;CREATED: May 4, 2011

;FOR BMP FORMAT, RECTIFIED LADYBUG IMAGES
;Written to limit the search areas for object movement

;INPUT:  image0 and image1 - Two BMP images from LadybugCap program
;        signif_thresh = the threshold byte value for difference between images.
;OUTPUT: returns a bit mask of significantly difference between images
;        image pixel = 1 is significant change, = 0 is not significant
;        based of user defined threshold




function image_significant_difference_mask, image0, image1, signif_thresh

width = N_ELEMENTS(image0[0,*,0])
height = N_ELEMENTS(image0[0,0,*])
window, 0, xsize=width-1, ysize=height-1

tv, abs(fix(image0[0,*,*]) - fix(image1[0,*,*])), 0, 0, 3
tv, abs(fix(image0[1,*,*]) - fix(image1[1,*,*])), 0, 0, 2
tv, abs(fix(image0[2,*,*]) - fix(image1[2,*,*])), 0, 0, 1


window, 1, xsize=width, ysize=height
image_mask = bytarr(width,height)
for i=signif_thresh, signif_thresh do begin
  image_mask[*,*] = ((byte(abs(fix(image0[0,*,*]) - fix(image1[0,*,*]))) gt i) $
              + (byte(abs(fix(image0[1,*,*]) - fix(image1[1,*,*]))) gt i) $
              + (byte(abs(fix(image0[2,*,*]) - fix(image1[2,*,*]))) gt i)) gt 0
  tvscl, image_mask;, 0, 0, 2
  XYOUTS, width/3, 30, "threshold = " + strtrim(i,2), /DEVICE
  wait, 0.3
end

return, image_mask

end