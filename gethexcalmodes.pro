;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function gethexcalmodes
;;  - function to read hex header file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function gethexcalmodes
line = ''
header = '../piccflight/src/hex_functions.h'


found_calmodes = 0
ncalmodes      = 0
calmodestr = strarr(100)
openr,unit,header,/get_lun
while(not EOF(unit)) do begin
   readf,unit,line
   if(strpos(line,'enum hexcalmodes') ge 0) then found_calmodes = 1
   if found_calmodes eq 1 then begin
      if(strpos(line,'HEX_NCALMODES') ge 0) then found_calmodes = 0 else begin
         a=strpos(line,'HEX_CALMODE_')
         calmode = strmid(line,a)
         calmode = strmid(calmode,0,strlen(calmode)-1)
         calmodestr[ncalmodes++]=calmode
      endelse
   endif
endwhile
close,unit
free_lun,unit
return,calmodestr[0:ncalmodes-1]
end
