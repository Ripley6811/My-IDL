;Notes for GO game

;calculate a 'threat assesment' or 'lifeline' or 'reversal'(a way to turn the tables)
;because a move assesment tree would be far too complex to be effective, another method must be used

;Base it on the things I have learned
;Calculate the areas of influence, must be able to sacrifice areas for greater good
;using qi strength works out, because if qi = 0, then those pieces would be removed anyway and space is set to 0


;SPECIFICS
;calculate the total 'qi' of all connected groups
;use 2d array, 0=no peice, 1+ = 'qi' of white group, -1- = 'qi' of black group


pro showgame, gameB, gameW
;   for i = 0, 18 do begin
;     print, format='(19I3)', game[i,*]
;   endfor
   print, N_PARAMS()
   if(N_PARAMS() eq 2) then begin
      for i=0, 18 do begin
         outstr = ''
         for j=0, 18 do begin
            if(gameB[i,j] gt 0) then outstr += ' B' else $
            if(gameW[i,j] gt 0) then outstr += ' W' else $
            outstr += ' -'
         endfor
         print, outstr
      endfor
   endif
   if(N_PARAMS() eq 1) then begin
      for i=0, 18 do begin
         outstr = ''
         for j=0, 18 do begin
            if(gameB[i,j] gt 0) then outstr += '' & outstr += string(format='(I2)', gameB[i,j]) 
         endfor
         print, outstr
      endfor
   endif
   
   
   ;print, format='(19I4)', transpose(gameview)
end

pro decrH, heading
   incrH, heading
   heading = heading*(-1)
end

pro incrH, heading
   if (heading eq [1,0]) then heading = [1,-1] else $
   if (heading eq [1,-1]) then heading = [0,-1] else $
   if (heading eq [0,-1]) then heading = [-1,-1] else $
   if (heading eq [-1,-1]) then heading = [-1,0] else $
   if (heading eq [-1,0]) then heading = [-1,1] else $
   if (heading eq [-1,1]) then heading = [0,1] else $
   if (heading eq [0,1]) then heading = [1,1] else $
   if (heading eq [1,1]) then heading = [1,0]
end
   

pro GO

   gameB = bytarr(19,19);
   gameW = bytarr(19,19);
   gameBqi = bytarr(19,19);
   gameWqi = bytarr(19,19);
   influence = intarr(19,19);
   influenceLarge = intarr(380,380);
   leaning = intarr(19,19);
   print, '--------------------EMPTY BOARD--------------------------'
   showgame, gameB, gameW;
   print, '-------------------random Layout--------------------------'
   placepieces, gameB, gameW;
   showgame, gameB, gameW;
   print, '-------------------qi layout------------------------------'
   calculateQi, gameB, gameW, gameBqi, gameWqi
;   showgame, gameqi
   showgame, gameBqi
;   print, '-------------------field of influence---------------------'
;   calculateInfluence, game, influence
;   showgame, influence
;   print, "total=", total(influence)
;   print, 'max=', max(influence)
;   window, 1, xsize=1140, ysize=380, xpos=0, ypos=-1024
;   tvscl, enlarge(influence, 20), 380, 0, /order
;   tvscl, enlarge(game, 20), /order
;;   calculateInfluenceLarge, enlarge(game, 7), influenceLarge, 7
;;   tvscl, influenceLarge, 760, 0, /order
;   tvscl, enlarge(showControlledAreas(influence),20), 760, 0, /order
;   print, total(influence)
;   print, 'controlled=', total(showControlledAreas(influence))
end

function enlarge, board, multiplier

   larger = intarr(19 * multiplier,19 * multiplier)
   for i = 0, 19 * multiplier -1 do for j = 0, 19 * multiplier -1 do larger[i,j] = board[i/multiplier,j/multiplier]
   return, transpose(larger)
end
function showControlledAreas, influence
   output = intarr(19,19)
   for i = 0, 18 do for j = 0, 18 do begin
      if (influence[i,j] ne 0) then begin
         if (influence[i,j] gt 0) then output[i,j] = 1 else output[i,j] = -1
      endif
   endfor
   return, output
end

;This procedure just help create a random game layout (temporary use)
pro placepieces, gameB, gameW
;   game = FIX(RANDOMN(seed, 19, 19, BINOMIAL=[2,.5])-1)
;   gameW[3,3]=255
;   gameW[15,3]=255
;   gameB[15,15]=255
;   gameB[3,15]=255
;   gameW[9,3]=255
;   gameB[2,6]=255

   gameW[3,3]=255
   gameW[6,2]=255
   gameW[8,2]=255
   gameW[9,2]=255
   gameW[10,2]=255
   gameW[12,2]=255
   gameW[17,2]=255
   gameW[16,3]=255
   gameW[15,5]=255
   gameW[15,6]=255
   gameW[15,7]=255
   gameW[16,10]=255
   gameW[2,12]=255
   gameW[2,13]=255
   gameW[3,12]=255
   gameW[6,13]=255
   gameW[5,15]=255
   gameW[5,16]=255
   gameW[8,16]=255
   
