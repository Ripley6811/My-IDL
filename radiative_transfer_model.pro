;***************************************************************************/
;  A radiative transfer model based on the Monte-Carlo approach            */
;  This code was originally developed for verifying the Monte-Carlo model  */
;  Detailed description of the problem can be referred to (Mobley 1994)    */
;  This code is rewritten to demonstrate the concept of Monte-Carlo method */
;                                                    Dr. Cheng-Chien Liu   */
;                Depart of Earth Sciences, National Cheng-Kung University  */
;                                                       10 November 2006   */
;***************************************************************************/
;  Model 1: Albedo = 0.9;                                                  */
;           Z_Height = 60.0;                                               */
;           SunLight = 1.0;                                                */
;           BDepth = 100.0;                                                */
;           NPhoton = 60000000.0;                                          */
;           ViewAng1 =   0.0;                                              */
;           ViewAng2 = 180.0;                                              */
;           Coeff_C = 1.0;                                                 */
;  Output : Depth0 = 0 m;           (air)                                  */
;           Depth1 = 0 m;           (water)                                */
;           Depth2 = 1.0 m;                                                */
;           Depth3 = 5.0 m;                                                */
;           Depth4 = 20.0 m;                                               */
;***************************************************************************/


;***************************************************************************/
function randm, data   ;  return random number in range [0.0, 1.0]  */
   data.seed = data.seed +1
   return, randomu(data.seed)
end
;***************************************************************************/
pro Setup, data
;print, '>Setup'
  sum = 0.0;

  data.AdivC = 1.0 - data.Albedo;
  data.cf = data.SunLight / data.NPhoton;
  data.DAng = !dpi / data.I_ZenAng;
  data.QuadArea = data.DAng^2;

  data.DInterval = data.BDepth / (data.N_Layers-2);
  data.I_Depth3 = 1 + fix( 5.0*data.Coeff_C/data.DInterval);
  data.I_Depth4 = 1 + fix(20.0*data.Coeff_C/data.DInterval);
  data.ViewAng1B = data.ViewAng1 + 0.5*data.DAng;
  data.ViewAng1S = 2.0 * !dpi - 0.5*data.DAng;
  data.ViewAng2B = data.ViewAng2 + 0.5*data.DAng;
  data.ViewAng2S = data.ViewAng2 - 0.5*data.DAng;

  for j=0, data.N_ScaAng-1 do data.Beta_Scat[j] = data.Beta_P[j];
  data.Beta_Scat[0] = 2.0 * !dpi * sin(data.SPAng[0]) * data.Beta_Scat[0] * data.SPAng[0];
  for j=1, data.N_ScaAng-1 do $
    data.Beta_Scat[j] = 2.0 * !dpi * sin(data.SPAng[j]) * data.Beta_Scat[j] *(data.SPAng[j]-data.SPAng[j-1]);
  for j=0, data.N_ScaAng-1 do sum += data.Beta_Scat[j];
  for j=0, data.N_ScaAng-1 do data.Beta_Scat[j] = data.Beta_Scat[j]/sum;
  for j=1, data.N_ScaAng-1 do data.Beta_Scat[j] += data.Beta_Scat[j-1];
end
;***************************************************************************/
pro RecordRad, II, JJ, data
;print, '>RecordRad'
  ISS = fix(data.ThetaP / data.DAng);
  DSS = (ISS + 0.5) * data.DAng;
;  print, abs( 1.0 / (2.0 * sin(DSS) * cos(DSS) * data.QuadArea) ), data.ThetaP, data.DAng
  data.rad[II,ISS,JJ] += abs( 1.0 / (2.0 * sin(DSS) * cos(DSS) * data.QuadArea) );
end
;***************************************************************************/
pro RTF2XYZ, RR, data, PP
;print, '>RTF2XYZ'
  PP[0] = RR*cos(data.ThetaP);
  PP[1] = RR*sin(data.ThetaP)*cos(data.AzimP);
  PP[2] = RR*sin(data.ThetaP)*sin(data.AzimP);
