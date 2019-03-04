;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path, set  
  common piccgse_block, set
  
  ;;Open the config file
  openr, unit, path, /get_lun
  
  ;;Read config file
  line = ''
  for i=0L,file_lines(path)-1 do begin

     ;;Read line
     readf, unit, line
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
           ;;Data Settings
           'TMSERVER_TYPE'   : set.tmserver_type     = value
           'TMSERVER_ADDR'   : set.tmserver_addr     = value
           'TMSERVER_PORT'   : set.tmserver_port     = value
           'TMSERVER_TMFILE' : set.tmserver_tmfile   = value
           'TMSERVER_IDLFILE': set.tmserver_idlfile  = value

           ;;SHK Window
           'SHK_NAME'        : set.w[set.wshk].name  = value
           'SHK_XSIZE'       : set.w[set.wshk].xsize = value
           'SHK_YSIZE'       : set.w[set.wshk].ysize = value
           'SHK_XPOS'        : set.w[set.wshk].xpos  = value
           'SHK_YPOS'        : set.w[set.wshk].ypos  = value
           'SHK_FONT'        : set.w[set.wshk].font  = value
           
           ;;LYT Window
           'LYT_NAME'        : set.w[set.wlyt].name  = value
           'LYT_XSIZE'       : set.w[set.wlyt].xsize = value
           'LYT_YSIZE'       : set.w[set.wlyt].ysize = value
           'LYT_XPOS'        : set.w[set.wlyt].xpos  = value
           'LYT_YPOS'        : set.w[set.wlyt].ypos  = value
           'LYT_FONT'        : set.w[set.wlyt].font  = value
           
           ;;ALP Window
           'ALP_NAME'        : set.w[set.walp].name  = value
           'ALP_XSIZE'       : set.w[set.walp].xsize = value
           'ALP_YSIZE'       : set.w[set.walp].ysize = value
           'ALP_XPOS'        : set.w[set.walp].xpos  = value
           'ALP_YPOS'        : set.w[set.walp].ypos  = value
           'ALP_FONT'        : set.w[set.walp].font  = value
           
           ;;BMC Window
           'BMC_NAME'        : set.w[set.wbmc].name  = value
           'BMC_XSIZE'       : set.w[set.wbmc].xsize = value
           'BMC_YSIZE'       : set.w[set.wbmc].ysize = value
           'BMC_XPOS'        : set.w[set.wbmc].xpos  = value
           'BMC_YPOS'        : set.w[set.wbmc].ypos  = value
           'BMC_FONT'        : set.w[set.wbmc].font  = value
           
           ;;ACQ Window
           'ACQ_NAME'        : set.w[set.wacq].name  = value
           'ACQ_XSIZE'       : set.w[set.wacq].xsize = value
           'ACQ_YSIZE'       : set.w[set.wacq].ysize = value
           'ACQ_XPOS'        : set.w[set.wacq].xpos  = value
           'ACQ_YPOS'        : set.w[set.wacq].ypos  = value
           'ACQ_FONT'        : set.w[set.wacq].font  = value
           
           ;;SCI Window
           'SCI_NAME'        : set.w[set.wsci].name  = value
           'SCI_XSIZE'       : set.w[set.wsci].xsize = value
           'SCI_YSIZE'       : set.w[set.wsci].ysize = value
           'SCI_XPOS'        : set.w[set.wsci].xpos  = value
           'SCI_YPOS'        : set.w[set.wsci].ypos  = value
           'SCI_FONT'        : set.w[set.wsci].font  = value
           
           ;;ZER Window
           'ZER_NAME'        : set.w[set.wzer].name  = value
           'ZER_XSIZE'       : set.w[set.wzer].xsize = value
           'ZER_YSIZE'       : set.w[set.wzer].ysize = value
           'ZER_XPOS'        : set.w[set.wzer].xpos  = value
           'ZER_YPOS'        : set.w[set.wzer].ypos  = value
           'ZER_FONT'        : set.w[set.wzer].font  = value
           
           ;;THM Window
           'THM_NAME'        : set.w[set.wthm].name  = value
           'THM_XSIZE'       : set.w[set.wthm].xsize = value
           'THM_YSIZE'       : set.w[set.wthm].ysize = value
           'THM_XPOS'        : set.w[set.wthm].xpos  = value
           'THM_YPOS'        : set.w[set.wthm].ypos  = value
           'THM_FONT'        : set.w[set.wthm].font  = value
           
 
           else : stop,'ERROR (piccgse_loadConfig): Tag '+tag+' not found'
        endcase
     endif
  endfor
  

  ;;Close the config file
  free_lun,cunit
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_setupFiles
;;  - procedure to setup paths and open logfiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
  common piccgse_block, set
  
  ;;set paths and filenames
  STARTUP_TIMESTAMP = gettimestamp('.')
  set.datapath = 'data/data/piccgse.'+STARTUP_TIMESTAMP+'/'
  check_and_mkdir,set.datapath
  pktlogfile = set.datapath+'piccgse.'+STARTUP_TIMESTAMP+'.pktlog.txt'
  
  ;;close open files
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit
  
  ;;open logs
  openw,pktlogunit,pktlogfile,/get_lun,error=con_status
  set.pktlogunit=pktlogunit
  if(con_status eq 0) then print,'Opened: '+file_basename(pktlogfile)+' fd: '+n2s(set.pktlogunit) else print,'Failed: '+file_basename(pktlogfile)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_createWindows
