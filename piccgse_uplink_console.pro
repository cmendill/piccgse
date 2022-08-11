;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path, win

  ;;Open the config file
  openr, unit, path, /get_lun
  
  ;;Read config file
  line = ''
  for i=0L,file_lines(path)-1 do begin
     ;;Read line
     readf, unit, line
     ;;Check for comment
     if strmid(line,0,1) eq '#' then continue
     ;;Parse line
     pieces = strsplit(strcompress(line), ' ',/extract)
     if n_elements(pieces) ge 2 then begin
        tag = pieces[0]
        value = pieces[1]
        for j=2, n_elements(pieces)-1 do begin
           value+=' '+pieces[j]
        endfor
        
        ;;Set values
        case tag OF
           ;;Console Window
           'UPL_SHOW'        : win.show  = value
           'UPL_NAME'        : win.name  = value
           'UPL_XSIZE'       : win.xsize = value
           'UPL_YSIZE'       : win.ysize = value
           'UPL_XPOS'        : win.xpos  = value
           'UPL_YPOS'        : win.ypos  = value
           'UPL_FONT'        : win.font  = value
           else: ;;do nothing
        endcase
     endif
  endfor
  
  ;;Close the config file
  free_lun,unit,/force
end

;;UPLINK
;;  Function to format CSBF "Request-to-Send" packets for command uplink
pro uplink, fd, cmd
  lmax = 255
  lmin = 21 ;;discovered by experimenting with uplink at FTS
  bcmd = byte(cmd)
  len  = n_elements(bcmd)
  if len lt lmin then bcmd = [bcmd,bytarr(lmin - len)]
  len  = n_elements(bcmd)
  if len gt lmax then begin
     print, 'UPLINK: Command failed: length exceedes '+n2s(lmax)+' characters'
     return
  endif
  ;;Init packet and add command
  pkt  = [0B,0B,0B,0B,bcmd,0B]
  npkt = n_elements(pkt)
  ;;Fill out static packet elements
  pkt[0]   = 16  ;;start byte == 0x10
  pkt[1]   = 0   ;;link routing (0=LOS,1=TDRSS,2=Iridium)
  pkt[2]   = 9   ;;routing addresss (9=COMM1,C=COMM2)
  pkt[3]   = len ;;length
  pkt[-1]  = 3   ;;stop byte == 0x3
  ;;Send packet
  writeu,fd,pkt
  ;;Print packet
  if 0 then begin
     print,'Sent: '+string(pkt[0:25 < (npkt-1)],format='(65Z3.2)')
     nlines = ceil(npkt / 26.)
     for i=1,nlines-1 do print,'      '+string(pkt[26*i:(26*i+25) < (npkt-1)],format='(65Z3.2)')
  endif
end

pro command_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;Install error handler
  ON_IOERROR, COMMAND_ERROR

  ;;command line event
  widget_control,ev.id,GET_VALUE=cmd_array

  ;;loop over multiple commands
  for icmd=0,n_elements(cmd_array)-1 do begin
     cmd = cmd_array[icmd]
     ;;send command
     if shm_var[settings.shm_remote] then begin
        rcmd = bytarr(settings.cmdlength)
        rcmd[0:strlen(cmd)-1]=byte(cmd)
        if remotefd gt 0 then writeu,remotefd,rcmd
     endif else begin
        if shm_var[settings.shm_uplink] then begin
           if upfd ge 0 then begin
              ;;use uplink port
              if strlen(cmd) eq 0 then uplink,upfd,string(10B) else uplink,upfd,cmd+string(10B)
           endif
        endif else begin
           if dnfd ge 0 then begin
              ;;use downlink port
              if strlen(cmd) eq 0 then writeu,dnfd,10B else writeu,dnfd,[byte(cmd),10B]
           endif
        endelse
     endelse
     
     ;;print command to screen
     ts=gettimestamp('.')
     if strlen(cmd) eq 0 then cmd='CR'
     cmdstr=ts+': '+cmd
     widget_control,log_text,SET_VALUE=cmd,/APPEND
     widget_control,ev.id,set_value=''
     
     ;;log command
     gsets=strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
     logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
     if not file_test(logfile) then begin
        ;;close logfile if it is open
        if cmdlogfd gt 0 then free_lun,cmdlogfd,/force
        ;;open logfile
        openw,cmdlogfd,logfile,/get_lun
        print,'UPLINK: Widget opened: '+file_basename(logfile)
     endif
     printf,cmdlogfd,cmdstr
  endfor

  ;;skip over error handler
  goto, NO_COMMAND_ERROR
  
  COMMAND_ERROR:
  print,'UPLINK: COMMAND_ERROR'
  if lunit gt 0 then free_lun,lunit,/force
  if runit gt 0 then free_lun,runit,/force
  if remotefd gt 0 then free_lun,remotefd,/force
  lunit = -1
  runit = -1
  remotefd = -1

  NO_COMMAND_ERROR:
  
