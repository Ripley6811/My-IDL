;Jay William Johnson 
;L46997017

;Question B:
 ;Please download the ascii data file "CR1000_ms700.dat" and the corresponding ascii data template "CR1000_ms700_Template".
 ;Write the second IDL program "Ex2.pro" with the following functions:
 ;1. Restore the template "CR1000_ms700_Template".
 ;2. Read the file "CR1000_ms700.dat" based on the template "CR1000_ms700_Template"
 ;3. Refer to the instruction of HW 2, calculate the reflectance R for all wavebands collected on 8/20 at 9:20, 10:30, 11:40, 12:50, 14:00.
 ;4. Plot the calculated R with wavelength ranged from 400nm to 700nm, reflectance R ranged from 0.0 to 0.5. Use different color to indicate the reflectance R calculated at different time.
 ;5. Find the maximum value of your calculated R and print this value in the console window.

pro Ex2
   ;RESTORE THE CORE FILE AND START ENVI IN BATCH
   envi, /restore_base_save_files
   envi_batch_init, log_file ='batch.log'
   
   ;SET DIRECTORY OF DATA AND TEST FOR EXISTENCE OF FILES
   fileDir = dialog_pickfile(/directory, title='Select the location of data files')
   if file_test(fileDir + 'CR1000_ms700.dat') eq 0 then begin
      print, 'CR1000_ms700.dat not found'
      envi_batch_exit
   endif
   if file_test(fileDir + 'CR1000_ms700_template') eq 0 then begin
      print, 'CR1000_ms700_template not found'
      envi_batch_exit
   endif

   ;RESTORE AND READ DATA FILE.  TEMPLATE WAS SAVED AS 'MyTemplate'
   restore, fileDir + 'CR1000_ms700_template',/verbose
   data = read_ascii( fileDir + 'CR1000_ms700.dat',      $
      template = MyTemplate)
   ;help, data, /structure

   ;CALCULATE R FOR ALL BANDS ON 8/20 AT 9:20, 10:30, 11:40, 12:50, 14:00
   ;ELEMENTS [0:34] ARE 8/20; [0] = 9:10
   ;THEREFORE; 9:20 = [1], 10:30 = [8], 11:40 = [15], 12:50 = [22], 14:00 = [29]
   ;ExArray[BAND, TIME]
   RArray = findgen(256, 5)
   EdArray = findgen(256, 1295)
   EuArray = findgen(256, 1295)
