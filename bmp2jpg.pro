;CREATED: May 4, 2011

;INPUT:  full filename for BMP image
;OUTPUT:  Saves a PNG to same location

pro bmp2jpg, filename

;filename = 'H:\Suhua_rectified_output\ladybug_Rectified_0808x0616_00001000_Cam4.bmp'
image = READ_BMP(filename)

filename = file_dirname(filename, /mark_directory) + file_basename(filename, 'bmp') + 'jpg'

;image = reform(image[0,*,*])
crop_rectified_image, image

write_jpeg, filename, true=1, $
;write_ppm, filename, $
;            image
            [image[2,*,*],image[1,*,*],image[0,*,*]]

end