pro block_data


filename = envi_pickfile()
envi_open_file, filename, r_fid = OriImage_fid
envi_file_query, image_fid, dims = dims, ns = ns, nl = nl, nb = nb
  
window,1
tv, image_fid, /true
  
  
  
end