end
;***************************************************************************/
pro New_Photon, data
;print, '>New_Photon'
  data.I_scattering=0;
  data.ThetaP = data.Z_Height;
  data.AzimP  = !dpi;
  RecordRad, 0, 1, data
  RTF2XYZ, 1.0, data, data.p
  for i=0, data.XYZ-1 do data.Pt[i] = -5.0 * data.p[i];
  data.zbeg = 0;
  for i=0, data.XYZ-1 do data.Pt[i] = 0.0;
  data.zbeg = 0;
  Psi = data.ThetaP;
  PsiOut = asin( sin(Psi) * 1.0 / 1.34 );
  sum = Psi + PsiOut;
  dif = Psi - PsiOut;
  data.prefl = 0.5 * ( (sin(dif)^2)/(sin(sum)^2) + $
                  (tan(dif)^2)/(tan(sum)^2) );
  data.pdotf = data.p[1]*data.f[1] + data.p[2]*data.f[2] + data.p[0]*data.f[0];
  if randm( data ) le data.prefl then begin
    data.I_enter = 0;
    for i=0, data.XYZ-1 do data.p[i] += -2.0*data.pdotf*data.f[i];
    data.ThetaP = acos(data.p[0]);
    if data.ThetaP lt 0.0 then data.ThetaP += !dpi;
    data.AzimP  = atan(data.p[2]/data.p[1]);
    if data.p[1] le 0.0 then data.AzimP += !dpi else if data.AzimP lt 0.0 then data.AzimP += 2.0*!dpi
    if data.AzimP le data.ViewAng1B  or data.AzimP gt data.ViewAng1S then RecordRad, 0, 0, data
    if data.AzimP le data.ViewAng2B and data.AzimP gt data.ViewAng2S then RecordRad, 0, 1, data

    for i=0, data.XYZ-1 do data.Pt[i] = 5.0 * data.p[i];
  end else begin
    data.I_enter = 1;
    c = data.pdotf + sqrt( data.pdotf^2 + 1.34^2 - 1.0 );
    for i=0, data.XYZ-1 do data.p[i] = (data.p[i]-c*data.f[i]) / 1.34;

    psize  = sqrt( data.p[1]^2 + data.p[2]^2 + data.p[0]^2 );
    for i=0, data.XYZ-1 do data.p[i] = data.p[i] / psize;

    data.ThetaP = acos(data.p[0]);
    if (data.ThetaP lt 0.0) then data.ThetaP += !dpi;
    data.AzimP  = atan(data.p[2]/data.p[1]);
    if data.p[1] le 0.0 then data.AzimP += !dpi $
      else if data.AzimP lt 0.0 then data.AzimP += 2.0*!dpi
    if (data.AzimP le data.ViewAng1B or data.AzimP gt data.ViewAng1S) then RecordRad, 1, 0, data
    if (data.AzimP le data.ViewAng2B and data.AzimP gt data.ViewAng2S) then RecordRad, 1, 1, data
    data.zbeg = 1;
  endelse
;  print, data.ThetaP
end
;***************************************************************************/
pro Absorb, data
;print, '>Absorb'
  if randm(data) le data.AdivC then data.I_scattering=0 $
  else data.I_scattering=1
end
;***************************************************************************/
pro Trace_Up, data
;print, '>Trace_Up'
  cont = 1
  check = -1.0 * alog(1.0-randm(data));
  dl = abs( data.DInterval / cos(data.ThetaP) );
  data.zbeg = 1 + fix(data.Pt[0]/data.DInterval);
  sum_dl = abs( (data.Pt[0] - data.DInterval * (double(data.zbeg-1))) / cos(data.ThetaP) );
  sum_C_dl = data.Coeff_C * sum_dl;
  for i=data.zbeg, 1, -1 do begin
    if sum_C_dl gt check then begin
      path = check / data.Coeff_C;
      RTF2XYZ, path, data, data.Pt_add
      for  j=0, data.XYZ-1 do data.Pt[j] += data.Pt_add[j];
      Absorb, data
      cont = 0
      break   ; problem?
    end
    sum_dl += dl;
    sum_C_dl += data.Coeff_C *dl;
    if data.AzimP le data.ViewAng1B or data.AzimP gt data.ViewAng1S then begin
      if (i eq data.I_Depth1) then RecordRad, 1, 0, data
      if (i eq data.I_Depth2) then RecordRad, 2, 0, data
      if (i eq data.I_Depth3) then RecordRad, 3, 0, data
      if (i eq data.I_Depth4) then RecordRad, 4, 0, data
    end
    if data.AzimP lt data.ViewAng2B and data.AzimP gt data.ViewAng2S then begin
      if (i eq data.I_Depth1) then RecordRad, 1, 1, data
      if (i eq data.I_Depth2) then RecordRad, 2, 1, data
      if (i eq data.I_Depth3) then RecordRad, 3, 1, data
      if (i eq data.I_Depth4) then RecordRad, 4, 1, data
    end
  end
  if cont then Air_Sea_Up, data
