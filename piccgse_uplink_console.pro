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
     ;;Print packet
     ;;print,'Sent: '+string(pkt[0:25],format='(65Z3.2)')
     ;;for i=1,9 do print,'      '+string(pkt[26*i:26*i+25],format='(65Z3.2)')
  endelse
end

pro command_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;command line event
  widget_control,ev.id,GET_VALUE=cmd_array

  ;;loop over multiple commands
  for icmd=0,n_elements(cmd_array)-1 do begin
     cmd = cmd_array[icmd]
     ;;send command
     if shm_var[settings.shm_uplink] then begin
        if upfd ge 0 then begin
           ;;use uplink port
           if strlen(cmd) eq 0 then uplink,upfd,string(10B) else uplink,upfd,cmd
        endif
     endif else begin
        if dnfd ge 0 then begin
           ;;use downlink port
           if strlen(cmd) eq 0 then writeu,dnfd,10B else writeu,dnfd,[byte(cmd),10B]
        endif
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
        if n_elements(cmdlogfd) gt 0 then free_lun,cmdlogfd
        ;;open logfile
        openw,cmdlogfd,logfile,/get_lun
        print,'Widget opened: '+file_basename(logfile)
     endif
     printf,cmdlogfd,cmdstr
  endfor
  
end


pro serial_command_buttons_event, ev
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat
 
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
        scale = 0.001d
        dv = -dx * scale ;;+X = +V
        du =  dy * scale ;;+Y = -U
        cr = string(10B)
        cmd = 'hex move du '+n2s(du,format='(F15.4)')+cr+'hex move dv '+n2s(dv,format='(F15.4)')
     endif
     
     ;;send command
     if shm_var[settings.shm_uplink] then begin
        ;;use uplink port
        if upfd ge 0 then begin
           uplink,upfd,cmd
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
        if n_elements(cmdlogfd) gt 0 then free_lun,cmdlogfd
        ;;open logfile
        openw,cmdlogfd,logfile,/get_lun
        print,'Widget opened: '+file_basename(logfile)
     endif
     printf,cmdlogfd,cmdstr
     
  endif
end

pro gse_command_buttons_event, ev 
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

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
     
  endif else print,'GSE Command ['+n2s(uval)+'] Not Recognized'

  ;;check for exit
  if NOT shm_var[settings.shm_run] then begin
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
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat
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
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

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

pro piccgse_uplink_console
  common uplink_block,settings,upfd,dnfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat,uplk_connstat

  ;;load settings
  settings = load_settings()
  
  ;;load buttons
  buttondb = load_buttondb()
  
  ;;setup shared memory
  shmmap, 'shm', /byte, settings.shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  ;;Open uplink console (write-only)
  openw,upfd,settings.uplink_dev,/get_lun,error=error
  if error ne 0 then begin
     print,'ERROR (piccgse_uplink_console): Could not open '+settings.uplink_dev
     upfd = -1
  endif else print,'UPLINK: Opened '+settings.uplink_dev+' for writing'

  ;;Open dnlink console (write-only)
  openw,dnfd,settings.dnlink_dev,/get_lun,error=error
  if error ne 0 then begin
     print,'ERROR (piccgse_uplink_console): Could not open '+settings.dnlink_dev
     dnfd = -1
  endif else print,'UPLINK: Opened '+settings.dnlink_dev+' for writing'
  
  ;;configure serial ports
  if (upfd ge 0) OR (dnfd ge 0) then begin
     cmd = 'serial/serial_setup'
     spawn, cmd
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
  door_sub2 = widget_base(col5,column=1,/align_center)
  door_but1 = widget_base(door_sub2,row=1,/frame,/align_center) 
  door_but2 = widget_base(door_sub2,row=1,/frame,/align_center) 
  door_but3 = widget_base(door_sub2,row=1,/frame,/align_center) 
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

  ;;--install event handler
  xmanager,'serial_command_buttons',door_sub2,/no_block

  ;;SCI Display Type
  scitype_sub1 = widget_base(col5,/row,/align_center)            
  scitype_sub2 = widget_base(col5,column=1,/align_center)            
  scitype_but1 = widget_base(scitype_sub2,row=1,/align_center)
  button_label = widget_label(scitype_sub1,value='SCI Type',/align_center)
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq 'scitype' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_droplist(scitype_but1,VALUE=buttons.name,uvalue=buttons.id)
  endif

  ;;--install event handler
  xmanager,'gse_command_buttons',scitype_sub2,/no_block

  ;;BMC Display Type
  bmctype_sub1 = widget_base(col5,/row,/align_center)            
  bmctype_sub2 = widget_base(col5,column=1,/align_center)            
  bmctype_but1 = widget_base(bmctype_sub2,row=1,/align_center)
  button_label = widget_label(bmctype_sub1,value='BMC Type',/align_center)
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq 'bmctype' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_droplist(bmctype_but1,VALUE=buttons.name,uvalue=buttons.id)
  endif

  ;;--install event handler
  xmanager,'gse_command_buttons',bmctype_sub2,/no_block
 
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

  ;;SHK arrows
  shk_arrow_sub1 = widget_base(col6,/row)
  button_label = widget_label(shk_arrow_sub1,value='SHK:',/align_left)
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
  sci_arrow_sub1 = widget_base(col6,/row)
  button_label = widget_label(sci_arrow_sub1,value='SCI:',/align_left)
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
  ;hex_z_sub1 = widget_base(col6,/row)
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
  connstat_sub1  = widget_base(connstat,column=3,/frame)
  button_label = widget_label(connstat_sub1,value=' LINK ',/align_center)
  link_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='link', TOOLTIP='TM Link Status',/align_center)
  button_label = widget_label(connstat_sub1,value=' DATA ',/align_center)
  data_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='data', TOOLTIP='TM Data Status',/align_center)
  button_label = widget_label(connstat_sub1,value=' UPLK ',/align_center)
  uplk_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light, UVALUE='uplink', TOOLTIP='Toggle Uplink Command',/align_center)
  ;;install event handler
  xmanager,'connstat',connstat,/no_block
 
  ;;create widgets
  widget_control,base,/realize

  ;;update gsepath
  widget_control,gsepath_text,timer=0

  ;;start status icons
  widget_control,connstat,timer=0,set_uval='timer'
  
end
