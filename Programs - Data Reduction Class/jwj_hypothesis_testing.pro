pro JWJ_hypothesis_testing
!P.background = 'FFFFFF'x
!P.COLOR = '000000'x 

data = [  $
[173, 155],$
[175, 171],$
[166, 163],$
[167, 155],$
[178, 159],$
[166, 159],$
[169, 154],$
[160, 153],$
[175, 170],$
[175, 152],$
[168, 164],$
[170, 157],$
[168, 160],$
[171, 158],$
[164, 155],$
[178, 163],$
[168, 160],$
[172, 160],$
[173, 158],$
[175, 163],$
[175, 168],$
[179, 162],$
[170, 164],$
[168, 157],$
[182, 160]]
H_m = intarr(N_ELEMENTS(data[0,*]))
H_f = intarr(N_ELEMENTS(data[0,*]))
H_m[*] = data[0,*]
H_f[*] = data[1,*]

print, ''
print, 'Null hypothesis: The average height of females in Tainan is less'
print, ' than the average male height.'
print, 'Alternate hypothesis: The mean of female height is not significantly'
print, ' different from that of men.'
print, 'Male mean  : ', strtrim(mean(H_m),1), '  SD: ', strtrim(stddev(H_m),1)
print, 'Female mean: ', strtrim(mean(H_f),1), '  SD: ', strtrim(stddev(H_f),1)
print, ' male mean - 2*SD = ', strtrim(mean(H_m)-2*stddev(H_m),1)
print, ' female mean + 2*SD = ', strtrim(mean(H_f)+2*stddev(H_f),1)
print, 'The two means are a little more than two standard deviations from eachother.'
print, 'The two means do not fall within the 95% normal distribution for each mean'
print, ' and therefore the null hypothesis is not rejected;'
print, ' Means are significantly different.'

print, ''
print, 'T-test of means'
print, 't value: ', strtrim((TM_TEST(H_m, H_f))[0],1)
print, 't cutoff 5%: ', strtrim(T_CVF(0.05, N_ELEMENTS(H_m)+N_ELEMENTS(H_f)-2),2)
print, 't cutoff 0.1%: ', strtrim(T_CVF(0.001, N_ELEMENTS(H_m)+N_ELEMENTS(H_f)-2),2)
print, 't cutoff 0.01%: ', strtrim(T_CVF(0.0001d, N_ELEMENTS(H_m)+N_ELEMENTS(H_f)-2),2)
print, 'The t value is far above the cutoffs and therefore the difference'
print, ' in means is very significant.'



end