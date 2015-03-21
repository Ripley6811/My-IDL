; *******************************************************
; This example shows a simple IDL procedure that prompts you to select a DEM file 
; and to display the DEM and its shaded relief image side-by-side. Instead of 
; coding a shaded-relief algorithm from scratch, use the TOPO_DOIT library routine.
; *******************************************************
pro view_dem
; restore the core file and start envi in batch
envi, /restore_base_save_files
envi_batch_init, log_file ='batch.log'

; select a dem file (d:\enviprog\dems\boulder.dem)
dem_file = envi_pickfile(title = 'select a dem')
if (dem_file eq "") then return
envi_open_file, dem_file, r_fid = dem_fid

; query file information
envi_file_query, dem_fid, dims = dims, ns=ns, nl=nl, nb=nb
proj = envi_get_projection(fid = dem_fid, pixel_size = pixel_size)

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [2], dims = dims, $
  elevation = 35.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
shaded = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [0], dims = dims, $
  elevation = 45.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
sloped = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [1], dims = dims, $
  elevation = 45.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
aspected = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [3], dims = dims, $
  elevation = 45.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
profiled = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [4], dims = dims, $
  elevation = 45.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
planed = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; create shaded image based on the dem
envi_doit, 'topo_doit', azimuth = 15.0, bptr = [5], dims = dims, $
  elevation = 45.0, fid = dem_fid, in_memory = 1, pos = [0], $
  r_fid = shaded_fid, pixel_size = pixel_size
dem = envi_get_data(fid = dem_fid, dims = dims, pos = [0])
longed = envi_get_data(fid = shaded_fid, dims = dims, pos = [0])

; display the image
window, 10, xsize = (ns * 1.4), ysize = nl * 0.60
tvscl, dem, order = 1
window, 11, xsize = (ns), ysize = nl * 0.60

tvscl, shaded, 200, 0, order = 1
tvscl, sloped, 400, 0, order = 1
;tvscl, aspected, 000, 0, order = 1  ; Overlays the previous image
;tvscl, profiled, 600, 0, order = 1
wset, 10
tvscl, planed, 800, 0, order = 1
tvscl, longed, 1000, 0, order = 1

; exit envi
envi_batch_exit
end

