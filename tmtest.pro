pro tmtest, mode, nocheck=nocheck, pattern2=pattern2
;;Settings
ntmtest       = 2048
tmtestmax     = 65536UL
tmserver_addr = '192.168.0.13'
tmserver_port = 14443
empty_code    = 'FADE'XU
tmtest_count  = 0UL
flush_count   = 0UL
tmarray       = uintarr(ntmtest)
nflush        = 150

if mode eq 'picture_eth' then begin
   ;;Get data directly from flight computer over ethernet
   tmserver_addr = 'picture'
   tmserver_port = 1337
   cmd_senddata  = '0ABACABB'XUL
endif
if mode eq 'picture_gdp' then begin
   ;;Get data from tmserver connected to GDP
   tmserver_addr = 'tmserver'
   tmserver_port = 14443
   cmd_senddata  = '11110001'XUL
endif
if mode eq 'picture_exp' then begin
   ;;Get data from tmserver connected directly to experiment
   tmserver_addr = 'tmserver'
   tmserver_port = 14443
   cmd_senddata  = '22220001'XUL
endif
if mode eq 'picture_tmrecv' then begin
   ;;Get data from tmrecv program
   tmserver_addr = 'localhost'
   tmserver_port = 14443
   cmd_senddata  = '0ABACABB'XUL
endif

;;Create Socket connection
PRINT, 'Attempting to create Socket connection Image Server to >'+tmserver_addr+'< on port '+n2s(tmserver_port)
SOCKET, TMUNIT, tmserver_addr, tmserver_port, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status, READ_TIMEOUT=2
if con_status eq 0 then begin
   PRINT, 'Socket created'
   ;;Ask for images
   WRITEU,TMUNIT,swap_endian(cmd_senddata)
   print,'Asking for data with command: 0x'+n2s(cmd_senddata,format='(Z8.8)')
endif else begin
   stop,'Connection failed'
endelse
print,'Connection successful'
print,'Press: CTRL-C to stop'

;;Read and check data
while(1) do begin
   if FILE_POLL_INPUT(TMUNIT,TIMEOUT=0.01) then begin
      ;;Read data into tmarray
      ON_IOERROR, IOERROR_START
      readu,TMUNIT,tmarray

      ;;Clear old data from socket
      if flush_count++ lt nflush then begin
         statusline,'Flushing socket...                                             '
         continue
      endif
     
      
      ;;Strip out empty codes
      sel = where(tmarray ne empty_code,nsel)
      if nsel gt 0 then tmarray=tmarray[sel] else begin
         statusline,'Empty data stream...     '
         continue
      endelse

      if NOT keyword_set(NOCHECK) then begin
         ;;Check data
         if tmtest_count++ eq 0 then begin
            checkword = tmarray[0]
         endif else begin
            checkword = (tmcheck_last + 1) mod tmtestmax
            if keyword_set(pattern2) then begin
               if tmcheck_last eq 0 then checkword = 65535 else checkword = 0
            endif
         endelse
         for i=0,n_elements(tmarray)-1 do begin
            if checkword eq empty_code then checkword++
            checkword = checkword mod tmtestmax
            if tmarray[i] ne checkword then begin
               ;;Error messages
               print,''
               print,'TM Test: ERROR after '+n2s(tmtest_count)+' transfers'
               stop,'First ERROR occured at index '+n2s(i)+' --> Read: '+n2s(tmarray[i],format='(I)')+' Expected: '+n2s(checkword,format='(I)')
               free_lun,TMUNIT
            endif
            if keyword_set(pattern2) then begin
               if checkword eq 0 then checkword = 65535 else checkword = 0
            endif else begin
               checkword++
            endelse
         endfor
      
         ;;Print status
         if tmtest_count MOD 100 eq 0 then statusline,'TM Test: Checked '+n2s(tmtest_count)+' transfers with no errors...'
         
         ;;Set last word for next iteration
         tmcheck_last = tmarray[-1]
      endif else begin
         ;;Print status
         if tmtest_count MOD 100 eq 0 then statusline,'TM Test: Received '+n2s(tmtest_count++)+' transfers...'
      endelse
   endif else begin
      IOERROR_START:
      flush_count = 0
      tmtest_count = 0
      statusline,'No data...                                                        '
      wait,1
   endelse
endwhile


end
