;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path  
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
           'SHK_NAME'        : set.w[wshk].name  = value
           'SHK_XSIZE'       : set.w[wshk].xsize = value
           'SHK_YSIZE'       : set.w[wshk].ysize = value
           'SHK_XPOS'        : set.w[wshk].xpos  = value
           'SHK_YPOS'        : set.w[wshk].ypos  = value
           'SHK_FONT'        : set.w[wshk].font  = value
           
           ;;LYT Window
           'LYT_SHOW'        : set.w[wlyt].show  = value
           'LYT_NAME'        : set.w[wlyt].name  = value
           'LYT_XSIZE'       : set.w[wlyt].xsize = value
           'LYT_YSIZE'       : set.w[wlyt].ysize = value
           'LYT_XPOS'        : set.w[wlyt].xpos  = value
           'LYT_YPOS'        : set.w[wlyt].ypos  = value
           'LYT_FONT'        : set.w[wlyt].font  = value
           
           ;;ALP Window
           'ALP_SHOW'        : set.w[walp].show  = value
           'ALP_NAME'        : set.w[walp].name  = value
           'ALP_XSIZE'       : set.w[walp].xsize = value
           'ALP_YSIZE'       : set.w[walp].ysize = value
           'ALP_XPOS'        : set.w[walp].xpos  = value
           'ALP_YPOS'        : set.w[walp].ypos  = value
           'ALP_FONT'        : set.w[walp].font  = value
           
           ;;BMC Window
           'BMC_SHOW'        : set.w[wbmc].show  = value
           'BMC_NAME'        : set.w[wbmc].name  = value
           'BMC_XSIZE'       : set.w[wbmc].xsize = value
           'BMC_YSIZE'       : set.w[wbmc].ysize = value
           'BMC_XPOS'        : set.w[wbmc].xpos  = value
           'BMC_YPOS'        : set.w[wbmc].ypos  = value
           'BMC_FONT'        : set.w[wbmc].font  = value
           
           ;;ACQ Window
           'ACQ_SHOW'        : set.w[wacq].show  = value
           'ACQ_NAME'        : set.w[wacq].name  = value
           'ACQ_XSIZE'       : set.w[wacq].xsize = value
           'ACQ_YSIZE'       : set.w[wacq].ysize = value
           'ACQ_XPOS'        : set.w[wacq].xpos  = value
           'ACQ_YPOS'        : set.w[wacq].ypos  = value
           'ACQ_FONT'        : set.w[wacq].font  = value
           
           ;;SCI Window
           'SCI_SHOW'        : set.w[wsci].show  = value
           'SCI_NAME'        : set.w[wsci].name  = value
           'SCI_XSIZE'       : set.w[wsci].xsize = value
           'SCI_YSIZE'       : set.w[wsci].ysize = value
           'SCI_XPOS'        : set.w[wsci].xpos  = value
           'SCI_YPOS'        : set.w[wsci].ypos  = value
           'SCI_FONT'        : set.w[wsci].font  = value
           
           ;;SHZ Window
           'SHZ_SHOW'        : set.w[wshz].show  = value
           'SHZ_NAME'        : set.w[wshz].name  = value
           'SHZ_XSIZE'       : set.w[wshz].xsize = value
           'SHZ_YSIZE'       : set.w[wshz].ysize = value
           'SHZ_XPOS'        : set.w[wshz].xpos  = value
           'SHZ_YPOS'        : set.w[wshz].ypos  = value
           'SHZ_FONT'        : set.w[wshz].font  = value
           
           ;;LYZ Window
           'LYZ_SHOW'        : set.w[wlyz].show  = value
           'LYZ_NAME'        : set.w[wlyz].name  = value
           'LYZ_XSIZE'       : set.w[wlyz].xsize = value
           'LYZ_YSIZE'       : set.w[wlyz].ysize = value
           'LYZ_XPOS'        : set.w[wlyz].xpos  = value
           'LYZ_YPOS'        : set.w[wlyz].ypos  = value
           'LYZ_FONT'        : set.w[wlyz].font  = value
           
           ;;THM Window
           'THM_SHOW'        : set.w[wthm].show  = value
           'THM_NAME'        : set.w[wthm].name  = value
           'THM_XSIZE'       : set.w[wthm].xsize = value
           'THM_YSIZE'       : set.w[wthm].ysize = value
           'THM_XPOS'        : set.w[wthm].xpos  = value
           'THM_YPOS'        : set.w[wthm].ypos  = value
           'THM_FONT'        : set.w[wthm].font  = value

           ;;SDA Window
           'SDA_SHOW'        : set.w[wsda].show  = value
           'SDA_NAME'        : set.w[wsda].name  = value
           'SDA_XSIZE'       : set.w[wsda].xsize = value
           'SDA_YSIZE'       : set.w[wsda].ysize = value
           'SDA_XPOS'        : set.w[wsda].xpos  = value
           'SDA_YPOS'        : set.w[wsda].ypos  = value
           'SDA_FONT'        : set.w[wsda].font  = value

           ;;LDA Window
           'LDA_SHOW'        : set.w[wlda].show  = value
           'LDA_NAME'        : set.w[wlda].name  = value
           'LDA_XSIZE'       : set.w[wlda].xsize = value
           'LDA_YSIZE'       : set.w[wlda].ysize = value
           'LDA_XPOS'        : set.w[wlda].xpos  = value
           'LDA_YPOS'        : set.w[wlda].ypos  = value
           'LDA_FONT'        : set.w[wlda].font  = value

           ;;BMD Window
           'BMD_SHOW'        : set.w[wbmd].show  = value
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
  

  ;;Close the config file
  free_lun,unit
  
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
  common processdata_block1, states, alpcalmodes, hexcalmodes, tgtcalmodes, bmccalmodes, shkbin, shkxs, shkys, lytxs, lytys, shkid, watid, lytid
  common processdata_block2, scirebin,lytrebin,scixs,sciys,scisel,scinotsel,scidark,lytxs_rebin,lytys_rebin,sciring,lytmasksel,lytmasknotsel
  common processdata_block3, lowfs_n_zernike, lowfs_n_pid, alpimg, alpsel, alpnotsel, alpctag, bmcimg, bmcsel, bmcnotsel, adc1, adc2, adc3
  common processdata_block4, wshk, wlyt, wacq, wsci, walp, wbmc, wshz, wlyz, wthm, wsda, wlda, wbmd, wpix
  common processdata_block5, sci_temp, sci_set, sci_tec, acq_xstar, acq_ystar, acq_xhole, acq_yhole, bmcflat, actuator_alp, actuator_hex
  
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
     SHKBIN = read_c_define(header,"SHKBIN")
     SHKXS  = read_c_define(header,"SHKXS")
     SHKYS  = read_c_define(header,"SHKYS")
     LYTXS  = read_c_define(header,"LYTXS")
     LYTYS  = read_c_define(header,"LYTYS")
     SCIXS  = read_c_define(header,"SCIXS")
     SCIYS  = read_c_define(header,"SCIYS")
     LOWFS_N_ZERNIKE = read_c_define(header,"LOWFS_N_ZERNIKE")
     LOWFS_N_PID = read_c_define(header,"LOWFS_N_PID")
     ACTUATOR_ALP = read_c_define(header,"ACTUATOR_ALP")
     ACTUATOR_HEX = read_c_define(header,"ACTUATOR_HEX")

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
     restore,'config/howfs_scimask.idl' ;;built by picctest/export_howfc.pro
     scisel = where(scimask,complement=scinotsel)

     ;;Init scidark
     scidark = dblarr(SCIXS,SCIYS)
     
     ;;Temperature database
     t = load_tempdb()
     adc1 = t[where(t.adc eq 1)]
     adc2 = t[where(t.adc eq 2)]
     adc3 = t[where(t.adc eq 3)]

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
     sciring = where(fix(rim) eq 6)
     image = intarr(scixs,sciys)
     image[sciring] = 1
     image = rebin(image,scirebin,scirebin,/sample)
     sciring = where(round(image) eq 1)

     ;;SCI Temperatures
     sci_temp = 0d
     sci_set  = 0d
     sci_tec  = 0

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

  ;;Swap column/row major for 2D arrays
  struct_swap_majority,pkt
  
  ;;SHKPKT
  if tag eq 'shkpkt' then begin
     ;;Display image
     if set.w[wshk].show then begin
        ;;set window
        wset,wshk
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wshk].font
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set color table
        linecolor
        ;;setup plotting
        plotsym,0,/fill
        ;;plot image axes
        zoom=40
        xoff=-5
        yoff=-7
        plot,[0],[0],xrange=[zoom+xoff,shkxs-zoom+xoff],yrange=[zoom+yoff,shkys-zoom+yoff],xstyle=5,ystyle=5,/nodata,position=[0,0,1,1]
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
              xcentroid = (double(pkt.cells[i].xtarget) + double(pkt.cells[i].xtarget_deviation[0]))/SHKBIN
              ycentroid = (double(pkt.cells[i].ytarget) + double(pkt.cells[i].ytarget_deviation[0]))/SHKBIN
              if pkt.cells[i].maxval eq 255 then color = 1 else color = 255
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
     if set.w[wsda].show then begin
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
               string(pkt.gain_alp_zern[0,1],pkt.gain_alp_zern[0,1],pkt.gain_alp_zern[0,2],format='(3F7.3)'),$
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
     if set.w[wshz].show then begin
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
        dy = 16
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        ;;calc zernike values
        zavg = mean(pkt.zernike_measured,dimension=2)
        zstd = stddev(pkt.zernike_measured,dimension=2)
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
           xyouts,sx,sy-dy*c++,string(i,zavg[i],ztar[i],zstd[i],format='(I2.2,F+6.2,F+6.2,F+6.2)'),/device,color=zclr[i]
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
     if hed.alp_commander eq SHKID OR hed.alp_commander eq WATID then begin
        if set.w[walp].show then begin
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
     if set.w[wlyt].show then begin
        ;;set window
        wset,wlyt
        ;;set font
        !P.FONT = 0
        device,set_font=set.w[wlyt].font
        simage = transpose(pkt.image.data)
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
        if set.w[walp].show then begin
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
     if set.w[wlda].show then begin
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
        xyouts,sx,sy-dy*c++,'Max Pixel: '+n2s(max(pkt.image.data),format='(I5)'),/device
        xyouts,sx,sy-dy*c++,'Avg Pixel: '+n2s(mean(pkt.image.data),format='(I5)'),/device
        xyouts,sx,sy-dy*c++,'Bkg Pixel: '+n2s(pkt.background,format='(I5)'),/device
        xyouts,sx,sy-dy*c++,'Centroid: '+n2s(mean(pkt.xcentroid),format='(F0.2)')+'  '+n2s(mean(pkt.ycentroid),format='(F0.2)'),/device
        if pkt.locked then locked='YES' else locked='NO'
        xyouts,sx,sy-dy*c++,'Locked: '+locked,/device
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
     if set.w[wlyz].show then begin
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
        dy = 16
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        ;;calc zernike values
        zavg = mean(pkt.zernike_measured,dimension=2)*1000
        zstd = stddev(pkt.zernike_measured,dimension=2)*1000
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
  
  ;;SCIEVENT
  if tag eq 'scievent' then begin
     ;;Display Image
     if set.w[wsci].show then begin
        ;;save SCI temps to common block
        sci_temp = pkt.ccd_temp
        sci_set  = pkt.tec_setpoint
        sci_tec  = pkt.tec_enable
        if (shm_var[settings.shm_scitype] eq settings.scitype_image) OR (shm_var[settings.shm_scitype] eq settings.scitype_log) then begin
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
           xyouts,sx,sy-dy*c++,'Frm | Exp: '+n2s(hed.ontime,format='(F0.3)')+' | '+n2s(hed.exptime,format='(F0.3)')+' sec',/device
           dt = long((double(hed.end_sec) - double(hed.start_sec))*1d6 + (double(hed.end_nsec) - double(hed.start_nsec))/1d3)
           xyouts,sx,sy-dy*c++,'Event Time: '+n2s(dt)+' us',/device
           xyouts,sx,sy-dy*c++,'CCD Temp: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C',/device
           xyouts,sx,sy-dy*c++,'iHOWFS: '+n2s(fix(pkt.ihowfs)),/device
           ;;display image
           for i=0,n_elements(pkt.bands.band)-1 do begin
              image  = double(transpose(reform(pkt.bands.band[i].data)))
              if (pkt.ihowfs eq 0) AND (states[hed.state] eq 'STATE_EFC')  then scidark = image ;;only update darkhole numbers when in STATE_EFC
              xyouts,sx,sy-dy*c++,string('Min|Max|Avg['+n2s(i)+'] Full: ',min(image),max(image),mean(image),format='(A,I8,I8,I8)'),/device
              xyouts,sx,sy-dy*c++,string('Min|Max|Avg['+n2s(i)+'] DrkH: ',min(image[scisel]),max(image[scisel]),mean(image[scisel]),mean(scidark[scisel]),$
                                         format='(A,I8,I8,I8,I8)'),/device
              simage = rebin(image,scirebin,scirebin,/sample)
              sat = where(simage ge 65535,nsat)
              
              if(shm_var[settings.shm_scitype] eq settings.scitype_log) then begin
                 simage = alog10(simage/max(simage)) > (-5)
                 greygrscale,simage,65535
                 if nsat gt 0 then simage[sat] = 254
              endif else begin
                 ;;scale image
                 greygrscale,simage,65535
              endelse
                            
              ;;add IWA ring
              simage[sciring] = 253
              ;;display
              greygr
              xsize = !D.X_SIZE/n_elements(pkt.bands.band)
              tv,simage,i*xsize+(xsize-scirebin)/2,(!D.Y_SIZE-scirebin)/2
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

  ;;WFSEVENT
  if tag eq 'wfsevent' then begin
     ;;Display Image
     if set.w[wsci].show then begin
        if (shm_var[settings.shm_scitype] ne settings.scitype_image) AND (shm_var[settings.shm_scitype] ne settings.scitype_log) then begin
           ;;set window
           wset,wsci
           ;;set font
           !P.FONT = 0
           device,set_font=set.w[wsci].font
           for i=0,n_elements(pkt.field)-1 do begin
              simage  = dblarr(scixs,sciys)
              if shm_var[settings.shm_scitype] eq settings.scitype_real      then simage[scisel] = pkt.field[i].r
              if shm_var[settings.shm_scitype] eq settings.scitype_imaginary then simage[scisel] = pkt.field[i].i
              if shm_var[settings.shm_scitype] eq settings.scitype_amplitude then simage[scisel] = sqrt(pkt.field[i].r^2 + pkt.field[i].i^2)
              if shm_var[settings.shm_scitype] eq settings.scitype_phase     then simage[scisel] = atan(pkt.field[i].i,pkt.field[i].r,/phase)
              simage = rebin(simage,scirebin,scirebin,/sample)
              ;;scale image
              greygrscale,simage,1e9
              ;;add IWA ring
              simage[sciring] = 253
              ;;display
              greygr
              xsize = !D.X_SIZE/n_elements(pkt.field)
              tv,simage,i*xsize+(xsize-scirebin)/2,(!D.Y_SIZE-scirebin)/2
           endfor
           loadct,0
        endif
     endif
  endif

  ;;ACQEVENT
  if tag eq 'acqevent' then begin
     ;;Display Image
     if set.w[wacq].show then begin
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
     ;;Display Thermal Data
     if set.w[wthm].show then begin
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
        dy = 16
        dx = 130
        sx = 5            
        sy = !D.Y_SIZE - dy
        nl = 24
        c  = 0
        ;;adc1 data
        for i=0,n_elements(adc1)-1 do begin
           color = green
           if pkt.adc1_temp[i] lt adc1[i].min then color = blue
           if pkt.adc1_temp[i] gt adc1[i].max then color = red
           fmt='F-+6.1'
           if adc1[i].abbr eq 'VREF' then fmt='F-+6.2'
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc1[i].abbr+':',pkt.adc1_temp[i],format='(A-7,'+fmt+')'),/device,color=color
           c++
        endfor
        ;;adc2 data
        for i=0,n_elements(adc2)-1 do begin
           color = green
           if pkt.adc2_temp[i] lt adc2[i].min then color = blue
           if pkt.adc2_temp[i] gt adc2[i].max then color = red
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc2[i].abbr+':',pkt.adc2_temp[i],format='(A-7,F-+6.1)'),/device,color=color
           c++
        endfor
        ;;adc3 data
        for i=0,n_elements(adc3)-1 do begin
           color = green
           if pkt.adc3_temp[i] lt adc3[i].min then color = blue
           if pkt.adc3_temp[i] gt adc3[i].max then color = red
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc3[i].abbr+':',pkt.adc3_temp[i],format='(A-7,F-+6.1)'),/device,color=color
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
        xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string('SCI',sci_temp,'/',sci_set,format='(A5,F7.1,A,F-7.1)'),/device,color=tec
        c++
        ;;print state
        bxs=204
        bys=24
        bth=2
        box=bytarr(bxs,bys)
        box[0:bth-1,*]=255    ;;left
        box[bxs-bth:-1,*]=255 ;;right
        box[*,0:bth-1]=255    ;;bottom
        box[*,bys-bth:-1]=255 ;;top
        tv,box,!D.X_SIZE-bxs,0
        xyouts,!D.X_SIZE-200,sy-dy*(nl-1),states[hed.state],/device,color=white
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
  
  ;;save data
  if set.savedata then save,hed,pkt,tag,filename=set.datapath+'piccgse.'+gettimestamp('.')+'.'+tag+'.'+n2s(hed.frame_number,format='(I8.8)')+'.idl'
    
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_tmConnect
;;  - function to connect to the image server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function piccgse_tmConnect
  common piccgse_block, settings, set, shm_var
  
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
     WRITE_ERROR:PRINT, 'WRITE_ERROR: '+!ERR_STRING  ;;jump here on writeu error
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
;;   NOUPLINK
;;      Use bidirectional downlink for commands instead of uplink
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse, NOSAVE=NOSAVE, NOUPLINK=NOUPLINK
  common piccgse_block, settings, set, shm_var