end


pro serial_command_buttons_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat
 
  ;;Install error handler
  ON_IOERROR, SERIAL_COMMAND_BUTTONS_ERROR

  ;;get command
  widget_control,ev.id,GET_UVALUE=uval
  sel = where(buttondb.id eq uval,nsel)
  event_type = TAG_NAMES(ev, /STRUCTURE_NAME) 
  if event_type eq 'WIDGET_LIST' then begin
     if ev.clicks eq 2 then begin 
        index = widget_info(ev.id,/LIST_SELECT)
        id = uval[index]
        sel = where(buttondb.id eq id,nsel)
     endif else nsel=0
  endif

  if nsel gt 0 then begin
     ;;command was recognized 
     cmd = buttondb[sel].cmd
     if buttondb[sel].type1 eq 'hex' AND buttondb[sel].name eq 'ACQUIRE' then begin
        ;;Special case for HEX auto acquire
        ;;--get dx,dy from shared memory
        dx = fix(ishft(fix(shm_var[settings.shm_acq_dx]),8) + shm_var[settings.shm_acq_dx+1])
        dy = fix(ishft(fix(shm_var[settings.shm_acq_dy]),8) + shm_var[settings.shm_acq_dy+1])
        ;;--convert dx,dy to du,dv
        scale = 0.0003d
        dv = -dx * scale ;;+X = +V
        du =  dy * scale ;;+Y = -U
        cr = string(10B)
        cmd = 'hex move du '+n2s(du,format='(F15.4)')+cr+'sleep 0.5'+cr+'hex move dv '+n2s(dv,format='(F15.4)')
     endif
     
     ;;send command
     if shm_var[settings.shm_remote] then begin
        rcmd = bytarr(settings.cmdlength)
        rcmd[0:strlen(cmd)-1]=byte(cmd)
        if remotefd gt 0 then writeu,remotefd,rcmd
     endif else begin
        if shm_var[settings.shm_uplink] then begin
           ;;use uplink port
           if upfd ge 0 then begin
              uplink,upfd,cmd+string(10B)
           endif
        endif else begin
           ;;use downlink port
           if dnfd ge 0 then begin
              if strlen(cmd) eq 0 then writeu,dnfd,10B else writeu,dnfd,[byte(cmd),10B]
           endif
        endelse
     endelse
     
     ;;print command to screen
     ts=gettimestamp('.')
     cmdstr=ts+': '+cmd
     widget_control,log_text,SET_VALUE=cmd,/APPEND

     ;;log command
     gsets=strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
     logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
     if not file_test(logfile) then begin
        ;;close logfile if it is open
        if cmdlogfd gt 0 then free_lun,cmdlogfd,/force
        ;;open logfile
        openw,cmdlogfd,logfile,/get_lun
        print,'UPLINK: Widget opened: '+file_basename(logfile)
     endif
     printf,cmdlogfd,cmdstr
     
  endif

  ;;skip over error handler
  goto,NO_SERIAL_COMMAND_BUTTONS_ERROR
  
  SERIAL_COMMAND_BUTTONS_ERROR:
  print,'UPLINK: SERIAL_COMMAND_BUTTONS_ERROR'
  if lunit gt 0 then free_lun,lunit,/force
  if runit gt 0 then free_lun,runit,/force
  if remotefd gt 0 then free_lun,remotefd,/force
  lunit = -1
  runit = -1
  remotefd = -1
  
  NO_SERIAL_COMMAND_BUTTONS_ERROR:
  
end

