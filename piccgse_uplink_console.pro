;;UPLINK
;;  Function to format CSBF "Request-to-Send" packets for command uplink
pro uplink, fd, cmd
  pkt = bytarr(260)
  ;;Fill out static packet elements
  pkt[0]   = 16  ;;start byte == 0x10
  pkt[1]   = 0   ;;link routing (0=LOS,1=TDRSS,2=Iridium)
  pkt[2]   = 9   ;;routing addresss (9=COMM1,C=COMM2)
  pkt[3]   = 255 ;;length (always 255, zero-padded)
  pkt[259] = 3   ;;stop byte == 0x3
  ;;Fill out command
  barr = bytarr(255)
  bcmd = byte(cmd)
  if n_elements(bcmd) gt 255 then begin
     print, 'Uplink command failed: length exceedes 255 characters'
  endif else begin
     ;;Add command to byte array
     barr[0:n_elements(bcmd)-1] = bcmd
     ;;Add byte array to packet
     pkt[4:258] = barr
     ;;Send packet
     writeu,fd,pkt
  endelse
end

pro command_event, ev
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ
  ;;command line event
  widget_control,ev.id,GET_VALUE=cmd
  ;;send command
  if upfd ge 0 then begin
     if shm_var[shm_uplink] then begin
        if strlen(cmd) eq 0 then uplink,upfd,string(10B) else uplink,upfd,cmd
     endif else begin
        if strlen(cmd) eq 0 then writeu,upfd,10B else writeu,upfd,[byte(cmd),10B]
     endelse
  endif
  
  ;;print command to screen
  ts=gettimestamp('.')
  if strlen(cmd) eq 0 then cmd='CR'
  cmdstr=ts+': '+cmd
  widget_control,log_text,SET_VALUE=cmd,/APPEND
  widget_control,ev.id,set_value=''
  
  ;;log command
  gsets=strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
  logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
  if not file_test(logfile) then begin
     ;;close logfile if it is open
     if n_elements(cmdlogfd) gt 0 then free_lun,cmdlogfd
     ;;open logfile
     openw,cmdlogfd,logfile,/get_lun
     print,'Widget opened: '+file_basename(logfile)
  endif
  printf,cmdlogfd,cmdstr
  
end


pro serial_command_buttons_event, ev
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ
 
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
     
     ;;send command
     if upfd ge 0 then begin
        if shm_var[shm_uplink] then begin
           uplink,upfd,cmd
        endif else begin
           if strlen(cmd) eq 0 then writeu,upfd,10B else writeu,upfd,[byte(cmd),10B]
        endelse
     endif
    
     ;;print command to screen
     ts=gettimestamp('.')
     cmdstr=ts+': '+cmd
     widget_control,log_text,SET_VALUE=cmd,/APPEND

     ;;log command
     gsets=strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
     logfile='data/piccgse/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
     if not file_test(logfile) then begin
        ;;close logfile if it is open
        if n_elements(cmdlogfd) gt 0 then free_lun,cmdlogfd
        ;;open logfile
        openw,cmdlogfd,logfile,/get_lun
        print,'Widget opened: '+file_basename(logfile)
     endif
     printf,cmdlogfd,cmdstr
     
  endif
end

pro gse_command_buttons_event, ev 
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ

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
     shm_var[SHM_CMD]=1
     
  endif else print,'GSE Command ['+n2s(uval)+'] Not Recognized'

  ;;check for exit
  if NOT shm_var[SHM_RUN] then begin
     ;;unmap shared memory
     shmunmap,'shm'
     ;;close files
     close,/all
     ;;exit
     widget_control,base,/destroy
     return
  endif
end

pro gsepath_event, ev
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ
  common gsepath_block, path
 
  temp='piccgse.'+strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
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
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ

  ;;get light bitmaps
  red_light = read_bmp('bmp/red.bmp',/rgb)
  red_light = transpose(red_light,[1,2,0])
  green_light = read_bmp('bmp/green.bmp',/rgb)
  green_light = transpose(green_light,[1,2,0])
  
  ;;set lights
  if shm_var[SHM_LINK] then widget_control,link_connstat,set_value=green_light else widget_control,link_connstat,set_value=red_light
  if shm_var[SHM_DATA] then widget_control,data_connstat,set_value=green_light else widget_control,data_connstat,set_value=red_light
  
  ;;trigger self
  widget_control,ev.id,timer=0.5
end

