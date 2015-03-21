;CREATED: May 4, 2011
;CHANGED: May 5, 2011 - reduced the default window

;Autocrop the recified image from LadybugCap output.
;Get the rectangle region just within the black borders or smaller

;INPUT:  image = image that will be cropped
;        cropMore = a percentage, to return a smaller portion of central image
;                (cut more around the edges)
;                 NOT WRITTEN YET!!
;OUPUT:  image = the cropped image


pro crop_rectified_image, image, cropMore


width = N_ELEMENTS(image[0,*,0])-1
height = N_ELEMENTS(image[0,0,*])-1

;tv, image[0,*,*], 0, 0, 3
;tv, image[2,*,*], 0, 0, 1

x0 = 0.00
x1 = 1.00
y0 = 0.10
y1 = 0.90


;DISPLAY WHOLE IMAGE AND CROPPING AREA
;window, 0, xsize=width-1, ysize=height-1
;tv, image[1,*,*], 0, 0, 2
;PLOTS, [width*x0, width*x1], [height*y0,height*y0], /DEVICE
;PLOTS, [width*x0, width*x0], [height*y0,height*y1], /DEVICE
;PLOTS, [width*x0, width*x1], [height*y1,height*y1], /DEVICE
;PLOTS, [width*x1, width*x1], [height*y0,height*y1], /DEVICE



image = image[*,width*x0:width*x1,height*y0:height*y1]


end