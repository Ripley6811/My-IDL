;Programmed by Jay W Johnson
;L46997017

;This program demonstrates brownian motion

pro JWJ_Brownian


n = 20 ; steps
p = 0.5 ; probability left step
z = 200000 ; number of drunks to calculate
l = 5 ; steps to home(+) or cliff(-)

paths = intarr(z, n+1)
fates = intarr(z)  ; 0 = lost, 1 = home, 2 = death

seed=SYSTIME( 1, /SECONDS )

for i=0ul, z-1 do begin
   turning=randomu(seed, n)
   paths[i,0] = 0
   for j=1, n do begin
      paths[i,j] = -1 + 2*(turning[j-1] gt p) + paths[i,j-1]
      if fates[i] eq 0 then begin
         if paths[i,j] ge l then fates[i] = 1
         if paths[i,j] le -l then fates[i] = 2
      endif
   endfor
endfor

window, 0
plot, [0,n], [-n,n], /NODATA
for i=0ul,z-1 do begin
   oplot, paths[i,*], color=i*i*100
endfor

print, paths[*,n]
print, ''
histo = histogram(paths[*,n], min=-n, max=n)
print, histo

window, 1
plot, histo


pathMean = mean(paths[*,n])
pathSD = stddev(paths[*,n])
pathSkew = skewness(paths[*,n])

print, 'Path end Average = ', strtrim(pathMean,1), '  SD = ', strtrim(pathSD,1), '  Skewness = ',  strtrim(pathSkew,1)
print, '   1 Std Dev = ', strtrim( $
       100*total(histo[20+(pathMean - pathSD):20+(pathMean + pathSD)])/total(histo), 1), $
       '%   2 Std Dev = ', strtrim( $
       100*total(histo[20+ pathMean - 2*pathSD:20+ pathMean + 2*pathSD])/total(histo), 1), '%'


window, 2

print, '        Lost        Home        Died'
print, histogram(fates)
plot, histogram(fates)


end;pro