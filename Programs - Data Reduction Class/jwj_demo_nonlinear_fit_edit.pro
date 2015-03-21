pro gfunct, X, A, F, pder
	bx = EXP(A[1] * X)
	F = A[0] * bx + A[2]
	;If the procedure is called with four parameters, calculate the  	;partial derivatives.
	IF N_PARAMS() GE 4 THEN $
	pder = [[bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]]
END

function gfunct, X, A
	bx = EXP(A[1] * X)
	F = A[0] * bx + A[2]
	return,  [F, [bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]]
END

pro jwj_demo_nonlinear_fit_edit

;
; generate data with error bar
;

seed=systime(1,/second)

window, 0

x= findgen(101)*0.1 - (randomu(seed, 101)-0.5)*0.5  ; x: 0-10, but unevenly spaced
dy=abs(randomn(seed, 101))*2.0

a=3.0
b=2.0
c=3.0
d=0.0
e=0.0
f=0.0
g=0.0
h=0.0

y = a * exp(-1*((x-b)^2)/(c^2)) + dy*(randomu(seed,101)-0.5)*4.0
;FOR PART 2
y2 = a * exp(-1*((x-b)^2)/(c^2)) + d*x + e + dy*(randomu(seed,101)-0.5)*4.0
;FOR PART 3
y3 = a * exp(-1*((x-b)^2)/(c^2)) + d*x + e + f * exp(-1*((x-g)^2)/(h^2)) + dy*(randomu(seed,101)-0.5)*4.0


;
; plot data with error bar
;

t = FINDGEN(17) * (!PI*2/16.)

  USERSYM, COS(t)*0.8, SIN(t)*0.8, /FILL
; Plot data:
PLOT, X, Y, psym=8, symsize=0.5,  xrange=[-1, 11], title='Part 1';,/ylog, yrange=[0.1,10000]


; Overplot error bars:
ERRPLOT, X, Y-dy, Y+dy


weight=1/dy
;print, 'weights', weight

coef=[1.0, 2.0, 1.0]
result = CURVEFIT( X, Y, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='00FFFF'x


coef=[1.0, 3.0, 3.0]
result = CURVEFIT( X, Y, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FFFF00'x


coef=[1.0, 2.0, 1.0]
result = LMFIT( X, Y, coef, MEASURE_ERRORS=dy, sigma=sigma, FUNCTION_NAME='gfunct',/double)

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FF00FF'x





;PART 2
window,1
t = FINDGEN(17) * (!PI*2/16.)

  USERSYM, COS(t)*0.8, SIN(t)*0.8, /FILL
; Plot data:
PLOT, X, Y2, psym=8, symsize=0.5,  xrange=[-1, 11], title='Part 2';,/ylog, yrange=[0.1,10000]


; Overplot error bars:
ERRPLOT, X, Y2-dy, Y2+dy


weight=1/dy
;print, 'weights', weight

coef=[1.0, 2.0, 1.0]
result = CURVEFIT( X, Y2, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='00FFFF'x


coef=[1.0, 3.0, 3.0]
result = CURVEFIT( X, Y2, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FFFF00'x


coef=[1.0, 2.0, 1.0]
result = LMFIT( X, Y2, coef, MEASURE_ERRORS=dy, sigma=sigma, FUNCTION_NAME='gfunct',/double)

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FF00FF'x



;PART 3
window,2
t = FINDGEN(17) * (!PI*2/16.)

  USERSYM, COS(t)*0.8, SIN(t)*0.8, /FILL
; Plot data:
PLOT, X, Y3, psym=8, symsize=0.5,  xrange=[-1, 11], title='Part 3';,/ylog, yrange=[0.1,10000]


; Overplot error bars:
ERRPLOT, X, Y3-dy, Y3+dy


weight=1/dy
;print, 'weights', weight

coef=[1.0, 2.0, 1.0]
result = CURVEFIT( X, Y3, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='00FFFF'x


coef=[1.0, 3.0, 3.0]
result = CURVEFIT( X, Y3, Weight, coef, sigma, FUNCTION_NAME='gfunct')

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FFFF00'x


coef=[1.0, 2.0, 1.0]
result = LMFIT( X, Y3, coef, MEASURE_ERRORS=dy, sigma=sigma, FUNCTION_NAME='gfunct',/double)

print, coef
oplot, x, coef[0] * exp(coef[1]*x) + coef[2], color='FF00FF'x

end
