
PRO gfunct, X, A, F, pder 
  bx = EXP(A[1] * X) 
  F = A[0] * bx + A[2] 
 
;If the procedure is called with four parameters, calculate the 
;partial derivatives. 
  IF N_PARAMS() GE 4 THEN $ 
    pder = [[bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]] 
END 

pro calculateRectification, HEIGHT=height

height = 2.0D ; height of camera above ground
angInt = 0.1D ; vertical degree interval from camera
maxAng = 89.0D ; 0 = straight down, 90 = straight ahead horizon
downAng = 90.0D ; starting angle at ground

degs = findgen(maxAng/angInt) * angInt
y = dblarr(fix(maxAng/angInt))
x = y
y[0] = height

for i=1, N_ELEMENTS(y)-1 do begin
  y[i] = y[i-1] * sin(!DTOR * downAng) / sin(!DTOR * (180-angInt-downAng))
;  print, y[i], downAng
  downAng += angInt
end 

downAng = 90.0
for i=0, N_ELEMENTS(x)-1 do begin
  x[i] = y[i] * sin(!DTOR * angInt) / sin(!DTOR * (180-angInt-downAng))
  downAng += angInt
end 

print, y
print, 'hello'
print, x


plot, degs, x, /ylog
weights = 1.0/x

;A = [0.00001, 1.0, 0.3]

yfit = gaussfit(degs, x, coeff, SIGMA=sigma, NTERMS=3)
wait, 2
;print, yfit
print, coeff
oplot, degs, yfit
;oplot, degs, A[0] * exp(A[1]*degs) + A[2]
;oplot, degs, 0.00001 * exp(0.1 * degs) + 0.003


end