;PROCESSING Ed into single array      
EdArray[0,*]  = data.field022
EdArray[1,*]   = data.field023
EdArray[2,*]   = data.field024
EdArray[3,*]   = data.field025
EdArray[4,*]   = data.field026
EdArray[5,*]   = data.field027
EdArray[6,*]   = data.field028
EdArray[7,*]   = data.field029
EdArray[8,*]   = data.field030
EdArray[9,*]   = data.field031
EdArray[10,*]  = data.field032
EdArray[11,*]  = data.field033
EdArray[12,*]  = data.field034
EdArray[13,*]  = data.field035
EdArray[14,*]  = data.field036
EdArray[15,*]  = data.field037
EdArray[16,*]  = data.field038
EdArray[17,*]  = data.field039
EdArray[18,*]  = data.field040
EdArray[19,*]  = data.field041
EdArray[20,*]  = data.field042
EdArray[21,*]  = data.field043
EdArray[22,*]  = data.field044
EdArray[23,*]  = data.field045
EdArray[24,*]  = data.field046
EdArray[25,*]  = data.field047
EdArray[26,*]  = data.field048
EdArray[27,*]  = data.field049
EdArray[28,*]  = data.field050
EdArray[29,*]  = data.field051
EdArray[30,*]  = data.field052
EdArray[31,*]  = data.field053
EdArray[32,*]  = data.field054
EdArray[33,*]  = data.field055
EdArray[34,*]  = data.field056
EdArray[35,*]  = data.field057
EdArray[36,*]  = data.field058
EdArray[37,*]  = data.field059
EdArray[38,*]  = data.field060
EdArray[39,*]  = data.field061
EdArray[40,*]  = data.field062
EdArray[41,*]  = data.field063
EdArray[42,*]  = data.field064
EdArray[43,*]  = data.field065
EdArray[44,*]  = data.field066
EdArray[45,*]  = data.field067
EdArray[46,*]  = data.field068
EdArray[47,*]  = data.field069
EdArray[48,*]  = data.field070
EdArray[49,*]  = data.field071
EdArray[50,*]  = data.field072
EdArray[51,*]  = data.field073
EdArray[52,*]  = data.field074
EdArray[53,*]  = data.field075
EdArray[54,*]  = data.field076
EdArray[55,*]  = data.field077
EdArray[56,*]  = data.field078
EdArray[57,*]  = data.field079
EdArray[58,*]  = data.field080
EdArray[59,*]  = data.field081
EdArray[60,*]  = data.field082
EdArray[61,*]  = data.field083
EdArray[62,*]  = data.field084
EdArray[63,*]  = data.field085
EdArray[64,*]  = data.field086
EdArray[65,*]  = data.field087
EdArray[66,*]  = data.field088
EdArray[67,*]  = data.field089
EdArray[68,*]  = data.field090
EdArray[69,*]  = data.field091
EdArray[70,*]  = data.field092
EdArray[71,*]  = data.field093
EdArray[72,*]  = data.field094
EdArray[73,*]  = data.field095
EdArray[74,*]  = data.field096
EdArray[75,*]  = data.field097
EdArray[76,*]  = data.field098
EdArray[77,*]  = data.field099
EdArray[78,*]  = data.field100
EdArray[79,*]  = data.field101
EdArray[80,*]  = data.field102
EdArray[81,*]  = data.field103
EdArray[82,*]  = data.field104
EdArray[83,*]  = data.field105
EdArray[84,*]  = data.field106
EdArray[85,*]  = data.field107
EdArray[86,*]  = data.field108
EdArray[87,*]  = data.field109
EdArray[88,*]  = data.field110
EdArray[89,*]  = data.field111
EdArray[90,*]  = data.field112
EdArray[91,*]  = data.field113
EdArray[92,*]  = data.field114
EdArray[93,*]  = data.field115
EdArray[94,*]  = data.field116
EdArray[95,*]  = data.field117
EdArray[96,*]  = data.field118
EdArray[97,*]  = data.field119
EdArray[98,*]  = data.field120
EdArray[99,*]  = data.field121
EdArray[100,*]   = data.field122
EdArray[101,*]   = data.field123
EdArray[102,*]   = data.field124
EdArray[103,*]   = data.field125
EdArray[104,*]   = data.field126
EdArray[105,*]   = data.field127
EdArray[106,*]   = data.field128
EdArray[107,*]   = data.field129
EdArray[108,*]   = data.field130
EdArray[109,*]   = data.field131
EdArray[110,*]   = data.field132
EdArray[111,*]   = data.field133
EdArray[112,*]   = data.field134
EdArray[113,*]   = data.field135
EdArray[114,*]   = data.field136
EdArray[115,*]   = data.field137
EdArray[116,*]   = data.field138
EdArray[117,*]   = data.field139
EdArray[118,*]   = data.field140
EdArray[119,*]   = data.field141
EdArray[120,*]   = data.field142
EdArray[121,*]   = data.field143
EdArray[122,*]   = data.field144
EdArray[123,*]   = data.field145
EdArray[124,*]   = data.field146
EdArray[125,*]   = data.field147
EdArray[126,*]   = data.field148
EdArray[127,*]   = data.field149
EdArray[128,*]   = data.field150
EdArray[129,*]   = data.field151
EdArray[130,*]   = data.field152
EdArray[131,*]   = data.field153
EdArray[132,*]   = data.field154
EdArray[133,*]   = data.field155
EdArray[134,*]   = data.field156
EdArray[135,*]   = data.field157
EdArray[136,*]   = data.field158
EdArray[137,*]   = data.field159
EdArray[138,*]   = data.field160
EdArray[139,*]   = data.field161
EdArray[140,*]   = data.field162
EdArray[141,*]   = data.field163
EdArray[142,*]   = data.field164
EdArray[143,*]   = data.field165
EdArray[144,*]   = data.field166
EdArray[145,*]   = data.field167
EdArray[146,*]   = data.field168
EdArray[147,*]   = data.field169
EdArray[148,*]   = data.field170
EdArray[149,*]   = data.field171
EdArray[150,*]   = data.field172
EdArray[151,*]   = data.field173
EdArray[152,*]   = data.field174
EdArray[153,*]   = data.field175
EdArray[154,*]   = data.field176
EdArray[155,*]   = data.field177
EdArray[156,*]   = data.field178
EdArray[157,*]   = data.field179
EdArray[158,*]   = data.field180
EdArray[159,*]   = data.field181
EdArray[160,*]   = data.field182
EdArray[161,*]   = data.field183
EdArray[162,*]   = data.field184
EdArray[163,*]   = data.field185
EdArray[164,*]   = data.field186
EdArray[165,*]   = data.field187
EdArray[166,*]   = data.field188
EdArray[167,*]   = data.field189
EdArray[168,*]   = data.field190
EdArray[169,*]   = data.field191
EdArray[170,*]   = data.field192
EdArray[171,*]   = data.field193
EdArray[172,*]   = data.field194
EdArray[173,*]   = data.field195
EdArray[174,*]   = data.field196
EdArray[175,*]   = data.field197
EdArray[176,*]   = data.field198
EdArray[177,*]   = data.field199
EdArray[178,*]   = data.field200
EdArray[179,*]   = data.field201
EdArray[180,*]   = data.field202
EdArray[181,*]   = data.field203
EdArray[182,*]   = data.field204
EdArray[183,*]   = data.field205
EdArray[184,*]   = data.field206
EdArray[185,*]   = data.field207
EdArray[186,*]   = data.field208
EdArray[187,*]   = data.field209
EdArray[188,*]   = data.field210
EdArray[189,*]   = data.field211
EdArray[190,*]   = data.field212
EdArray[191,*]   = data.field213
EdArray[192,*]   = data.field214
EdArray[193,*]   = data.field215
EdArray[194,*]   = data.field216
EdArray[195,*]   = data.field217
EdArray[196,*]   = data.field218
EdArray[197,*]   = data.field219
EdArray[198,*]   = data.field220
EdArray[199,*]   = data.field221
EdArray[200,*]   = data.field222
EdArray[201,*]   = data.field223
EdArray[202,*]   = data.field224
EdArray[203,*]   = data.field225
EdArray[204,*]   = data.field226
EdArray[205,*]   = data.field227
EdArray[206,*]   = data.field228
EdArray[207,*]   = data.field229
EdArray[208,*]   = data.field230
EdArray[209,*]   = data.field231
EdArray[210,*]   = data.field232
EdArray[211,*]   = data.field233
EdArray[212,*]   = data.field234
EdArray[213,*]   = data.field235
EdArray[214,*]   = data.field236
EdArray[215,*]   = data.field237
EdArray[216,*]   = data.field238
EdArray[217,*]   = data.field239
EdArray[218,*]   = data.field240
EdArray[219,*]   = data.field241
EdArray[220,*]   = data.field242
EdArray[221,*]   = data.field243
EdArray[222,*]   = data.field244
EdArray[223,*]   = data.field245
EdArray[224,*]   = data.field246
EdArray[225,*]   = data.field247
EdArray[226,*]   = data.field248
EdArray[227,*]   = data.field249
EdArray[228,*]   = data.field250
EdArray[229,*]   = data.field251
EdArray[230,*]   = data.field252
EdArray[231,*]   = data.field253
EdArray[232,*]   = data.field254
EdArray[233,*]   = data.field255
EdArray[234,*]   = data.field256
EdArray[235,*]   = data.field257
EdArray[236,*]   = data.field258
EdArray[237,*]   = data.field259
EdArray[238,*]   = data.field260
EdArray[239,*]   = data.field261
EdArray[240,*]   = data.field262
EdArray[241,*]   = data.field263
EdArray[242,*]   = data.field264
EdArray[243,*]   = data.field265
EdArray[244,*]   = data.field266
EdArray[245,*]   = data.field267
EdArray[246,*]   = data.field268
EdArray[247,*]   = data.field269
EdArray[248,*]   = data.field270
EdArray[249,*]   = data.field271
EdArray[250,*]   = data.field272
EdArray[251,*]   = data.field273
EdArray[252,*]   = data.field274
EdArray[253,*]   = data.field275
EdArray[254,*]   = data.field276
EdArray[255,*]   = data.field277
   
