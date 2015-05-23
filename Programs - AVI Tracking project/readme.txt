avi_test.pro

	AVI_READ
		*asks for an *.avi file and loads it into XINTERANIMATE
		!Change the number of frames to load by changing "nframes="

	AVI_WRITE_TRUE
		*write frames to an *.avi file
		!Didn't work
			"AVI_OPENW: Unable to create compressed stream"

	AVI_WRITE_IND
		*Works. But I don't know where it saved the file

cw_animate.pro

	CW_ANIMATE(parent, sizeX, sizeY, nframes)
		*create as a widget from another program
		*uses XINTERANIMATE, but can open multiple instances
