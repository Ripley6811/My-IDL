; *******************************************************
; this batch example is run from the idl command line without any
; user interactions.
;
; this batch routine performs a saturation stretch on an rgb file.
;
; 1. open an rgbfile.
; 2. perform a 2% stretch on the rgb, store the result in tmp1_name
; 3. transform the rgb to hls, store the result in tmp2_name.
; 4. gaussian stretch the saturation band, store the result tmp3_name.
; 5. transform the hl and stretched saturation band to rgb, store the
; result in out_name.
;
; for more information see the envi programmers guide.
; *******************************************************
; copyright (c) 2000-2001, itt visual information solutions
; *******************************************************
pro satstrch

; restore the envi core files
envi, /restore_base_save_files

; initialize envi and send all errors to an error file.
envi_batch_init, log_file ='batch.log'

; define the needed file names (remember to specify the full path).
in_name = 'c:\program files\itt\idl70\products\envi45\data\can_tmr.img'
out_name = 'new_rgb'
tmp1_name = 'tmp1'
tmp2_name = 'tmp2'
tmp3_name = 'tmp3'

; open the file
envi_open_file, in_name, r_fid = fid
if (fid eq -1) then begin
  envi_batch_exit
  return
endif

; set up to process the entire image, first 3 bands as rgb
envi_file_query, fid, bnames = bnames, dims = dims, ns=ns, nl=nl, nb=nb
pos = [0, 1, 2]
; stretch the input image with a 2% stretch
envi_doit, 'stretch_doit', $
  fid = fid, pos = pos, dims = dims, $
  out_name = tmp1_name, method = 1, out_dt = 1, $
  i_min = 2.0, i_max = 98.0, range_by = 0, $
  out_min = 0, out_max = 255, in_memory = 0, $
  r_fid = st_fid
if (n_elements(st_fid) eq 0) then begin
  envi_batch_exit
  return
endif

; convert stretched data to hls, all bands are from the
; samefile so make an arrayof 3 from st_fid
envi_doit, 'rgb_trans_doit', fid = [st_fid, st_fid, st_fid], $
  pos = pos, out_name = tmp2_name, dims = dims, r_fid = hls_fid, $
  hsv = 0, in_memory = 0
if (n_elements(hls_fid) eq 0) then begin
  envi_batch_exit
  return
endif

; gaussian stretch the saturation band, do a percent
; stretch 0% to 100% (the entire range). set the output range
; from 0.0 to 1.0. store the result tmp2_name.
envi_doit, 'stretch_doit', $
  fid = hls_fid, pos = [2], dims = dims, $
  method = 3, range_by = 0, i_min = 0.0, $
  i_max = 100.0, stdv = 2.0, out_dt = 4, $
  out_min = 0.0, out_max = 1.0, in_memory = 0, $
  r_fid = gst_fid, out_name = tmp3_name
if (n_elements(gst_fid) eq 0) then begin
  envi_batch_exit
  return
endif

; preform the inverse color transformation of the hl and the
; stretched saturation band back to rgb. now we incorporate
; the results of two file for the inverse transformation and
; must build the fid and pos arrays.
out_bname = 'satstrch(' + bnames[pos] + ')'
envi_doit, 'rgb_itrans_doit', $
  fid = [hls_fid, hls_fid, gst_fid], pos = [0, 1, 0], $
  out_name = out_name, dims = dims, hsv = 0, $
  out_bname = out_bname, in_memory = 0, r_fid = new_fid

; display the image
PImage = envi_get_data(fid = new_fid, dims = dims, pos = [0, 1, 2])
window, /free, xsize = ns*2, ysize = (nl*2)
;tvscl, envi_get_data(fid = fid, dims = dims, pos = [0]), ns, nl, order = 1, channel = 3
;tvscl, envi_get_data(fid = fid, dims = dims, pos = [1]), ns, nl, order = 1, channel = 2
;tvscl, envi_get_data(fid = fid, dims = dims, pos = [2]), ns, nl, order = 1, channel = 1
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [0]), ns, 0, order = 1, channel = 3
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [1]), 0, nl, order = 1, channel = 2
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [2]), 0, 0, order = 1, channel = 1
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [0]), ns, nl, order = 1, channel = 3
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [1]), ns, nl, order = 1, channel = 2
tvscl, envi_get_data(fid = new_fid, dims = dims, pos = [2]), ns, nl, order = 1, channel = 1

; close the input file and delete the tmp files from disk.
envi_file_mng, id = fid, /remove
envi_file_mng, id = st_fid, /remove, /delete
envi_file_mng, id = hls_fid, /remove, /delete
envi_file_mng, id = gst_fid, /remove, /delete

; remember to exit envi
envi_batch_exit
end