;;  - procedure to create all interface windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_createWindows
  common piccgse_block, set
  for i=0, n_elements(set.w)-1 do begin
     if set.w[i].show then WINDOW, set.w[i].index, XSIZE=set.w[i].xsize, YSIZE=set.w[i].ysize,$
                                   XPOS=set.w[i].xpos, YPOS=set.w[i].ypos, TITLE=set.w[i]name,RETAIN=2
  endfor
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_newWindows
;;  - function to decide if we need to restart any windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION piccgse_newWindows, old
  common piccgse_block, set
  for i=0, n_elements(set.w)-1 do begin
     if (old.w[i].xsize NE set.w[i].xsize) OR  (old.w[i].ysize NE set.w[i].ysize) OR $ 
        (old.w[i].xpos NE set.w[i].xpos)   OR  (old.w[i].ypos NE set.w[i].ypos)   OR $
        (old.w[i].show NE set.w[i].show) then return, 1
  endfor
  return, 0
       
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_processData
;;  - procedure to process and plot data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_processData, header, packet
  common piccgse_block, set
 
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_tmConnect
;;  - function to connect to the image server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function piccgse_tmConnect
  common piccgse_block, set

  ;;Check if we are reading from a file
  if set.tmserver_type eq 'tmfile' then begin
     openr,TMUNIT,set.tmserver_tmfile,/GET_LUN,ERROR=con_status
     
     if con_status eq 0 then begin
        MESSAGE, 'File opened.', /INFORM
        return, TMUNIT
     endif else begin
        MESSAGE, !ERR_STRING, /INFORM
     endelse
  endif
  
  ;;Check if we are reading form the network
  if set.tmserver_type eq 'network' then begin
     ;;Command to ask server for data
     ;;NOTE: Investigate why the endian is different, both are x86 PCs
     if set.tmserver_addr eq 'picture'   then CMD_SENDDATA = swap_endian('0ABACABB'XUL)
     if set.tmserver_addr eq 'localhost' then CMD_SENDDATA = swap_endian('0ABACABB'XUL)
     if set.tmserver_addr eq 'tmserver'  then CMD_SENDDATA = '22220001'XUL
     
     ;;Create Socket connection
     PRINT, 'Attempting to create Socket connection Image Server to >'+set.tmserver_addr+'< on port '+n2s(set.tmserver_port)
     SOCKET, TMUNIT, set.tmserver_addr, set.tmserver_port, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status, READ_TIMEOUT=2
     if con_status eq 0 then begin
        PRINT, 'Socket created'
        ;;Ask for images
        ON_IOERROR, WRITE_ERROR
        WRITEU,TMUNIT,CMD_SENDDATA
        return,TMUNIT
     endif else begin
        MESSAGE, !ERR_STRING, /INFORM
     endelse
     WRITE_ERROR:PRINT, !ERR_STRING  ;;jump here on writeu error
     return,-1
  endif
  
  ;;Should never get to this point
  return,-1
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;piccgse
;; -- Main program
;; -- Display science products in several windows
;;
;;KEYWORDS:
;;   NOSAVE
;;      Do not save data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse, NOSAVE=NOSAVE
  common piccgse_block, set