end
;***************************************************************************/
pro Trace_Down, data
;print, '>Trace_Down' 
  cont = 1
  check = -1.0 * alog( 1.0 - randm(data) );
  dl = abs( data.DInterval / cos(data.ThetaP) );
  data.zbeg = 2 + fix(data.Pt[0]/data.DInterval);
  sum_dl = abs( (data.Pt[0] - data.DInterval * (double(data.zbeg-1))) / cos(data.ThetaP) );
  sum_C_dl = data.Coeff_C * sum_dl;
  for i=data.zbeg, data.N_Layers do begin
;  print, data.zbeg, data.N_Layers, i
    if (sum_C_dl gt check) then begin
      path = check / data.Coeff_C;
      RTF2XYZ, path, data, data.Pt_add
      for j=0, data.XYZ-1 do data.Pt[j] +=data.Pt_add[j];
      Absorb, data
      cont = 0
      break   ; problem?
    end
    sum_dl += dl;
    sum_C_dl += data.Coeff_C *dl;
    if (data.AzimP le data.ViewAng1B or data.AzimP gt data.ViewAng1S) then begin
      if (i eq data.I_Depth2) then RecordRad, 2, 0, data
      if (i eq data.I_Depth3) then RecordRad, 3, 0, data
      if (i eq data.I_Depth4) then RecordRad, 4, 0, data
    end
    if (data.AzimP le data.ViewAng2B and data.AzimP gt data.ViewAng2S) then begin
      if (i eq data.I_Depth2) then RecordRad, 2, 1, data
      if (i eq data.I_Depth3) then RecordRad, 3, 1, data
      if (i eq data.I_Depth4) then RecordRad, 4, 1, data
    end
  end
  if cont then begin
     path = sum_dl;
     RTF2XYZ, path, data, data.Pt_add
     for  i=0, data.XYZ-1 do data.Pt[i] +=data.Pt_add[i];
     data.I_scattering=0;
  end
;print, 'exit Trace_down'
end
;***************************************************************************/
pro Air_Sea_Up, data
;print, '>Air_Sea_Up'
  path = -1.0 * data.Pt[0] / cos(data.ThetaP);
  RTF2XYZ, path, data, data.Pt_add
  for  i=0, data.XYZ-1 do data.Pt[i] +=data.Pt_add[i];
  data.zbeg = 1;
  data.pdotf = data.p[1]*data.f[1] + data.p[2]*data.f[2] + data.p[0]*data.f[0];
  Psi = abs( acos(data.pdotf) );
  PsiTotal = asin( 1.0/1.34 );
  if Psi eq 0.0 then data.prefl = 0.0211 $
   else begin
    if Psi ge PsiTotal then data.prefl = 1.0 $
     else begin
      PsiOut = asin( sin(Psi) * 1.34 / 1.0 );
      sum = Psi + PsiOut;
      dif = Psi - PsiOut;
      data.prefl = 0.5 * ( sin(dif)*sin(dif)/sin(sum)/sin(sum) + $
                      tan(dif)*tan(dif)/tan(sum)/tan(sum) );
    endelse
  endelse
  if ( randm(data) le data.prefl) then begin
    for i=0, data.XYZ-1 do data.p[i] += -2.0*data.pdotf*data.f[i];
    data.ThetaP = acos(data.p[0]);
    if (data.ThetaP lt 0.0) then data.ThetaP += !dpi;
    data.AzimP  = atan(data.p[2]/data.p[1]);
    if (data.p[1] le 0.0) then data.AzimP += !dpi $
     else if (data.AzimP lt 0.0) then data.AzimP += 2.0*!dpi
    if (data.AzimP le data.ViewAng1B or data.AzimP gt data.ViewAng1S) then RecordRad, 1, 0, data
    if (data.AzimP le data.ViewAng2B and data.AzimP gt data.ViewAng2S) then RecordRad, 1, 1, data
    Trace_Down, data
  end else begin
    data.I_scattering = 0;
    c = 1.34*data.pdotf - sqrt( 1.34*1.34*data.pdotf^2 - 1.34*1.34 + 1.0 );
    for i=0, data.XYZ-1 do data.p[i] = 1.34 * data.p[i] - c * data.f[i];

    psize  = sqrt( data.p[1]^2 + data.p[2]^2 + data.p[0]^2 );
    for i=0, data.XYZ-1 do data.p[i] = data.p[i] / psize;

    data.ThetaP = acos(data.p[0]);
    if data.ThetaP lt 0.0 then data.ThetaP += !dpi;
    data.AzimP  = atan(data.p[2]/data.p[1]);
    if data.p[1] le 0.0 then data.AzimP += !dpi $
     else if data.AzimP lt 0.0 then data.AzimP += 2.0*!dpi
    if data.AzimP le data.ViewAng1B or data.AzimP gt data.ViewAng1S then RecordRad, 0, 0, data
    if data.AzimP le data.ViewAng2B and data.AzimP gt data.ViewAng2S then RecordRad, 0, 1, data
    for i=0, data.XYZ-1 do data.Pt[i] = 5.0 * data.p[i];
  endelse
