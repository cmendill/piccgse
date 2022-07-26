pro console_event, ev
  common dnlink_block,settings,dnfd,conlogfd,lunit,runit,remotefd,base,con_text,shm_var,nchar

  ;;Install error handler
  ON_IOERROR, RESET_CONNECTION

  ;;check for exit
  if NOT shm_var[settings.shm_run] then begin
     print,'DNLINK: exiting'
     ;;unmap shared memory
     shmunmap,'shm'
     ;;free files
     if dnfd gt 0 then free_lun,dnfd,/force
     if conlogfd gt 0 then free_lun,conlogfd,/force
     if lunit gt 0 then free_lun,lunit,/force
     if runit gt 0 then free_lun,runit,/force
     if remotefd gt 0 then free_lun,remotefd,/force
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
  bline = bytarr(settings.cmdlength)
  if dnfd ge 0 then begin
     ;;read data until we reach a line feed or read a maximum number of characters
     while FILE_POLL_INPUT(dnfd,timeout=0.1) AND bytesread lt settings.cmdlength do begin
        readu,dnfd,word
        bytesread++
        ;;use only standard ASCII characters
        if word ge 32B AND word le 126 then newline+=string(word)
        if word eq 9B then newline+='  ' ;;Replace horizontal tab with double space
        if word eq 10B then break        ;;Linefeed
     endwhile
  endif
  if remotefd gt 0 then begin
     ;;we are remote, read data from main interface
     if file_poll_input(remotefd,timeout=0.1) then begin
        readu,remotefd,bline
        newline = string(bline)
        bytesread = strlen(newline)
     endif
  endif
  
  if bytesread gt 0 then begin
     ;;print console text to screen
     widget_control,ev.id,set_value=strmid(newline,0,nchar),/append
     ;;send console text to remote
     if runit gt 0 then begin
        bline = bytarr(settings.cmdlength)
        bline[0:strlen(newline)-1]=byte(newline)
        writeu,runit,bline
     endif
     ;;print console text to log file
     gsets=strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
     logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.conlog.txt'
     if not file_test(logfile) then begin
        ;;close logfile if it is open
        if conlogfd gt 0 then free_lun,conlogfd,/force
        ;;open logfile
        openw,conlogfd,logfile,/get_lun
        print,'DNLINK: Widget opened: '+file_basename(logfile)
     endif
     ts=gettimestamp('.')
     printf,conlogfd,ts+': '+newline
  endif

  if 0 then begin
     RESET_CONNECTION:
     if lunit gt 0 then free_lun,lunit,/force
     if runit gt 0 then free_lun,runit,/force
     if remotefd gt 0 then free_lun,remotefd,/force
     lunit = -1
     runit = -1
     remotefd = -1
  endif
    
  ;;re-trigger this loop immidiately
  widget_control,ev.id,timer=0
  
end

pro socket_event, ev
  common dnlink_block,settings,dnfd,conlogfd,lunit,runit,remotefd,base,con_text,shm_var,nchar

  ;;get piccgse settings
  restore,'.piccgse_set.idl'

  ;;remote setup
  if shm_var[settings.shm_remote] then begin
     if remotefd lt 0 then begin
        ;;We are the remote, open socket to the server (remote_event)
        socket, remotefd, set.tmserver_addr, settings.dnlink_port, /get_lun, error=con_status, connect_timeout=3, write_timeout=2
        if con_status eq 0 then begin
           print,'DNLINK: Opened socket to '+set.tmserver_addr+':'+n2s(settings.dnlink_port) 
        endif else begin
           print,'DNLINK: ERROR Remote socket failed to open'
           print,'DNLINK: '+!ERR_STRING
           if remotefd gt 0 then free_lun,remotefd,/force
           remotefd = -1
        endelse
     endif
  endif

  ;;setup listener for remote connections
  if lunit lt 0 then begin
     socket, lunit, settings.dnlink_port, /listen, /get_lun, error=con_error
     if con_error eq 0 then begin
        print,'DNLINK: Listening for remote connections on port '+n2s(settings.dnlink_port) 
     endif else begin
        print,'DNLINK: Listening socket failed to open'
        print,'DNLINK: '+!ERR_STRING
        if lunit gt 0 then free_lun,lunit,/force
        lunit=-1
     endelse
  endif
  
  ;;listen for remote connections
  if (lunit gt 0) AND (runit lt 0) then begin
     if file_poll_input(lunit, timeout=0) then begin
        socket, runit, accept=lunit, /get_lun, error=con_error
        if con_error eq 0 then begin
           print,'DNLINK: Remote connection established'
        endif else begin
           print,'DNLINK: Remote connection failed'
           print,'DNLINK: '+!ERR_STRING
           if runit gt 0 then free_lun,runit,/force
           runit=-1
        endelse
     endif
  endif

  ;;re-trigger this loop automatically
  widget_control,ev.id,timer=1

end


pro piccgse_dnlink_console
  common dnlink_block,settings,dnfd,conlogfd,lunit,runit,remotefd,base,con_text,shm_var,nchar

  ;;load settings
  settings = load_settings()
  
  ;;setup shared memory
  shmmap, 'shm', /byte, settings.shm_size
  shm_var = shmvar('shm')
  print,'DNLINK: Shared memory mapped'

  ;;init file descriptors
  dnfd = -1
  conlogfd = -1
  lunit = -1
  runit = -1
  remotefd = -1

  ;;Check if we are remote or main interface
  if NOT shm_var[settings.shm_remote] then begin
     ;;open serial connection
     openr,dnfd,settings.dnlink_dev,/get_lun,error=error
     if error ne 0 then begin
        print,'ERROR Could not open '+settings.dnlink_dev
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

  ;;socket widget
  soc = widget_base(base)
  xmanager,'socket',soc,/no_block
  
  ;;create widgets
  widget_control,base,/realize
  
  ;;start console
  widget_control,con_text,timer=0

  ;;start socket
  widget_control,soc,timer=0
end
