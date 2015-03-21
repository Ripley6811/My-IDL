;TEMPLATE : LOADING DATA FROM ASCII FILE

function request_data, title

 filename = dialog_pickfile(title=title)

 lines = file_lines(filename) 
 print, strtrim(lines,1), " lines of data found in ", filename, "."
 x = fltarr(lines)
 y = fltarr(lines)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
; READF, unit, str ; skip first line
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    
    x[count] = strmid(str[0],0,7)  ;strmid(input string, start index, read how many char)
    y[count] = strmid(str[0],7)    ;Leaving out last number reads to end of line
         
    count = count + 1
 ENDWHILE    
 FREE_LUN, unit 

 data = {  $
    x:x, $
    y:y  $
 }
 return, data
end

Method 1:
IDL> data=fltarr(2,5) ; create the data array
IDL> openr,lun,'in_array.dat',/get_lun ; open the data file
IDL> readf,lun,data ; read data from the file
IDL> close,/all ; close the data file
IDL> help,data ; check the data array
DATA FLOAT = Array[2, 5]
IDL> print,data
1.00000 5.00000
2.00000 6.00000
3.00000 7.00000
4.00000 8.00000
5.00000 9.00000
IDL> x=reform(data(0,*)) ; separate the columns
IDL> y=reform(data(1,*))
IDL> print,x
1.00000 2.00000 3.00000 4.00000 5.00000
IDL> print,y
5.00000 6.00000 7.00000 8.00000 9.00000

Method 2:
IDL> x=fltarr(5) ; create the x data array
IDL> y=fltarr(5) ; create the y data array
IDL> openr,lun,'in_array.dat',/get_lun ; open the data file
IDL> .run ; execute a group of control statement
- for j=0,4 do begin ;start of the loop
- readf,lun,tmp1,tmp2 ; read the j-th row
- x(j)=tmp1 ; put the data into the x array
- y(j)=tmp2 ; put the data into the y array
- endfor ; end of the for loop
- end ; end of the control group
% Compiled module: $MAIN$.
IDL> print,x
1.00000 2.00000 3.00000 4.00000 5.00000
IDL> print,y
5.00000 6.00000 7.00000 8.00000 9.00000