;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path  
  common piccgse_block, set


  ;;Get window indicies
  wshk = where(set.w.id eq 'shk')
  wlyt = where(set.w.id eq 'lyt')
  wacq = where(set.w.id eq 'acq')
  wsci = where(set.w.id eq 'sci')
  walp = where(set.w.id eq 'alp')
  wbmc = where(set.w.id eq 'bmc')
  wzer = where(set.w.id eq 'zer')
  wthm = where(set.w.id eq 'thm')
  
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
           
           ;;ZER Window
           'ZER_SHOW'        : set.w[wzer].show  = value
           'ZER_NAME'        : set.w[wzer].name  = value
           'ZER_XSIZE'       : set.w[wzer].xsize = value
           'ZER_YSIZE'       : set.w[wzer].ysize = value
           'ZER_XPOS'        : set.w[wzer].xpos  = value
           'ZER_YPOS'        : set.w[wzer].ypos  = value
           'ZER_FONT'        : set.w[wzer].font  = value
           
           ;;THM Window
           'THM_SHOW'        : set.w[wthm].show  = value
           'THM_NAME'        : set.w[wthm].name  = value
           'THM_XSIZE'       : set.w[wthm].xsize = value
           'THM_YSIZE'       : set.w[wthm].ysize = value
           'THM_XPOS'        : set.w[wthm].xpos  = value
           'THM_YPOS'        : set.w[wthm].ypos  = value
           'THM_FONT'        : set.w[wthm].font  = value

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
  common piccgse_block, set
  
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
  common piccgse_block, set
  for i=0, n_elements(set.w)-1 do begin
     if set.w[i].show then window, i, XSIZE=set.w[i].xsize, YSIZE=set.w[i].ysize,$
                                   XPOS=set.w[i].xpos, YPOS=set.w[i].ypos, TITLE=set.w[i].name, RETAIN=2
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
pro piccgse_processData, hed, pkt, tag
  common piccgse_block, set
  common processdata_block1, states, alpcalmodes, hexcalmodes, tgtcalmodes, bmccalmodes, shkbin, shkimg
  common processdata_block2, lowfs_n_zernike, lowfs_n_pid, alpimg, alpsel, alpnotsel, bmcimg, bmcsel, bmcnotsel, adc1, adc2, adc3
  common processdata_block3, wshk, wlyt, wacq, wsci, walp, wbmc, wzer, wthm, wpix

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
     LOWFS_N_ZERNIKE = read_c_define(header,"LOWFS_N_ZERNIKE")
     LOWFS_N_PID = read_c_define(header,"LOWFS_N_PID")

     ;;Blank SHK image
     shkimg = intarr(shkxs,shkys)

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
     alpsel = reverse(alpsel)
     alpimg = mask * 0d
     
     ;;BMC DM Display
     os = 64
     bmcsize = 34
     xyimage,bmcsize*os,bmcsize*os,xim,yim,rim,/quadrant
     rim /= os
     sel = where(rim lt 17)
     mask = rim*0
     mask[sel]=1
     mask = rebin(mask,bmcsize,bmcsize)
     bmcsel = where(mask gt 0.005,complement=bmcnotsel)
     bmcsel = reverse(bmcsel)
     bmcimg = mask * 0d
     
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
     wzer = where(set.w.id eq 'zer')
     wthm = where(set.w.id eq 'thm')
     wpix = n_elements(set.w)+1
  endif
  
  ;;Swap column/row major for 2D arrays
  struct_swap_majority,pkt
  
  ;;SHKPKT
  if tag eq 'shkpkt' then begin
     ;;Display image
     if set.w[wshk].show then begin
        ;;set window
        wset,wshk
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;display blank image
        imdisp,shkimg,/axis,/erase,title='Frame: '+n2s(hed.ontime*1000,format='(F10.1)')+' ms'+' CCD: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C'
        ;;setup plotting
        plotsym,0,/fill
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
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wshk
        ;;set color table
        linecolor
        ;;display image
        tv,snap
        loadct,0
     endif
     
     ;;Display Zernikes
     if set.w[wzer].show then begin
        ;;set window
        wset,wzer
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE/2,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin and spacing
        dy = 16
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        charsize = 1.6
        ;;calc zernike values
        zavg = mean(pkt.zernike_measured,dimension=2)
        zstd = stddev(pkt.zernike_measured,dimension=2)
        ztar = pkt.zernike_target
        ;;print header
        xyouts,sx,sy-dy*c++,string('--- SHK ZERNIKES ---',format='(A20)'),/device,charsize=charsize
        xyouts,sx,sy-dy*c++,string('Z','AVG','TAR','STD',format='(A2,A6,A6,A6)'),/device,charsize=charsize
        ;;print zernikes
        for i=0,n_elements(zavg)-1 do begin
           xyouts,sx,sy-dy*c++,string(i,zavg[i],ztar[i],zstd[i],format='(I2.2,F+6.2,F+6.2,F+6.2)'),/device,charsize=charsize
        endfor
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wzer
        ;;set color table
        loadct,0
        ;;display data
        tv,snap,0,0
        loadct,0
     endif
     
     ;;Display ALPAO Command
     if set.w[walp].show then begin
        ;;set window
        wset,walp
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;fill out image
        alpimg[alpsel] = pkt.alp_acmd[*,0]
        ;;display image
        implot,alpimg,ctable=0,blackout=alpnotsel,range=[-1,1],/erase,$
               cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='ALPAO DM Command'
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,walp
        ;;set color table
        loadct,39
        ;;display image
        tv,snap
        loadct,0
     endif
  endif
  
  ;;LYTPKT
  if tag eq 'lytpkt' then begin
     ;;Display Image
     if set.w[wlyt].show then begin
        ;;set window
        wset,wlyt
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;scale image
        simage = pkt.image.data
        greyrscale,simage,4092
        ;;display image
        imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(hed.ontime*1000,format='(F10.1)')+' ms'+' CCD: '+n2s(pkt.ccd_temp,format='(F10.1)')+' C'
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wlyt
        ;;set color table
        greyr
        ;;display image
        tv,snap
        loadct,0
     endif

     ;;Display Zernikes
     if set.w[wzer].show then begin
        ;;set window
        wset,wzer
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE/2,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin and spacing
        dy = 16
        sx = 5            
        sy = !D.Y_SIZE - dy
        c  = 0
        charsize = 1.6
        ;;calc zernike values
        zavg = mean(pkt.zernike_measured,dimension=2)*1000
        zstd = stddev(pkt.zernike_measured,dimension=2)*1000
        ztar = pkt.zernike_target*1000
        ;;print header
        xyouts,sx,sy-dy*c++,string('--- LYT ZERNIKES ---',format='(A20)'),/device,charsize=charsize
        xyouts,sx,sy-dy*c++,string('Z','AVG','TAR','STD',format='(A2,A6,A6,A6)'),/device,charsize=charsize
        ;;print zernikes
        for i=0,n_elements(zavg)-1 do begin
           xyouts,sx,sy-dy*c++,string(i,zavg[i],ztar[i],zstd[i],format='(I2.2,F+6.1,F+6.1,F+6.1)'),/device,charsize=charsize
        endfor
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wzer
        ;;set color table
        loadct,0
        ;;display data
        tv,snap,!D.X_SIZE/2,0
        loadct,0
     endif
  endif
  
  ;;SCIEVENT
  if tag eq 'scievent' then begin
     ;;Display Image
     if set.w[wsci].show then begin
        ;;set window
        wset,wsci
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        !P.Multi = [0, n_elements(pkt.image)]
        for i=0,n_elements(pkt.image)-1 do begin
           image  = reform(pkt.image[i].data)
           simage = reform(pkt.image[i].data)
           ;;do photometry
           m=max(simage,imax)
           xy=array_indices(simage,imax)
           bgr=mean(simage[10:50,10:50])
           xmin = xy[0]-3 > 0
           xmax = xy[0]+3 < n_elements(simage[*,0])-1
           ymin = xy[1]-3 > 0
           ymax = xy[1]+3 < n_elements(simage[0,*])-1
           avg=mean(double(simage[xmin:xmax,ymin:ymax]))-bgr
           wset,wpix
           ;;scale image
           greyrscale,simage,65535
           ;;display
           imdisp,simage,margin=0.01,charsize=1.8,/noscale,/axis,title='Band '+n2s(i)+' Exp: '+n2s(hed.exptime,format='(F10.3)')+' Max: '+n2s(max(image))+' Avg: '+n2s(avg,format='(I)')
        endfor
        !P.Multi = 0
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wsci
        ;;set color table
        greyr
        ;;display image
        tv,snap
        loadct,0
     endif
     
     ;;Display BMC Command
     if set.w[wbmc].show then begin
        ;;set window
        wset,wbmc
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;fill out image
        bmcimg[bmcsel] = pkt.bmc.acmd
        ;;display image
        implot,bmcimg,ctable=0,blackout=bmcnotsel,range=[-1,1],/erase,$
               cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='BMC DM Command'
        ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wbmc
        ;;set color table
        loadct,39
        ;;display image
        tv,snap
        loadct,0
     endif
  endif
    
  ;;THMEVENT
  if tag eq 'thmevent' then begin
     ;;Display Thermal Data
     if set.w[wthm].show then begin
        ;;set window
        wset,wthm
        ;;create pixmap window
        window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
        wset,wpix
        ;;set text origin and spacing
        dy = 16
        dx = 130
        sx = 5            
        sy = !D.Y_SIZE - dy
        nl = 24
        c  = 0
        charsize = 1.6
        red=1
        green=2
        blue=3
        white=255
        ;;adc1 data
        for i=0,n_elements(adc1)-1 do begin
           color = green
           if pkt.adc1_temp[i] lt adc1[i].min then color = blue
           if pkt.adc1_temp[i] gt adc1[i].max then color = red
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc1[i].abbr+':',pkt.adc1_temp[i],format='(A-7,F-+6.1)'),/device,charsize=charsize,color=color
           c++
        endfor
        ;;adc2 data
        for i=0,n_elements(adc2)-1 do begin
           color = green
           if pkt.adc2_temp[i] lt adc2[i].min then color = blue
           if pkt.adc2_temp[i] gt adc2[i].max then color = red
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc2[i].abbr+':',pkt.adc2_temp[i],format='(A-7,F-+6.1)'),/device,charsize=charsize,color=color
           c++
        endfor
        ;;adc3 data
        for i=0,n_elements(adc3)-1 do begin
           color = green
           if pkt.adc3_temp[i] lt adc3[i].min then color = blue
           if pkt.adc3_temp[i] gt adc3[i].max then color = red
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(adc3[i].abbr+':',pkt.adc3_temp[i],format='(A-7,F-+6.1)'),/device,charsize=charsize,color=color
           c++
        endfor
       ;;heater data
        for i=0,n_elements(pkt.htr)-1 do begin
           str=string(string(pkt.htr[i].name)+':',pkt.htr[i].power,' ',$
                      pkt.htr[i].temp,' ',$
                      pkt.htr[i].setpoint,format='(A-7,I-4,A,F-+6.1,A,F-+6.1)')
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),str,/device,charsize=charsize,color=white
           c++
        endfor
        ;;humidity sensors
        for i=0,n_elements(pkt.hum)-1 do begin
           xyouts,sx+dx*(c / nl),sy-dy*(c mod nl),string(i,pkt.hum[i].temp,pkt.hum[i].humidity,format='(I2,F6.1,F6.1)'),/device,charsize=charsize,color=white
           c++
        endfor
         ;;take snapshot
        snap = TVRD()
        ;;delete pixmap window
        wdelete,wpix
        ;;switch back to real window
        wset,wthm
        linecolor
        tv,snap
        loadct,0
     endif
  endif
  
  ;;save data
  if set.savedata then save,hed,pkt,tag,filename=set.datapath+tag+'.'+gettimestamp('.')+'.'+n2s(hed.frame_number,format='(I8.8)')+'.idl'
    
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
;;   NOUPLINK
;;      Use bidirectional downlink for commands instead of uplink
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse, NOSAVE=NOSAVE, NOUPLINK=NOUPLINK
  common piccgse_block, set