;*************************************************
;* DEFINE SETTINGS STRUCTURES
;*************************************************
  ;;Windows
  win = {name:'',xsize:0,ysize:0,xpos:0,ypos:0,index:0,font:'',show:0}

  ;;Settings
  set = {tmserver_type:'',tmserver_addr:'',tmserver_port:0U,$
         tmserver_tmfile:'',tmserver_idlfile:'',datapath:'',pktlogunit:0,$
         wshk:0,wlyt:1,walp:2,wbmc:3,wsci:4,wacq:5,wzer:6,wthm:7,w:replicate(win,8)}

;*************************************************
;* GET INFORMATION FROM FLIGHT SOFTWARE
;*************************************************
  ;;Flight software header file
  header='../piccflight/src/controller.h'

  ;;Buffer IDs
  buffer_id = read_c_enum(header,'bufids')
  for i=0, n_elements(buffer_id)-1 do void=execute(buffer_id[i]+'='+n2s(i))
  
  ;;Build packet structures
  pkthed   = read_c_struct(header,'pkthed')
  shkfull  = read_c_struct(header,'shkfull')
  acqfull  = read_c_struct(header,'acqfull')
  lytevent = read_c_struct(header,'lytevent')
  scievent = read_c_struct(header,'scievent')
  thmevent = read_c_struct(header,'thmevent')
  mtrevent = read_c_struct(header,'mtrevent')

  ;;Check for padding
  if check_padding(pkthed)   then stop,'pkthed contains padding'
  if check_padding(shkfull)  then stop,'shkfull contains padding'
  if check_padding(acqfull)  then stop,'acqfull contains padding'
  if check_padding(lytevent) then stop,'lytevent contains padding'
  if check_padding(scievent) then stop,'scievent contains padding'
  if check_padding(thmevent) then stop,'thmevent contains padding'
  if check_padding(mtrevent) then stop,'mtrevent contains padding'

  ;;Remove headers from structures -- they are read seperately
  struct_delete_field,shkfull,'hed'
  struct_delete_field,acqfull,'hed'
  struct_delete_field,lytevent,'hed'
  struct_delete_field,scievent,'hed'
  struct_delete_field,thmevent,'hed'
  struct_delete_field,mtrevent,'hed'

  ;;Get states & calmodes
  states = read_c_enum(header,'states')
  for i=0, n_elements(states)-1 do void=execute(states[i]+'='+n2s(i))
  alpcalmodes = read_c_enum(header,'alpcalmodes')
  for i=0, n_elements(calmodes)-1 do void=execute(alpcalmodes[i]+'='+n2s(i))
  hexcalmodes = read_c_enum(header,'hexcalmodes')
  for i=0, n_elements(calmodes)-1 do void=execute(hexcalmodes[i]+'='+n2s(i))
  tgtcalmodes = read_c_enum(header,'tgtcalmodes')
  for i=0, n_elements(calmodes)-1 do void=execute(tgtcalmodes[i]+'='+n2s(i))
  bmccalmodes = read_c_enum(header,'bmccalmodes')
  for i=0, n_elements(calmodes)-1 do void=execute(bmccalmodes[i]+'='+n2s(i))

  ;;Get #defines
  SHKBIN = read_c_define(header,"SHKBIN")
  LOWFS_N_ZERNIKE = read_c_define(header,"LOWFS_N_ZERNIKE")
  LOWFS_N_PID = read_c_define(header,"LOWFS_N_PID")

