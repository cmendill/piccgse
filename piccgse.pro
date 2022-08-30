;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path, TMTYPE=TMTYPE, TMADDR=TMADDR, TMPORT=TMPORT, TMFILE=TMFILE, IDLFILE=IDLFILE
  common piccgse_block, settings, set, shm_var


  ;;Get window indicies
  wshk = where(set.w.id eq 'shk')
  wlyt = where(set.w.id eq 'lyt')
  wacq = where(set.w.id eq 'acq')
  wsci = where(set.w.id eq 'sci')
  walp = where(set.w.id eq 'alp')
  wbmc = where(set.w.id eq 'bmc')
  wshz = where(set.w.id eq 'shz')
  wlyz = where(set.w.id eq 'lyz')
  wthm = where(set.w.id eq 'thm')
  wsda = where(set.w.id eq 'sda')
  wlda = where(set.w.id eq 'lda')
  wbmd = where(set.w.id eq 'bmd')
  
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
           ;;Data Settings
           'TMSERVER_TYPE'   : set.tmserver_type     = value
           'TMSERVER_ADDR'   : set.tmserver_addr     = value
           'TMSERVER_PORT'   : set.tmserver_port     = value
           'TMSERVER_TMFILE' : set.tmserver_tmfile   = value
           'TMSERVER_IDLFILE': set.tmserver_idlfile  = value

           ;;SHK Window
           'SHK_SHOW'        : set.w[wshk].show  = value
           'SHK_FAST'        : set.w[wshk].fast  = value
           'SHK_NAME'        : set.w[wshk].name  = value
           'SHK_XSIZE'       : set.w[wshk].xsize = value
           'SHK_YSIZE'       : set.w[wshk].ysize = value
           'SHK_XPOS'        : set.w[wshk].xpos  = value
           'SHK_YPOS'        : set.w[wshk].ypos  = value
           'SHK_FONT'        : set.w[wshk].font  = value
           
           ;;LYT Window
           'LYT_SHOW'        : set.w[wlyt].show  = value
           'LYT_FAST'        : set.w[wlyt].fast  = value
           'LYT_NAME'        : set.w[wlyt].name  = value
           'LYT_XSIZE'       : set.w[wlyt].xsize = value
           'LYT_YSIZE'       : set.w[wlyt].ysize = value
           'LYT_XPOS'        : set.w[wlyt].xpos  = value
           'LYT_YPOS'        : set.w[wlyt].ypos  = value
           'LYT_FONT'        : set.w[wlyt].font  = value
           
           ;;ALP Window
           'ALP_SHOW'        : set.w[walp].show  = value
           'ALP_FAST'        : set.w[walp].fast  = value
           'ALP_NAME'        : set.w[walp].name  = value
           'ALP_XSIZE'       : set.w[walp].xsize = value
           'ALP_YSIZE'       : set.w[walp].ysize = value
           'ALP_XPOS'        : set.w[walp].xpos  = value
           'ALP_YPOS'        : set.w[walp].ypos  = value
           'ALP_FONT'        : set.w[walp].font  = value
           
           ;;BMC Window
           'BMC_SHOW'        : set.w[wbmc].show  = value
           'BMC_FAST'        : set.w[wbmc].fast  = value
           'BMC_NAME'        : set.w[wbmc].name  = value
           'BMC_XSIZE'       : set.w[wbmc].xsize = value
           'BMC_YSIZE'       : set.w[wbmc].ysize = value
           'BMC_XPOS'        : set.w[wbmc].xpos  = value
           'BMC_YPOS'        : set.w[wbmc].ypos  = value
           'BMC_FONT'        : set.w[wbmc].font  = value
           
           ;;ACQ Window
           'ACQ_SHOW'        : set.w[wacq].show  = value
           'ACQ_FAST'        : set.w[wacq].fast  = value
           'ACQ_NAME'        : set.w[wacq].name  = value
           'ACQ_XSIZE'       : set.w[wacq].xsize = value
           'ACQ_YSIZE'       : set.w[wacq].ysize = value
           'ACQ_XPOS'        : set.w[wacq].xpos  = value
           'ACQ_YPOS'        : set.w[wacq].ypos  = value
           'ACQ_FONT'        : set.w[wacq].font  = value
           
           ;;SCI Window
           'SCI_SHOW'        : set.w[wsci].show  = value
           'SCI_FAST'        : set.w[wsci].fast  = value
           'SCI_NAME'        : set.w[wsci].name  = value
           'SCI_XSIZE'       : set.w[wsci].xsize = value
           'SCI_YSIZE'       : set.w[wsci].ysize = value
           'SCI_XPOS'        : set.w[wsci].xpos  = value
           'SCI_YPOS'        : set.w[wsci].ypos  = value
           'SCI_FONT'        : set.w[wsci].font  = value
           
           ;;SHZ Window
           'SHZ_SHOW'        : set.w[wshz].show  = value
           'SHZ_FAST'        : set.w[wshz].fast  = value
           'SHZ_NAME'        : set.w[wshz].name  = value
           'SHZ_XSIZE'       : set.w[wshz].xsize = value
           'SHZ_YSIZE'       : set.w[wshz].ysize = value
           'SHZ_XPOS'        : set.w[wshz].xpos  = value
           'SHZ_YPOS'        : set.w[wshz].ypos  = value
           'SHZ_FONT'        : set.w[wshz].font  = value
           
           ;;LYZ Window
           'LYZ_SHOW'        : set.w[wlyz].show  = value
           'LYZ_FAST'        : set.w[wlyz].fast  = value
           'LYZ_NAME'        : set.w[wlyz].name  = value
           'LYZ_XSIZE'       : set.w[wlyz].xsize = value
           'LYZ_YSIZE'       : set.w[wlyz].ysize = value
           'LYZ_XPOS'        : set.w[wlyz].xpos  = value
           'LYZ_YPOS'        : set.w[wlyz].ypos  = value
           'LYZ_FONT'        : set.w[wlyz].font  = value
           
           ;;THM Window
           'THM_SHOW'        : set.w[wthm].show  = value
           'THM_FAST'        : set.w[wthm].fast  = value
           'THM_NAME'        : set.w[wthm].name  = value
           'THM_XSIZE'       : set.w[wthm].xsize = value
           'THM_YSIZE'       : set.w[wthm].ysize = value
           'THM_XPOS'        : set.w[wthm].xpos  = value
           'THM_YPOS'        : set.w[wthm].ypos  = value
           'THM_FONT'        : set.w[wthm].font  = value

           ;;SDA Window
           'SDA_SHOW'        : set.w[wsda].show  = value
           'SDA_FAST'        : set.w[wsda].fast  = value
           'SDA_NAME'        : set.w[wsda].name  = value
           'SDA_XSIZE'       : set.w[wsda].xsize = value
           'SDA_YSIZE'       : set.w[wsda].ysize = value
           'SDA_XPOS'        : set.w[wsda].xpos  = value
           'SDA_YPOS'        : set.w[wsda].ypos  = value
           'SDA_FONT'        : set.w[wsda].font  = value

           ;;LDA Window
           'LDA_SHOW'        : set.w[wlda].show  = value
           'LDA_FAST'        : set.w[wlda].fast  = value
           'LDA_NAME'        : set.w[wlda].name  = value
           'LDA_XSIZE'       : set.w[wlda].xsize = value
           'LDA_YSIZE'       : set.w[wlda].ysize = value
           'LDA_XPOS'        : set.w[wlda].xpos  = value
           'LDA_YPOS'        : set.w[wlda].ypos  = value
           'LDA_FONT'        : set.w[wlda].font  = value

           ;;BMD Window
           'BMD_SHOW'        : set.w[wbmd].show  = value
           'BMD_FAST'        : set.w[wbmd].fast  = value
           'BMD_NAME'        : set.w[wbmd].name  = value
           'BMD_XSIZE'       : set.w[wbmd].xsize = value
           'BMD_YSIZE'       : set.w[wbmd].ysize = value
           'BMD_XPOS'        : set.w[wbmd].xpos  = value
           'BMD_YPOS'        : set.w[wbmd].ypos  = value
           'BMD_FONT'        : set.w[wbmd].font  = value
          else: ;;do nothing
        endcase
     endif
  endfor

  ;;Keywords
  if keyword_set(tmtype)  then set.tmserver_type = tmtype
  if keyword_set(tmaddr)  then set.tmserver_addr = tmaddr
  if keyword_set(tmport)  then set.tmserver_port = tmport
  if keyword_set(tmfile)  then set.tmserver_tmfile = tmfile
  if keyword_set(idlfile) then set.tmserver_idlfile = idlfile
  
  
  ;;Close the config file
  free_lun,unit,/force

  ;;Save settings structure
  save,set,filename='.piccgse_set.idl'
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_setupFiles
;;  - procedure to setup paths and open logfiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
  common piccgse_block, settings, set, shm_var
  
  ;;set paths and filenames
  STARTUP_TIMESTAMP = gettimestamp('.')
  set.datapath = 'data/piccgse/piccgse.'+STARTUP_TIMESTAMP+'/'
  check_and_mkdir,set.datapath
  pktlogfile = set.datapath+'piccgse.'+STARTUP_TIMESTAMP+'.pktlog.txt'
  
  ;;close open files
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit,/force
  
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
  common piccgse_block, settings, set, shm_var
  while !D.WINDOW ne -1 do wdelete
  for i=0, n_elements(set.w)-1 do begin
     if set.w[i].show then window, i, XSIZE=set.w[i].xsize, YSIZE=set.w[i].ysize,$
                                   XPOS=set.w[i].xpos, YPOS=set.w[i].ypos, TITLE=set.w[i].name, RETAIN=1
  endfor
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_newWindows
;;  - function to decide if we need to restart any windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION piccgse_newWindows, old
  common piccgse_block, settings, set, shm_var
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
pro piccgse_processData, hed, pkt, tag
  common piccgse_block, settings, set, shm_var
  common processdata_block1, states, alpcalmodes, hexcalmodes, tgtcalmodes, bmccalmodes, shkbin, shkxs, shkys, lytxs, lytys, shkid, watid, lytid, sciid
  common processdata_block2, scirebin,lytrebin,scixs,sciys,sci_dhrot,scisel,scinotsel,sci_nbands,censel,scidark,sci_temp_inc,lytxs_rebin,lytys_rebin,sciring,scidz,lytmasksel,lytmasknotsel
  common processdata_block3, lowfs_n_zernike, lowfs_n_pid, alpimg, alpsel, alpnotsel, alpctag, bmcimg, bmcsel, bmcnotsel, tdb, tsort
  common processdata_block4, wshk, wlyt, wacq, wsci, walp, wbmc, wshz, wlyz, wthm, wsda, wlda, wbmd, wpix
  common processdata_block5, sci_temp, sci_set, sci_tec, sci_pow, sci_temp_init, sci_dark, sci_bias, contrast_array
  common processdata_block6, acq_xstar, acq_ystar, acq_xhole, acq_yhole, bmcflat, actuator_alp, actuator_hex,sci_fastmode
  
  ;;Initialize common block
  if n_elements(states) eq 0 then begin 
     ;;Flight software header file
     header='../piccflight/src/controller.h'
     
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
     SHKBIN          = read_c_define(header,"SHKBIN")
     SHKXS           = read_c_define(header,"SHKXS")
     SHKYS           = read_c_define(header,"SHKYS")
     LYTXS           = read_c_define(header,"LYTXS")
     LYTYS           = read_c_define(header,"LYTYS")
     SCIXS           = read_c_define(header,"SCIXS")
     SCIYS           = read_c_define(header,"SCIYS")
     SCI_ROI_XSIZE   = read_c_define(header,"SCI_ROI_XSIZE")
     SCI_ROI_YSIZE   = read_c_define(header,"SCI_ROI_YSIZE")
     SCI_TEMP_INC    = read_c_define(header,"SCI_TEMP_INC")
     SCI_NBANDS      = read_c_define(header,"SCI_NBANDS")
     LOWFS_N_ZERNIKE = read_c_define(header,"LOWFS_N_ZERNIKE")
     LOWFS_N_PID     = read_c_define(header,"LOWFS_N_PID")
     ACTUATOR_ALP    = read_c_define(header,"ACTUATOR_ALP")
     ACTUATOR_HEX    = read_c_define(header,"ACTUATOR_HEX")

     ;;Get process IDs
     procids = read_c_enum(header,'procids')
     for i=0, n_elements(procids)-1 do void=execute(procids[i]+'='+n2s(i))
     
     ;;ALPAO DM Display
     os = 64
     alpsize = 11
     xyimage,alpsize*os,alpsize*os,xim,yim,rim,/quadrant
     rim /= os
     sel = where(rim lt 5.)
     mask = rim*0
     mask[sel]=1
     mask = rebin(mask,alpsize,alpsize)
     alpsel = where(mask gt 0.005,complement=alpnotsel)
     alpimg = mask * 0d
     alpctag = ''

     ;;BMC Actuator Selection
     restore,'config/howfs_bmcmask.idl' ;;built by picctest/export_howfc.pro
     bmcsel = where(bmcmask,complement=bmcnotsel)
     bmcimg = float(bmcmask*0)

     ;;SCI Image Pixel Selection
     sci_dhrot=0
     restore,'config/howfs_scimask_rot'+n2s(sci_dhrot)+'.idl' ;;built by picctest/export_howfc.pro
     scisel = where(scimask,complement=scinotsel)
     
     ;;Init scidark
     scidark = dblarr(SCIXS,SCIYS,SCI_NBANDS)
     
     ;;Temperature database
     tdb = load_tempdb()
     tsort = sort(tdb.abbr)
     tdb = tdb[tsort]
     
     ;;Get window indicies
     wshk = where(set.w.id eq 'shk')
     wlyt = where(set.w.id eq 'lyt')
     wacq = where(set.w.id eq 'acq')
     wsci = where(set.w.id eq 'sci')
     walp = where(set.w.id eq 'alp')
     wbmc = where(set.w.id eq 'bmc')
     wshz = where(set.w.id eq 'shz')
     wlyz = where(set.w.id eq 'lyz')
     wthm = where(set.w.id eq 'thm')
     wsda = where(set.w.id eq 'sda')
     wlda = where(set.w.id eq 'lda')
     wbmd = where(set.w.id eq 'bmd')
     wpix = n_elements(set.w)+1

     ;;Image sizes and locations
     minsize  = min([set.w[wlyt].xsize,set.w[wlyt].ysize])
     lytrebin = (minsize/lytxs) * lytxs
     minsize  = min([set.w[wsci].xsize,set.w[wsci].ysize])
     scirebin = (minsize/scixs) * scixs

     ;;LYT Mask (HACK FOR NOW)
     xyimage,32,32,xim,yim,rim,/quad,/index
     lytmasksel = where(rim le 15,complement=lytmasknotsel)

     ;;SCI IWA ring
     xyimage,scixs,sciys,xim,yim,rim,/quadrant,/index
     censel = where(rim le 7)
     sciring = where(fix(rim) eq 7)
     image = intarr(scixs,sciys)
     image[sciring] = 1
     image = rebin(image,scirebin,scirebin,/sample)
     sciring = where(round(image) eq 1)

     ;;SCI Dark Zone
     scidz = scimask
     outline,scidz
     scidz = rebin(scidz,scirebin,scirebin,/sample)
     scidz = where(round(scidz) eq 1)
     
     ;;SCI Temperatures
     sci_temp = 0d
     sci_set  = 0d
     sci_tec  = 0
     sci_pow  = 0d
     sci_temp_init = 1000

     ;;SCI Fastmode
     sci_fastmode=0
     
     ;;SCI Calibration images
     sci_dark = dblarr(SCI_ROI_XSIZE,SCI_ROI_YSIZE)
     sci_bias = dblarr(SCI_ROI_XSIZE,SCI_ROI_YSIZE)
     
     ;;ACQ positions
     acq_xstar = 0
     acq_ystar = 0
     acq_xhole = 0
     acq_yhole = 0
  endif
  
  ;;Colors
  red=1
  green=2
  blue=3
  white=255

  ;;SHKPKT
  if tag eq 'shkpkt' then begin
     ;;Display image
     if set.w[wshk].show AND ((sci_fastmode AND set.w[wshk].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wshk
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wshk].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set color table
        greyr
        ;;setup plotting
        plotsym,0,/fill
        ;;plot image axes
        zoom=80/SHKBIN
        xoff=-5
        yoff=-7
        plot,[0],[0],xrange=[zoom+xoff,shkxs-zoom+xoff],yrange=[zoom+yoff,shkys-zoom+yoff],xstyle=5,ystyle=5,/nodata,position=[0,0,1,1],/iso
        maxval = double(max(pkt.cells.maxval))
        val = double(pkt.cells.maxval)
        greyrscale,val,255,bot=100
        ;;loop over cells
        for i=0,n_elements(pkt.cells)-1 do begin
           ;;draw centroid box
           blx = floor((pkt.cells[i].xtarget - pkt.cells[i].boxsize)/SHKBIN)
           bly = floor((pkt.cells[i].ytarget - pkt.cells[i].boxsize)/SHKBIN)
           trx = floor((pkt.cells[i].xtarget + pkt.cells[i].boxsize)/SHKBIN)
           try = floor((pkt.cells[i].ytarget + pkt.cells[i].boxsize)/SHKBIN)
           ;;bottom
           oplot,[blx,trx],[bly,bly]
           ;;top
           oplot,[blx,trx],[try,try]
           ;;left
           oplot,[blx,blx],[bly,try]
           ;;right
           oplot,[trx,trx],[bly,try]
           ;;plot centroid
           if pkt.cells[i].spot_found then begin
              xcentroid = (double(pkt.cells[i].xtarget) + mean(pkt.cells[i].xtarget_deviation[0:pkt.nsamples-1]))/SHKBIN
              ycentroid = (double(pkt.cells[i].ytarget) + mean(pkt.cells[i].ytarget_deviation[0:pkt.nsamples-1]))/SHKBIN
              if pkt.cells[i].maxval eq 255 then color = 1 else color = 255
              color = val[i]
              oplot,[xcentroid],[ycentroid],color=color,psym=8,symsize=0.5
           endif
        endfor
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wshk
        ;;display image
        tv,snap,true=1
        loadct,0
     endif

     ;;Display text data
     if set.w[wsda].show AND ((sci_fastmode AND set.w[wsda].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wsda
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wsda].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin
        dy  = 16
        sx = 5
        sy = !D.Y_SIZE - dy
        c=0
        ;;print data
        xyouts,sx,sy-dy*c++,'Frame number: '+n2s(hed.frame_number),/device
        xyouts,sx,sy-dy*c++,'# of Samples: '+n2s(pkt.nsamples),/device
        xyouts,sx,sy-dy*c++,'Frm | Exp: '+n2s(long(hed.frmtime*1d6))+' | '+n2s(long(hed.exptime*1d6))+' us',/device
        dt = long((double(hed.end_sec) - double(hed.start_sec))*1d6 + (double(hed.end_nsec) - double(hed.start_nsec))/1d3)
        xyouts,sx,sy-dy*c++,'Event Time: '+n2s(dt)+' us',/device
        xyouts,sx,sy-dy*c++,'CCD Temp: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C',/device
        xyouts,sx,sy-dy*c++,'ALP Cell PID: '+string(pkt.gain_alp_cell,format='(3F7.3)'),/device
        xyouts,sx,sy-dy*c++,'ALP Zern PID: '+$
               string(pkt.gain_alp_zern[0,0],pkt.gain_alp_zern[0,1],pkt.gain_alp_zern[0,2],format='(3F7.3)'),$
               /device
        xyouts,sx,sy-dy*c++,'HEX Zern PID: '+string(pkt.gain_hex_zern,format='(3F7.3)'),/device
        xyouts,sx,sy-dy*c++,'MAX Max Pixel: '+n2s(long(max(pkt.cells.maxval)))+' counts',/device
        xyouts,sx,sy-dy*c++,'AVG Max Pixel: '+n2s(long(mean(pkt.cells.maxval)))+' counts',/device
        xyouts,sx,sy-dy*c++,'BKG Intensity: '+n2s(mean(pkt.cells.background),format='(F10.2)')+' counts/px',/device
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wsda
        ;;display image
        tv,snap,true=1
        loadct,0
     endif
     
     ;;Display Zernikes
     if set.w[wshz].show AND ((sci_fastmode AND set.w[wshz].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wshz
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wshz].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set color table
        linecolor
        ;;set text origin and spacing
        dy = round(!D.Y_SIZE / double(LOWFS_N_ZERNIKE+2))+1
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        ;;calc zernike values
        if pkt.nsamples ge 2 then begin
           zavg = mean(pkt.zernike_measured[*,0:pkt.nsamples-1],dimension=2)
           zstd = stddev(pkt.zernike_measured[*,0:pkt.nsamples-1],dimension=2)
        endif else begin
           zavg = pkt.zernike_measured[*,0]
           zstd = pkt.zernike_measured[*,0]*0
        endelse
        ztar = pkt.zernike_target
        ;;set zernike colors
        zclr = intarr(n_elements(ztar)) + white
        zsel = where(pkt.zernike_control eq ACTUATOR_ALP,nzsel)
        if nzsel gt 0 then zclr[zsel] = green
        zsel = where(pkt.zernike_control eq ACTUATOR_HEX,nzsel)
        if nzsel gt 0 then zclr[zsel] = blue
        
        ;;print header
        xyouts,sx,sy-dy*c++,string('Z','AVG','TAR','STD',format='(A2,A6,A6,A6)'),/device
        ;;print zernikes
        for i=0,n_elements(zavg)-1 do begin
           if i lt 2 then xyouts,sx,sy-dy*c++,string(i,zavg[i],ztar[i],zstd[i],format='(I2.2,F+6.2,F+6.2,F+6.2)'),/device,color=zclr[i]
           if i ge 2 then xyouts,sx,sy-dy*c++,string(i,zavg[i]*1000,ztar[i]*1000,zstd[i]*1000,format='(I2.2,F+6.1,F+6.1,F+6.1)'),/device,color=zclr[i]
        endfor
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wshz
        ;;display data
        tv,snap,0,0,true=1
        loadct,0
     endif
     
     ;;Display ALPAO Command
     if set.w[walp].show AND ((sci_fastmode AND set.w[walp].fast) OR (NOT sci_fastmode)) then begin
        if hed.alp_commander eq SHKID OR hed.alp_commander eq WATID then begin
           ;;set window
           wset,walp
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[walp].font
           ;;fill out image
           alpimg[alpsel] = pkt.alp_acmd
           ;;set commander tag
           ctag='SHK'
           if hed.alp_commander eq WATID then ctag='WAT'
           ;;display image
           implot,alpimg,blackout=alpnotsel,range=[-1,1],cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='ALPAO DM Command ('+ctag+')',erase=(ctag ne alpctag)
           alpctag = ctag
           loadct,0
        endif
     endif
  endif
  
  ;;LYTPKT
  if tag eq 'lytpkt' then begin
     ;;Display Image
     if set.w[wlyt].show AND ((sci_fastmode AND set.w[wlyt].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wlyt
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wlyt].font
        simage = pkt.image.data
        simage[lytxs/2,lytys/2] = max(simage) ;; max out center pixel
        ;;mask image (make this switchable)
                                ;simage[lytmasknotsel]=min(simage[lytmasksel])
        ;;scale image
        simage = rebin(simage,lytrebin,lytrebin,/sample)
        greyrscale,simage,4092
        ;;display image
        greyr
        tv,simage,(!D.X_SIZE-lytrebin)/2,(!D.Y_SIZE-lytrebin)/2
        loadct,0
     endif

     ;;Display ALPAO Command
     if hed.alp_commander eq LYTID then begin
        if set.w[walp].show AND ((sci_fastmode AND set.w[walp].fast) OR (NOT sci_fastmode)) then begin
           ;;set window
           wset,walp
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[walp].font
           ;;fill out image
           alpimg[alpsel] = pkt.alp_acmd
           ;;set commander tag
           ctag='LYT'
           ;;display image
           implot,alpimg,blackout=alpnotsel,range=[-1,1],cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='ALPAO DM Command ('+ctag+')',erase=(ctag ne alpctag)
           alpctag=ctag
           loadct,0
        endif
     endif

     ;;Display text data
     if set.w[wlda].show AND ((sci_fastmode AND set.w[wlda].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wlda
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wlda].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin
        dy  = 16
        sx = 5
        sy = !D.Y_SIZE - dy
        c=0
        ;;print data
        xyouts,sx,sy-dy*c++,'Frame number: '+n2s(hed.frame_number),/device
        xyouts,sx,sy-dy*c++,'# of Samples: '+n2s(pkt.nsamples),/device
        xyouts,sx,sy-dy*c++,'Frm | Exp: '+n2s(long(hed.frmtime*1d6))+' | '+n2s(long(hed.exptime*1d6))+' us',/device
        dt = long((double(hed.end_sec) - double(hed.start_sec))*1d6 + (double(hed.end_nsec) - double(hed.start_nsec))/1d3)
        xyouts,sx,sy-dy*c++,'Event Time: '+n2s(dt)+' us',/device
        xyouts,sx,sy-dy*c++,'CCD Temp: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C',/device
        xyouts,sx,sy-dy*c++,'Origin: '+string(pkt.xorigin,pkt.yorigin,format='(2I5)'),/device
        xyouts,sx,sy-dy*c++,'ALP Zern PID: '+$
               string(pkt.gain_alp_zern[0,0],pkt.gain_alp_zern[0,1],pkt.gain_alp_zern[0,2],format='(3F7.3)'),$
               /device
        xyouts,sx,sy-dy*c++,'Tot Pixel: '+n2s(total(pkt.image.data),format='(I10)'),/device
        xyouts,sx,sy-dy*c++,'Avg Pixel: '+n2s(mean(pkt.image.data),format='(I5)')+' Max Pixel: '+n2s(max(pkt.image.data),format='(I5)'),/device
        xyouts,sx,sy-dy*c++,'Bkg Pixel: '+n2s(pkt.background,format='(I5)'),/device
        xcentroid = pkt.xcentroid[0:pkt.nsamples-1]
        ycentroid = pkt.ycentroid[0:pkt.nsamples-1]
        r = sqrt(xcentroid^2 + ycentroid^2)
        dummy = max(r,rmax)
        xyouts,sx,sy-dy*c++,'Max Centroid: '+n2s(xcentroid[rmax],format='(F0.2)')+'  '+n2s(ycentroid[rmax],format='(F0.2)'),/device
        if pkt.status_locked then locked='YES' else locked='NO'
        if pkt.status_valid  then valid='YES'  else valid='NO'
        xyouts,sx,sy-dy*c++,'Valid: '+valid+'  |  Locked: '+locked,/device
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wlda
        ;;display image
        tv,snap,true=1
        loadct,0
     endif

     ;;Display Zernikes
     if set.w[wlyz].show AND ((sci_fastmode AND set.w[wlyz].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wlyz
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wlyz].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set color table
        linecolor
        ;;set text origin and spacing
        dy = round(!D.Y_SIZE / double(LOWFS_N_ZERNIKE+2))+1
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        ;;calc zernike values
        if pkt.nsamples ge 2 then begin
           zavg = mean(pkt.zernike_measured[*,0:pkt.nsamples-1],dimension=2)*1000
           zstd = stddev(pkt.zernike_measured[*,0:pkt.nsamples-1],dimension=2)*1000
        endif else begin
           zavg = pkt.zernike_measured[*,0]*1000
           zstd = pkt.zernike_measured[*,0]*0
        endelse
        ztar = pkt.zernike_target*1000
        ;;set zernike colors
        zclr = intarr(n_elements(ztar)) + white
        zsel = where(pkt.zernike_control eq ACTUATOR_ALP,nzsel)
        if nzsel gt 0 then zclr[zsel] = green
        zsel = where(pkt.zernike_control eq ACTUATOR_HEX,nzsel)
        if nzsel gt 0 then zclr[zsel] = blue
        ;;print header
        xyouts,sx,sy-dy*c++,string('Z','AVG','TAR','STD',format='(A2,A6,A6,A6)'),/device
        ;;print zernikes
        for i=0,n_elements(zavg)-1 do begin
           xyouts,sx,sy-dy*c++,string(i,zavg[i],ztar[i],zstd[i],format='(I2.2,F+6.1,F+6.1,F+6.1)'),/device,color=zclr[i]
        endfor
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wlyz
        ;;display data
        tv,snap,0,0,true=1
        loadct,0
     endif
  endif

  ;;WFSEVENT
  if tag eq 'wfsevent' then begin
     ;;Display Image
     if set.w[wsci].show then begin
     if (shm_var[settings.shm_scitype] ne settings.scitype_image) AND (shm_var[settings.shm_scitype] ne settings.scitype_log) AND (shm_var[settings.shm_scitype] ne settings.scitype_contrast) then begin
           ;;set window
           wset,wsci
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[wsci].font
           ;;create pixmap window
           window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
           wset,wpix
           
           
           ;;set text origin
           dy  = 16
           sx = 5
           sy = !D.Y_SIZE - dy
           c=0
           
           ;;print data
           xyouts,sx,sy-dy*c++,'Frame number: '+n2s(hed.frame_number),/device
           xyouts,sx,sy-dy*c++,'Frm | Exp: '+n2s(hed.frmtime,format='(F0.3)')+' | '+n2s(hed.exptime,format='(F0.3)')+' sec',/device
           dt = long((double(hed.end_sec) - double(hed.start_sec))*1d6 + (double(hed.end_nsec) - double(hed.start_nsec))/1d3)
           xyouts,sx,sy-dy*c++,'Event Time: '+n2s(dt)+' us',/device

           for iband=0,n_elements(pkt.field)-1 do begin
              simage  = dblarr(scixs,sciys)
              if shm_var[settings.shm_scitype] eq settings.scitype_real      then begin
                 simage[scisel] = pkt.field[iband].r
                 simage[scisel] /= max(abs(simage[scisel]))
                 title='WFS: Real Part'
                 cbtitle='FLD'
              endif
              if shm_var[settings.shm_scitype] eq settings.scitype_imaginary then begin
                 simage[scisel] = pkt.field[iband].i
                 title='WFS: Imaginary Part'
                 simage[scisel] /= max(abs(simage[scisel]))
                 cbtitle='FLD'
              endif
              if shm_var[settings.shm_scitype] eq settings.scitype_amplitude then begin
                 simage[scisel] = sqrt(pkt.field[iband].r^2 + pkt.field[iband].i^2)
                 title='WFS: Amplitude'
                 simage[scisel] /= max(abs(simage[scisel]))
                 cbtitle='AMP'
             endif
              if shm_var[settings.shm_scitype] eq settings.scitype_phase     then begin
                 simage[scisel] = atan(pkt.field[iband].i,pkt.field[iband].r,/phase)
                 title='WFS: Phase'
                 cbtitle='RAD'
              endif
              cbrange = minmax(simage[scisel])
              simage = rebin(simage,scirebin,scirebin,/sample)
              ;;scale image
              greygrscale,simage,1e9
              ;;add box
              simage[*,0]  = 252
              simage[*,-1] = 252
              simage[0,*]  = 252
              simage[-1,*] = 252
              ;;add IWA ring
              simage[sciring] = 253
              simage[scidz] = 253
              ;;display
              greygr
              xsize = !D.X_SIZE/n_elements(pkt.field)
              xpos  = iband*xsize+(xsize-scirebin)/2
              ypos  = (!D.Y_SIZE-scirebin)/2
              tv,simage,xpos,ypos
              position=[xpos+scirebin+5,ypos,xpos+scirebin+5+10,ypos+scirebin] / double([!D.X_SIZE,!D.Y_SIZE,!D.X_SIZE,!D.Y_SIZE])
              xyouts,xpos+scirebin/2,ypos+scirebin+2,title,/device,alignment=0.5
              cbmcolorbar,range=cbrange,/vertical,/right,title=cbtitle,position=position,ncolors=253,format='(F0.2)',divisions=5
           endfor
           
           ;;take snapshot
           snap = TVRD(true=1)
           ;;delete pixmap window
           wdelete,wpix
           ;;switch back to real window
           wset,wsci
           ;;display image
           tv,snap,true=1
           
           loadct,0
        endif
     endif
  endif

  ;;ACQEVENT
  if tag eq 'acqevent' then begin
     ;;Display Image
     if set.w[wacq].show AND ((sci_fastmode AND set.w[wacq].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wacq
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wacq].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set color table
        greyr
        ;;scale image
        image = pkt.image.data
        ss=size(image)
        ysize = !D.Y_SIZE
        xsize = ysize * float(ss[1]) / float(ss[2])
        xpos  = !D.X_SIZE-xsize
        ypos  = 0
        simage = congrid(image,xsize,ysize)
        greyrscale,simage,255
        ;;display image
        tv,simage,xpos,ypos
        ;;set text origin
        dy  = 16
        sx = 5
        sy = !D.Y_SIZE - dy
        c=0
        ;;print data
        xyouts,sx,sy-dy*c++,'Frame: '+n2s(hed.frame_number,format='(I)'),/device
        xyouts,sx,sy-dy*c++,'Time: '+n2s(hed.ontime,format='(F10.1)')+' s',/device
        ;;calculate event time
        dt = long((double(hed.end_sec) - double(hed.start_sec))*1d3 + (double(hed.end_nsec) - double(hed.start_nsec))/1d6)
        xyouts,sx,sy-dy*c++,'Event: '+n2s(dt)+' us',/device
        xyouts,sx,sy-dy*c++,'Max: '+n2s(long(max(image)))+' ADU',/device
        xyouts,sx,sy-dy*c++,'Hole: '+n2s(acq_xhole)+','+n2s(acq_yhole),/device
        xyouts,sx,sy-dy*c++,'Star: '+n2s(acq_xstar)+','+n2s(acq_ystar),/device
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wacq
        ;;display image
        tv,snap,true=1
        loadct,0
        ;;get mouse events
        cursor,x,y,/nowait,/device
        if x ge 0 and y ge 0 and !mouse.button ne 0 then begin
           if !mouse.button eq 1 then begin
              ;;Left click star position
              x = fix(double(x-xpos)/xsize * ss[1])
              y = fix(double(y-ypos)/ysize * ss[2])
              if x ge 0 and x lt ss[1] and y ge 0 and y lt ss[2] then begin
                 acq_xstar = x
                 acq_ystar = y
              endif
           endif
           if !mouse.button eq 4 then begin
              ;;Right click hole position
              x = fix(double(x-xpos)/xsize * ss[1])
              y = fix(double(y-ypos)/ysize * ss[2])
              if x ge 0 and x lt ss[1] and y ge 0 and y lt ss[2] then begin
                 acq_xhole = x
                 acq_yhole = y
              endif
           endif
           ;;Put deltas into shared memory
           dx = fix(acq_xstar - acq_xhole)
           dy = fix(acq_ystar - acq_yhole)
           shm_var[settings.shm_acq_dx+0] = byte(ishft(dx,-8)) 
           shm_var[settings.shm_acq_dx+1] = byte(dx AND 255)
           shm_var[settings.shm_acq_dy+0] = byte(ishft(dy,-8)) 
           shm_var[settings.shm_acq_dy+1] = byte(dy AND 255)
        endif
        
     endif
  endif

  ;;THMEVENT
  if tag eq 'thmevent' then begin
     ;;Set state
     shm_var[settings.shm_state] = hed.state

     ;;Display Thermal Data
     if set.w[wthm].show AND ((sci_fastmode AND set.w[wthm].fast) OR (NOT sci_fastmode)) then begin
        ;;set window
        wset,wthm
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wthm].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        linecolor
        ;;set text origin and spacing
        dy = round(!D.Y_SIZE / double(LOWFS_N_ZERNIKE+2))+1
        dx = !D.X_SIZE/6
        sx = 5            
        sy = !D.Y_SIZE - dy
        nl = 24
        c  = 0
        ;;concatinate data and sort
        temp = [pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp]
        temp = temp[tsort]
        ;;print data
        for i=0,n_elements(temp)-1 do begin
           color = green
           if temp[i] lt tdb[i].min then color = blue
           if temp[i] gt tdb[i].max then color = red
           fmt='F-+6.1'
           if tdb[i].abbr eq 'VREF' then fmt='F-+6.2'
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(tdb[i].abbr+':',temp[i],format='(A-7,'+fmt+')'),/device,color=color
           c++
        endfor
        ;;heater data
        for i=0,n_elements(pkt.htr)-1 do begin
           sta='DIS'
           ovr='AUTO'
           if pkt.htr[i].enable then sta='ENA'
           if pkt.htr[i].override then ovr='OVER'
           str=string(string(pkt.htr[i].name)+':',$
                      sta,ovr,$
                      pkt.htr[i].power,' ',$
                      pkt.htr[i].temp,' ',$
                      pkt.htr[i].setpoint,format='(A-7,A-4,A-5,I-4,A,F-+6.1,A,F-+6.1)')
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),str,/device,color=white
           c++
        endfor
        ;;humidity sensors
        hum_name=['INST','M2','M1']
        xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string('Sens','Temp','RH %',format='(A5,A7,A7)'),/device,color=white
        c++
        for i=0,n_elements(pkt.hum)-1 do begin
           hum = pkt.hum[i].humidity
           if hum gt 50 then hum = '>50' else hum = n2s(hum,format='(F7.1)')
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(hum_name[i],pkt.hum[i].temp,hum,format='(A5,F7.1,A7)'),$
                  /device,color=white
           c++
        endfor
        ;;print CPU temps
        xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string('CPU1',pkt.cpu1_temp,format='(A5,F7.1)'),/device,color=white
        c++
        xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string('CPU2',pkt.cpu2_temp,format='(A5,F7.1)'),/device,color=white
        c++
        ;;print SCI temps
        if sci_tec then tec=green else tec=red
        xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string('SCI',sci_temp,'/',sci_set,sci_pow,'%',format='(A5,F7.1,A,F-5.1,I3,A)'),/device,color=tec
        c++
        ;;print state
                                ;bxs=204
                                ;bys=24
                                ;bth=2
                                ;box=bytarr(bxs,bys)
                                ;box[0:bth-1,*]=255       ;;left
                                ;box[bxs-bth:-1,*]=255    ;;right
                                ;box[*,0:bth-1]=255       ;;bottom
                                ;box[*,bys-bth:-1]=255    ;;top
                                ;tv,box,!D.X_SIZE-bxs,0
                                ;xyouts,!D.X_SIZE-200,sy-dy*(nl-1),states[hed.state],/device,color=white
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wthm
        tv,snap,true=1
        loadct,0
     endif
  endif


  ;;MSGEVENT
  if tag eq 'msgevent' then begin
     print,string(pkt.message),format='(A,$)'
  endif

  ;;SCIEVENT -- NOTE: All scievent data displayed during sci fastmode
  if tag eq 'scievent' then begin
     ;;Display Image
     if set.w[wsci].show then begin

        ;;Check if darkhole rotation has changed
        if sci_dhrot ne pkt.dhrot then begin
           ;;Set dhrot
           sci_dhrot = pkt.dhrot
           print,'SCI darkhole rotation changed to '+n2s(sci_dhrot)
           
           ;;SCI Image Pixel Selection
           restore,'config/howfs_scimask_rot'+n2s(sci_dhrot)+'.idl' ;;built by picctest/export_howfc.pro
           scisel = where(scimask,complement=scinotsel)
           
           ;;SCI IWA ring
           xyimage,scixs,sciys,xim,yim,rim,/quadrant,/index
           censel = where(rim le 7)
           sciring = where(fix(rim) eq 7)
           image = intarr(scixs,sciys)
           image[sciring] = 1
           image = rebin(image,scirebin,scirebin,/sample)
           sciring = where(round(image) eq 1)

           ;;SCI Dark Zone
           scidz = scimask
           outline,scidz
           scidz = rebin(scidz,scirebin,scirebin,/sample)
           scidz = where(round(scidz) eq 1)
        endif
        
        ;;save SCI temps to common block
        sci_temp = pkt.ccd_temp
        sci_set  = pkt.tec_setpoint
        sci_tec  = pkt.tec_enable
        sci_pow  = pkt.tec_power

        ;;save SCI fastmode to common block
        sci_fastmode = pkt.fastmode

        ;;check if we need to reload sci calibration data
        if (SCI_TEMP_INC * round(sci_temp/SCI_TEMP_INC)) ne sci_temp_init then begin
           sci_temp_init = SCI_TEMP_INC * round(sci_temp/SCI_TEMP_INC)
           file = file_search('config/sci_dark_'+n2s(sci_temp_init)+'.idl',count=nfiles)
           if nfiles eq 1 then begin
              restore,file
              print,'Opened '+file
           endif else begin
              print,'Dark file not found for '+n2s(sci_temp_init)+'C'
              sci_dark[*] = 0
           endelse
           file = file_search('config/sci_bias_'+n2s(sci_temp_init)+'.idl',count=nfiles)
           if nfiles eq 1 then begin
              restore,file
              print,'Opened '+file
           endif else begin
              print,'Bias file not found for '+n2s(sci_temp_init)+'C'
              sci_bias[*] = 0
           endelse
        endif

        ;;display scievent
        if (shm_var[settings.shm_scitype] eq settings.scitype_image) OR (shm_var[settings.shm_scitype] eq settings.scitype_log) OR (shm_var[settings.shm_scitype] eq settings.scitype_contrast) then begin
           ;;set window
           wset,wsci
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[wsci].font
           ;;create pixmap window
           window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
           wset,wpix
           
           
           ;;set text origin
           dy  = 16
           sx = 5
           sy = !D.Y_SIZE - dy
           c=0
           
           ;;print data
           xyouts,sx,sy-dy*c++,'Frame number: '+n2s(hed.frame_number),/device
           xyouts,sx,sy-dy*c++,'Frm | Exp: '+n2s(hed.frmtime,format='(F0.3)')+' | '+n2s(hed.exptime,format='(F0.3)')+' sec',/device
           dt = long((double(hed.end_sec) - double(hed.start_sec))*1d6 + (double(hed.end_nsec) - double(hed.start_nsec))/1d3)
           xyouts,sx,sy-dy*c++,'Event Time: '+n2s(dt)+' us',/device
           origin = ''
           for i=0,n_elements(pkt.xorigin)-1 do origin +='('+n2s(pkt.xorigin[i])+','+n2s(pkt.yorigin[i])+') '
           xyouts,sx,sy-dy*c++,'Origin: '+origin,/device
           xyouts,sx,sy-dy*c++,'CCD Temp: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C',/device
           xyouts,sx,sy-dy*c++,'iHOWFS: '+n2s(fix(pkt.ihowfs))+'  iSPECKLE: '+n2s(fix(pkt.ispeckle)),/device

           ;;display image
           contrast = dblarr(sci_nbands)
           update_contrast = 0
           for iband=0,sci_nbands-1 do begin
              image  = double(reform(pkt.bands.band[iband].data))
              blx    = pkt.xorigin[iband] - (SCIXS/2)
              bly    = pkt.yorigin[iband] - (SCIYS/2)
              bkg    = sci_bias[blx:blx+SCIXS-1,bly:bly+SCIYS-1] + sci_dark[blx:blx+SCIXS-1,bly:bly+SCIYS-1] * hed.exptime
              bgsub  = image - bkg

              ;;only update darkhole numbers on DM flat command
              if (pkt.ihowfs eq 0) AND (pkt.ispeckle eq 0) then begin
                 scidark[*,*,iband] = bgsub
                 if pkt.refmax[iband] gt 0 then contrast[iband] = mean(bgsub[scisel]) / hed.exptime / pkt.refmax[iband] else contrast[iband]=1
                 update_contrast = 1
              endif
              xyouts,sx,sy-dy*c++,string('Min|Max|Avg['+n2s(iband)+'] Full: ',min(bgsub),max(bgsub),mean(bgsub),format='(A,I8,I8,I8)'),/device
              xyouts,sx,sy-dy*c++,string('Min|Max|Avg['+n2s(iband)+'] Cent: ',min(bgsub[censel]),max(bgsub[censel]),mean(bgsub[censel]),format='(A,I8,I8,I8)'),/device
              xyouts,sx,sy-dy*c++,string('Min|Max|Avg['+n2s(iband)+'] DrkH: ',min(bgsub[scisel]),max(bgsub[scisel]),mean(bgsub[scisel]),mean((scidark[*,*,iband])[scisel]),$
                                         format='(A,I8,I8,I8,I8)'),/device

              ;;prepare image for display
              simage = rebin(double(image),scirebin,scirebin,/sample)
              sbgsub = rebin(bgsub,scirebin,scirebin,/sample)
              sat = where(simage ge 65535,nsat)

              if(shm_var[settings.shm_scitype] eq settings.scitype_image) then begin
                 ;;scale image
                 greygrscale,simage,65535
                 cbrange=minmax(image)
                 cbtitle='ADU'
                 cbformat='(I)'
              endif
              
              if(shm_var[settings.shm_scitype] eq settings.scitype_log) then begin
                 simage = alog10(simage/max(simage)) > (-5)
                 cbrange = minmax(simage)
                 greygrscale,simage,65535
                 cbtitle='LOG'
                 cbformat='(F0.1)'
              endif

              if(shm_var[settings.shm_scitype] eq settings.scitype_contrast) then begin
                 if pkt.refmax[iband] gt 0 then simage = alog10(sbgsub / hed.exptime / pkt.refmax[iband]) else simage[*]=1
                 ;simage = round(2*simage)/2d
                 greygrscale,simage,65535,min=-8,max=-3
                 cbrange = [-8,-3]
                 cbtitle='CON'
                 cbformat='(F0.1)'
              endif
              
              if nsat gt 0 then simage[sat] = 254

              ;;add box
              simage[*,0]  = 252
              simage[*,-1] = 252
              simage[0,*]  = 252
              simage[-1,*] = 252
              
              ;;add IWA ring
              simage[sciring] = 253
              simage[scidz] = 253
              ;;display
              greygr
              xsize = !D.X_SIZE/n_elements(pkt.bands.band)
              xpos  = iband*xsize+(xsize-scirebin)/2
              ypos  = (!D.Y_SIZE-scirebin)/2
              tv,simage,xpos,ypos
              position=[xpos+scirebin+5,ypos,xpos+scirebin+5+10,ypos+scirebin] / double([!D.X_SIZE,!D.Y_SIZE,!D.X_SIZE,!D.Y_SIZE])
              xyouts,xpos+scirebin/2,ypos+scirebin+2,'Rot: '+n2s(fix(pkt.dhrot))+'  iHOWFS: '+n2s(fix(pkt.ihowfs))+'  iSPECKLE: '+n2s(fix(pkt.ispeckle)),/device,alignment=0.5
              cbmcolorbar,range=cbrange,/vertical,/right,title=cbtitle,position=position,ncolors=253,format=cbformat,divisions=5
           endfor
           
           ;;plot live contrast
           if update_contrast then if n_elements(contrast_array) eq 0 then contrast_array = contrast else contrast_array = [[contrast_array],[contrast]]
           if n_elements(contrast_array) gt 0 then begin
              ncon = n_elements(contrast_array[0,*])
              ndisp = 10
              pdisp = ndisp < ncon
              title='Contrast: '
              if n_elements(contrast_array[0,*]) gt 1 then delta = contrast_array[*,-1] - contrast_array[*,-2] else delta=dblarr(sci_nbands)
              for iband=0,sci_nbands-1 do title+=n2s(contrast_array[iband,-1],format='(E10.1)')+' ('+n2s(delta[iband],format='(E10.2)')+')'
              
              plot,[0],[0],xrange=[0,ndisp+1],yrange=[1e-10,1],/ylog,position=[0,0,0.3,0.5],/nodata,/noerase,/xs,/ys,title=title
              linecolor
              for iband=0,sci_nbands-1 do begin
                 oplot,contrast_array[iband,-pdisp:*],color=iband+1
              endfor
              oplot,!X.CRANGE,[1e-7,1e-7],color=255,linestyle=2
           endif
           
           ;;take snapshot
           snap = TVRD(true=1)
           ;;delete pixmap window
           wdelete,wpix
           ;;switch back to real window
           wset,wsci
           ;;display image
           tv,snap,true=1
           
           loadct,0
        endif
        
     endif
     
     ;;Display ALPAO Command
     if hed.alp_commander eq SCIID then begin
        if set.w[walp].show then begin
           ;;set window
           wset,walp
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[walp].font
           ;;fill out image
           alpimg[alpsel] = pkt.alp.acmd
           ;;set commander tag
           ctag='SCI'
           ;;display image
           implot,alpimg,blackout=alpnotsel,range=[-1,1],cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='ALPAO DM Command ('+ctag+')',erase=(ctag ne alpctag)
           alpctag=ctag
           loadct,0
        endif
     endif
     
     ;;Display BMC Command
     if set.w[wbmc].show then begin
        ;;set window
        wset,wbmc
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wbmc].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;fill out image
        if shm_var[settings.shm_bmctype] eq settings.bmctype_cmd then begin
           bmcimg[bmcsel] = pkt.bmc.acmd
           bmcflat = pkt.bmc.acmd
           range = [0,150]
        endif
        if shm_var[settings.shm_bmctype] eq settings.bmctype_dif then begin
           bmcimg[bmcsel] = pkt.bmc.acmd - bmcflat
           range = 0
        endif
        ;;display image
        implot,bmcimg,blackout=bmcnotsel,range=range,cbtitle='V',cbformat='(I)',ncolors=254,title='BMC DM Command',/erase
        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wbmc
        ;;display image
        tv,snap,true=1
        loadct,0
     endif
     
     ;;Display BMC telemetry
     if set.w[wbmd].show then begin
        ;;set window
        wset,wbmd
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wsda].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin
        dy  = 16
        sx = 5
        sy = !D.Y_SIZE - dy
        c=0
        ;;text formatting
        str_power = ['OFF','RAMP UP 01','RAMP UP 02','RAMP UP 03','RAMP UP 04','RAMP UP 05','ON','UNKNOWN 07','UNKNOWN 08','RAMP DOWN']
        str_range = ['100 V','150 V','200 V','225 V']
        str_voltstat = ['ERROR','GOOD']
        str_onoff = ['OFF','ON']
        str_overtemp = ['NORM','OVER']
        ;;testpoints
        str_testpoint_set = strmid(strcompress(string(pkt.bmc.tcmd,format='(11I4)')),1)
        str_testpoint_val = strmid(strcompress(string(pkt.bmc_status.testpoint_v,format='(11I4)')),1)
        ;;print data
        xyouts,sx,sy-dy*c++,' Power: '+str_power[pkt.bmc_status.power],/device
        xyouts,sx,sy-dy*c++,' Range: '+str_range[pkt.bmc_status.range],/device
        xyouts,sx,sy-dy*c++,'    HV: '+str_onoff[pkt.bmc_status.supply_hv],/device
        xyouts,sx,sy-dy*c++,'  3.3V: '+str_voltstat[pkt.bmc_status.volt_3v3],/device
        xyouts,sx,sy-dy*c++,'  5.0V: '+str_voltstat[pkt.bmc_status.volt_5],/device
        xyouts,sx,sy-dy*c++,' Input: '+n2s(pkt.bmc_status.voltage_input_v,format='(F10.1)'),/device
        xyouts,sx,sy-dy*c++,' mAmps: '+n2s(pkt.bmc_status.current_ma,format='(F10.1)'),/device
        xyouts,sx,sy-dy*c++,'3V Sup: '+n2s(pkt.bmc_status.rail_3v1_v,format='(F10.1)')+' '+n2s(pkt.bmc_status.rail_3v2_v,format='(F10.1)'),/device
        xyouts,sx,sy-dy*c++,'5V Sup: '+n2s(pkt.bmc_status.rail_5v1_v,format='(F10.1)')+' '+n2s(pkt.bmc_status.rail_5v2_v,format='(F10.1)'),/device
        xyouts,sx,sy-dy*c++,'HV Sup: '+n2s(pkt.bmc_status.hv_supp_v[0],format='(F10.1)')+' '+n2s(pkt.bmc_status.hv_supp_v[1],format='(F10.1)'),/device
        xyouts,sx,sy-dy*c++,'TP Set: '+str_testpoint_set,/device
        xyouts,sx,sy-dy*c++,'TP Val: '+str_testpoint_val,/device
        ;;second column
        c=0
        dx=180
        xyouts,sx+dx,sy-dy*c++,'  LEDS: '+str_onoff[pkt.bmc_status.leds],/device
        xyouts,sx+dx,sy-dy*c++,'  TEMP: '+str_overtemp[pkt.bmc_status.over_temp],/device
        xyouts,sx+dx,sy-dy*c++,'Main B: '+n2s(pkt.bmc_status.main_brd_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,' Top B: '+n2s(pkt.bmc_status.top_brd_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,' Mid B: '+n2s(pkt.bmc_status.mid_brd_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,' Bot B: '+n2s(pkt.bmc_status.bot_brd_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,'Heat S: '+n2s(pkt.bmc_status.heatsink_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,'Sock 1: '+n2s(pkt.bmc_status.sock1_temp_c,format='(F10.1)')+' C',/device
        xyouts,sx+dx,sy-dy*c++,'Sock 2: '+n2s(pkt.bmc_status.sock2_temp_c,format='(F10.1)')+' C',/device


        ;;take snapshot
        snap = TVRD(true=1)
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wbmd
        ;;display image
        tv,snap,true=1
        loadct,0
     endif
  endif
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_tmConnect
;;  - function to connect to the image server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function piccgse_tmConnect
  common piccgse_block, settings, set, shm_var
  unit=-1
  
  ;;Check if we are reading from a file
  if set.tmserver_type eq 'tmfile' then begin
     print,'PICCGSE: Opening tmfile: '+set.tmserver_tmfile
     openr,unit,set.tmserver_tmfile,/GET_LUN,ERROR=con_status
     if con_status eq 0 then begin
        print,'PICCGSE: File opened.'
        return, unit
     endif else begin
        print,'PICCGSE: piccgse_tmConnect tmfile open failed'
        print,'PICCGSE: '+!ERR_STRING
        if unit gt 0 then free_lun,unit,/force
        return,-1
     endelse
  endif
  
  ;;Check if we are reading form the network
  if set.tmserver_type eq 'network' then begin
     ;;Command to ask server for data
     ;;NOTE: Investigate why the endian is different, both are x86 PCs
     cmd_senddata = swap_endian('0ABACABB'XUL)
     if set.tmserver_addr eq 'picture'   then cmd_senddata = swap_endian('0ABACABB'XUL)
     if set.tmserver_addr eq 'localhost' then cmd_senddata = swap_endian('0ABACABB'XUL)
     if set.tmserver_addr eq 'tmserver'  then cmd_senddata = '22220001'XUL
     
     ;;Create Socket connection
     print, 'PICCGSE: Opening TM socket to '+set.tmserver_addr+' on port '+n2s(set.tmserver_port)
     socket, unit, set.tmserver_addr, set.tmserver_port, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status, READ_TIMEOUT=2
     if con_status eq 0 then begin
        print, 'PICCGSE TM socket created, requesting data'
        ;;Ask for images
        ON_IOERROR, WRITE_ERROR
        writeu,unit,cmd_senddata
        return,unit
     endif else begin
        print,'PICCGSE: TM socket failed to open'
        print,'PICCGSE: '+!ERR_STRING
        if unit gt 0 then free_lun,unit,/force
        return,-1
     endelse

     ;;skip over error handler
     goto, NO_WRITE_ERROR
     
     WRITE_ERROR:
     print,'PICCGSE: Data request write error'
     print,'PICCGSE: '+!ERR_STRING
     if unit gt 0 then free_lun,unit,/force

     NO_WRITE_ERROR:
     return,-1
  endif
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_remoteListen
;;  - function to listen for remote connections
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function piccgse_remoteListen
  common piccgse_block, settings, set, shm_var
  unit=-1
  print, 'PICCGSE: Opening remote listening socket on port '+n2s(settings.remote_port)
  socket, unit, settings.remote_port,/listen,/get_lun,error=con_error
  if con_error eq 0 then begin
     print,'PICCGSE: Listening for remote connections on port '+n2s(settings.remote_port)
     return, unit
  endif else begin
     print,'PICCGSE: Remote listening socket failed to open'
     print,'PICCGSE: '+!ERR_STRING
     if unit gt 0 then free_lun,unit,/force
     return, -1
  endelse
end
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;piccgse
;; -- Main program
;; -- Display science products in several windows
;;
;;KEYWORDS:
;;   NOSAVE
;;      Do not save data
;;   NOUPLINK
;;      Use bidirectional downlink for commands instead of uplink
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse, NOSAVE=NOSAVE, NOUPLINK=NOUPLINK, NOPLOT=NOPLOT, REMOTE=REMOTE, TMTYPE=TMTYPE, TMADDR=TMADDR, TMPORT=TMPORT, TMFILE=TMFILE, IDLFILE=IDLFILE
  common piccgse_block, settings, set, shm_var

;*************************************************
;* LOAD SETTINGS
;*************************************************
settings = load_settings()
  
;*************************************************
;* DEFINE SETTINGS STRUCTURES
;*************************************************
  ;;Windows
  win = {id:'',name:'',show:0,fast:0,xsize:0,ysize:0,xpos:0,ypos:0,font:''}

  ;;Settings
  set = {tmserver_type:'',tmserver_addr:'',tmserver_port:0U,tmserver_tmfile:'',tmserver_idlfile:'',$
         datapath:'',pktlogunit:0,savedata:(NOT keyword_set(NOSAVE)),w:replicate(win,12)}
  
  ;;Assign window ID tags
  i=0
  set.w[i++].id = 'shk'
  set.w[i++].id = 'lyt'
  set.w[i++].id = 'alp'
  set.w[i++].id = 'bmc'
  set.w[i++].id = 'sci'
  set.w[i++].id = 'acq'
  set.w[i++].id = 'shz'
  set.w[i++].id = 'lyz'
  set.w[i++].id = 'thm'
  set.w[i++].id = 'sda'
  set.w[i++].id = 'lda'
  set.w[i++].id = 'bmd'

;*************************************************
;* GET INFORMATION FROM FLIGHT SOFTWARE
;*************************************************
  ;;Flight software header file
  header='../piccflight/src/controller.h'

  ;;Packet names
  packet_name = strsplit(read_c_enum(header,'bufids'),'_',/extract)
  packet_name = packet_name.toarray()
  packet_name = strlowcase(packet_name[*,1])
  packet_name = packet_name[0:-2] ;;remove last entry for NCIRCBUF
  
  ;;Read packet header and check for padding
  hed   = read_c_struct(header,'pkthed')
  if check_padding(hed)   then stop,'pkthed contains padding'

  ;;Read packet structures
  packet_list = list()
  for i=0, n_elements(packet_name)-1 do begin
     ;;read structure
     void = execute(packet_name[i]+'= read_c_struct(header,"'+packet_name[i]+'")')
     ;;remove header
     void = execute('struct_delete_field,'+packet_name[i]+',"hed"')
     ;;add to list
     void = execute('packet_list.add,'+packet_name[i])
     ;;check for padding
     if check_padding(packet_list[i]) then stop,packet_name[i]+' contains padding'
  endfor
  
  ;;Get #defines
  TLM_PRESYNC   = '12345678'XUL
  TLM_POSTSYNC  = 'DEADBEEF'XUL
  TLM_LPRE      = lss(TLM_PRESYNC)
  TLM_MPRE      = mss(TLM_PRESYNC)
  TLM_LPOST     = lss(TLM_POSTSYNC)
  TLM_MPOST     = mss(TLM_POSTSYNC)

;*************************************************
;* LOAD CONFIGURATION FILE
;*************************************************
  config_props = FILE_INFO(settings.config_file)
  if config_props.exists EQ 0 then stop, 'ERROR: Config file '+settings.config_file+' not found'
  cfg_mod_sec = config_props.mtime
  piccgse_loadConfig, settings.config_file, TMTYPE=TMTYPE, TMADDR=TMADDR, TMPORT=TMPORT, TMFILE=TMFILE, IDLFILE=IDLFILE
 
;*************************************************
;* INIT CONNECTIONS
;*************************************************
  tm_last_connected = -1
  tm_last_data      = -1
  tmunit = -1
  lunit = -1
  runit = -1
  sync1 = 0U
  sync2 = 0U
  sync3 = 0U
  sync4 = 0U

;*************************************************
;* SETUP FILES
;*************************************************
  piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
 
;*************************************************
;* CREATE WINDOWS
;*************************************************
  if NOT keyword_set(NOPLOT) then piccgse_createWindows
 
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

  ;;last time we listened for connections
  t_last_listen = SYSTIME(1)
  
;*************************************************
;* SETUP DATA PLAYBACK
;*************************************************
  if(set.tmserver_type eq 'idlfile') then begin
     ;;get filenames
     idlfiles = file_search(set.tmserver_idlfile,count=nfiles)
     ifile = 0L
     print,'PICCGSE: Opening idlfile images'
     help,idlfiles
     set.savedata=0
  endif
  if(set.tmserver_type eq 'tmfile') then begin
     set.savedata=0
  endif

;*************************************************
;* SETUP SHARED MEMORY
;*************************************************
  shmmap, 'shm', /byte, settings.shm_size
  ;;NOTE: This creates a file /dev/shm/shm of size shm_size bytes
  ;;      The file does not get deleted when you quit IDL, so if
  ;;      shm_size changes, you must delete this file manualy. 
  
  shm_var = shmvar('shm')
  shm_var[*] = bytarr(settings.shm_size)
  shm_var[settings.shm_run] = 1
  shm_var[settings.shm_uplink] = NOT keyword_set(NOUPLINK)
  shm_var[settings.shm_remote] = keyword_set(REMOTE)
  shm_var[settings.shm_timestamp:settings.shm_timestamp+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
  print,'PICCGSE: Shared memory mapped'
  
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
  obridge_dn->execute,'piccgse_dnlink_console'
  print,'PICCGSE: Up/Down Console widgets started'

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
        print,'PICCGSE: Resetting TM connection'
        if tmunit gt 0 then free_lun,tmunit,/force
        if lunit gt 0 then free_lun,lunit,/force
        if runit gt 0 then free_lun,runit,/force
        tmunit = -1
        lunit  = -1
        runit  = -1
     endif
     CATCH, /CANCEL
  endif

;*************************************************
;* MAIN LOOP
;*************************************************
  while 1 do begin
     ;;Get time
     t_now = SYSTIME(1)
     
     ;;Start remote listener
     if (lunit lt 0) AND (t_now - t_last_listen gt 1) then begin
        lunit = piccgse_remoteListen()
        t_last_listen = t_now
     endif
     
     ;;----------------------------------------------------------
     ;;Decide how we will read data (idlfile,tmfile,network)
     ;;----------------------------------------------------------
     
     ;;READ DATA FROM TMSERVER_IDLFILE [Read back IDL savefiles]
     if set.tmserver_type eq 'idlfile' then begin
        if nfiles eq 0 then begin
           print,'PICCGSE: No IDL files found @: '+set.tmserver_idlfile
           wait,1
        endif else begin
           restore,idlfiles[ifile]
           ;;process data
           if NOT keyword_set(NOPLOT) then piccgse_processData,hed,pkt,tag
           ;;relay packet
           if runit ge 0 then begin
              ;;Install error handler
              ON_IOERROR, REMOTE_SEND_ERROR
              send = pkt
              struct_add_field,send,'hed',hed,itag=0
              struct_add_field,send,'presync',TLM_PRESYNC,itag=0
              struct_add_field,send,'postsync',TLM_POSTSYNC
              writeu,runit,send
           endif

           ;;skip over error handler
           goto, NO_REMOTE_SEND_ERROR

           REMOTE_SEND_ERROR:
           print,'PICCGSE: ERROR --> REMOTE_ERROR'
           print,'PICCGSE: '+!ERR_STRING 
           if lunit gt 0 then begin
              free_lun,lunit,/force
           endif
           if runit gt 0 then begin
              free_lun,runit,/force
           endif
           lunit=-1
           runit=-1

           NO_REMOTE_SEND_ERROR:
           ;;save time
           t_last_telemetry = t_now
           ;;increment file for next time
           ifile = (ifile+1) mod nfiles
           wait,0.1
        endelse
     endif

     ;;READ DATA FROM NETWORK OR TMFILE
     ;;-- Expected data: experiment data with empty codes (0xFADE) stripped out
     if set.tmserver_type eq 'network' OR set.tmserver_type eq 'tmfile' then begin
        if tmunit gt 0 then begin
           ;;Install error handler
           ON_IOERROR, TM_ERROR
           ;;Set link status
           shm_var[settings.shm_link] = 1
           ;;Wait for data
           if file_poll_input(tmunit,timeout=0.01) then begin
              ;;Set data status
              shm_var[settings.shm_data] = 1
              tm_last_data = systime(1)
              ;;Check presync words
              readu, tmunit, sync1
              if sync1 eq TLM_LPRE then begin
                 readu, tmunit, sync2
                 if sync2 eq TLM_MPRE then begin
                    ;;Read header
                    readu, tmunit, hed
                    ;;Get frame number
                    sfn = n2s(hed.frame_number,format='(I8.8)')
                    ;;Init packet string tag
                    tag=''
                    ;;Identify data
                    if (hed.type ge 0) AND (hed.type lt n_elements(packet_name)) then begin
                       tag = packet_name[hed.type]
                       pkt = packet_list[hed.type]
                    endif
                    ;;If we identified the packet
                    if tag ne '' then begin 
                       ;;read and process packet
                       msg1 = gettimestamp('.')+': '+'header.'+tag+'.'+sfn
                       printf,set.pktlogunit,msg1
                       ;;read packet
                       readu, tmunit, pkt
                       ;;check postsync words 
                       readu, tmunit, sync3
                       if sync3 eq TLM_LPOST then begin
                          readu, tmunit, sync4
                          if sync4 eq TLM_MPOST then begin
                             ;;process packet
                             start_time = systime(1)
                             ;;swap column/row major for 2D arrays
                             if NOT shm_var[settings.shm_remote] then begin
                                struct_swap_majority,hed
                                struct_swap_majority,pkt
                             endif
                             if NOT keyword_set(NOPLOT) then piccgse_processData,hed,pkt,tag
                             ;;save packet
                             if set.savedata then save,hed,pkt,tag,filename=set.datapath+'piccgse.'+gettimestamp('.')+'.'+tag+'.'+n2s(hed.frame_number,format='(I8.8)')+'.idl'
                             end_time = systime(1)
                             msg2 = gettimestamp('.')+': '+'packet.'+tag+'.'+sfn+'.'+n2s((end_time-start_time)*1000,format='(I)')+'ms'
                             ;;relay packet to remote
                             if runit ge 0 then begin
                                send = pkt
                                struct_add_field,send,'hed',hed,itag=0
                                struct_add_field,send,'presync',TLM_PRESYNC,itag=0
                                struct_add_field,send,'postsync',TLM_POSTSYNC
                                writeu,runit,send
                             endif
                          endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps2.' + $
                                            n2s(sync3,format='(Z4.4)')+'['+n2s(TLM_MPOST,format='(Z4.4)')+']'
                       endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps1.' + $
                                         n2s(sync4,format='(Z4.4)')+'['+n2s(TLM_LPOST,format='(Z4.4)')+']'
                       printf,set.pktlogunit,msg2
                       first = strpos(msg2,'dropped')
                       if(first ge 0) then print,msg2
                    endif else begin
                       ;;Unknown packet
                       msg=gettimestamp('.')+': '+'unknown.'+n2s(hed.type)+'.'+sfn
                       printf,set.pktlogunit,msg
                       print,msg
                       print,'PKTHED: '+n2s(hed.type,format='(Z)')+'     '+sfn
                    endelse
                 endif
              endif
           endif else begin
              ;;here if FILE_POLL_INPUT timed out
              ;;if no data, check for timeout
              ;;if timed out, reconnect
              if ((t_now-tm_last_data) GT 5) then begin
                 print,'PICCGSE: IMAGE SERVER TIMEOUT!'

                 ;;skip over error handler
                 goto, NO_TM_ERROR
                 
                 TM_ERROR:
                 print,'PICCGSE: ERROR --> TM_ERROR'
                 print,'PICCGSE: '+!ERR_STRING
                 
                 NO_TM_ERROR:
                 if tmunit gt 0 then free_lun,tmunit,/force
                 if lunit gt 0 then free_lun,lunit,/force
                 if runit gt 0 then free_lun,runit,/force
                 tmunit=-1
                 lunit=-1
                 runit=-1
                 shm_var[settings.shm_link] = 0
                 shm_var[settings.shm_data] = 0
                 print,'PICCGSE: CONNECTION RESET'
                 print,''
                 wait,1
              endif
           endelse
        endif else begin
           ;;if not connected, reconnect
           tmunit = piccgse_tmConnect()
           if tmunit GT 0 then begin 
              tm_last_connected = systime(1)
              tm_last_data      = systime(1)
           endif else wait,1
        endelse
     endif
     
     ;;----------------------------------------------------------
     ;; Check config file
     ;;----------------------------------------------------------
     ;;Has config file been modified?
     if (t_now-t_last_cfg) GT 0.5 then begin
        
        ;;Get config file properties
        config_props = FILE_INFO(settings.config_file)
        
        ;;Update last time config file was checked
        t_last_cfg = SYSTIME(1)
        
        ;;If config file has been modified then load the new version
        if config_props.mtime NE cfg_mod_sec then begin
           PRINT, 'PICCGSE: Loading modified configuration file'
           cfg_mod_sec = config_props.mtime
           old_set = set
           piccgse_loadConfig, settings.config_file, TMTYPE=TMTYPE, TMADDR=TMADDR, TMPORT=TMPORT, TMFILE=TMFILE, IDLFILE=IDLFILE
           if(set.tmserver_type eq 'idlfile') then begin
              ;;get filenames
              idlfiles = file_search(set.tmserver_idlfile,count=nfiles)
              
              print,'PICCGSE: Opening idlfile images'
              help,idlfiles
           endif

           ;;Check if we need to reset windows
           if piccgse_newWindows(old_set) then if NOT keyword_set(NOPLOT) then piccgse_createWindows
           
        endif
     endif
     
     ;;----------------------------------------------------------
     ;; Check for commands
     ;;----------------------------------------------------------
     if shm_var[settings.shm_cmd] then begin
        ;;reset command bit
        shm_var[settings.shm_cmd]=0
        
        ;;exit
        if NOT shm_var[settings.shm_run] then begin
           if tmunit gt 0 then free_lun,tmunit,/force
           if lunit gt 0 then free_lun,lunit,/force
           if runit gt 0 then free_lun,runit,/force
           if set.pktlogunit gt 0 then free_lun,set.pktlogunit,/force
           close,/all
           for i=0,9 do begin
              if (shm_var[settings.shm_up_run] eq 0) AND (shm_var[settings.shm_dn_run] eq 0) then break
              wait,0.1
           endfor
           obj_destroy,obridge_up
           obj_destroy,obridge_dn
           shmunmap,'shm'
           print,'PICCGSE: Shared memory unmapped'
           while !D.WINDOW ne -1 do wdelete
           print,'PICCGSE: Exiting IDL'
           ;;IDL requires two exit commands to fully exit
           exit
           exit
        endif
        
        ;;reset
        if shm_var[settings.shm_reset] then begin
           shm_var[settings.shm_reset]=0
           print,'PICCGSE: Resetting paths...'
           piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
           ;;set timestamp in shared memory
           shm_var[settings.shm_timestamp:settings.shm_timestamp+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
        endif
     endif
     
     ;;----------------------------------------------------------
     ;; Check for remote connections
     ;;----------------------------------------------------------
     if lunit gt 0 then begin
        if file_poll_input(lunit,timeout=0) then begin
           if runit lt 0 then begin
              ;;establish a connection to send data to the client
              socket, runit, accept=lunit, /get_lun, error=con_error, connect_timeout=3, write_timeout=2, read_timeout=2
              if con_error eq 0 then begin
                 print,'PICCGSE: Remote connection established'
                 if file_poll_input(runit, timeout=1) then begin
                    cmd = 0UL
                    readu,runit,cmd
                    print,'PICCGSE: Got remote command '+n2s(cmd,format='(Z8.8)')
                 endif
              endif else begin
                 print,'PICCGSE: Remote connection failed'
                 if runit gt 0 then free_lun,runit,/force
                 runit=-1
              endelse
           endif
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
  if tmunit gt 0 then free_lun,tmunit,/force
  if lunit gt 0 then free_lun,lunit,/force
  if runit gt 0 then free_lun,runit,/force
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit,/force
  close,/all
  for i=0,9 do begin
     if (shm_var[settings.shm_up_run] eq 0) AND (shm_var[settings.shm_dn_run] eq 0) then break
     wait,0.1
  endfor
  obj_destroy,obridge_up
  obj_destroy,obridge_dn
  shmunmap,'shm'
  print,'PICCGSE: Shared memory unmapped'
  while !D.WINDOW ne -1 do wdelete
end
