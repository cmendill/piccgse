pro console_event, ev
  common dnlink_block,settings,dnfd,conlogfd,base,con_text,shm_var,nchar

  ;;check for exit
  if NOT shm_var[settings.shm_run] then begin
     print,'exit'
     ;;unmap shared memory
     shmunmap,'shm'
     ;;close files
     close,/all
     ;;exit
     widget_control,base,/destroy
     return
  endif

  ;;console event
  newline=''
  word = 0B
  bytesread=0L
  if dnfd ge 0 then begin
     ;;read data until we reach a line feed
     while FILE_POLL_INPUT(dnfd,timeout=0.1) AND bytesread lt 200 do begin
        readu,dnfd,word
        bytesread++
        ;;use only standard ASCII characters
        if word ge 32B AND word le 126 then newline+=string(word)
        if word eq 9B then newline+='  ' ;;Replace horizontal tab with double space
        if word eq 10B then break        ;;Linefeed
     endwhile
     
     ;;If we are here, the serial port is empty or we reached a linefeed
     
     if bytesread gt 0 then begin
        ;;print console text to screen
        widget_control,ev.id,set_value=strmid(newline,0,nchar),/append
        ;;print console text to log file
        gsets=strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
        logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.conlog.txt'
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
    
  ;;re-trigger this loop immidiately
  widget_control,ev.id,timer=0
  
end

pro piccgse_dnlink_console
  common dnlink_block,settings,dnfd,conlogfd,base,con_text,shm_var,nchar

  ;;load settings
  settings = load_settings()
  
  ;;setup shared memory
  shmmap, 'shm', /byte, settings.shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  dnfd = -1
  if NOT shm_var[settings.shm_remote] then begin
     ;;open serial connection
     openr,dnfd,settings.dnlink_dev,/get_lun,error=error
     if error ne 0 then begin
        print,'ERROR (piccgse_dnlink_console): Could not open '+settings.dnlink_dev
        dnfd = -1
     endif else print,'DNLINK: Opened '+settings.dnlink_dev+' for reading'
     
     ;;configure serial port
     if dnfd ge 0 then begin
        cmd = 'serial/serial_setup'
        spawn, cmd
     endif
  endif
  
  ;;setup base widget
  wxs = 504
  wys = 291
  wxp = 35  ;;dock ends at x=35
  wyp = 2000
  title = 'PICTURE Downlink Console'
  base = widget_base(xsize=wxs,ysize=wys,xoffset=wxp,yoffset=wyp,/row,title=title)
  
  ;;setup downlink console
  nchar = 80
  sub1 = widget_base(base,/column)
  ;con_label = widget_label(sub1,value='Downlink',/align_left)
  con_text  = widget_text(sub1,xsize=nchar,ysize=21)
  xmanager,'console',sub1,/no_block
  
  ;;create widgets
  widget_control,base,/realize
  
  ;;start console
  widget_control,con_text,timer=0
end
