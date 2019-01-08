pro command_event, ev
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common command_block, SHM_SIZE, SHM_TIMESTAMP
  if n_elements(SHM_SIZE) eq 0 then restore,'shmdef.idl'
  
  ;;command line event
  widget_control,ev.id,GET_VALUE=val
  
  ;;send command
  printf,serfd,val
  
  ;;print command to screen
  ts=gettimestamp('.')
  cmdstr=ts+': '+val
  widget_control,log_text,SET_VALUE=cmdstr,/APPEND
  widget_control,ev.id,set_value=''
  
  ;;log command
  gsets=strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
  logfile='data/gsedata/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
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
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common serial_command_block, SHM_SIZE, SHM_TIMESTAMP
  if n_elements(SHM_SIZE) eq 0 then restore,'shmdef.idl'
 
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
     printf,serfd,cmd
     
     ;;print command to screen
     ts=gettimestamp('.')
     cmdstr=ts+': '+cmd
     widget_control,log_text,SET_VALUE=cmdstr,/APPEND

     ;;log command
     gsets=strcompress(string(shm_var[SHM_TIMESTAMP:n_elements(shm_var)-1]),/REMOVE_ALL)
     logfile='data/gsedata/piccgse.'+gsets+'/piccgse.'+gsets+'.cmdlog.txt'
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
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common gse_command_block, SHM_SIZE, SHM_CMD
  if n_elements(SHM_SIZE) eq 0 then restore,'shmdef.idl'

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
     
     ;;check for exit
     if buttondb[sel].igse eq 0 and buttondb[sel].vgse eq 0 then begin
        ;;unmap shared memory
        shmunmap,'shm'
        ;;close files
        close,/all
        ;;exit
        widget_control,base,/destroy
     endif
  endif else print,'GSE Command ['+n2s(uval)+'] Not Recognized'
end