end
;***************************************************************************/
pro Scattering, data
;print, '>Scattering'
  h = dblarr(3)
  v = dblarr(3) 
  q = dblarr(3);

  r1 = randm(data);
  i = -1;
  repeat i++ until r1 le data.Beta_Scat[i]
  a2 = data.SPAng[i];
  if (i eq 0) then a1 = 0.0 $
    else a1 = data.SPAng[i-1];
  psis = a1 + randm(data) * (a2 - a1);
  AzimS = randm(data) * 2.0*!dpi; ; Azimuthal angle "s" of trajectory change due to scattering */
  if data.p[2] ne 0.0 then begin
    h[1] = sqrt( 1.0 / (1.0 + (data.p[1]^2) / (data.p[2]^2)) );
    h[2] = -1.0 * h[1] * data.p[1] / data.p[2];
  end else begin
    h[1] = 0.0;
    h[2] = 1.0;
  endelse
  h[0] = 0.0;
  if data.p[0] eq 0.0 then begin
    v[1] = 0.0;
    v[2] = 0.0;
    v[0] = -1.0;
  end else begin
    if h[2] eq 0.0 then begin
      v[1] = 0.0;
      v[2] = -1.0 * data.p[0];
      v[0] = data.p[2];
    end else begin
       aaa = h[2]*h[2]*data.p[0]^2 + h[1]*h[1]*data.p[0]^2 + $
             h[2]*h[2]*data.p[1]^2 + h[1]*h[1]*data.p[2]^2 - $
             2.0*h[1]*h[2]*data.p[1]*data.p[2];
       v[1] = sqrt( h[2]*h[2]*data.p[0]^2 / aaa );
       v[2] = - v[1] * h[1] / h[2];
       v[0] = v[1] * (data.p[2]*h[1]-(data.p[1]*h[2])) / (h[2]*data.p[0]);
    end
  end
  for i=0, data.XYZ-1 do q[i] = h[i] * cos(AzimS) + v[i] * sin(AzimS);
  for i=0, data.XYZ-1 do data.p[i] = data.p[i] * cos(psis) + q[i] * sin(psis);

  data.ThetaP = acos(data.p[0]);
  if data.ThetaP lt 0.0 then data.ThetaP += !dpi;
  data.AzimP  = atan(data.p[2]/data.p[1]);
  if data.p[1] le 0.0 then data.AzimP += !dpi $
    else if data.AzimP lt 0.0 then data.AzimP += 2.0*!dpi;