;Processing Eu into single array
EuArray[0,*]   = data.field278
EuArray[1,*]   = data.field279
EuArray[2,*]   = data.field280
EuArray[3,*]   = data.field281
EuArray[4,*]   = data.field282
EuArray[5,*]   = data.field283
EuArray[6,*]   = data.field284
EuArray[7,*]   = data.field285
EuArray[8,*]   = data.field286
EuArray[9,*]   = data.field287
EuArray[10,*]  = data.field288
EuArray[11,*]  = data.field289
EuArray[12,*]  = data.field290
EuArray[13,*]  = data.field291
EuArray[14,*]  = data.field292
EuArray[15,*]  = data.field293
EuArray[16,*]  = data.field294
EuArray[17,*]  = data.field295
EuArray[18,*]  = data.field296
EuArray[19,*]  = data.field297
EuArray[20,*]  = data.field298
EuArray[21,*]  = data.field299
EuArray[22,*]  = data.field300
EuArray[23,*]  = data.field301
EuArray[24,*]  = data.field302
EuArray[25,*]  = data.field303
EuArray[26,*]  = data.field304
EuArray[27,*]  = data.field305
EuArray[28,*]  = data.field306
EuArray[29,*]  = data.field307
EuArray[30,*]  = data.field308
EuArray[31,*]  = data.field309
EuArray[32,*]  = data.field310
EuArray[33,*]  = data.field311
EuArray[34,*]  = data.field312
EuArray[35,*]  = data.field313
EuArray[36,*]  = data.field314
EuArray[37,*]  = data.field315
EuArray[38,*]  = data.field316
EuArray[39,*]  = data.field317
EuArray[40,*]  = data.field318
EuArray[41,*]  = data.field319
EuArray[42,*]  = data.field320
EuArray[43,*]  = data.field321
EuArray[44,*]  = data.field322
EuArray[45,*]  = data.field323
EuArray[46,*]  = data.field324
EuArray[47,*]  = data.field325
EuArray[48,*]  = data.field326
EuArray[49,*]  = data.field327
EuArray[50,*]  = data.field328
EuArray[51,*]  = data.field329
EuArray[52,*]  = data.field330
EuArray[53,*]  = data.field331
EuArray[54,*]  = data.field332
EuArray[55,*]  = data.field333
EuArray[56,*]  = data.field334
EuArray[57,*]  = data.field335
EuArray[58,*]  = data.field336
EuArray[59,*]  = data.field337
EuArray[60,*]  = data.field338
EuArray[61,*]  = data.field339
EuArray[62,*]  = data.field340
EuArray[63,*]  = data.field341
EuArray[64,*]  = data.field342
EuArray[65,*]  = data.field343
EuArray[66,*]  = data.field344
EuArray[67,*]  = data.field345
EuArray[68,*]  = data.field346
EuArray[69,*]  = data.field347
EuArray[70,*]  = data.field348
EuArray[71,*]  = data.field349
EuArray[72,*]  = data.field350
EuArray[73,*]  = data.field351
EuArray[74,*]  = data.field352
EuArray[75,*]  = data.field353
EuArray[76,*]  = data.field354
EuArray[77,*]  = data.field355
EuArray[78,*]  = data.field356
EuArray[79,*]  = data.field357
EuArray[80,*]  = data.field358
EuArray[81,*]  = data.field359
EuArray[82,*]  = data.field360
EuArray[83,*]  = data.field361
EuArray[84,*]  = data.field362
EuArray[85,*]  = data.field363
EuArray[86,*]  = data.field364
EuArray[87,*]  = data.field365
EuArray[88,*]  = data.field366
EuArray[89,*]  = data.field367
EuArray[90,*]  = data.field368
EuArray[91,*]  = data.field369
EuArray[92,*]  = data.field370
EuArray[93,*]  = data.field371
EuArray[94,*]  = data.field372
EuArray[95,*]  = data.field373
EuArray[96,*]  = data.field374
EuArray[97,*]  = data.field375
EuArray[98,*]  = data.field376
EuArray[99,*]  = data.field377
EuArray[100,*]   = data.field378
EuArray[101,*]   = data.field379
EuArray[102,*]   = data.field380
EuArray[103,*]   = data.field381
EuArray[104,*]   = data.field382
EuArray[105,*]   = data.field383
EuArray[106,*]   = data.field384
EuArray[107,*]   = data.field385
EuArray[108,*]   = data.field386
EuArray[109,*]   = data.field387
EuArray[110,*]   = data.field388
EuArray[111,*]   = data.field389
EuArray[112,*]   = data.field390
EuArray[113,*]   = data.field391
EuArray[114,*]   = data.field392
EuArray[115,*]   = data.field393
EuArray[116,*]   = data.field394
EuArray[117,*]   = data.field395
EuArray[118,*]   = data.field396
EuArray[119,*]   = data.field397
EuArray[120,*]   = data.field398
EuArray[121,*]   = data.field399
EuArray[122,*]   = data.field400
EuArray[123,*]   = data.field401
EuArray[124,*]   = data.field402
EuArray[125,*]   = data.field403
EuArray[126,*]   = data.field404
EuArray[127,*]   = data.field405
EuArray[128,*]   = data.field406
EuArray[129,*]   = data.field407
EuArray[130,*]   = data.field408
EuArray[131,*]   = data.field409
EuArray[132,*]   = data.field410
EuArray[133,*]   = data.field411
EuArray[134,*]   = data.field412
EuArray[135,*]   = data.field413
EuArray[136,*]   = data.field414
EuArray[137,*]   = data.field415
EuArray[138,*]   = data.field416
EuArray[139,*]   = data.field417
EuArray[140,*]   = data.field418
EuArray[141,*]   = data.field419
EuArray[142,*]   = data.field420
EuArray[143,*]   = data.field421
EuArray[144,*]   = data.field422
EuArray[145,*]   = data.field423
EuArray[146,*]   = data.field424
EuArray[147,*]   = data.field425
EuArray[148,*]   = data.field426
EuArray[149,*]   = data.field427
EuArray[150,*]   = data.field428
EuArray[151,*]   = data.field429
EuArray[152,*]   = data.field430
EuArray[153,*]   = data.field431
EuArray[154,*]   = data.field432
EuArray[155,*]   = data.field433
EuArray[156,*]   = data.field434
EuArray[157,*]   = data.field435
EuArray[158,*]   = data.field436
EuArray[159,*]   = data.field437
EuArray[160,*]   = data.field438
EuArray[161,*]   = data.field439
EuArray[162,*]   = data.field440
EuArray[163,*]   = data.field441
EuArray[164,*]   = data.field442
EuArray[165,*]   = data.field443
EuArray[166,*]   = data.field444
EuArray[167,*]   = data.field445
EuArray[168,*]   = data.field446
EuArray[169,*]   = data.field447
EuArray[170,*]   = data.field448
EuArray[171,*]   = data.field449
EuArray[172,*]   = data.field450
EuArray[173,*]   = data.field451
EuArray[174,*]   = data.field452
EuArray[175,*]   = data.field453
EuArray[176,*]   = data.field454
EuArray[177,*]   = data.field455
EuArray[178,*]   = data.field456
EuArray[179,*]   = data.field457
EuArray[180,*]   = data.field458
EuArray[181,*]   = data.field459
EuArray[182,*]   = data.field460
EuArray[183,*]   = data.field461
EuArray[184,*]   = data.field462
EuArray[185,*]   = data.field463
EuArray[186,*]   = data.field464
EuArray[187,*]   = data.field465
EuArray[188,*]   = data.field466
EuArray[189,*]   = data.field467
EuArray[190,*]   = data.field468
EuArray[191,*]   = data.field469
EuArray[192,*]   = data.field470
EuArray[193,*]   = data.field471
EuArray[194,*]   = data.field472
EuArray[195,*]   = data.field473
EuArray[196,*]   = data.field474
EuArray[197,*]   = data.field475
EuArray[198,*]   = data.field476
EuArray[199,*]   = data.field477
EuArray[200,*]   = data.field478
EuArray[201,*]   = data.field479
EuArray[202,*]   = data.field480
EuArray[203,*]   = data.field481
EuArray[204,*]   = data.field482
EuArray[205,*]   = data.field483
EuArray[206,*]   = data.field484
EuArray[207,*]   = data.field485
EuArray[208,*]   = data.field486
EuArray[209,*]   = data.field487
EuArray[210,*]   = data.field488
EuArray[211,*]   = data.field489
EuArray[212,*]   = data.field490
EuArray[213,*]   = data.field491
EuArray[214,*]   = data.field492
EuArray[215,*]   = data.field493
EuArray[216,*]   = data.field494
EuArray[217,*]   = data.field495
EuArray[218,*]   = data.field496
EuArray[219,*]   = data.field497
EuArray[220,*]   = data.field498
EuArray[221,*]   = data.field499
EuArray[222,*]   = data.field500
EuArray[223,*]   = data.field501
EuArray[224,*]   = data.field502
EuArray[225,*]   = data.field503
EuArray[226,*]   = data.field504
EuArray[227,*]   = data.field505
EuArray[228,*]   = data.field506
EuArray[229,*]   = data.field507
EuArray[230,*]   = data.field508
EuArray[231,*]   = data.field509
EuArray[232,*]   = data.field510
EuArray[233,*]   = data.field511
EuArray[234,*]   = data.field512
EuArray[235,*]   = data.field513
EuArray[236,*]   = data.field514
EuArray[237,*]   = data.field515
EuArray[238,*]   = data.field516
EuArray[239,*]   = data.field517
EuArray[240,*]   = data.field518
EuArray[241,*]   = data.field519
EuArray[242,*]   = data.field520
EuArray[243,*]   = data.field521
EuArray[244,*]   = data.field522
EuArray[245,*]   = data.field523
EuArray[246,*]   = data.field524
EuArray[247,*]   = data.field525
EuArray[248,*]   = data.field526
EuArray[249,*]   = data.field527
EuArray[250,*]   = data.field528
EuArray[251,*]   = data.field529
EuArray[252,*]   = data.field530
EuArray[253,*]   = data.field531
EuArray[254,*]   = data.field532
EuArray[255,*]   = data.field533