pro remote_command_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;Install error handler
  ON_IOERROR, REMOTE_COMMAND_ERROR

  if runit gt 0 then begin
     if file_poll_input(runit, timeout=0) then begin
        ;;read command from remote client
        cmd=bytarr(settings.cmdlength)
        readu,runit,cmd
        cmd = string(cmd)
        print,'UPLINK: Got remote command: '+cmd
        ;;send command
        if shm_var[settings.shm_uplink] then begin
           ;;use uplink port
           if upfd ge 0 then begin
              uplink,upfd,cmd+string(10B)
           endif
        endif else begin
           ;;use downlink port
           if dnfd ge 0 then begin
              if strlen(cmd) eq 0 then writeu,dnfd,10B else writeu,dnfd,[byte(cmd),10B]
           endif
        endelse

        ;;print command to screen
        ts=gettimestamp('.')
        cmdstr=ts+': '+cmd
        widget_control,log_text,SET_VALUE=cmd,/APPEND

        ;;log command
        gsets=strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
        logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
        if not file_test(logfile) then begin
           ;;close logfile if it is open
           if cmdlogfd gt 0 then free_lun,cmdlogfd,/force
           ;;open logfile
           openw,cmdlogfd,logfile,/get_lun
           print,'UPLINK: Widget opened: '+file_basename(logfile)
        endif
        printf,cmdlogfd,cmdstr
     endif
  endif 

  ;;skip over error handler
  goto,NO_REMOTE_COMMAND_ERROR
  
  REMOTE_COMMAND_ERROR:
  print,'UPLINK: REMOTE_COMMAND_ERROR'
  if lunit gt 0 then free_lun,lunit,/force
  if runit gt 0 then free_lun,runit,/force
  if remotefd gt 0 then free_lun,remotefd,/force
  lunit = -1
  runit = -1
  remotefd = -1

  NO_REMOTE_COMMAND_ERROR:
  ;;trigger self
  widget_control,ev.id,timer=0.5
end


pro gse_command_buttons_event, ev 
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  event_type = TAG_NAMES(ev, /STRUCTURE_NAME) 
  
  ;;get command
  widget_control,ev.id,GET_UVALUE=uval
  sel = where(buttondb.id eq uval,nsel)
  if event_type eq 'WIDGET_DROPLIST' then begin
     index = widget_info(ev.id,/DROPLIST_SELECT)
     id = uval[index]
     sel = where(buttondb.id eq id,nsel)
  endif
  if nsel gt 0 then begin
     ;;command was recognized 
     
     ;;set command
     shm_var[buttondb[sel].igse]=buttondb[sel].vgse
     
     ;;trigger update
     shm_var[settings.shm_cmd]=1

     ;;close logfile on reset command
     if (buttondb[sel].igse eq settings.shm_reset) AND (buttondb[sel].vgse eq 1) then begin
        if cmdlogfd gt 0 then free_lun,cmdlogfd,/force
     endif
     
  endif else print,'UPLINK: GSE Command ['+n2s(uval)+'] Not Recognized'

  ;;check for exit
  if NOT shm_var[settings.shm_run] then begin
     print,'UPLINK: exiting'
     if upfd gt 0 then free_lun,upfd,/force
     if dnfd gt 0 then free_lun,dnfd,/force
     if cmdlogfd gt 0 then free_lun,cmdlogfd,/force
     if remotefd gt 0 then free_lun,remotefd,/force
     if lunit gt 0 then free_lun,lunit,/force
     if runit gt 0 then free_lun,runit,/force
     ;;close files
     close,/all
     ;;check out
     shm_var[settings.shm_up_run]=0
     ;;unmap shared memory
     shmunmap,'shm'
     ;;exit
     widget_control,base,/destroy
     return
  endif
end

pro gsepath_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat
  common gsepath_block, path
 
  temp='piccgse.'+strcompress(string(shm_var[settings.shm_timestamp:*]),/REMOVE_ALL)
  if n_elements(path) eq 0 then begin
     path=temp
     widget_control,ev.id,SET_VALUE=path
  endif
  if not strcmp(path,temp) then begin
     path=temp
     widget_control,ev.id,SET_VALUE=path
  endif
  ;;trigger self
  widget_control,ev.id,timer=0.5
end

