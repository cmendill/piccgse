pro console_event, ev
  common downlink_block,serfd,conlogfd,base,con_text,shm_var,nchar
  
  ;;console event
  newline=''
  tag = 0B
  bytesread=0L
  SHM_TIMESTAMP=28

  while FILE_POLL_INPUT(serfd,TIMEOUT=0.01) do begin
     readu,serfd,tag
     bytesread++
     if tag ne  7B and $    ;;Bell
        tag ne  8B and $    ;;Backspace
        ;tag ne  9B and $    ;;Horizontal Tab
        tag ne 10B and $    ;;Linefeed
        tag ne 11B and $    ;;Vertical Tab
        tag ne 12B and $    ;;Formfeed
        tag ne 13B and $    ;;Carriage Return
        tag ne 27B     $    ;;Escape
     then newline+=string(byte(tag))
     if tag eq 10B then break ;;Linefeed
     if strlen(newline) eq nchar then break
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

  ;;re-trigger this loop after a timer
  widget_control,ev.id,timer=0.1

end

pro piccgse_downlink_console
  common downlink_block,serfd,conlogfd,base,con_text,shm_var,nchar
  
  ;;move to the correct working directory, starts in /home/cmendill
  CD,'/home/cmendill/code/piccgse/',current=old_dir
  
  ;;setup serial port
  ;spawn,'./serial/serial_setup'

  ;;open serial connection
  dev = '/dev/ttyUSB0'
  openr,serfd,dev,/get_lun
  
  ;;setup shared memory
  shm_size = 128
  shmmap, 'shm', /byte, shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  ;;setup base widget
  downlink_xs = 500
  screen_dimensions = get_screen_size()
  sxs = fix(screen_dimensions[0])
  sys = fix(screen_dimensions[1])
  wxs = downlink_xs
  wys = 268
  wxp = 0
  wyp = sys-wys
  title = 'PICTURE Downlink Console'
  base = WIDGET_BASE(xsize=wxs,ysize=wys,xoffset=wxp,yoffset=wyp,/row,title=title)
  
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