;*************************************************
;* LOAD CONFIGURATION FILE
;*************************************************
  config_file = 'piccgse.conf'
  config_props = FILE_INFO(config_file)
  if config_props.exists EQ 0 then stop, 'ERROR: Config file '+config_file+' not found'
  cfg_mod_sec = config_props.mtime
  piccgse_loadConfig, config_file
  
;*************************************************
;* INIT CONNECTIONS
;*************************************************
  tm_connected = 0
  tm_last_connected = -1
  tm_last_data      = -1
  TMUNIT = -1
  sync = 0U

;*************************************************
;* SETUP FILES
;*************************************************
  piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP

;*************************************************
;* CREATE WINDOWS
;*************************************************
  piccgse_createWindows
 
;*************************************************
;* INIT TIMERS
;*************************************************
  ;;start time
  t_start = SYSTIME(1)
  
  ;;last time any telemetry was received
  t_last_telemetry = SYSTIME(1)

  ;;last time config file was checked
  t_last_cfg = SYSTIME(1)       

  ;;last time main loop finished
  t_last_loop = SYSTIME(1) 
  
;*************************************************
;* SETUP DATA PLAYBACK
;*************************************************
  if(set.tmserver_type eq 'idlfile') then begin
     ;;get filenames
     idlfiles = file_search(set.tmserver_idlfile,count=nfiles)
     ifile = 0L
     print,'Opening idlfile images'
     help,idlfiles
  endif
  
