pro tmtest, mode

  
;;Settings
ntmtest       = 1024
tmtestmax     = 65536UL
tmserver_addr = '192.168.0.13'
tmserver_port = '14443'

if mode eq 'picture_gdp' then cmd_senddata  = '11110001'XUL
if mode eq 'picture_exp' then cmd_senddata  = '22220001'XUL


;;Create Socket connection
PRINT, 'Attempting to create Socket connection Image Server to >'+tmserver_addr+'< on port '+n2s(tmserver_port)
SOCKET, TMUNIT, tmserver_addr, tmserver_port, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status, READ_TIMEOUT=2
if con_status eq 0 then begin
   PRINT, 'Socket created'
   ;;Ask for images
   WRITEU,TMUNIT,CMD_SENDDATA
endif else begin
   stop,'Connection failed'
endelse
print,'Connection successful'

;;Read and check data
while(1) do begin
   tmarray = uintarr(ntmtest)
   if FILE_POLL_INPUT(TMUNIT,TIMEOUT=0.01) then begin
      readu,TMUNIT,tmarray
      if tm_test_count++ eq 0 then tmcheck=tmarray else begin 
         tmcheck = lonarr(ntmtest)
         tmc=0UL
         for i=0,ntmtest-1 do begin
            tmcheck[i] = (tmc + tm_test_last + 1) mod tmtestmax
            tmc++
            if tmcheck[i] eq 'FADE'XU then begin
               tmcheck[i]++
               tmc++
            endif
         endfor
      endelse
      if array_equal(tmarray,tmcheck) then begin
         statusline,'TM Test: '+n2s(tm_test_count)+' transfers without error'
      endif else begin
         print,''
         print,'TM Test: ERROR after '+n2s(tm_test_count)+' transfers'
         for i=0,ntmtest-1 do begin
            if tmarray[i] ne tmcheck[i] then begin
               print,'First ERROR occured at index '+n2s(i)+' --> Read: 0x'+n2s(tmarray[i],format='(Z4.4)')+' Expected: 0x'+n2s(tmcheck[i],format='(Z4.4)')
               break
            endif
         endfor
         tm_test_count=0
         break
      endelse
      tm_test_last = tmarray[ntmtest-1]
   endif
endwhile


end