pro gsepath_event, ev
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common gsepath_block, path, SHM_SIZE, SHM_TIMESTAMP
  if n_elements(SHM_SIZE) eq 0 then restore,'shmdef.idl'
 
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
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat
  common connstat_block, SHM_SIZE, SHM_LINK, SHM_DATA
  if n_elements(SHM_SIZE) eq 0 then restore,'shmdef.idl'

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
  common uplink_block,serfd,cmdlogfd,base,con_text,log_text,cmd_text,shm_var,buttondb,link_connstat,data_connstat

  ;;move to the correct working directory, starts in /home/cmendill
  CD,'/home/cmendill/code/piccgse/',current=old_dir

  
  ;;restore shared memory definitions
  restore,'shmdef.idl'
  
  
  ;;restore button commands
  restore,'buttondef.idl'
  
  ;;setup serial port
  spawn,'./serial/serial_setup'

  ;;open serial connection
  dev = '/dev/ttyUSB0'
  openw,serfd,dev,/get_lun
  
  ;;setup shared memory
  shm_size = 128
  shmmap, 'shm', /byte, shm_size
  shm_var = shmvar('shm')
  print,'Shared memory mapped'

  ;;setup base widget
  downlink_xs = 500
  nudge = 16
  screen_dimensions = get_screen_size()
  sxs = fix(screen_dimensions[0])
  sys = fix(screen_dimensions[1])
  wxs = sxs-downlink_xs-nudge
  wys = 268
  wxp = downlink_xs+nudge
  wyp = sys-wys
  title = 'PICTURE Uplink Command Console'
  base = WIDGET_BASE(xsize=wxs,ysize=wys,xoffset=wxp,yoffset=wyp,/row,title=title)
    
  ;;setup command log
  size = 50
  sub2 = widget_base(base,/column)
  log_label = widget_label(sub2,value='Command Log',/align_left)
  log_text  = widget_text(sub2,xsize=size,ysize=13)

  ;;setup command line
  size = 50
  cmd_label = widget_label(sub2,value='Command Line:',/align_left)
  cmd_text  = widget_text(sub2,xsize=size,ysize=1,/editable)
  xmanager,'command',sub2,/no_block
  
  
 ;;Camera flight buttons
  camflt  = widget_base(base,/column,/align_center)
  camflt_sub1 = widget_base(camflt,/row,/align_center)
  camflt_sub2 = widget_base(camflt,column=1,/frame,/align_center)
  button_label = widget_label(camflt_sub1,value='Camera Commands',/align_center)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'camera_flight' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(camflt_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',camflt_sub2,/no_block


  ;;Status icons
  red_light   = read_bmp('bmp/red.bmp',/rgb)
  red_light   = transpose(red_light,[1,2,0])
  connstat       = widget_base(camflt,/row)
  connstat_sub1  = widget_base(connstat,column=2,/frame)
  button_label = widget_label(connstat_sub1,value=' LINK ',/align_center)
  link_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light,/align_center)
  button_label = widget_label(connstat_sub1,value=' DATA ',/align_center)
  data_connstat = WIDGET_BUTTON(connstat_sub1, VALUE=red_light,/align_center)
  ;;install event handler
  xmanager,'connstat',connstat,/no_block



  ;;FPS flight buttons
  fpsflt  = widget_base(base,/column)
  fpsflt_sub1 = widget_base(fpsflt,/row)
  fpsflt_sub2 = widget_base(fpsflt,column=3,/frame)
  button_label = widget_label(fpsflt_sub1,value='FPS Commands',/align_left)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'fps_flight' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(fpsflt_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',fpsflt_sub2,/no_block
  
  ;;GSE path display
  fpsflt_sub3 = widget_base(fpsflt,/row)
  gsepath_label = widget_label(fpsflt_sub3,value='GSE Path: ',/align_left)
  gsepath_text = widget_text(fpsflt_sub3,xsize=22,ysize=1)
  ;;install event handler
  xmanager,'gsepath',gsepath_text,/no_block



  ;;nuller flight buttons
  nullflt  = widget_base(base,/column)
  nullflt_sub1 = widget_base(nullflt,/row)
  nullflt_sub2 = widget_base(nullflt,column=3,/frame)
  button_label = widget_label(nullflt_sub1,value='Nuller Commands',/align_left)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'nuller_flight' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(nullflt_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;--make arrow buttons
  nullflt_sub3 = widget_base(nullflt,/row)
  button_label = widget_label(nullflt_sub3,value='WFS Window: ',/align_left)
  sel = where(buttondb.type1 eq 'nuller_flight' and buttondb.type2 eq 'arrow' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(nullflt_sub3, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip,/BITMAP)
     endfor
  endif
  ;;install event handler
  xmanager,'serial_command_buttons',nullflt,/no_block
 
   ;;GSE buttons
  gse  = widget_base(base,/column)
  gse_sub1 = widget_base(gse,/row)
  gse_sub2 = widget_base(gse,column=1,/frame)
  button_label = widget_label(gse_sub1,value='GSE Commands',/align_left)
  ;;--make buttons
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq '' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     for i=0,n_elements(buttons)-1 do begin
        bid = WIDGET_BUTTON(gse_sub2, VALUE=buttons[i].name, UVALUE=buttons[i].id, TOOLTIP=buttons[i].tooltip)
     endfor
  endif
  ;;--make plottype dropdown
  sel = where(buttondb.type1 eq 'gse' and buttondb.type2 eq 'plottype' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_droplist(gse_sub2,VALUE=buttons.name,uvalue=buttons.id)
  endif
  xmanager,'gse_command_buttons',gse_sub2,/no_block

  ;;STATES buttons
  states  = gse;widget_base(base,/row)
  states_sub1 = widget_base(states,/row)
  states_sub2 = widget_base(states,column=1,/frame)
  button_label = widget_label(states_sub1,value='Test States',/align_left)
  ;;--make plottype dropdown
  sel = where(buttondb.type1 eq 'states' and buttondb.show eq 1,nsel)
  if nsel gt 0 then begin
     buttons = buttondb[sel]
     dropid=widget_list(states_sub2,VALUE=buttons.name,uvalue=buttons.id,SCR_YSIZE=105,SCR_XSIZE=120)
  endif
  xmanager,'serial_command_buttons',states_sub2,/no_block


  ;;create widgets
  widget_control,base,/realize

  ;;update gsepath
  widget_control,gsepath_text,timer=0

  ;;start status icons
  widget_control,connstat,timer=0
  
end