;*************************************************
;* LOAD SETTINGS
;*************************************************
settings = load_settings()
  
;*************************************************
;* DEFINE SETTINGS STRUCTURES
;*************************************************
  ;;Windows
  win = {id:'',name:'',show:0,xsize:0,ysize:0,xpos:0,ypos:0,font:''}

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

  ;;Buffer IDs
  buffer_id = read_c_enum(header,'bufids')
  for i=0, n_elements(buffer_id)-1 do void=execute(buffer_id[i]+'='+n2s(i))
  
  ;;Build packet structures
  pkthed   = read_c_struct(header,'pkthed')
  shkpkt   = read_c_struct(header,'shkpkt')
  lytpkt   = read_c_struct(header,'lytpkt')
  scievent = read_c_struct(header,'scievent')
  wfsevent = read_c_struct(header,'wfsevent')
  acqevent = read_c_struct(header,'acqevent')
  thmevent = read_c_struct(header,'thmevent')
  mtrevent = read_c_struct(header,'mtrevent')

  ;;Get #defines
  TLM_PRESYNC   = '12345678'XUL
  TLM_POSTSYNC  = 'DEADBEEF'XUL
  TLM_LPRE      = lss(TLM_PRESYNC)
  TLM_MPRE      = mss(TLM_PRESYNC)
  TLM_LPOST     = lss(TLM_POSTSYNC)
  TLM_MPOST     = mss(TLM_POSTSYNC)

  ;;Check for padding
  if check_padding(pkthed)   then stop,'pkthed contains padding'
  if check_padding(shkpkt)   then stop,'shkpkt contains padding'
  if check_padding(lytpkt)   then stop,'lytpkt contains padding'
  if check_padding(scievent) then stop,'scievent contains padding'
  if check_padding(wfsevent) then stop,'wfsevent contains padding'
  if check_padding(acqevent) then stop,'acqevent contains padding'
  if check_padding(thmevent) then stop,'thmevent contains padding'
  if check_padding(mtrevent) then stop,'mtrevent contains padding'

  ;;Remove headers from structures -- they are read seperately
  struct_delete_field,shkpkt,'hed'
  struct_delete_field,lytpkt,'hed'
  struct_delete_field,scievent,'hed'
  struct_delete_field,wfsevent,'hed'
  struct_delete_field,acqevent,'hed'
  struct_delete_field,thmevent,'hed'
  struct_delete_field,mtrevent,'hed'
  
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
  shm_var[settings.shm_timestamp:settings.shm_timestamp+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
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
  obridge_dn->execute,'piccgse_dnlink_console'
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
           piccgse_processData,hed,pkt,tag
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
           shm_var[settings.shm_link] = 1
           ;;Wait for data
           if file_poll_input(TMUNIT,timeout=0.01) then begin
              ;;Set data status
              shm_var[settings.shm_data] = 1
              tm_last_data = systime(1)
              ;;Check presync words
              readu, TMUNIT, sync
              if sync eq TLM_LPRE then begin
                 readu, TMUNIT, sync
                 if sync eq TLM_MPRE then begin
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
                       BUFFER_WFSEVENT: begin
                          tag = 'wfsevent'
                          pkt = wfsevent
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
                       else:;;do nothing
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
                       if sync eq TLM_LPOST then begin
                          readu, TMUNIT, sync
                          if sync eq TLM_MPOST then begin
                             ;;process packet
                             start_time = systime(1)
                             piccgse_processData,pkthed,pkt,tag
                             end_time = systime(1)
                             msg2 = gettimestamp('.')+': '+'packet.'+tag+'.'+sfn+'.'+n2s((end_time-start_time)*1000,format='(I)')+'ms'
                          endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps2.' + $
                                            n2s(sync,format='(Z4.4)')+'['+n2s(TLM_MPOST,format='(Z4.4)')+']'
                       endif else msg2 = gettimestamp('.')+': '+'dropped.'+tag+'.'+sfn+'.ps1.' + $
                                         n2s(sync,format='(Z4.4)')+'['+n2s(TLM_LPOST,format='(Z4.4)')+']'
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
              if ((t_now-tm_last_data) GT 5) then begin
                 print,'IMAGE SERVER TIMEOUT!'
                 RESET_CONNECTION: PRINT, 'IO ERROR: '+!ERR_STRING ;;Jump here if an IO error occured
                 print,'RESETTING CONNECTION'
                 ON_IOERROR,FREE_LUN_ERROR
                 free_lun,TMUNIT
                 if 0 then begin
                    FREE_LUN_ERROR: PRINT, 'FREE_LUN_ERROR: '+!ERR_STRING
                 endif
                 tm_connected = 0
                 shm_var[settings.shm_link] = 0
                 shm_var[settings.shm_data] = 0
                 wait,1
              endif
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
     endif
     
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

           ;;Check if we need to reset windows
           if piccgse_newWindows(old_set) then piccgse_createWindows
           
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
        
        ;;reset
        if shm_var[settings.shm_reset] then begin
           shm_var[settings.shm_reset]=0
           print,'Resetting paths...'
           piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
           ;;set timestamp in shared memory
           shm_var[settings.shm_timestamp:settings.shm_timestamp+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
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