;Process the R array for five times
for b = 0, 256-1 do begin
   for t = 0, 5-1 do begin
      RArray[b,t] = EuArray[b,1+t*7] / EdArray[b,1+t*7]
   endfor 
endfor
;print, RArray

;PLOTTING R FROM 400 TO 700 NM AND USING DIFFERENT COLORS FOR EACH TIME
   ;CREATE LABEL ARRAY FOR X AXIS, WAVELENGTHS
   xAxisLabel = lindgen(256)
   for i = 0, 256-1 do begin
      xAxisLabel[i] = long(350 + float(i)*2.734375)
   endfor
   ;PLOT EMPTY GRAPH
   window, 1, xsize = 600, ysize = 600, xpos = 0, ypos = 0, title = 'Plot of R'
   plot, xAxisLabel[19:128], [0.0,0.5], /nodata,   $
            title = 'R(lambda) = Eu(lambda) /Ed(lambda)',    $
            xtitle = 'Wavelength (nm)',    $
            ytitle = 'R(lambda)',   $
            /xstyle, font = -1, charsize = 0.6
   ;PLOT THE DATA FOR 5 TIME PERIODS
   oplot, xAxisLabel, RArray[*,0], color = 'FF0000'x
   oplot, xAxisLabel, RArray[*,1], color = 'FFFF00'x
   oplot, xAxisLabel, RArray[*,2], color = '00FF00'x
   oplot, xAxisLabel, RArray[*,3], color = '00FFFF'x
   oplot, xAxisLabel, RArray[*,4], color = '0000FF'x

   ;OUTPUT HIGHEST VALUE IN R ARRAY
   print, string(max(RArray, /NaN)) + ' is the highest value of R'
   
   ;EXIT ENVI
   envi_batch_exit
end