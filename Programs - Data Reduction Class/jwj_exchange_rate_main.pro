function request_data, title

 filename = dialog_pickfile(title=title)

 lines = file_lines(filename) 
 date = lonarr(lines-1)
 rate = dblarr(lines-1)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
 READF, unit, str ; skip first line
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    
    strA = strsplit(str, ',', /EXTRACT)
    
    if size(strA,/N_ELEMENTS) gt 12 then begin
      month = fix(strmid(strA[0],4,2))
      day = fix(strmid(strA[0],6,2))
      year = strmid(strA[0],0,4)
      date[count] = julday(month,day,year)
      rate[count] = double(strA[size(strA,/N_ELEMENTS)-9])
         
      count = count + 1
    end
 ENDWHILE    
 FREE_LUN, unit 

 data = {  $
    date:date, $
    rate:rate  $
 }
 return, data
end


pro JWJ_exchange_rate_main

;filename = 'C:\Users\rs59\gauss_data.txt'
 feb18data = request_data('Select exchange rate csv file ending on 2011/02/18')
 mar23data = request_data('Select exchange rate csv file ending on 2011/03/23')


;PLOT DATA
 print,''
 !P.background = 'FFFFFF'x
 !P.COLOR = '000000'x 
 offset = max(feb18data.date)
 
 plot, feb18data.date, feb18data.rate, $
       yrange=[min(feb18data.rate),max(feb18data.rate)], xrange=[min(feb18data.date)-max(feb18data.date), $
       max(mar23data.date-max(feb18data.date))], /NODATA, ystyle=9, $
       ytitle='TWD/USD$1', xtitle='day 0 is Feb 18, 2011'
 oplot, feb18data.date-max(feb18data.date), feb18data.rate, psym=4
 oplot, mar23data.date-max(feb18data.date), mar23data.rate, psym=1
 
 x = reverse(feb18data.date-offset)
 y = reverse(feb18data.rate)
 y2 = SPL_INIT(x, y)
 x2 = findgen(max(mar23data.date)-min(feb18data.date))+min(feb18data.date)-max(feb18data.date)
 yfit = SPL_INTERP(x, y, y2, x2)
 
 oplot, x2, yfit, linestyle=0, color='FF0000'x, thick=1
 txt = 'Day 1 estimate = $' + string(strtrim(yfit[where(x2 eq 1)],1))
 XYOUTS, 620, 140, txt, color='FF0000'x, /device
 txt = 'Day 3 estimate = $' + string(strtrim(yfit[where(x2 eq 3)],1))
 XYOUTS, 620, 100, txt, color='FF0000'x, /device
 
 
 x = reverse([mar23data.date,feb18data.date]-offset)
 y = reverse([mar23data.rate,feb18data.rate])
 y2 = SPL_INIT(x, y)
 x2 = findgen(max(mar23data.date)-min(feb18data.date))+min(feb18data.date)-max(feb18data.date)
 yfit = SPL_INTERP(x, y, y2, x2)
 
 oplot, x2, yfit, linestyle=2, color='0000FF'x, thick=3
 txt = 'Day 1 interpolated = $' + string(strtrim(yfit[where(x2 eq 1)],1))
 XYOUTS, 620, 120, txt, color='0000FF'x, /device
 txt = 'Day 3 interpolated = $' + string(strtrim(yfit[where(x2 eq 3)],1))
 XYOUTS, 620, 80, txt, color='0000FF'x, /device
 
 print, 'The result looks accurate because before the 19th there is an upward trend with a dip at the end.', $
        'There is a reasonable expectation that the rate will continue to increase after the dip.', $
        'This extrapolation method can not be use for future events more than a couple days because', $
        'the curve would rise or descend rapidly.'
end