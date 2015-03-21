@movie_io

;Taken from avi_test.pro
;Edited by Jay W Johnson


PRO AVI_EXTRACT_FRAME  ; Example that shows how to read true-color images from AVI

;DEVICE,DEC=0   ; For indexed image

DEVICE,DEC=1   ; For true-color

avi_id=AVI_OPENR(PICKFILE(),r,g,b)

PRINT, avi_id   ; avi_id is [bpp, xsize, ysize, nframes, ...some internal info]
nframes= avi_id(3)
help, avi_id


image = avi_get(avi_id, 10)

window,1
tv, image, /TRUE


result = DIALOG_WRITE_IMAGE(image)



END