;CREATED: May 4, 2011

;To test image significant difference to limit the object movement (flow) search areas


pro image_diff_and_search
print, QUERY_BMP('D:\Suhua_rectified_output\ladybug_Rectified_0808x0616_00001000_Cam4.bmp', info)
print, info
help, info
image0 = READ_BMP('D:\Suhua_rectified_output\ladybug_Rectified_0808x0616_00001000_Cam4.bmp')
image1 = READ_BMP('D:\Suhua_rectified_output\ladybug_Rectified_0808x0616_00001001_Cam4.bmp')
crop_rectified_image, image0
crop_rectified_image, image1

help, image0

mask = image_significant_difference_mask( image0, image1, 17 )
;print, mask
;help, mask


window, 3, xsize=500, ysize=700
tv, image0[0,*,*], 0, 0, 3
tv, image0[1,*,*], 0, 0, 2
tv, image0[2,*,*], 0, 0, 1

end