pro connstat_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;get light bitmaps
  red_light = read_bmp('bmp/red.bmp',/rgb)
  red_light = transpose(red_light,[1,2,0])
  green_light = read_bmp('bmp/green.bmp',/rgb)
  green_light = transpose(green_light,[1,2,0])
  
  ;;get command
  widget_control,ev.id,GET_UVALUE=uval
  
  if uval eq 'uplink' then begin
     ;;Toggle uplink command
     if shm_var[settings.shm_uplink] then shm_var[settings.shm_uplink] = 0 else shm_var[settings.shm_uplink] = 1
  endif
  
  ;;set lights
  if shm_var[settings.shm_link]   then widget_control,link_connstat,set_value=green_light else widget_control,link_connstat,set_value=red_light
  if shm_var[settings.shm_data]   then widget_control,data_connstat,set_value=green_light else widget_control,data_connstat,set_value=red_light
  if shm_var[settings.shm_uplink] then widget_control,uplk_connstat,set_value=green_light else widget_control,uplk_connstat,set_value=red_light

  ;;return if triggered by command
  if uval ne 'timer' then return
  
  ;;trigger self
  widget_control,ev.id,timer=0.5
end

pro socket_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;get piccgse settings
  restore,'.piccgse_set.idl'

  ;;remote setup
  if shm_var[settings.shm_remote] then begin
     if remotefd lt 0 then begin
        ;;We are the remote, open socket to the server (remote_event)
        socket, remotefd, set.tmserver_addr, settings.uplink_port, /get_lun, error=con_status, connect_timeout=3, write_timeout=2
        if con_status eq 0 then begin
           print,'UPLINK: Opened socket to '+set.tmserver_addr+':'+n2s(settings.uplink_port) 
        endif else begin
           print,'UPLINK: ERROR Remote socket failed to open'
           print,'UPLINK: '+!ERR_STRING
           if remotefd gt 0 then free_lun,remotefd,/force
           remotefd = -1
        endelse
     endif
  endif

  ;;setup listener for remote connections
  if lunit lt 0 then begin
     socket, lunit, settings.uplink_port, /listen, /get_lun, error=con_error
     if con_error eq 0 then begin
        print,'UPLINK: Listening for remote connections on port '+n2s(settings.uplink_port) 
     endif else begin
        print,'UPLINK: Listening socket failed to open'
        print,'UPLINK: '+!ERR_STRING
        if lunit gt 0 then free_lun,lunit,/force
        lunit=-1
     endelse
  endif
  
  ;;listen for remote connections
  if (lunit gt 0) AND (runit lt 0) then begin
     if file_poll_input(lunit, timeout=0) then begin
        socket, runit, accept=lunit, /get_lun, error=con_error
        if con_error eq 0 then begin
           print,'UPLINK: Remote connection established'
        endif else begin
           print,'UPLINK: Remote connection failed'
           print,'UPLINK: '+!ERR_STRING
           if runit gt 0 then free_lun,runit,/force
           runit=-1
        endelse
     endif
  endif

  ;;re-trigger this loop automatically
  widget_control,ev.id,timer=1

end