pro piccgse_uplink_console
  common uplink_block,upfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common shmem_block, SHM_SIZE, SHM_RUN, SHM_RESET, SHM_LINK, SHM_DATA, SHM_CMD, SHM_TIMESTAMP, SHM_UPLINK, SHM_ACQ

  ;;restore settings
  restore,'settings.idl'
  
  ;;load buttons
  buttondb = load_buttondb()
  
  ;;setup shared memory
  shmmap, 'shm', /byte, shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  ;;choose serial device
  if(shm_var[shm_uplink]) then begin
     dev  = uplink_dev
     baud = uplink_baud
  endif else begin
     dev  = dnlink_dev
     baud = dnlink_baud
  endelse

  ;;open serial connection
  openw,upfd,dev,/get_lun,error=error
  if error ne 0 then begin
     print,'ERROR (piccgse_uplink_console): Could not open '+dev
     upfd = -1
  endif
  
  ;;configure serial port
  if upfd ge 0 then begin
     cmd = 'serial/serial_setup'
     spawn, cmd
     print,'UPLINK: Opened '+dev
     print,'UPLINK: Configured with: '+cmd
  endif

  ;;setup base widget
  wxs = 814
  wys = 291
  wxp = 35+324+6+200
  wyp = 2000
  title = 'PICTURE Uplink Command Console'
  base = WIDGET_BASE(xsize=wxs,ysize=wys,xoffset=wxp,yoffset=wyp,/row,title=title)
    
  ;;setup command log
  size = 32
  sub2 = widget_base(base,/column)
  log_label = widget_label(sub2,value='Command Log',/align_left)
  log_text  = widget_text(sub2,xsize=size,ysize=13)

  ;;setup command line
  size = 32
  cmd_label = widget_label(sub2,value='Command Line:',/align_left)
  cmd_text  = widget_text(sub2,xsize=size,ysize=1,/editable)
  xmanager,'command',sub2,/no_block

  ;;Column 1
  col1 = widget_base(base,/column,/align_top)

  ;;State buttons
  state_sub1 = widget_base(col1,/row,/align_center)            
  state_sub2 = widget_base(col1,column=1,/frame,/align_center) 
  button_label = widget_label(state_sub1,value='States',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'state' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(state_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',state_sub2,/no_block

  ;;Column 2
  col2 = widget_base(base,/column,/align_top)

  ;;Hex buttons
  hex_sub1 = widget_base(col2,/row,/align_center)            
  hex_sub2 = widget_base(col2,column=1,/frame,/align_center) 
  button_label = widget_label(hex_sub1,value='Hexapod',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'hex' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(hex_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',hex_sub2,/no_block

  ;;Column 3
  col3 = widget_base(base,/column,/align_top)

  ;;Other buttons
  other_sub1 = widget_base(col3,/row,/align_center)            
  other_sub2 = widget_base(col3,column=1,/frame,/align_center) 
  button_label = widget_label(other_sub1,value='Other',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'other' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(other_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',other_sub2,/no_block

  ;;Column 4
  col4 = widget_base(base,/column,/align_top)
  
  ;;Camera buttons
  cam_sub1 = widget_base(col4,/row,/align_center)            
  cam_sub2 = widget_base(col4,column=1,/frame,/align_center) 
  button_label = widget_label(cam_sub1,value='Cameras',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'camera' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(cam_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',cam_sub2,/no_block

  ;;Column 5
  col5 = widget_base(base,/column,/align_top)

  ;;Door buttons
  door_sub1 = widget_base(col5,/row,/align_center)            
  door_but1 = widget_base(col5,row=1,/frame,/align_center) 
  door_but2 = widget_base(col5,row=1,/frame,/align_center) 
  door_but3 = widget_base(col5,row=1,/frame,/align_center) 
  button_label = widget_label(door_sub1,value='Doors',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd1' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd2' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  sel = where(buttondb.type1 eq 'door' and buttondb.type2 eq 'd3' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(door_but3, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',col5,/no_block
 
  ;;Column 6
  col6 = widget_base(base,/column,/align_top)

  ;;LYT arrows
  lyt_arrow_sub1 = widget_base(col6,/row)
  button_label = widget_label(lyt_arrow_sub1,value='LYT:',/align_left)
  sel = where(buttondb.type1 eq 'lyt' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(lyt_arrow_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',lyt_arrow_sub1,/no_block

  ;;HEX arrows
  hex_arrow_sub1 = widget_base(col6,/row)
  button_label = widget_label(hex_arrow_sub1,value='HEX:',/align_left)
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
  hex_z_sub1 = widget_base(col6,/row)
  button_label = widget_label(hex_z_sub1,value='HEX:',/align_left)
  sel = where(buttondb.type1 eq 'hex' and buttondb.type2 eq 'z' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(hex_z_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',hex_z_sub1,/no_block

  ;;GSE buttons
  gse_sub1 = widget_base(col6,/row)
  button_label = widget_label(gse_sub1,value='GSE Commands:',/align_left)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(gse_sub1, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  xmanager,'gse_command_buttons',gse_sub1,/no_block
  
  ;;GSE path display
  gsepath = widget_base(col6,/row)
  gsepath_text = widget_text(gsepath,xsize=22,ysize=1)
  ;;install event handler
  xmanager,'gsepath',gsepath_text,/no_block

  ;;Status icons
  red_light   = read_bmp('bmp/red.bmp',/rgb)
  red_light   = transpose(red_light,[1,2,0])
  connstat       = widget_base(col6,/row)
  connstat_sub1  = widget_base(connstat,column=2,/frame)
  button_label = widget_label(connstat_sub1,value=' LINK ',/align_center)
  link_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light,/align_center)
  button_label = widget_label(connstat_sub1,value=' DATA ',/align_center)
  data_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light,/align_center)
  ;;install event handler
  xmanager,'connstat',connstat,/no_block
 
  ;;create widgets
  widget_control,base,/realize

  ;;update gsepath
  widget_control,gsepath_text,timer=0

  ;;start status icons
  widget_control,connstat,timer=0
  
end
