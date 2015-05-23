Copyright (C), 2005, Oleg Kornilov, oleg.kornilov@mail.ru
If you have a comments, need help or would like to financial support
this program, please do not hesitate to write to oleg.kornilov@mail.ru

This software is free, you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
("LGPL") as published by the Free Software Foundation.
See http://www.gnu.org/copyleft/lesser.html for additional information about the GNU LGPL.

******************************************************************************************

   These routines allow reading and writing frames (using standart Windows
multimedia subsystem) from or into AVI format at any position.
Later this movie is possible to convert into MPEG (I prefer free bbMpeg
with source at http://members.home.net/beyeler/bbmpeg.html)
 Using free 'frame server' Avisynth (http://www.avisynth.org) it's
possible to read MPEG, QT  or DVD movies from programs that can work with AVI.
 Also it's possible to use Avisynth for some video preprocessing without
intermediate files (deinterlacing, spatial and temporal smoothing, sharpening,
color correction, levels control, non-linear editing, and many more, see
Avisynth documentation and avi_test.pro example).

   Changes:
 Now it's possible to set video codec directly, without compression dialog.
 New keywords CODEC, RATE, QUALITY, IFRAME_GAP, BITRATE.
 Avisynth preprocessing filters support.


   Files description:
avi.dll - DLL for 'Video for Windows' accessing from IDL (try them for
 intermediate versions of IDL)
movie_io.pro - routines for avi access using avi.dll and CALL_EXTERNAL
 ( There are some other useful routines for working with movie )
cw_animate.pro - modyfied IDL routine (uses movie_io.pro and avi.dll)
with added 'AVI write' button and possibility to write AVI with a framerate
that is about equal with animation framerate (Frames/sec slider)

avi_test.pro - example routines that shows how to work with AVI and
 Avisynth frameserver.

 For installation just put movie_io.pro and cw_animate.pro into idl/lib
directory and avi.dll together with others idl .dll and .dlm files
(idl home directory) If you wish to use Avisynth preprocessing don't
forget to download (version 2.5 is tested) and install it before.

 For using (and automatical compilation) include movie_io.pro file
to your program as @movie_io


   Notes using video codecs:
 For capture and saving AVI files I prefer free XVID codec
(http://nic.dnsalias.com/xvid.html or http://www.divx-digest.com/software/xvid.html)
If you wish to read XVID files in IDL probably it's necessary to install also
DIVX50 or later codec (http://www.divx.com/divx/download/ or
http://www.divx-digest.com/software/divxcodec5.html)
You can check installed codecs in 'Desktop->My computer->Control Panel->
Sounds and Multimedia->Hardware->Video Codecs->Properties'

 Settings for XVID codec ("Configure" button):
  "Encoding mode" - "1 Pass - quality"
  "Quality" - test it, I use 97.
  "Advanced options":
    "Motion search precision" - "6 - Ultra high"
    "FourCC used" - "DX50" (probably it's necessary for opening XVID files
     in IDL, you can change this value for existing XVID files using 'AviC
     (FourCC Charger)' tool from XVID package)
    "Maximum I-frame interval" = 15 (seeking is highly dependable from this value).


   Notes reading avi files:   
On some operating systems (probably XP SP3 or later) direct open of avi files might not work
	avi_id=AVI_OPENR(PICKFILE(),r,g,b)
try to open using Avisynth frameserver (don't forget to install it before)
	avi_id=AVI_OPENR(MOVIE2AVS(PICKFILE(),'AVI'),r,g,b)
	
   Notes reading DVD files:
For opening DVD it's possible to use frameserver with 'DirectShowSource' filter
	avi_id=AVI_OPENR(MOVIE2AVS(PICKFILE(),'DVD'),r,g,b)
note that 'DirectShowSource' not always accurate with frame seeking, 
try to explore DGDecode filter (http://avisynth.org/mediawiki/External_filters)