;*************************************************
;* SETUP SHARED MEMORY
;*************************************************
  restore,'shmdef.idl'
  shmmap, 'shm', /byte, shm_size
  ;;NOTE: This creates a file /dev/shm/shm of size shm_size bytes
  ;;      The file does not get deleted when you quit IDL, so if
  ;;      shm_size changes, you must delete this file manualy. 
  
  shm_var = shmvar('shm')
  shm_var[*] = bytarr(shm_size)
  shm_var[SHM_RUN] = 1
  shm_var[SHM_TIMESTAMP:SHM_TIMESTAMP+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
  print,'Shared memory mapped'
  
;*************************************************
;* START CONSOLE WIDGETS
;*************************************************
  ;;Get working directory
  cd,current=working_dir
  ;;Create uplink console object
  obridge_up=obj_new("IDL_IDLBridge",output='')
  ;;Set path
  obridge_up->setvar,'!PATH',!PATH
  ;;CD to working directory
  obridge_up->execute,"cd,'"+working_dir+"'"
  ;;Launch console
  obridge_up->execute,'piccgse_uplink_console'
  ;;Create downlink console object
  obridge_dn=obj_new("IDL_IDLBridge",output='')
  ;;Set path
  obridge_dn->setvar,'!PATH',!PATH
  ;;CD to working directory
  obridge_dn->execute,"cd,'"+working_dir+"'"
  ;;Launch console
  obridge_dn->execute,'piccgse_downlink_console'
  print,'Up/Down Console widgets started'

;*************************************************
;* INSTALL ERROR HANDLER
;  -- This may have been made obsolete by the use
;     of ON_IOERROR, but we'll leave it here to
;     be safe
;*************************************************
  CATCH,error_status

  if error_status ne 0 then begin 
     print,!ERROR_STATE.MSG,error_status
     
     ;;READU EOF errors
     if error_status eq -262 then begin
        print,'Resetting TM connection'
        free_lun,TMUNIT
        tm_connected=0
     endif
     CATCH, /CANCEL
  endif

;*************************************************
;* MAIN LOOP
;*************************************************
  while 1 do begin
     ;;Get time
     t_now = SYSTIME(1)
     
     ;;----------------------------------------------------------
     ;;Decide how we will read data (idlfile,tmfile,network)
     ;;----------------------------------------------------------
     
     ;;READ DATA FROM TMSERVER_IDLFILE [Read back IDL savefiles]
     if set.tmserver_type eq 'idlfile' then begin
        if nfiles eq 0 then begin
           print,'No IDL files found @: '+set.tmserver_idlfile
           wait,1
        endif else begin
           restore,idlfiles[ifile]
           ;;process data
           piccgse_processDATA,header,packet
           ;;save time
           t_last_telemetry = t_now
           ;;increment file for next time
           ifile = (ifile+1) mod nfiles
        endelse
     endif

     ;;READ DATA FROM NETWORK OR TMFILE
     ;;-- Expected data: experiment data with empty codes (0xFADE) stripped out
     if set.tmserver_type eq 'network' OR set.tmserver_type eq 'tmfile' then begin
        if tm_connected then begin
           ;;Install error handler
           ON_IOERROR, RESET_CONNECTION
           ;;Set link status
           shm_var[SHM_LINK] = 1
           ;;Wait for data
           if file_poll_input(TMUNIT,timeout=0.01) then begin
              ;;Set data status
              shm_var[SHM_DATA] = 1
              tm_last_data = systime(1)
              ;;Check presync words
              readu, TMUNIT, sync
              if sync eq lss(TLM_PRESYNC) then begin
                 readu, TMUNIT, sync
                 if sync eq mss(TLM_PRESYNC) then begin
                    ;;Read header
                    readu, TMUNIT, pkthed
                    ;;Get frame number
                    sfn = n2s(pkthed.frame_number,format='(I8.8)')
                    ;;Init packet string tag
                    tag=''
                    ;;Identify data
                    case pkthed.type of
                       BUFFER_SHKPKT: begin
                          tag = 'shkpkt'
                          pkt = shkpkt
                       end
                       BUFFER_LYTPKT: begin
                          tag = 'lytpkt'
                          pkt = lytpkt
                       end
                       BUFFER_SCIEVENT: begin
                          tag = 'scievent'
                          pkt = scievent
                       end
                       BUFFER_ACQEVENT: begin
                          tag = 'acqevent'
                          pkt = acqevent
                       end
                       BUFFER_MTREVENT: begin
                          tag = 'mtrevent'
                          pkt = mtrevent
                       end
                       BUFFER_THMEVENT: begin
                          tag = 'thmevent'
                          pkt = thmevent
                       end
                    endcase
                    ;;If we identified the packet
                    if tag ne '' then begin 
                       ;;read and process packet
                       msg1 = gettimestamp('.')+': '+'header.'+tag+'.'+sfn
                       printf,set.pktlogunit,msg1
                       ;;read packet
                       readu, TMUNIT, pkt
                       ;;check postsync words 
                       readu, TMUNIT, sync
                       if(sync eq lss(TLM_POSTSYNC)) then begin
                          readu, TMUNIT, sync
                          if(sync eq mss(TLM_POSTSYNC))then begin
                             ;;process packet
                             piccgse_processData,pkthed,pkt
                             msg2 = gettimestamp('.')+': '+'packet.'+tag+'.'+sfn
                          endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps2.'+n2s(sync,format='(Z4.4)')
                       endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps1.'+n2s(sync,format='(Z4.4)')
                       printf,set.pktlogunit,msg2
                       first = strpos(msg2,'dropped')
                       if(first ge 0) then print,msg2
                    endif else begin
                       ;;Unknown packet
                       msg=gettimestamp('.')+': '+'unknown.'+n2s(pkthed.type)+'.'+sfn
                       printf,set.pktlogunit,msg
                       print,msg
                       print,'PKTHED: '+n2s(pkthed.type,format='(Z)')+'     '+sfn
                    endelse
                 endif
              endif
           endif else begin
              ;;here if FILE_POLL_INPUT timed out
              ;;if no data, check for timeout
              ;;if timed out, reconnect
              if ((t_now-tm_last_data) GT 20) then begin
                 RESET_CONNECTION: PRINT, !ERR_STRING ;;Jump here if an IO error occured
                 print,"IMAGE SERVER TIMEOUT!"
                 print,''
                 ON_IOERROR,FREE_LUN_ERROR
                 free_lun,TMUNIT
                 FREE_LUN_ERROR: ;PRINT, !ERR_STRING
                 tm_connected = 0
                 shm_var[SHM_LINK] = 0
                 shm_var[SHM_DATA] = 0
              endif
           endelse
        endelse
     endif else begin
        ;;if not connected, reconnect
        TMUNIT = piccgse_tmConnect()
        if TMUNIT GT 0 then begin 
           tm_connected = 1 
           tm_last_connected = systime(1)
           tm_last_data      = systime(1)
        endif else wait,1
     endelse
     
     ;;----------------------------------------------------------
     ;; Check config file
     ;;----------------------------------------------------------
     ;;Has config file been modified?
     if (t_now-t_last_cfg) GT 0.5 then begin
        
        ;;Get config file properties
        config_props = FILE_INFO(config_file)
        
        ;;Update last time config file was checked
        t_last_cfg = SYSTIME(1)
        
        ;;If config file has been modified then load the new version
        if config_props.mtime NE cfg_mod_sec then begin
           PRINT, 'Loading modified configuration file'
           cfg_mod_sec = config_props.mtime
           old_set = set
           piccgse_loadConfig, config_file
           if(set.tmserver_type eq 'idlfile') then begin
              ;;get filenames
              idlfiles = file_search(set.tmserver_idlfile,count=nfiles)
              
              print,'Opening idlfile images'
              help,idlfiles
           endif

           ;;Check if hist structure needs to be reset
           
           if piccgse_newWindows(old_set) then piccgse_createWindows
           
        endif
     endif
     
     ;;----------------------------------------------------------
     ;; Check for commands
     ;;----------------------------------------------------------
     if shm_var[SHM_CMD] then begin
        ;;reset command bit
        shm_var[SHM_CMD]=0
        
        ;;exit
        if NOT shm_var[SHM_RUN] then begin
           if TMUNIT gt 0 then free_lun,TMUNIT
           if set.pktlogunit gt 0 then free_lun,set.pktlogunit
           obj_destroy,obridge_up
           obj_destroy,obridge_dn
           shmunmap,'shm'
           print,'Shared memory unmapped'
           while !D.WINDOW ne -1 do wdelete
           print,'Exiting IDL'
           exit
        endif
        
        ;;plot type
        set.plottype=shm_var[SHM_PTYPE]
        
        ;;reset
        if shm_var[SHM_RESET] then begin
           shm_var[SHM_RESET]=0
           print,'Resetting paths...'
           piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
           ;;set timestamp in shared memory
           shm_var[SHM_TIMESTAMP:SHM_TIMESTAMP+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
        endif
     endif
     
     ;;----------------------------------------------------------
     ;; Save loop time
     ;;----------------------------------------------------------
     t_last_loop = t_now

     ;;----------------------------------------------------------
     ;; Sleep if necessary
     ;;----------------------------------------------------------
     if set.tmserver_type eq 'idlfile' OR set.tmserver_type eq 'tmfile' then wait,0.01
  endwhile

  ;;shutdown
  if TMUNIT gt 0 then free_lun,TMUNIT
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit
  obj_destroy,obridge_up
  obj_destroy,obridge_dn
  shmunmap,'shm'
  print,'Shared memory unmapped'
  while !D.WINDOW ne -1 do wdelete
end