end
;***************************************************************************/
pro Output, data
print, '>Output'
  openw, 2, 'radiance_6000000p.txt'
  printf, 2, format='(d,d,d,d,d,d)', double(data.I_ZenAng)*data.DAng*180/!dpi, $
     (data.rad[0,data.I_ZenAng-1,1]+0.5*(data.rad[0,data.I_ZenAng-1,1]-data.rad[0,data.I_ZenAng-2,1]))*data.cf, $
     (data.rad[1,data.I_ZenAng-1,1]+0.5*(data.rad[1,data.I_ZenAng-1,1]-data.rad[1,data.I_ZenAng-2,1]))*data.cf, $
     (data.rad[2,data.I_ZenAng-1,1]+0.5*(data.rad[2,data.I_ZenAng-1,1]-data.rad[2,data.I_ZenAng-2,1]))*data.cf, $
     (data.rad[3,data.I_ZenAng-1,1]+0.5*(data.rad[3,data.I_ZenAng-1,1]-data.rad[3,data.I_ZenAng-2,1]))*data.cf, $
     (data.rad[4,data.I_ZenAng-1,1]+0.5*(data.rad[4,data.I_ZenAng-1,1]-data.rad[4,data.I_ZenAng-2,1]))*data.cf
  for i=data.I_ZenAng-1, 0, -1 do begin
    printf, 2, format='(d,d,d,d,d,d)', double(i+0.5)*data.DAng*180/!dpi, $
    data.rad[0,i,1]*data.cf,data.rad[1,i,1]*data.cf,data.rad[2,i,1]*data.cf,data.rad[3,i,1]*data.cf,data.rad[4,i,1]*data.cf
  end
  for i=0, data.I_ZenAng-1 do begin
    printf, 2, format='(d,d,d,d,d,d)', (-1.0)*(i+0.5)*data.DAng*180/!dpi, $
    data.rad[0,i,0]*data.cf,data.rad[1,i,0]*data.cf,data.rad[2,i,0]*data.cf,data.rad[3,i,0]*data.cf,data.rad[4,i,0]*data.cf
  end
  printf, 2, format='(d,d,d,d,d,d)', (-1.0)*(data.I_ZenAng)*data.DAng*180/!dpi, $
     (data.rad[0,data.I_ZenAng-1,0]+0.5*(data.rad[0,data.I_ZenAng-1,0]-data.rad[0,data.I_ZenAng-2,0]))*data.cf, $
     (data.rad[1,data.I_ZenAng-1,0]+0.5*(data.rad[1,data.I_ZenAng-1,0]-data.rad[1,data.I_ZenAng-2,0]))*data.cf, $
     (data.rad[2,data.I_ZenAng-1,0]+0.5*(data.rad[2,data.I_ZenAng-1,0]-data.rad[2,data.I_ZenAng-2,0]))*data.cf, $
     (data.rad[3,data.I_ZenAng-1,0]+0.5*(data.rad[3,data.I_ZenAng-1,0]-data.rad[3,data.I_ZenAng-2,0]))*data.cf, $
     (data.rad[4,data.I_ZenAng-1,0]+0.5*(data.rad[4,data.I_ZenAng-1,0]-data.rad[4,data.I_ZenAng-2,0]))*data.cf
  close, 2
end
;***************************************************************************/
pro Result, data
print, '>Result'
  openw, 1, 'radiative_output.txt'
  printf, 1,"Total No. of photons in simulation = ", strtrim(long(data.NPhoton), 1)
  printf, 1,"The interval depth between layers =  ", strtrim(data.DInterval, 1)
  printf, 1,"Total No. of layers in depth =       ", strtrim(data.N_Layers-1, 1)
  printf, 1,"Total No. of intervals in circle =   ", strtrim(data.I_AziAng, 1)
  printf, 1,"Total No. of Wave Bands =            ", strtrim(data.N_WavBan, 1)
  printf, 1,"Solar zenith angle (to vertical) =   ", strtrim(data.Z_Height*180/!dpi, 1)
  printf, 1,"Surface Light Intensity (DW Irr) =   ", strtrim(data.SunLight, 1)
  close, 1
end
;***************************************************************************/
pro radiative_transfer_model
seed     = systime(1)/2      ;This will be incremented each time a call to randm() is made
I_ZenAng = 20
N_ScaAng = 55
XYZ      = 3

Beta_P = [1767.0, 1296.0, 950.2, 699.1, 514.0, 376.4, 276.3, 218.8, 144.4, 102.2, $
         71.61, 49.58, 33.95, 22.81, 15.16, 10.02, 6.580, 4.295, 2.807, 1.819, $
         1.153, 0.4893, 0.2444, 0.1472, 0.08609, 0.05931, 0.04210, 0.03067, 0.02275, 0.01699, $
         0.01313, 0.01046, 0.008488, 0.006976, 0.005842, 0.004953, 0.004292, 0.003782, 0.003404, 0.003116, $
         0.002912, 0.002797, 0.002686, 0.002571, 0.002476, 0.002377, 0.002329, 0.002313, 0.002365, 0.002506, $
         0.002662, 0.002835, 0.003031, 0.003092, 0.003154];
