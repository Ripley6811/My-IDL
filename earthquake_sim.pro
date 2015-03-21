pro earthquake_sim
T=systime(/seconds)

array_size = 600
;STORE Ax, Ay, EXISTANCE, DEPTH.  MAY ADD MORE LAYERS LATER
particle_map = fltarr(4,array_size,array_size)

r = array_size/2.0   ;Radius
c = [r,r]            ;center coord


for i=0, array_size-1 do for j=0, array_size-1 do begin
  particle_map[2,i,j] = (r gt sqrt((i-c[0])^2 + (j-c[1])^2)) ? 1.0 : 0.0
  particle_map[3,i,j] = (particle_map[2,i,j] eq 1.0) ? r - sqrt((i-c[0])^2 + (j-c[1])^2) : 0.0
end

window,0,xsize=array_size,ysize=array_size
tvscl, particle_map[3,*,*]


G_big = (6.67428e-11)*10000000000   ;Gravitational constant
m_part = 1   ;Mass of particle
M_tot = total(particle_map[2,*,*])
print, M_tot
;for i=0, array_size-1 do for j=0, array_size-1 do begin
;   if particle_map[2,i,j] eq 1.0 then begin
;      for u=0, array_size-1 do for v=0, array_size-1 do begin
;         if particle_map[2,u,v] eq 1.0 and i ne u and j ne v then begin
;            r2 = (i-u)^2 + (j-v)^2
;            a = G / r2
;            particle_map[0,i,j] += a * (u - i) / sqrt(r2)
;            particle_map[1,i,j] += a * (v - j) / sqrt(r2)
;         end
;      end
;   end
;end
for i=0, array_size-1 do for j=0, array_size-1 do begin
   if particle_map[2,i,j] eq 1.0 then begin
      r2 = (i-r)^2 + (j-r)^2
      a = G_big * M_tot / r2
      particle_map[0,i,j] += a * (r - i) / sqrt(r2)
      particle_map[1,i,j] += a * (r - j) / sqrt(r2)
   end
end


print, particle_map[0,r-3,*]
window,1,xsize=array_size,ysize=array_size
tvscl, particle_map[0,*,*]

print, systime(/seconds) - T
end