;*************************************************
;* LOAD SETTINGS
;*************************************************
restore,'settings.idl'
  
;*************************************************
;* DEFINE SETTINGS STRUCTURES
;*************************************************
  ;;Windows
  win = {id:'',name:'',show:0,xsize:0,ysize:0,xpos:0,ypos:0,font:''}

  ;;Settings
  set = {tmserver_type:'',tmserver_addr:'',tmserver_port:0U,tmserver_tmfile:'',tmserver_idlfile:'',$
         datapath:'',pktlogunit:0,savedata:(NOT keyword_set(NOSAVE)),w:replicate(win,8)}
  
  ;;Assign window ID tags
  set.w[0].id = 'shk'
  set.w[1].id = 'lyt'
  set.w[2].id = 'alp'
  set.w[3].id = 'bmc'
  set.w[4].id = 'sci'
  set.w[5].id = 'acq'
  set.w[6].id = 'zer'
  set.w[7].id = 'thm'

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
  acqevent = read_c_struct(header,'acqevent')
  thmevent = read_c_struct(header,'thmevent')
  mtrevent = read_c_struct(header,'mtrevent')

  ;;Get #defines
  TLM_PRESYNC  =    '12345678'XUL
  TLM_POSTSYNC =    'DEADBEEF'XUL

  ;;Check for padding
  if check_padding(pkthed)   then stop,'pkthed contains padding'
  if check_padding(shkpkt)   then stop,'shkpkt contains padding'
  if check_padding(lytpkt)   then stop,'lytpkt contains padding'
  if check_padding(scievent) then stop,'scievent contains padding'
  if check_padding(acqevent) then stop,'acqevent contains padding'
  if check_padding(thmevent) then stop,'thmevent contains padding'
  if check_padding(mtrevent) then stop,'mtrevent contains padding'

  ;;Remove headers from structures -- they are read seperately
  struct_delete_field,shkpkt,'hed'
  struct_delete_field,lytpkt,'hed'
  struct_delete_field,scievent,'hed'
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
  endif
  
;*************************************************
;* SETUP SHARED MEMORY
;*************************************************
  shmmap, 'shm', /byte, shm_size
  ;;NOTE: This creates a file /dev/shm/shm of size shm_size bytes
  ;;      The file does not get deleted when you quit IDL, so if
  ;;      shm_size changes, you must delete this file manualy. 
  
  shm_var = shmvar('shm')
  shm_var[*] = bytarr(shm_size)
  shm_var[SHM_RUN] = 1
  shm_var[SHM_UPLINK] = NOT keyword_set(NOUPLINK)
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
           piccgse_processDATA,header,packet,tag
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
                       if(sync eq lss(TLM_POSTSYNC)) then begin
                          readu, TMUNIT, sync
                          if(sync eq mss(TLM_POSTSYNC))then begin
                             ;;process packet
                             piccgse_processData,pkthed,pkt,tag
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
