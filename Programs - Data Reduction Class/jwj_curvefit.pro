PRO gfunct, X, A, F, pder 
  bx = EXP(A[1] * X) 
  F = A[0] * bx + A[2] 

  IF N_PARAMS() GE 4 THEN $ 
    pder = [[bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]] 
END

;    F(x)     = A[0] * exp( A[1] * X) + A[2]
;    dF/dA(0) = EXP( A[1] * x )
;    dF/dA(1) = A[0] * x * exp( A[1] * x )
;    dF/dA(2) = 1.0
FUNCTION myfunct, X, A 
   bx = A[0]*EXP(A[1]*X) 
   RETURN,[ [A[0] * exp( A[1] * X) + A[2]], [EXP( A[1] * X)], $
             [A[0] * x * exp( A[1] * x )], [1.0] ] 
END 


pro JWJ_curvefit
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 

xy = [ $
[ 0.1d,      3.172d], $
[ 0.3d,      1.407d], $
[ 0.5d,      0.312d], $
[ 1.0d,      1.140d], $
[ 3.0d,     72.496d], $
[ 4.0d,     11.049d], $
[ 5.0d,     10.015d], $
[ 8.0d,    170.787d], $
[10.0d,    331.357d], $
[13.0d,    632.760d], $
[15.0d,   1506.023d], $
[18.0d,   1551.933d], $
[20.0d,   1044.895d]]
x = dblarr(13)
y = dblarr(13)
w = dblarr(13)
w[*] = 1.0/xy[1,*] 
x[*] = xy[0,*]
y[*] = xy[1,*]

;print, xy[1,*], format='(d)'
seed = systime(1)

window, 0, title='HW6.1'
plot, x, y, xrange=[-10,30], yrange=[-400,2000], xstyle=1, ystyle=1, psym=2;, /ylog


;TEST LINFIT on ALOG(Y)
coef = linfit(x, alog(y), sigma=sig, yfit=yfit)
x_ = (findgen(400)/10) - 10
;oplot, x, exp(yfit), color='00FF00'x, linestyle=2;  GREEN
oplot, x_, exp(coef[0] + coef[1] * x_), color='00FF00'x, thick=2
oplot, x_, exp((coef[0]+1.7) + (coef[1]+0.05268) * x_), color='00FF00'x, thick=1, linestyle=2
oplot, x_, exp((coef[0]-1.7) + (coef[1]-0.05268) * x_), color='00FF00'x, thick=1, linestyle=2
print, 'Line fit coefficients:'
print, 'a=', coef[0], " (", strtrim(sig[0],1), ")"
print, 'b=', coef[1], " (", strtrim(sig[1],1), ")"
XYOUTS, 15, -100, 'Linfit on alog(y) result', color='00FF00'x
linsig = sig


;TEST LMFIT
coef = [10.0,0.3,10.0]
yfit = lmfit(xy[0,*], xy[1,*], coef, sigma=sig, /double, function_name='myfunct')
print, 'LM fit coefficients:'
print, 'a=', coef[0], " (", strtrim(sig[0],1), ")"
print, 'b=', coef[1], " (", strtrim(sig[1],1), ")"
print, 'c=', coef[2], " (", strtrim(sig[2],1), ")"

;oplot, xy[0,*], yfit, color='0000FF'x, linestyle=2; RED
oplot, x_, coef[0] * exp(coef[1] * x_) + coef[2], color='0000FF'x, thick=2
XYOUTS, 15, -170, 'LMfit result', color='0000FF'x




;TEST CURVEFIT
coef = [10.0,0.3,10.0]
yfit = curvefit(x, y, w, coef, sig, FUNCTION_NAME='gfunct')
print, 'Curvefit coefficients:'
print, 'a=', coef[0], " (", strtrim(sig[0],1), ")"
print, 'b=', coef[1], " (", strtrim(sig[1],1), ")"
print, 'c=', coef[2], " (", strtrim(sig[2],1), ")"

;oplot, xy[0,*], yfit, color='FF0000'x, linestyle=2; BLUE
oplot, x_, (coef[0]) * exp(coef[1] * x_) + coef[2], color='FF0000'x, thick=2
oplot, x_, (coef[0]+2.58) * exp((coef[1]+0.00386) * x_) + coef[2], color='FF0000'x, thick=1, linestyle=2
oplot, x_, (coef[0]-2.58) * exp((coef[1]-0.00386) * x_) + coef[2], color='FF0000'x, thick=1, linestyle=2
XYOUTS, 15, -240, 'Curvefit result', color='FF0000'x
curvsig = sig


;TEST COMFIT
coef = [10.0,0.3,10.0]
coef = comfit(x, y, coef, sigma=sig, /geometric, yfit=yfit)
print, 'Comfit coefficients:'
print, 'a=', coef[0], " (", strtrim(sig[0],1), ")"
print, 'b=', coef[1], " (", strtrim(sig[1],1), ")"
print, 'c=', coef[2], " (", strtrim(sig[2],1), ")"

;oplot, xy[0,*], yfit, color='FFFF00'x, linestyle=2; CYAN
oplot, x_, coef[0] * (x_^coef[1]) + coef[2], color='FFFF00'x, thick=2
XYOUTS, 15, -310, 'Comfit result', color='FFFF00'x


print, 'When looking at the ylog graph, the data does not appear to be logarithmic.'
print, 'So I would not trust the linfit line.  The curvefit line appears to be the'
print, 'best fit, but there is not enough data to be sure in any case.  More data'
print, 'is needed or at least more information about the error of each pair.'
print, ''
print, 'linfit equation   -> e^(A + Bx) = e^(A) * e^(Bx)'
print, 'curvefit equation -> A e^(Bx) + C
print, "  The error in B can be directly compared."
print, "  The linfit's e^(A) can be compared to curvefit's A."
print, '                linfit         curvefit' 
print, 'A stddev = ', exp(linsig[0]), (curvsig[0])
print, 'B stddev = ', linsig[1], curvsig[1]
print, ''
print, 'B is more influential and this error is smaller in the'
print, 'curvefit result, supporting my view that curvefit is more appropriate.'
print, 'You can also see in the graph that when the error is added back in'
print, 'to the equations, the linfit error (dashed lines) spans a larger area'
print, 'than the curvefit error.'


end