SPAng = [0.100, 0.126, 0.158, 0.200, 0.251, 0.316, 0.398, 0.501, 0.631, 0.794, $
         1.000, 1.259, 1.585, 1.995, 2.512, 3.162, 3.981, 5.012, 6.310, 7.943, $
         10.0,  15.0,  20.0,  25.0,  30.0,  35.0,  40.0,  45.0,  50.0,  55.0, $
         60.0,  65.0,  70.0,  75.0,  80.0,  85.0,  90.0,  95.0,  100.0, 105.0, $
         110.0, 115.0, 120.0, 125.0, 130.0, 135.0, 140.0, 145.0, 150.0, 155.0, $
         160.0, 165.0, 170.0, 175.0, 180.0];

data = { $
   seed:seed,               $!! Set value above
   XYZ:XYZ,                 $!! Set value above
   I_ZenAng:I_ZenAng,       $!! Set value above
   N_ScaAng:N_ScaAng,       $!! Set value above
   SPAng:SPAng *(!dpi/180), $!! Set value above
   Beta_P:Beta_P,           $!! Set value above
   NPhoton:6000000L,      $  ;Number of photons to use in this simulation
   N_Layers:1002,        $
   N_WavBan:1,           $
   I_VerAng:10,          $
   I_AziAng:40,          $
   AdivC:0.0,            $  ; absorption probability (a/c) */
   AzimP:0.0,            $  ; Azimuthal angle "p" of the current photon in the simulation */
   Albedo:0.9,           $
   Beta_Scat:dblarr(N_ScaAng), $  ; Scattering Phase Function */
   BDepth:100.0,           $  ;  Depth of the Water Column  (m)  */
   Coeff_C:1.0,          $  ; total beam attenuation coefficient in each wave band */
   DAng:0.0,             $
   DInterval:0.0,        $
   n:0.0,                $
   f:[-1.0,0.0,0.0],        $  ; the normal to a capillary wave facet */
   cf:0.0,               $  ; conversion factor */
   Z_Height:60.0 *(!dpi/180),        $  ; the zenith angle of sun */
   QuadArea:0.0,         $
   p:dblarr(XYZ),        $  ; the current photon in the simulation */
   pdotf:0.0,            $  ; p dot f */
   prefl:0.0,            $  ; probibility of reflection */
   Pt:dblarr(XYZ),       $  ; the coordinate of photon in each event */
   Pt_add:dblarr(XYZ),   $
   rad:dblarr(5,I_ZenAng,2), $
   SunLight:1.0,         $  ; Light intensity (W m-2) */
   ThetaP:0.0,           $  ; theta angle "p" of the current photon in the simulation */
   ViewAng1:0.0 *(!dpi/180),         $
   ViewAng1B:0.0,        $
   ViewAng1S:0.0,        $
   ViewAng2:180.0 *(!dpi/180),       $
   ViewAng2B:0.0,        $
   ViewAng2S:0.0,        $
   WSpeed:0.0,           $  ; Windspeed (m s-1) */
   I_enter:0,            $
   I_scattering:0,       $
   I_Depth0:0,           $
   I_Depth1:1,           $
   I_Depth2:2,           $
   I_Depth3:0,           $
   I_Depth4:0,           $
   m:0,                  $
   zbeg:0                $
}


  start = systime(1);

  Setup, data
  
  ;TEST data STRUCTURE VARIABLES
  print, 'photons = ', data.NPhoton
  print, 'Depth 0-4 = ', data.I_Depth0, data.I_Depth1, data.I_Depth2, data.I_Depth3, data.I_Depth4
  
  
  
  for m=0, data.N_WavBan-1 do begin
    for n=0L, data.NPhoton-1 do begin
      if n mod 50000 eq 0 then print, n
      New_Photon, data
      if (data.I_enter eq 1 ) then begin
        repeat begin
          if ( data.I_scattering eq 1 ) then Scattering, data
;          print, 'ThetaP', data.ThetaP
          if ( data.ThetaP le (!dpi/2.0) ) then Trace_Down, data $
            else                      Trace_Up, data
        endrep until ( data.I_scattering ne 1 );
      end
    end
    Output, data
  end
  Result, data
  finish = systime(1);
  duration = (finish - start);
  print, 'Done! Running time = ', strtrim(duration,1), ' seconds'

end  ;  main 