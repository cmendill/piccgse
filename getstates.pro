;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function getstates
;;  - function to read states.h header file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function getstates
line = ''
header = '/home/cmendill/code/piccflight/src/states.h'


found_states = 0
nstates      = 0
statestr = strarr(100)
openr,unit,header,/get_lun
while(not EOF(unit)) do begin
   readf,unit,line
   if(strpos(line,'enum states') ge 0) then found_states = 1
   if found_states eq 1 then begin
      if(strpos(line,'NSTATES') ge 0) then found_states = 0 else begin
         a=strpos(line,'STATE_')
         state = strmid(line,a)
         state = strmid(state,0,strlen(state)-1)
         statestr[nstates++]=state
      endelse
   endif
endwhile
close,unit
free_lun,unit
return,statestr[0:nstates-1]
end