pro piccgse_uplink_console
  common uplink_block,settings,upfd,dnfd,cmdlogfd,remotefd,lunit,runit,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;load settings
  settings = load_settings()
  
  ;;load buttons
  buttondb = load_buttondb()

  ;;get piccgse settings
  restore,'.piccgse_set.idl'
  
  ;;setup shared memory
  shmmap, 'shm', /byte, settings.shm_size
  shm_var = shmvar('shm')
  print,'UPLINK: Shared memory mapped'

  ;;check in
  shm_var[settings.shm_up_run] = 1

  ;;init file descriptors
  upfd = -1
  dnfd = -1
  cmdlogfd = -1
  remotefd = -1
  lunit = -1
  runit = -1

  ;;Check if we are remote or main interface
  if NOT shm_var[settings.shm_remote] then begin
     ;;Open uplink console (write-only)
     openw,upfd,settings.uplink_dev,/get_lun,error=error
     if error ne 0 then begin
        print,'UPLINK: ERROR Could not open '+settings.uplink_dev
        print,'UPLINK: '+!ERR_STRING
        upfd = -1
     endif else print,'UPLINK: Opened '+settings.uplink_dev+' for writing'
     
     ;;Open dnlink console (write-only)
     openw,dnfd,settings.dnlink_dev,/get_lun,error=error
     if error ne 0 then begin
        print,'UPLINK: ERROR Could not open '+settings.dnlink_dev
        print,'UPLINK: '+!ERR_STRING
        dnfd = -1
     endif else print,'UPLINK: Opened '+settings.dnlink_dev+' for writing'
     
     ;;configure serial ports
     if (upfd ge 0) OR (dnfd ge 0) then begin
        cmd = 'serial/serial_setup'
        spawn, cmd
     endif
  endif
    
  ;;read window info from config file
  win={show:0, name:'', xsize:0, ysize:0, xpos:0, ypos:0, font:''}
  piccgse_loadConfig,settings.config_file,win

  ;;setup base widget
  base = widget_base(xsize=win.xsize,ysize=win.ysize,xoffset=win.xpos,yoffset=win.ypos,/row,title=win.name)
    
  ;;setup command log
  size = 32
  sub2 = widget_base(base,/column)
  log_label = widget_label(sub2,value='Command Log',/align_left,font=win.font)
  log_text  = widget_text(sub2,xsize=size,ysize=14,font=win.font)

  ;;setup command line
  size = 32
  cmd_label = widget_label(sub2,value='Command Line:',/align_left,font=win.font)
  cmd_text  = widget_text(sub2,xsize=size,ysize=1,/editable,font=win.font)
  xmanager,'command',sub2,/no_block

  ;;Column 1
  col1 = widget_base(base,/column,/align_top)
  !P.FONT=0
  
  ;;State buttons
  state1_sub1 = widget_base(col1,/row,/align_center)            
  state1_sub2 = widget_base(col1,column=1,/frame,/align_center) 
  button_label = widget_label(state1_sub1,value='States',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'state1' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(state1_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',state1_sub2,/no_block

  ;;Column 2
  col2 = widget_base(base,/column,/align_top)
  !P.FONT=0
  
  ;;State buttons
  state2_sub1 = widget_base(col2,/row,/align_center)            
  state2_sub2 = widget_base(col2,column=1,/frame,/align_center) 
  button_label = widget_label(state2_sub1,value='States',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'state2' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(state2_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',state2_sub2,/no_block

  ;;Column 3
  col3 = widget_base(base,/column,/align_top)

  ;;Hex buttons
  hex_sub1 = widget_base(col3,/row,/align_center)            
  hex_sub2 = widget_base(col3,column=1,/frame,/align_center) 
  button_label = widget_label(hex_sub1,value='Hexapod',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'hex' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(hex_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',hex_sub2,/no_block

  ;;Column 4
  col4 = widget_base(base,/column,/align_top)

  ;;Other buttons
  other_sub1 = widget_base(col4,/row,/align_center)            
  other_sub2 = widget_base(col4,column=1,/frame,/align_center) 
  button_label = widget_label(other_sub1,value='Other',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'other' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(other_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',other_sub2,/no_block

  ;;Column 5
  col5 = widget_base(base,/column,/align_top)
  
  ;;Camera buttons
  cam_sub1 = widget_base(col5,/row,/align_center)            
  cam_sub2 = widget_base(col5,column=1,/frame,/align_center) 
  button_label = widget_label(cam_sub1,value='Cameras',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'camera' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(cam_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',cam_sub2,/no_block

  ;;Column 6
  col6 = widget_base(base,/column,/align_top)

  ;;Door buttons
  door_sub1 = widget_base(col6,/row,/align_center)
  door_sub2 = widget_base(col6,column=1,/align_center)
  door_but1 = widget_base(door_sub2,row=1,/frame,/align_center) 
  door_but2 = widget_base(door_sub2,row=1,/frame,/align_center) 
  door_but3 = widget_base(door_sub2,row=1,/frame,/align_center) 
  button_label = widget_label(door_sub1,value='Doors',/align_center,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd1' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd2' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd3' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but3, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif

  ;;--install event handler
  xmanager,'serial_command_buttons',door_sub2,/no_block

  ;;SCI Display Type
  scitype_sub1 = widget_base(col6,/row,/align_center)            
  scitype_sub2 = widget_base(col6,column=1,/align_center)            
  scitype_but1 = widget_base(scitype_sub2,row=1,/align_center)
  button_label = widget_label(scitype_sub1,value='SCI Type',/align_center,font=win.font)
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq 'scitype' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_droplist(scitype_but1,VALUE=buttons.name,uvalue=buttons.id,font=win.font)
  endif

  ;;--install event handler
  xmanager,'gse_command_buttons',scitype_sub2,/no_block

  ;;BMC Display Type
  bmctype_sub1 = widget_base(col6,/row,/align_center)            
  bmctype_sub2 = widget_base(col6,column=1,/align_center)            
  bmctype_but1 = widget_base(bmctype_sub2,row=1,/align_center)
  button_label = widget_label(bmctype_sub1,value='BMC Type',/align_center,font=win.font)
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq 'bmctype' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_droplist(bmctype_but1,VALUE=buttons.name,uvalue=buttons.id,font=win.font)
  endif

  ;;--install event handler
  xmanager,'gse_command_buttons',bmctype_sub2,/no_block
 
  ;;Column 7
  col7 = widget_base(base,/column,/align_top)

  ;;LYT arrows
  lyt_arrow_sub1 = widget_base(col7,/row)
  button_label = widget_label(lyt_arrow_sub1,value='LYT:',/align_left,font=win.font)
  sel = where(buttondb.type1 eq 'lyt' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(lyt_arrow_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP,font=win.font)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',lyt_arrow_sub1,/no_block

  ;;SHK arrows
  shk_arrow_sub1 = widget_base(col7,/row)
  button_label = widget_label(shk_arrow_sub1,value='SHK:',/align_left,font=win.font)
  sel = where(buttondb.type1 eq 'shk' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(shk_arrow_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',shk_arrow_sub1,/no_block

  ;;SCI arrows
  sci_arrow_sub1 = widget_base(col7,/row)
  button_label = widget_label(sci_arrow_sub1,value='SCI:',/align_left,font=win.font)
  sel = where(buttondb.type1 eq 'sci' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(sci_arrow_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',sci_arrow_sub1,/no_block

  ;;HEX arrows
  hex_arrow_sub1 = widget_base(col7,/row)
  button_label = widget_label(hex_arrow_sub1,value='HEX:',/align_left,font=win.font)
  sel = where(buttondb.type1 eq 'hex' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(hex_arrow_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',hex_arrow_sub1,/no_block

  ;;HEX Z
  ;hex_z_sub1 = widget_base(col7,/row)
  ;button_label = widget_label(hex_z_sub1,value='HEX:',/align_left)
  ;sel = where(buttondb.type1 eq 'hex' and buttondb.type2 eq 'z' and buttondb.show eq 1,nsel)
  ;if nsel gt 0 then begin
  ;   buttons = buttondb[sel]
  ;   for i=0,n_elements(buttons)-1 do begin
  ;      bid = WIDGET_BUTTON(hex_z_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
  ;   endfor
  ;endif
  ;;install event handler
  ;xmanager,'serial_command_buttons',hex_z_sub1,/no_block

  ;;GSE buttons
  gse_sub1 = widget_base(col7,/row)
  button_label = widget_label(gse_sub1,value='GSE:',/align_left,font=win.font)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(gse_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,font=win.font)
     endfor
  endif
  xmanager,'gse_command_buttons',gse_sub1,/no_block
  
  ;;GSE path display
  gsepath = widget_base(col7,/row)
  gsepath_text = widget_text(gsepath,xsize=22,ysize=1,font=win.font)
  ;;install event handler
  xmanager,'gsepath',gsepath_text,/no_block

  ;;Status icons
  red_light   = read_bmp('bmp/red.bmp',/rgb)
  red_light   = transpose(red_light,[1,2,0])
  connstat       = widget_base(col7,/row)
  connstat_sub1  = widget_base(connstat,column=3,/frame)
  button_label = widget_label(connstat_sub1,value=' LINK ',/align_center,font=win.font)
  link_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='link', TOOLTIP='TM Link Status',/align_center)
  button_label = widget_label(connstat_sub1,value=' DATA ',/align_center,font=win.font)
  data_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='data', TOOLTIP='TM Data Status',/align_center)
  button_label = widget_label(connstat_sub1,value=' UPLK ',/align_center,font=win.font)
  uplk_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='uplink', TOOLTIP='Toggle Uplink Command',/align_center)
  ;;install event handler
  xmanager,'connstat',connstat,/no_block

  ;;Remote commands
  remote = widget_base(base,/row)
  xmanager,'remote_command',remote,/no_block

  ;;socket widget
  soc = widget_base(base)
  xmanager,'socket',soc,/no_block
  
  ;;create widgets
  widget_control,base,/realize

  ;;update gsepath
  widget_control,gsepath_text,timer=0

  ;;start remote
  widget_control,remote,timer=0

  ;;start status icons
  widget_control,connstat,timer=0,set_uval='timer'
  
  ;;start socket
  widget_control,soc,timer=0
end