;   gameW[8,8]=255
;   gameW[8,9]=255
;   gameW[8,10]=255
;   gameW[9,8]=255
;   gameW[9,9]=255
;   gameW[9,10]=255
;   gameW[10,8]=255
;   gameW[10,9]=255
;   gameW[10,10]=255
   
   gameB[7,3]=255
   gameB[8,3]=255
   gameB[9,3]=255
   gameB[11,3]=255
   gameB[13,4]=255
   gameB[14,3]=255
   gameB[14,6]=255
   gameB[15,2]=255
   gameB[16,2]=255
   gameB[2,11]=255
   gameB[2,14]=255
   gameB[3,13]=255
   gameB[3,15]=255
   gameB[4,13]=255
   gameB[4,16]=255
   gameB[9,15]=255
   gameB[9,16]=255
   gameB[16,15]=255
   gameB[14,16]=255
end

pro calculateQi, gameB, gameW, gameBqi, gameWqi
;   for i = 0, 18 do begin
;      for j = 0, 18 do begin
;;         if (gameB[i,j] ne 0 AND gameW[i,j] ne 0) then begin
;            qi = 0
;            if (i ne 0) then if (gameB[i-1,j] eq 0 AND gameW[i-1,j] eq 0) then qi++
;            if (i ne 18) then if (gameB[i+1,j] eq 0 AND gameW[i+1,j] eq 0) then qi++
;            if (j ne 0) then if (gameB[i,j-1] eq 0 AND gameW[i,j-1] eq 0) then qi++
;            if (j ne 18) then if (gameB[i,j+1] eq 0 AND gameW[i,j+1] eq 0) then qi++
;            gameqi[i,j] = qi
;;            gameqi[i,j] = qi * gamelayout[i,j] ; To get the sign(black or white)           
;;         endif
;      endfor
;   endfor
   
   
   for i = 0, 18 do begin
      for j = 0, 18 do begin
         if (gameB[i,j] ne 0) then begin
            gameBqi[i,j] = getQi( gameB, i, j, gameW, 0 )
         endif
         if (gameW[i,j] ne 0) then begin
            gameWqi[i,j] = getQi( gameW, i, j, gameB, 0 )         
         endif
      endfor
   endfor
   
end

function getQi, player, i, j, nullTemplate, initValue ; init value should be 0
print, '(', initValue, ')'
   nullarr = nullTemplate
   ;Calculate this point qi value
   if (i ne 0) then if (player[i-1,j] eq 0 AND nullarr[i-1,j] eq 0) then initValue++ & nullarr[i-1,j] = 1
   if (i ne 18) then if (player[i+1,j] eq 0 AND nullarr[i+1,j] eq 0) then initValue++ & nullarr[i+1,j] = 1
   if (j ne 0) then if (player[i,j-1] eq 0 AND nullarr[i,j-1] eq 0) then initValue++ & nullarr[i,j-1] = 1
   if (j ne 18) then if (player[i,j+1] eq 0 AND nullarr[i,j+1] eq 0) then initValue++ & nullarr[i,j+1] = 1
   nullarr[i,j] = 1
   ;Find qi of neighbors and add to this one
   if (i ne 0) then if (player[i-1,j] gt 0 AND nullarr[i-1,j] eq 0) then initValue = getQi( player, i-1, j, nullarr, initValue )
   if (i ne 18) then if (player[i+1,j] gt 0 AND nullarr[i+1,j] eq 0) then initValue = getQi( player, i+1, j, nullarr, initValue )
   if (j ne 0) then if (player[i,j-1] gt 0 AND nullarr[i,j-1] eq 0) then initValue = getQi( player, i, j-1, nullarr, initValue )
   if (j ne 18) then if (player[i,j+1] gt 0 AND nullarr[i,j+1] eq 0) then initValue = getQi( player, i, j+1, nullarr, initValue )
   ;Return qi value
   return, initValue
end;getQi


pro calculateInfluence, gamelayout, influence
   for i = 0, 18 do begin
      for j = 0, 18 do begin
         if (gamelayout[i,j] ne 0) then begin
            for ii = 0, 18 do begin
               for jj = 0, 18 do begin
                  if (i ne ii or j ne jj and gamelayout[ii,jj] eq 0) then begin
                     ;calculate point distance
                     pd = sqrt((fix(i-ii))*(fix(i-ii)) + (fix(j-jj))*(fix(j-jj)))
                     ;calculate charge at point
                     pc = fix(200*(1.0/(pd^2)))
;                     print, pc
                     influence[ii,jj] += pc * gamelayout[i,j]
                  endif else influence[ii,jj] = 2000* gamelayout[ii,jj]
               endfor
            endfor
   
         endif
      endfor
   endfor
   influence = influence/10
end

   
   
   
pro calculateInfluenceLarge, gamelayout, influence, multi
   count = 0
   for i = 0, 19 * multi -1 do begin
      for j = 0, 19 * multi -1 do begin
         if (gamelayout[i,j] ne 0) then begin
            for ii = 0, 19 * multi -1 do begin
               for jj = 0, 19 * multi -1 do begin
                  if (i ne ii or j ne jj and gamelayout[ii,jj] eq 0) then begin
                     ;calculate point distance
                     pd = sqrt((fix(i-ii))*(fix(i-ii)) + (fix(j-jj))*(fix(j-jj)))
                     ;calculate charge at point
                     pc = fix(100*(3.0/(pd+2)))
;                     print, pc
                     influence[ii,jj] += pc * gamelayout[i,j]
                  endif else influence[ii,jj] = 1000* gamelayout[ii,jj]
                  count++
               endfor
            endfor
   
         endif
         print, 'row=', i
         print, 'col=', j
      endfor
   endfor
   influence = influence/10
end
   
   
   
   
   
   
   