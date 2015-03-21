PRO EX_DRAW 
   ; Start with a blank screen: 
   ERASE 
   ; Get the initial point in normalized coordinates: 
   CURSOR, X, Y, /DEVICE, /CHANGE
   
   ; Repeat until right button is pressed. Get the second point. 
   ; Draw the line. Make the current second point be the new first. 
   WHILE (!MOUSE.button NE 4) DO BEGIN 
      CURSOR, X1, Y1, /device, /change
      PLOTS,[X,X1], [Y,Y1], /NORMAL 
      X = X1 & Y = Y1 
   ENDWHILE 
   
   
   
   
   print, 'END OF LINE'
END 
