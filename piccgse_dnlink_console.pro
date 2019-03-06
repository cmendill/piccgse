pro console_event, ev
  common dnlink_block,dnfd,conlogfd,base,con_text,shm_var,nchar
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ
  
  ;;console event
  newline=''
  tag = 0B
  bytesread=0L

  if dnfd ge 0 then begin
     ;;read data until we reach a line feed
     ;;NOTE: we could use readf here, but that may reach EOF before
     ;;finding a linefeed. readf would be much more efficient.
     while FILE_POLL_INPUT(dnfd,TIMEOUT=0.01) do begin
        readu,dnfd,tag
        bytesread++
        if tag ne  7B and $ ;;Bell
           tag ne  8B and $ ;;Backspace
          ;tag ne  9B and $ ;;Horizontal Tab
           tag ne 10B and $ ;;Linefeed
           tag ne 11B and $ ;;Vertical Tab
           tag ne 12B and $ ;;Formfeed
           tag ne 13B and $ ;;Carriage Return
           tag ne 27B and $ ;;Escape
           strlen(newline) lt nchar $ ;;Truncate lines to nchar
        then newline+=string(byte(tag))
        if tag eq 10B then break ;;Linefeed
     endwhile
     
     ;;If we are here, the serial port is empty or we reached a linefeed
     
     if bytesread gt 0 then begin
        ;;print console text to screen
        widget_control,ev.id,set_value=newline,/append
        ;;print console text to log file
        gsets=strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
        logfile='data/gsedata/piccgse.'+gsets+'/piccgse.'+gsets+'.conlog.txt'
        if not file_test(logfile) then begin
           ;;close logfile if it is open
           if n_elements(conlogfd) gt 0 then free_lun,conlogfd
           ;;open logfile
           openw,conlogfd,logfile,/get_lun
           print,'Widget opened: '+file_basename(logfile)
        endif
        ts=gettimestamp('.')
        printf,conlogfd,ts+': '+newline
     endif
  endif
    
  ;;re-trigger this loop after a timer
  widget_control,ev.id,timer=0.1
  
end

pro piccgse_dnlink_console
  common dnlink_block,dnfd,conlogfd,base,con_text,shm_var,nchar
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ

  ;;restore settings
  restore,'settings.idl'
 
  ;;open serial connection
  openr,dnfd,dnlink_dev,/get_lun,error=error
  if error ne 0 then begin
     print,'ERROR (piccgse_dnlink_console): Could not open '+dnlink_dev
     dnfd = -1
  endif

  ;;configure serial port
  if dnfd ge 0 then spawn,'stty -F '+dnlink_dev+' '+dnlink_baud+' cs8 -cstopb -parenb'
  
  ;;setup shared memory
  shmmap, 'shm', /byte, shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  ;;setup base widget
  wxs = 500
  wys = 268
  wxp = 0
  wyp = 2000
  title = 'PICTURE Downlink Console'
  base = widget_base(xsize=wxs,ysize=wys,xoffset=wxp,yoffset=wyp,/row,title=title)
  
  ;;setup downlink console
  nchar = 80
  sub1 = widget_base(base,/column)
  con_label = widget_label(sub1,value='Downlink',/align_left)
  con_text  = widget_text(sub1,xsize=nchar,ysize=17)
  xmanager,'console',sub1,/no_block
  
  ;;create widgets
  widget_control,base,/realize
  
  ;;start console
  widget_control,con_text,timer=0
end
