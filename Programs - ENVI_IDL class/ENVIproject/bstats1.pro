; *******************************************************
; This batch example shows how to calculate statistics
; in ENVI batch mode.
;
; For more information see the ENVI Programmers Guide.
; *******************************************************
; Copyright (c) 2000-2001, ITT Visual Information Solutions
; *******************************************************
pro bstats1
; restore the core file and start envi in batch
envi, /restore_base_save_files
envi_batch_init, log_file ='batch.log'
; open the input file
envi_open_file, 'c:\program files\itt\idl70\products\envi45\data\can_tmr.img', r_fid = fid
;envi_open_file, envi_pickfile(title = 'select a dem'), r_fid = fid
if (fid eq -1) then begin
envi_batch_exit
return
endif
envi_file_query, fid, nb = nb, dims = dims
; set the pos to process the entire image, all bands
pos = lindgen(nb)
; calculate the basic statistics
envi_doit, 'envi_stats_doit', $
fid = fid, pos = pos, dims = dims, $
dmin = dmin, dmax = dmax, mean = mean, $
stdv = stdv, comp_flag = 1
; make sure each one is defined on the return
print, dmin,mean,  dmax, stdv
; exit envi
;envi_batch_exit
end
