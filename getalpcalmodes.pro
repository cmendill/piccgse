;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function getalpcalmodes
;;  - function to read alp header file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function getalpcalmodes
line = ''
header = '../piccflight/src/alp_functions.h'


found_calmodes = 0
ncalmodes      = 0
calmodestr = strarr(100)
openr,unit,header,/get_lun
while(not EOF(unit)) do begin
   readf,unit,line
   if(strpos(line,'enum alpcalmodes') ge 0) then found_calmodes = 1
   if found_calmodes eq 1 then begin
      if(strpos(line,'ALP_NCALMODES') ge 0) then found_calmodes = 0 else begin
         a=strpos(line,'ALP_CALMODE_')
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
