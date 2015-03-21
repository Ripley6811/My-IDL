pro water_absorption

; filename = dialog_pickfile()
filename = 'K:\Data - Water data\Water absorption - Segelstein.txt'

 lines = file_lines(filename) 
 print, strtrim(lines,1), " lines of data found in ", filename, "."
 nm = fltarr(lines)
 a_ = fltarr(lines)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
; READF, unit, str ; skip first line
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    
    strtok = STRSPLIT(str, STRING(9b), /EXTRACT)
    print, strtok[0]
    nm[count] = strtok[0]
    a_[count] = strtok[1]
         
    count = count + 1
 ENDWHILE    
 FREE_LUN, unit 

window,0
loadct, 0

print, nm, a_
print, ''
print, where(nm eq 300)
plot, nm[85:310], a_[85:310], /ylog;, yrange=[0.0,0.002]
print, nm(where(a_ eq min(a_[100:190])))

;DISPLAY THE VISIBLE SPECTRUM USING THE RAINBOW COLORTABLE
DEVICE, DECOMPOSED = 0
loadct,13   ;Rainbow color table
for i=0, 7 do begin
   oplot, [4.0E2 + i*0.375E2, 4.0E2 + i*0.375E2], $
          [0, 100], color=i*32
endfor







;--------------------------------------------------
rho = 1000
T = 293.15
L = 589



a = [$
      0.244257733d,    $   a0
      0.00974634476d,  $   a1
     -0.00373234996d,  $   a2
      0.000268678472d, $   a3
      0.0015892057d,   $   a4
      0.00245934259d,  $   a5
      0.90070492d,     $   a6
     -0.0166626219d    $   a7
    ]
;print, a, format='(d)'
T_ = 273.15
rho_ = 1000
L_ = 589
L_IR = 5.432937d

AA = a[0] + a[1] * (rho/rho_) + a[2] * (T/T_) $
   + a[3] * ((L/L_)^2) * (T/T_) + a[4]/((L/L_)^2) $
   + a[5]/(((L/L_)^2) - (0.229202)^2) $
   + a[6]/(((L/L_)^2) - (5.432937)^2) $
   + a[7] * ((rho/rho_)^2)

print, AA * (rho/rho_)

n = sqrt(3/(1-(AA * (rho/rho_))) -2)
print, n

print, L
print, L_

end