;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_loadConfig
;;  - procedure to load config file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_loadConfig, path
  common piccgse_block, set
  

  ;;Open the config file
  OPENR, CUNIT, path, /GET_LUN
  
  ;;Initialize input var
  newline = ''


  ;;print, "Reading config file ", path

  for i=0L,FILE_LINES(path)-1 do begin
    
     READF, CUNIT, newline
     
     pieces = strsplit(strcompress(newline), ' ',/extract)
     if n_elements(pieces) GE 2 then begin
        tag = pieces[0]
        value = pieces[1]
        for j=2, n_elements(pieces)-1 do begin
           value+=' '+pieces[j]
        endfor
        
        case tag OF
           ;;Data Settings
           'TMSERVER_TYPE'   : set.tmserver_type  = value
           'TMSERVER_ADDR'   : set.tmserver_addr  = value
           'TMSERVER_PORT'   : set.tmserver_port  = value
           'TMSERVER_TMFILE' : set.tmserver_tmfile  = value
           'TMSERVER_IDLFILE': set.tmserver_idlfile  = value
                      
           ;;Switches
           'SAVE_IDL'        : set.saveidl    = value
           'SHOW_WFS'        : set.showwfs    = value
           'SHOW_SCI'        : set.showsci    = value
           'SHOW_NUM'        : set.shownum    = value
           'SHOW_SHS'        : set.showshs    = value 
           'SHOW_WHS'        : set.showwhs    = value 
           'SHOW_TMP'        : set.showtmp    = value 
           'SHOW_TTP'        : set.showttp    = value 
           'TMCONNECT'       : set.tmconnect  = value 
           
           ;;Display Options
           'PLOT_TYPE'       : set.plottype   = value 
           'IMAGE_SUB'       : set.imagesub   = value 
           'PZT_DISP'        : set.pztdisp    = value 
           
           ;;Housekeeping Options
           'SHOW_PASS'       : set.showpass   = value
           'SHOW_FAIL'       : set.showfail   = value
           'SHOW_IMSG'       : set.showimsg   = value
           
           ;;WFS & Image Produce Window
           'IW_NAME'         : set.iwname     = value
           'IW_INDEX'        : set.iwindex    = value
           'IW_XSIZE'        : set.iwxsize    = value
           'IW_YSIZE'        : set.iwysize    = value
           'IW_XPOS'         : set.iwxpos     = value
           'IW_YPOS'         : set.iwypos     = value
           'IW_FONT'         : set.iwfont     = value
           
           ;;SCI Image Window
           'SW_NAME'         : set.swname     = value
           'SW_INDEX'        : set.swindex    = value
           'SW_XSIZE'        : set.swxsize    = value
           'SW_YSIZE'        : set.swysize    = value
           'SW_XPOS'         : set.swxpos     = value
           'SW_YPOS'         : set.swypos     = value
           'SW_FONT'         : set.swfont     = value
           
           ;;Data Window
           'DW_NAME'         : set.dwname     = value
           'DW_INDEX'        : set.dwindex    = value
           'DW_XSIZE'        : set.dwxsize    = value
           'DW_YSIZE'        : set.dwysize    = value
           'DW_XPOS'         : set.dwxpos     = value
           'DW_YPOS'         : set.dwypos     = value
           'DW_FONT'         : set.dwfont     = value
           
           ;;Temperature Window
           'TW_NAME'         : set.twname     = value
           'TW_INDEX'        : set.twindex    = value
           'TW_XSIZE'        : set.twxsize    = value
           'TW_YSIZE'        : set.twysize    = value
           'TW_XPOS'         : set.twxpos     = value
           'TW_YPOS'         : set.twypos     = value
           'TW_FONT'         : set.twfont     = value
              
           ;;SCI Housekeeping Window
           'HWSCI_NAME'      : set.hwsname     = value
           'HWSCI_INDEX'     : set.hwsindex    = value
           'HWSCI_XSIZE'     : set.hwsxsize    = value
           'HWSCI_YSIZE'     : set.hwsysize    = value
           'HWSCI_XPOS'      : set.hwsxpos     = value
           'HWSCI_YPOS'      : set.hwsypos     = value
           'HWSCI_FONT'      : set.hwsfont     = value
           
           ;;WFS Housekeeping Window
           'HWWFS_NAME'      : set.hwwname     = value
           'HWWFS_INDEX'     : set.hwwindex    = value
           'HWWFS_XSIZE'     : set.hwwxsize    = value
           'HWWFS_YSIZE'     : set.hwwysize    = value
           'HWWFS_XPOS'      : set.hwwxpos     = value
           'HWWFS_YPOS'      : set.hwwypos     = value
           'HWWFS_FONT'      : set.hwwfont     = value
           
           ;;Tip/Tilt/Piston Plot Window
           'PWTTP_NAME'      : set.pwname     = value
           'PWTTP_INDEX'     : set.pwindex    = value
           'PWTTP_XSIZE'     : set.pwxsize    = value
           'PWTTP_YSIZE'     : set.pwysize    = value
           'PWTTP_XPOS'      : set.pwxpos     = value
           'PWTTP_YPOS'      : set.pwypos     = value
           'PWTTP_FONT'      : set.pwfont     = value
           else : w1 = 1
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
pro piccgse_setupFiles,TMRECORD=TMRECORD, STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
  common piccgse_block, set
  
  ;;set paths and filenames
  STARTUP_TIMESTAMP = gettimestamp('.')
  set.datapath = 'data/gsedata/piccgse.'+STARTUP_TIMESTAMP+'/'
  check_and_mkdir,set.datapath
  hsklogfile = set.datapath+'piccgse.'+STARTUP_TIMESTAMP+'.hsklog.txt'
  pktlogfile = set.datapath+'piccgse.'+STARTUP_TIMESTAMP+'.pktlog.txt'
  tmrecfile  = set.datapath+'piccgse.'+STARTUP_TIMESTAMP+'.tmrec.txt'
  
  ;;close open files
  if set.hsklogunit gt 0 then free_lun,set.hsklogunit
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit
  if set.tmrecunit  gt 0 then free_lun,set.tmrecunit
  
  
  ;;open logs
  openw,hsklogunit,hsklogfile,/get_lun,error=con_status
  set.hsklogunit=hsklogunit
  if(con_status eq 0) then print,'Opened: '+file_basename(hsklogfile)+' fd: '+n2s(set.hsklogunit) else print,'Failed: '+file_basename(hsklogfile)
  openw,pktlogunit,pktlogfile,/get_lun,error=con_status
  set.pktlogunit=pktlogunit
  if(con_status eq 0) then print,'Opened: '+file_basename(pktlogfile)+' fd: '+n2s(set.pktlogunit) else print,'Failed: '+file_basename(pktlogfile)
  
  ;;TM Recorder
  if keyword_set(TMRECORD) then begin 
     openw,tmrecunit,tmrecfile,/get_lun,error=con_status
     set.tmrecunit=tmrecunit
     if(con_status eq 0) then print,'Opened: '+file_basename(tmrecfile)+' fd: '+n2s(set.tmrecunit) else print,'Failed: '+file_basename(tmrecfile)
  endif
 
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_tempWindow
;;  - procedure to display temperatures
;;  - called by piccgse_processHSK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_tempWindow, num, cam, idisp, hkdb, val
common piccgse_block, set
linecolor
cstr=["SCI","WFS"]
passfail=["FAIL","PASS"]
wset, set.twindex
!P.FONT = 0  
DEVICE, SET_FONT = set.twfont
ntemp = 2*num
xpos  = 0.01
idisp += cam*ntemp/2
line  = fltarr(set.twxsize,3)+255
ypos  = reverse(findgen(ntemp)/ntemp)+0.01
blackout = fltarr(set.twxsize,set.twysize/ntemp)
result = passfail[(val ge hkdb.min) and (val le hkdb.max)]
if result eq 'FAIL' then begin
    if val lt hkdb.min then cc=3  ;;too cold
    if val gt hkdb.max then cc=1  ;;too hot
endif
if result eq 'PASS' then cc=2

str=string(cstr[cam]+' '+hkdb.desc+': ',val,' '+hkdb.unit,$
           ' [',hkdb.min,',',hkdb.max,'] ',$
           format='(A,T23,F6.1,A,T36,A,F5.1,A,F5.1,A,A)')
tvscl,blackout,0,ypos[idisp]-0.02,/normal
xyouts,xpos,ypos[idisp],str,color=cc,/normal
tv,line,0,0.495,/normal
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_initTdata
;;  - function to init temp data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_initTdata,RETtdata
  MAX_RATE_LIST = 600L               ;;Number of rate measurements to save
  rfill = intarr(MAX_RATE_LIST)-1    ;;Fill for rate variables
  dfill = fltarr(MAX_RATE_LIST)-1    ;;Fill for rate variables
  
  RETtdata = {index_tce_sci:1L,time_tce_sci:rfill, temp_tce_sci:dfill, $
              index_tce_wfs:1L,time_tce_wfs:rfill, temp_tce_wfs:dfill, $ 
              index_ccd_sci:1L,time_ccd_sci:rfill, temp_ccd_sci:dfill, $	
              index_ccd_wfs:1L,time_ccd_wfs:rfill, temp_ccd_wfs:dfill, $
              index_vtec_sci:1L,time_vtec_sci:rfill, volt_vtec_sci:dfill, $  
              index_vtec_wfs:1L,time_vtec_wfs:rfill, volt_vtec_wfs:dfill, $
              index_vco_sci:1L,time_vco_sci:rfill, volt_vco_sci:dfill, $ 
              index_vco_wfs:1L,time_vco_wfs:rfill, volt_vco_wfs:dfill  }
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_resetTplot
;;  - procedure to reset temperature plots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_resetTplot
  common piccgse_block, set
  !P.FONT = -1

  wset, set.hwsindex
  erase
  xyouts,0.5,0.5,'Please wait for SCI plots...',ALIGNMENT=0.5,/normal,charsize=3,charthick=1

  wset, set.hwwindex
  erase
  xyouts,0.5,0.5,'Please wait for WFS plots...',ALIGNMENT=0.5,/normal,charsize=3,charthick=1
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_createWindows
;;  - procedure to create all interface windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_createWindows
  common piccgse_block, set
  if set.showwfs then WINDOW, set.iwindex, XSIZE=set.iwxsize, YSIZE=set.iwysize  ,$
                              XPOS=set.iwxpos, YPOS=set.iwypos, TITLE=set.iwname,RETAIN=2
  
  if set.showsci then WINDOW, set.swindex, XSIZE=set.swxsize, YSIZE=set.swysize  ,$
                              XPOS=set.swxpos, YPOS=set.swypos, TITLE=set.swname,RETAIN=2
  
  if set.shownum then WINDOW, set.dwindex, XSIZE=set.dwxsize, YSIZE=set.dwysize  ,$
                              XPOS=set.dwxpos, YPOS=set.dwypos, TITLE=set.dwname,RETAIN=2
  
  if set.showtmp then WINDOW, set.twindex, XSIZE=set.twxsize, YSIZE=set.twysize  ,$
                              XPOS=set.twxpos, YPOS=set.twypos, TITLE=set.twname,RETAIN=2
  
  if set.showshs then WINDOW, set.hwsindex, XSIZE=set.hwsxsize, YSIZE=set.hwsysize,$
                              XPOS=set.hwsxpos, YPOS=set.hwsypos, TITLE=set.hwsname,RETAIN=2
  
  if set.showwhs then WINDOW, set.hwwindex, XSIZE=set.hwwxsize, YSIZE=set.hwwysize,$
                              XPOS=set.hwwxpos, YPOS=set.hwwypos, TITLE=set.hwwname,RETAIN=2
  
  if set.showttp then WINDOW, set.pwindex, XSIZE=set.pwxsize, YSIZE=set.pwysize,$
                              XPOS=set.pwxpos, YPOS=set.pwypos, TITLE=set.pwname,RETAIN=2
  
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; function piccgse_newWindows
;;  - function to decide if we need to restart any windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION piccgse_newWindows, old
  common piccgse_block, set
  
  iw = ( old.iwxsize NE set.iwxsize ) OR  ( old.iwysize NE set.iwysize ) $ 
       OR  ( old.iwxpos NE set.iwxpos ) OR  ( old.iwypos NE set.iwypos ) $
       OR (old.showwfs NE set.showwfs) 
  sw = ( old.swxsize NE set.swxsize ) OR  ( old.swysize NE set.swysize ) $ 
       OR  ( old.swxpos NE set.swxpos ) OR  ( old.swypos NE set.swypos ) $
       OR (old.showsci NE set.showsci)
  dw = ( old.dwxsize NE set.dwxsize ) OR  ( old.dwysize NE set.dwysize ) $ 
       OR  ( old.dwxpos NE set.dwxpos ) OR  ( old.dwypos NE set.dwypos ) $
       OR (old.shownum NE set.shownum)
  tw = ( old.twxsize NE set.twxsize ) OR  ( old.twysize NE set.twysize ) $ 
       OR  ( old.twxpos NE set.twxpos ) OR  ( old.twypos NE set.twypos ) $
       OR (old.showtmp NE set.showtmp)
  hws = ( old.hwsxsize NE set.hwsxsize ) OR  ( old.hwsysize NE set.hwsysize ) $ 
        OR  ( old.hwsxpos NE set.hwsxpos ) OR  ( old.hwsypos NE set.hwsypos ) $
        OR (old.showshs NE set.showshs)
  hww = ( old.hwwxsize NE set.hwwxsize ) OR  ( old.hwwysize NE set.hwwysize ) $ 
        OR  ( old.hwwxpos NE set.hwwxpos ) OR  ( old.hwwypos NE set.hwwypos ) $
        OR (old.showwhs NE set.showwhs)
  pw = ( old.pwxsize NE set.pwxsize ) OR  ( old.pwysize NE set.pwysize ) $ 
       OR  ( old.pwxpos NE set.pwxpos ) OR  ( old.pwypos NE set.pwypos ) $
       OR (old.showwhs NE set.showwhs)
  
  change = iw OR sw OR dw OR tw OR hws OR hww OR pw
  
  RETURN, change
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_plotTwo
;;  - procedure to plot two temperatures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_plotTwo, time1, time2, temp1, temp2, title1=title1, title2=title2,ytitle=ytitle,range=range
  loadct,39,/silent
  plotsym,0,/fill
  
  ;;get full time series
  tk1 = WHERE(time1 GE 0.0, ntk1)
  ;;get last 35 sec for calculating averages
  tka1 = WHERE( (time1 GE 0.0) AND (time1 GE (MAX(time1)-35.0)), ntka1)

  ;;get full time series
  tk2 = WHERE(time2 GE 0.0, ntk2)
  ;;get last 35 sec for calculating averages
  tka2 = WHERE( (time2 GE 0.0) AND (time2 GE (MAX(time2)-35.0)), ntka2)

  ;;calculate average temps
  temp1_avg = 0.0
  temp2_avg = 0.0
  if ntka1 GT 0 then temp1_avg = MEAN( temp1[tka1] )
  if ntka2 GT 0 then temp2_avg = MEAN( temp2[tka2] )

  ;;if have >= 3 points, do a linear fit
  value1_fit = [0.,0.]
  value2_fit = [0.,0.]
  if ntka1 GE 3 then begin
     value1_fit = LINFIT(time1[tka1],temp1[tka1])
     value2_fit = LINFIT(time2[tka2],temp2[tka2])
  endif
  
  if ntk1 GT 2 then begin

     if (MAX(time1[tk1])-MIN(time1[tk1])) GT 300 then begin
        XTITLE='Elapsed time [minutes]'
        x1 = time1/60.0
     endif else begin
        XTITLE='Elapsed time [seconds]'
        x1 = time1
     endelse

     if (MAX(time2[tk2])-MIN(time2[tk2])) GT 300 then begin
        
        x2 = time2/60.0
     endif else begin
        
        x2 = time2
     endelse


     FULL_TITLE = title1  + $
                  string(temp1_avg,format='(f6.1)') + $
                  string(value1_fit[1]*60.0,format='(f6.1)') + $
                  title2 + $ 
                  string(temp2_avg,format='(f6.1)') + $
                  string(value2_fit[1]*60.0,format='(f6.1)')

     tks1 = tk1[SORT(time1[tk1])]
     tks2 = tk2[SORT(time2[tk2])]


     mxr = max([max(temp1(where(temp1 NE -1))),max(temp2(where(temp2 NE -1)))])
     mnr = min([min(temp1(where(temp1 NE -1))),min(temp2(where(temp2 NE -1)))])
     yrange = [mnr,mxr]
     if keyword_set(range) then yrange = range

     plot, x1[tks1], temp1[tks1], title=full_title, $
           ytitle=ytitle, xs=1, ys=2, $
           xtitle=xtitle, psym=-8, charsize=1.0,YRANGE=yrange,thick=2,symsize=0.8
     oplot, x2[tks2], temp2[tks2], psym=-8, color=254,thick=2,symsize=0.8
  endif
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_plotTTP
;;  - procedure to plot tip,tilt,piston stripchart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_plotTTP, tip=tip, tilt=tilt, piston=piston, residual=residual, rms=rms
  common piccgse_block, set
  common plot_block,tiparr,tipi,tilarr,tili,pisarr,pisi,rmsarr,rmsi,resarr,resi
  npoints  = 30 ;;number of points to hold in strip chart
  xrange   = [0,45]
  ;;conversion from radians to nm
  r2n = 652./(2*!dpi)
  if n_elements(tipi) eq 0 then begin
     tipi      = 0
     tili      = 0
     pisi      = 0
     resi      = 0
     rmsi      = 0

     tiparr    = fltarr(npoints)
     tilarr    = fltarr(npoints)
     pisarr    = fltarr(npoints)
     resarr    = fltarr(npoints)
     rmsarr    = fltarr(npoints)
  endif

  if n_elements(tip) gt 0 then begin
     if tipi eq (npoints-1) then tiparr=shift(tiparr,-1)
     tipi = (tipi + 1) < (npoints-1)
     tiparr[tipi] = tip * r2n
  endif
  if n_elements(tilt) gt 0 then begin
     if tili eq (npoints-1) then tilarr=shift(tilarr,-1)
     tili = (tili + 1) < (npoints-1)
     tilarr[tili] = tilt * r2n
  endif
  if n_elements(piston) gt 0 then begin
     if pisi eq (npoints-1) then pisarr=shift(pisarr,-1)
     pisi = (pisi + 1) < (npoints-1)
     pisarr[pisi] = piston * r2n
  endif
  if n_elements(residual) gt 0 then begin
     if resi eq (npoints-1) then resarr=shift(resarr,-1)
     resi = (resi + 1) < (npoints-1)
     resarr[resi] = residual * r2n
  endif
  if n_elements(rms) gt 0 then begin
     if rmsi eq (npoints-1) then rmsarr=shift(rmsarr,-1)
     rmsi = (rmsi + 1) < (npoints-1)
     rmsarr[rmsi] = rms * r2n
  endif

  ;;plot ttp data
  wset,set.pwindex
  !P.MULTI = [0,1,5]
  !P.FONT  = 0  
  DEVICE, SET_FONT = set.iwfont

  xarr = indgen(npoints)
  zarr = fltarr(npoints)

  ;;set yrange
  yr   = ceil((max(abs(tiparr[0:tipi]))>0.1)/5.)*5*1.1 
  tipyr = [-yr,yr]
  yr   = ceil((max(abs(tilarr[0:tili]))>0.1)/5.)*5*1.1 
  tilyr = [-yr,yr]
  yr   = ceil((max(abs(pisarr[0:pisi]))>0.1)/5.)*5*1.1 
  pisyr = [-yr,yr]
  yr   = ceil((max(abs(rmsarr[0:rmsi]))>0.1)/5.)*5*1.1  
  rmsyr = [-yr,yr]
  yr   = ceil((max(abs(resarr[0:resi]))>0.1)/5.)*5*1.1  
  resyr = [-yr,yr]
  
  ;;get rms values
  if tipi gt 0 then tiprms = stdev(tiparr[0:tipi]) else tiprms = tiparr[0]
  if tili gt 0 then tilrms = stdev(tilarr[0:tili]) else tilrms = tilarr[0]
  if pisi gt 0 then pisrms = stdev(pisarr[0:pisi]) else pisrms = pisarr[0]
  if rmsi gt 0 then rmsrms = stdev(rmsarr[0:rmsi]) else rmsrms = rmsarr[0]
  if resi gt 0 then resrms = stdev(resarr[0:resi]) else resrms = resarr[0]

  plot,xarr[0:tipi],tiparr[0:tipi],title='Tip: '+n2s(tiparr[tipi],format='(F6.1)')+' nm/px'+'  RMS: '$
       +n2s(tiprms,format='(F6.1)')+' nm/px',xrange=xrange,yrange=tipyr,/xs,/ys,yticks=2,ymargin=[3,3]
  plot,xarr[0:tili],tilarr[0:tili],title='Tilt: '+n2s(tilarr[tili],format='(F6.1)')+' nm/px'+'  RMS: '$
       +n2s(tilrms,format='(F6.1)')+' nm/px',xrange=xrange,yrange=tilyr,/xs,/ys,yticks=2,ymargin=[3,3]
  plot,xarr[0:pisi],pisarr[0:pisi],title='Piston: '+n2s(pisarr[pisi],format='(F6.1)')+' nm'+'  RMS: '$
       +n2s(pisrms,format='(F6.1)')+' nm',xrange=xrange,yrange=pisyr,/xs,/ys,yticks=2,ymargin=[3,3]
  plot,xarr[0:rmsi],rmsarr[0:rmsi],title='RMS Error: '+n2s(rmsarr[rmsi],format='(F6.1)')+' nm'+'  RMS: '$
       +n2s(rmsrms,format='(F6.1)')+' nm',xrange=xrange,yrange=rmsyr,/xs,/ys,yticks=2,ymargin=[3,3]
  plot,xarr[0:resi],resarr[0:resi],title='RMS Residual: '+n2s(resarr[resi],format='(F6.1)')+' nm'+'  RMS: '$
       +n2s(resrms,format='(F6.1)')+' nm',xrange=xrange,yrange=resyr,/xs,/ys,yticks=2,ymargin=[3,3]
  !P.MULTI=0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_processDATA
;;  - procedure to process and plot data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_processDATA, header, data_input, dmdiff=dmdiff
  common piccgse_block, set
  common proc_block,masksel,nmask,notmasksel,nnotmask,ABC2TTP,wfsexp,wfsmode,sciexp,statenames,flatimg,halfimg,zeroimg,scitemp,scimode,sciflat,scidark,sciread,lasttype,wfsmax
  loadct,0,/silent
  npoints = 20
  wpixmap = 31
  ;;set plot position
  ppos=[0.15,0.1,0.95,0.9]
  wfs_scale = 0.5

  if n_elements(nmask) eq 0 then begin 
     nmask    = 0
     nnotmask = 0
     wfsexp   = 0
     sciexp   = 0
     wfsmode  = 0
     scimode  = 0
     wfsmax   = 2000
  endif
  if n_elements(ABC2TTP) eq 0 then begin
     restore,'data/pztcal.idl'
     ABC2TTP = M
  endif
  
  ;;protect data
  data = data_input
  
  ;;*********************************************
  ;;TLM PARAMETERS
  ;;*********************************************
  pztmax = 262143D
  pzta   = 10400D
  pztb   = 12000D


  NFRAME       =    4
  NPHASE       =    7
  NDM          =    2
  col          =    4

  framestr     = ['A','B','C','D']
  phasestr     = ['M','I','V','P','U','R']
  dmstr        = ['DM','DMDIFF']
  imageorder   = [framestr,phasestr,dmstr]
  blank        = intarr(2,2)
  statsel      = indgen(header.imxsize,header.imysize)

  statmask     = ['I','V','P','U','R'] ;;calc stats in mask only
  blankmask    = ['V','P','U','R']     ;;black out outside of mask
  rmsarr       = ['R','U']
  ;;blankmask    = ['']


  frametitle   = ['WFS A', $
                  'WFS B', $
                  'WFS C', $
                  'WFS D']

  phasetitle   = ['Mask', $
                  'Intensity',  $
                  'Visibility', $
                  'Wrapped Phase', $
                  'Unwrapped Phase', $
                  'Residual Phase']
  
  dmtitle      = ['DM Image','DM Difference']
  
  ;;packet types
  TLM_SCIENCE  =    'AAAA0000'XUL
  TLM_FRAME    =    'BBBB0000'XUL
  TLM_PHASE    =    'CCCC0000'XUL
  TLM_DATA     =    'DDDD0000'XUL
  TLM_DM       =    'EEEE0000'XUL
  TLM_HSK      =    'FFFF0000'XUL
  TYPE_MASK    =    'FFFF0000'XUL
  INDEX_MASK   =    '0000FFFF'XUL

  if(n_elements(statenames) eq 0) then begin
     ;;states
     readHeader,states=statenames
  endif 
  if(n_elements(flatimg) eq 0) then begin
     restore,'../dm/dmdata.idl'
  endif


  fn = header.frame_number
  t  = header.packet_type and TYPE_MASK
  i  = header.packet_type and INDEX_MASK
  if keyword_set(dmdiff) then i=1
  k  = 0
  g  = 0
  ns = 0
  sat = 4095
  a  = set.iwxsize/float(set.iwysize)
  tformat = '(F10.2)'
  tpos    = [header.imxsize,header.imxsize,header.imxsize]*[0.125,0.5,0.875]
  
  ;;get time
  time=systime(1)
  
  case t of
     ;;frame images
     TLM_FRAME: begin
        ;;save data
        if set.saveidl and set.tmserver_type ne 'idlfile' and not keyword_set(dmdiff) then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.'+n2s(fn,format='(I8.8)')+'.frame.'+strlowcase(framestr[i])+'.idl'
           save,data,header,time,statenames,filename=file
        endif
        data = data[0:header.imysize-1,*]

        if framestr[i] eq 'A' then begin
           wfsexp = header.ontime
           wfsmode = header.mode
           wfsmax = max(data)
        endif
        if set.showimsg then print,"Got: "+framestr[i]+" "+n2s(fn)
        if set.showwfs then begin
           k=where(imageorder eq framestr[i])
           k=k[0]
           g=1
           tstring = frametitle[i]
           tformat = '(I4)'
           sat = 1800
        endif

        ;;decide how to mask images
        statim = where(statmask eq framestr[i],usemask)
        if nmask gt 0 and usemask eq 1 then statsel = masksel
        blankim = where(blankmask eq framestr[i],blankout)
        if nmask gt 0 and blankout eq 1 then data[notmasksel] = min(data)

     end
     
     ;;phase images
     TLM_PHASE: begin
        
        ;;save data
        if set.saveidl and set.tmserver_type ne 'idlfile' then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.'+n2s(fn,format='(I8.8)')+'.phase.'+strlowcase(phasestr[i])+'.idl'
           save,data,header,time,statenames,filename=file
        endif
        if(phasestr[i] eq 'V') then data = sqrt(data)
        if set.showimsg then print,"Got: "+phasestr[i]+" "+n2s(fn)
        if set.showwfs then begin
           tstring = phasetitle[i]
           k=where(imageorder eq phasestr[i],g)
           k=k[0]
           tstring = phasetitle[i]
           tformat = '(F6.2)'
           sat = 10000
           if(phasestr[i] eq 'I') then tformat = '(I5)'
           
           ;;get new mask
           if(phasestr[i] eq 'M') then begin
              masksel = where(data eq 1,nmask,complement=notmask,ncomplement=nnotm)
              notmasksel = notmask
              nnotmask   = nnotm
              tformat = '(F3.1)'
           endif
           
           
           ;;decide how to mask images
           statim = where(statmask eq phasestr[i],usemask)
           if nmask gt 0 and usemask eq 1 then statsel = masksel
           blankim = where(blankmask eq phasestr[i],blankout)
           if nmask gt 0  and nnotmask gt 0 and blankout eq 1 then data[notmasksel] = min(data)
        endif
        ;;plot rms wavefront error
        if(phasestr[i] eq 'R') then begin
           rms = sqrt(total(data[statsel]^2)/float(n_elements(statsel)))
           piccgse_plotTTP,residual=rms
        endif
        if(phasestr[i] eq 'U') then begin
           rms = sqrt(total(data[statsel]^2)/float(n_elements(statsel)))
           piccgse_plotTTP,rms=rms
        endif
     end
     ;;dm images
     TLM_DM: begin
        ;;save data
        if set.saveidl and set.tmserver_type ne 'idlfile' then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.'+n2s(fn,format='(I8.8)')+'.dm.d.idl'
           if(i eq 0) then save,data,header,time,statenames,filename=file
        endif
        ;;transpose image
        if set.showimsg then print,"Got: DM "+n2s(fn)
        if set.showwfs then begin
           if keyword_set(dmdiff) then begin
              if(set.imagesub eq 'FLAT') then data -= transpose(flatimg)
              if(set.imagesub eq 'HALF') then data -= transpose(halfimg)
              if(set.imagesub eq 'ZERO') then data -= transpose(zeroimg)
           endif
           g=1
           k=where(imageorder eq dmstr[i])
           k=k[0]
           sat = 16383
           tstring = dmtitle[i]
           tformat = '(I6)'
           statsel = indgen(n_elements(data))
        endif
     end
     ;;science image
     TLM_SCIENCE: begin
        ;;save data
        if set.saveidl and set.tmserver_type ne 'idlfile' then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.'+n2s(fn,format='(I8.8)')+'.sci.s.idl'
           save,data,header,time,statenames,filename=file
        endif       
        ;;crop out overclocks
        data = data[0:header.imysize-1,*]
        
        
        if set.showimsg then print,"Got: SCI"+" "+n2s(fn)
        sciexp  = header.ontime
        scimode = header.mode
        if set.showsci then begin
           ;;set pixmap window
           ;;--switch to PIXMAP buffer and take snapshot
           window,wpixmap,/pixmap,xsize=set.swxsize,ysize=set.swysize
           wset,wpixmap
           !P.FONT = 0  
           DEVICE, SET_FONT = set.swfont
           !p.multi = 0
           ln   = fix(min(data))
           cn   = fix(mean(data))
           rn   = fix(max(data))
           sat  = 4095
           
           tformat = '(I4)'
           
           ;;choose how to display the data
           case set.plottype of 
              0: begin
                 ;;Display image
                 color_table='greyr'
                 greyrscale,data,sat
                 imdisp,data,/axis,title='SCI Camera',/erase,margin=0.07,$
                        yticks=1,ytickname=replicate(' ',10),$
                        xticks=2,xtickv=tpos,/noscale,$
                        xtickname=[n2s(ln,format=tformat),$
                                   n2s(cn,format=tformat),$
                                   n2s(rn,format=tformat)]
                 loadct,0,/silent
                 
              end
              1: begin
                 ;;X-Profile
                 color_table='grey'
                 xhist = total(data,2)/header.imysize
                 plot,xhist,title='SCI X-Profile',/xs,xticks=3,/ynozero,thick=1,position=ppos
              end
              2: begin
                 ;;Y-Profile
                 color_table='grey'
                 yhist = total(data,1)/header.imxsize
                 plot,yhist,title='SCI Y-Profile',/xs,xticks=3,/ynozero,thick=1,position=ppos
              end
              3: begin
                 ;;Intensity Histogram
                 color_table='grey'
                 statsel = where(data gt 200,nstatsel)
                 if nstatsel gt 0 then begin
                    ihist=histogram(float(data[statsel]),loc=xval,nbins=20)
                    fsel = where(finite(ihist) eq 0,nfsel)
                    if nfsel gt 0 then ihist[fsel]=0
                    plot,xval,ihist,title='SCI I-Histogram',xticks=3,psym=10,thick=1,xrange=[0,sat],/xs,position=ppos
                 endif else begin
                    plot,[0,1],[0,1],title='SCI I-Histogram',xticks=3,psym=10,thick=1,/xs,/ys,/nodata,position=ppos
                 endelse
              end
              else: stop,'no case SCI'
           endcase
       

           ;;take snapshot
           snap = TVRD()
           ;;delete pixmap window
           wdelete,wpixmap
           ;;switch back to real window
           wset, set.swindex
           ;;set color table
           if color_table eq 'greyr' then greyr
           if color_table eq 'ggreyr' then ggreyr
           if color_table eq 'grey' then loadct,0,/silent
           ;;display snapshot
           tv,snap
           loadct,0,/silent
         
           
        endif
     end
     ;;data
     TLM_DATA: begin
        ;;save data
        if set.saveidl and set.tmserver_type ne 'idlfile' then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.'+n2s(fn,format='(I8.8)')+'.data.d.idl'
           save,data,header,time,statenames,filename=file
        endif
        if set.showimsg then print,"Got: DATA"+" "+n2s(fn)
        if set.shownum then begin
           wset, set.dwindex
           !P.FONT = 0  
           DEVICE, SET_FONT = set.dwfont
           ndata = 14
           xpos  = 0.01
           ypos  = reverse(findgen(ndata)/ndata)+0.01
                    
           ;;DAC
           nDAC = [data.N.a[0],data.N.b[0],data.N.c[0]]
           pDAC = [data.P.a[0],data.P.b[0],data.P.c[0]]
           cDAC = [data.C.a[0],data.C.b[0],data.C.c[0]]
           
           ;;microns
           nA = 10 * data.N.a[0]/pztmax 
           nB = 10 * data.N.b[0]/pztmax 
           nC = 10 * data.N.c[0]/pztmax
           pA = 10 * data.P.a[0]/pztmax 
           pB = 10 * data.P.b[0]/pztmax 
           pC = 10 * data.P.c[0]/pztmax
           cA = 10 * data.C.a[0]/pztmax 
           cB = 10 * data.C.b[0]/pztmax 
           cC = 10 * data.C.c[0]/pztmax
           
           ;;alpha, beta, Z
           nalpha = (nA/pztA - 0.5*nB/pztA - 0.5*nC/pztA)*206265
           nbeta  = ((nB-nC)/pztB)*206265 
           palpha = (pA/pztA - 0.5*pB/pztA - 0.5*pC/pztA)*206265
           pbeta  = ((pB-pC)/pztB)*206265 
           calpha = (cA/pztA - 0.5*cB/pztA - 0.5*cC/pztA)*206265
           cbeta  = ((cB-cC)/pztB)*206265 
           
           nZ = mean(nDAC) * 10./pztmax
           pZ = mean(pDAC) * 10./pztmax
           cZ = mean(cDAC) * 10./pztmax
           
           ;;tip, tilt, piston
           nTTP = transpose(ABC2TTP)#nDAC
           pTTP = transpose(ABC2TTP)#pDAC
           cTTP = transpose(ABC2TTP)#cDAC
           
           ip = 0
           
           erase
           str=string("Frame: ",fn,format='(A,T10,I8)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           str=string("SCI Exp: ",sciexp,"Mode: ",scimode,format='(A,T10,F8.3,T20,A,I2)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           str=string("WFS Exp: ",wfsexp,"Mode: ",wfsmode,format='(A,T10,F8.3,T20,A,I2)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5

           str=string("TTP: ",data.tip,data.tilt,data.piston,format='(A,T12,F6.3,T19,F6.3,T26,F6.3)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           str=string("CHISQ: ",data.chisq,format='(A,T10,F8.2)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           str=string("INT: ",data.intensity,format='(A,T10,I8)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           str=string("BKG: ",data.background,format='(A,T10,F8.2)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           str=string("Ithresh: ",data.Ithresh,format='(A,T10,I8)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           str=string("Vthresh: ",data.Vthresh,format='(A,T10,F8.4)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           if(set.pztdisp eq 0) then begin
              ;;DAC
              str=string("N: ",nDAC[0],nDAC[1],nDAC[2],format='(A,T5,Z5.5,T15,Z5.5,T25,Z5.5)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("P: ",pDAC[0],pDAC[1],pDAC[2],format='(A,T5,Z5.5,T15,Z5.5,T25,Z5.5)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("C: ",cDAC[0],cDAC[1],cDAC[2],format='(A,T5,Z5.5,T15,Z5.5,T25,Z5.5)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           endif
           if(set.pztdisp eq 1) then begin
              ;;Microns
              str=string("N: ",nA,nB,nC,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("P: ",pA,pB,pC,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("C: ",cA,cB,cC,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           endif
           if(set.pztdisp eq 2) then begin
              ;;alpha, beta, Z
              str=string("N: ",nalpha,nbeta,nZ,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("P: ",palpha,pbeta,pZ,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("C: ",calpha,cbeta,cZ,format='(A,T5,F8.2,T15,F8.2,T25,F8.2)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           endif
           if(set.pztdisp eq 3) then begin
              ;;tip, tilt, Piston
              str=string("N: ",nTTP[0],nTTP[1],nTTP[2],format='(A,T5,F8.4,T15,F8.4,T25,F8.4)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("P: ",pTTP[0],pTTP[1],pTTP[2],format='(A,T5,F8.4,T15,F8.4,T25,F8.4)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
              
              str=string("C: ",cTTP[0],cTTP[1],cTTP[2],format='(A,T5,F8.4,T15,F8.4,T25,F8.4)')
              xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           endif
           
           str=string("State: ",statenames[header.state],format='(A,T15,A)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
           atmsg = 'NO'
           if tag_exist(data,'atlocked') then begin
              if data.atlocked eq 0 then atmsg = 'NO'
              if data.atlocked eq 1 then atmsg = 'YES'
              if data.atlocked eq 2 then atmsg = 'NO DATA'
              if data.atlocked eq 3 then atmsg = 'OVERRIDE ON'
              if data.atlocked eq 4 then atmsg = 'AT NO VALID DATA'
              if data.atlocked eq 5 then atmsg = 'AT FAKE'
           endif
           str=string("AT Locked: ",atmsg,format='(A,T15,A)')
           xyouts,xpos,ypos[ip++],str,/normal,charsize=1.5,charthick=1.5
           
        endif
        
        ;;plot TTP
        piccgse_plotTTP,tip=data.tip,tilt=data.tilt,piston=data.piston
        

     end
     else:
     
  endcase
  
  ;;add check for NaN Inf
  
  
  ;;display 
  if(g) then begin
     x0   = (k mod col)/float(col)
     y0   = a*(k / col)/float(col)
     x1   = x0+1./col
     y1   = y0+a/col
     pos  =[x0,y0,x1,y1]
     zxs=fix(set.iwxsize*(pos[2]-pos[0]))
     zys=fix(set.iwysize*(pos[3]-pos[1]))
     ;;--switch to PIXMAP buffer and take snapshot
     window,wpixmap,/pixmap,xsize=zxs,ysize=zys
     wset,wpixmap
     !P.FONT = 0  
     DEVICE, SET_FONT = set.iwfont
     !p.multi = 0
     
     if(n_elements(statsel) lt 5) then statsel = indgen(header.imxsize,header.imysize)
     rmssel = where(rmsarr eq imageorder[k],nrmssel)
     if(nrmssel gt 0) then begin
        ;;rms
        ln = min(data[statsel])
        cn = sqrt(total(data[statsel]^2)/float(n_elements(statsel)))
        rn = max(data[statsel])
     endif else begin
        ;;average
        ln = min(data[statsel])
        cn = mean(data[statsel])
        rn = max(data[statsel])
     endelse
     
     ;;decide how to display the image
     color_table='grey'
     case set.plottype of
        0: begin
           nos=0
           pdata=data ;;copy data for display
           if t eq TLM_DM and not keyword_set(dmdiff) then begin
              color_table='ggreyr'
              ggreyrscale,pdata,sat
              nos = 1
           endif
           if t eq TLM_FRAME then begin
              color_table='greyr'
              pdata=pdata^wfs_scale
              greyrscale,pdata,sat^wfs_scale,MAX=wfsmax^wfs_scale
              nos = 1
           endif
           imdisp,pdata,/axis,title=tstring,/erase,$
                  yticks=1,ytickname=replicate(' ',10),$
                  xticks=2,xtickv=tpos,noscale=nos,$
                  xtickname=[n2s(ln,format=tformat),$
                             n2s(cn,format=tformat),$
                             n2s(rn,format=tformat)]
           
        end
        
        1: begin
           ;;X-Profile
           color_table='grey'
           ;;define masks
           ss=size(data)
           npix=fltarr(ss[1],ss[2])
           npix[statsel]=1
           sel = where(npix eq 0,nsel)
           if nsel gt 0 then data[sel]=0
           if(nrmssel gt 0) then begin
              xdata = total(data*data,2)
              xnpix = total(npix,2)>0
              xhist = sqrt(xdata/xnpix)
           endif else begin
              ;;sum data
              xdata = total(data,2)
              xnpix = total(npix,2)>0
              xhist=xdata/xnpix
           endelse
           ;;mask where there is little data
           sel = where(xnpix lt 5,nsel)
           if(nsel gt 0) then xhist[sel]=0
           plot,xhist,title=tstring+'  X-Profile',/xs,xticks=3,/ynozero,thick=1,position=ppos
           
        end
        
        2: begin
           ;;Y-Profile
           color_table='grey'
           ;;define masks
           ss=size(data)
           npix=fltarr(ss[1],ss[2])
           npix[statsel]=1
           sel = where(npix eq 0,nsel)
           if nsel gt 0 then data[sel]=0
           ;;sum data
           ydata = total(data,1)
           ynpix = total(npix,1)
           ;;mask where there is little data
           sel = where(ynpix lt 5,nsel)
           if(nsel gt 0) then begin
              ydata[sel]=!VALUES.F_NAN
              ynpix[sel]=1
           endif
           yhist=ydata/ynpix
           fsel = where(finite(yhist) eq 0,nfsel)
           if nfsel gt 0 then yhist[fsel]=0
           plot,yhist,title=tstring+'  Y-Profile',/xs,xticks=3,/ynozero,thick=1,position=ppos
           
        end
        
        3: begin
           ;;I-Histogram
           color_table='grey'
           if not (min(data[statsel]) eq 0 and max(data[statsel]) eq 0) then begin
              ihist=histogram(float(data[statsel]),loc=xval,nbins=20)
              fsel = where(finite(ihist) eq 0,nfsel)
              if nfsel gt 0 then ihist[fsel]=0
              plot,xval,ihist,title=tstring+'  I-Histogram',xticks=3,psym=10,thick=1,position=ppos
           endif else begin
              plot,[0,1],[0,1],title=tstring+'  I-Histogram',xticks=3,psym=10,thick=1,/xs,/ys,/nodata,position=ppos
           endelse
        end
        else: stop,'no case WFS'
     endcase
     
     ;;take snapshot
     snap = TVRD()
     ;;delete pixmap window
     wdelete,wpixmap
     ;;switch back to real window
     wset, set.iwindex
     ;;set color table
     if color_table eq 'greyr' then greyr
     if color_table eq 'ggreyr' then ggreyr
     if color_table eq 'grey' then loadct,0,/silent
     ;;display snapshot
     tv,snap,pos[0],pos[1],/normal
     loadct,0,/silent
     
  endif

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pro piccgse_processHSK
;;  - procedure to process and plot houskeeping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro piccgse_processHSK, header, data_input, idlfile=idlfile, reset=reset
  common piccgse_block, set
  common processHSK_block, tdata, hkdb, t_start, t_last_sci, t_last_wfs

  ;;Initialize
  if keyword_set(reset) or n_elements(tdata) eq 0 then begin
     ;;tdata
     piccgse_initTdata,tdata
     piccgse_resetTplot
     ;;hkdb
     restore,'hkdb.idl'
     ;;times
     t_start     = systime(1)
     t_last_sci  = systime(1)
     t_last_wfs  = systime(1)
  endif
  
  ;;If reset, return here
  if keyword_set(reset) then return

  ;;Protect data
  data = data_input

  ;;Get time
  t_now = systime(1)
  t_dt  = t_now - t_start

  ;;General
  cstr=["SCI","WFS"]
  passfail=["FAIL","PASS"]
  numpass = 0
  numfail = 0
  MAX_RATE_LIST = 600L                      ;;Number of rate measurements to save
  CAM_MASK     =    '80000000'XUL
  
  ;;report status
  if set.showimsg then print,"Got: HSK"
  
  ;;hk database elements are:
  ;;name:"", cmd:"", desc:"", a:0., b:0., unit:"", min:0., max:0.
  ;;NOTE: cmd is now expected to be a string

  ;;decipher command and value
  if set.tmserver_type eq 'idlfile' then begin
     ;;idl save file
     cam = data.cam
     cmd = data.cmd
     val = data.v
  endif else begin
     ;;real data
     cam = data.cmd AND CAM_MASK
     cam = ishft(cam,-31)
     cmd = data.cmd AND NOT CAM_MASK
     ;;convert command to string
     cmd = n2s(cmd,format='(Z6.6)')
     val = data.val
  endelse

  ;;find command
  ic = where(hkdb.cmd eq cmd,nsel)
  if(nsel eq 1) then begin
     if(cam eq 0 and hkdb[ic].cmd eq '3D0000') then begin
        numpass = 0
        numfail = 0
        msg = "**********Starting HK TEST**********"
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
     endif
     if(hkdb[ic].b eq -999.999) then begin
        if(hkdb[ic].a eq -999.999) then begin
           ;;these are commands for set values
           msg = string(cstr[cam]+" "+hkdb[ic].desc+":",val and statmask,hkdb[ic].unit,format='(A,T30,Z2.2,T35,A)')
           print,msg
           printf,set.hsklogunit,gettimestamp('.')+': '+msg
           v=0
        endif else begin
           msg = string(cstr[cam]+" "+hkdb[ic].desc+": ",val*hkdb[ic].a,hkdb[ic].unit,format='(A,T30,F10.3,T40,A)')
           print,msg
           printf,set.hsklogunit,gettimestamp('.')+': '+msg
           v=0
        endelse
     endif else begin
        if keyword_set(idlfile) then v=val else begin
           if(hkdb[ic].cmd eq '210400') then v = (val-hkdb[ic].b)/hkdb[ic].a else v=val*hkdb[ic].a+hkdb[ic].b
        endelse       
        result = passfail[(v ge hkdb[ic].min) and (v le hkdb[ic].max)]
        if result eq "PASS" then numpass++
        if result eq "FAIL" then numfail++
        msg = string(cstr[cam]+' '+hkdb[ic].desc+' ['+n2s(val)+']:',v,' '+hkdb[ic].unit,$
                     ' [',hkdb[ic].min,',',hkdb[ic].max,'] ',result,t_now,$
                     format='(A,F7.2,A,A,F6.2,A,F6.2,A,A,I11)')
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
        if set.saveidl and set.tmserver_type ne 'idlfile' then begin
           file = set.datapath+'piccgse.'+gettimestamp('.')+'.hsk.'+n2s(cam)+'.'+cmd+'.idl'
           save,header,cam,cmd,v,filename=file
        endif
        if ((result eq 'PASS' and set.showpass) or (result eq 'FAIL' and set.showfail)) then begin
           print,msg
        endif
     endelse
     if(cam eq 1 and hkdb[ic].cmd eq '210600') then begin
        msg = "**********HK TEST Done**********"
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
        msg = "Number PASS: "+n2s(numpass)
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
        msg = "Number FAIL: "+n2s(numfail)
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
        numpass = 0
        numfail = 0
        
     endif
     
     ;;process hk for Temp window
     tempdisp = ['T_CR_CHAN1'  , 'T_CR_CHAN2'  , 'T_CR_CHAN5'  , 'T_HK_CHAN4'  , 'C_HK_CHAN14', $
                 'C_HK_CHAN12' , 'D_HK_CHAN30' , 'V_HK_CHAN18' , 'T_HK_CHAN7']
     idisp    = where(tempdisp eq hkdb[ic].name,nid)
     if nid gt 0 and set.showtmp then piccgse_tempWindow,n_elements(tempdisp),cam,idisp,hkdb[ic],v
     
     ;;fix glitches -- disabled
     if not (v eq hkdb[ic].b) or 1 then begin
        ;;process hk data for plots
        if(cam eq 0) then begin
           ;;got SCI HK
           case hkdb[ic].name of
              'T_CR_CHAN1':begin
                 ;;CCD Temp
                 i = (tdata.index_ccd_sci + 1L) mod MAX_RATE_LIST
                 tdata.index_ccd_sci   = i
                 tdata.temp_ccd_sci[i] = v
                 tdata.time_ccd_sci[i] = t_dt
              end
              'T_CR_CHAN2':begin
                 ;;Heat Sink Temp
                 i = (tdata.index_tce_sci + 1L) mod MAX_RATE_LIST
                 tdata.index_tce_sci   = i
                 tdata.temp_tce_sci[i] = v
                 tdata.time_tce_sci[i] = t_dt
              end
              'T_HK_CHAN4':begin
                 ;;TCE TEC Voltage
                 i = (tdata.index_vtec_sci + 1L) mod MAX_RATE_LIST
                 tdata.index_vtec_sci   = i
                 tdata.volt_vtec_sci[i] = v
                 tdata.time_vtec_sci[i] = t_dt
              end   
              'C_HK_CHAN14':begin
                 ;;Controller VCO_CV
                 i = (tdata.index_vco_sci + 1L) mod MAX_RATE_LIST
                 tdata.index_vco_sci    = i
                 tdata.volt_vco_sci[i] = v
                 tdata.time_vco_sci[i]  = t_dt
              end
              else:
           endcase
        endif 
        if(cam eq 1) then begin
           ;;got WFS HK
           case hkdb[ic].name of
              'T_CR_CHAN1':begin
                 ;;CCD Temp
                 i = (tdata.index_ccd_wfs + 1L) mod MAX_RATE_LIST
                 tdata.index_ccd_wfs   = i
                 tdata.temp_ccd_wfs[i] = v
                 tdata.time_ccd_wfs[i] = t_dt
              end
              'T_CR_CHAN2':begin
                 ;;Heat Sink Temp
                 i = (tdata.index_tce_wfs + 1L) mod MAX_RATE_LIST
                 tdata.index_tce_wfs   = i
                 tdata.temp_tce_wfs[i] = v
                 tdata.time_tce_wfs[i] = t_dt
              end
              'T_HK_CHAN4':begin
                 ;;TCE TEC Voltage
                 i = (tdata.index_vtec_wfs + 1L) mod MAX_RATE_LIST
                 tdata.index_vtec_wfs   = i
                 tdata.volt_vtec_wfs[i] = v
                 tdata.time_vtec_wfs[i] = t_dt
              end   
              'C_HK_CHAN14':begin
                 ;;Controller VCO_CV
                 i = (tdata.index_vco_wfs + 1L) mod MAX_RATE_LIST
                 tdata.index_vco_wfs    = i
                 tdata.volt_vco_wfs[i] = v
                 tdata.time_vco_wfs[i]  = t_dt
              end
              else:
           endcase
        endif
     endif
  endif else begin
     if nsel eq 0 then begin
        msg = string('command: '+n2s(cmd,format='(Z8.8)')+' not found')
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
     endif
     if nsel gt 1 then begin 
        msg = string("multiple commands found for "+n2s(hkdb[ic].cmd,format='(Z6.6)'))
        print,msg
        printf,set.hsklogunit,gettimestamp('.')+': '+msg
     endif
  endelse
  

  ;;----------------------------------------------------------
  ;; Plot housekeeping data
  ;;----------------------------------------------------------
  ;;science housekeeping
  if (t_now-t_last_sci) gt 10.1 and set.showshs then begin
     wset, set.hwsindex
     !P.FONT = 0  
     DEVICE, SET_FONT = set.hwsfont
     !p.multi = [0,0,2,0,0]
     
     ;;top plot -- temps
     piccgse_plotTwo,  tdata.time_tce_sci, tdata.time_ccd_sci, $
                      tdata.temp_tce_sci, tdata.temp_ccd_sci, $
                      TITLE1='White = HS:', TITLE2=' Red = CCD:',$
                      YTITLE='Temp C'
     
     ;;bottom plot -- voltages
     piccgse_plotTwo,  tdata.time_vtec_sci,  tdata.time_vco_sci, $
                      tdata.volt_vtec_sci, tdata.volt_vco_sci,$
                      TITLE1='White = VTEC:', TITLE2=' Red = VCO:',$
                      YTITLE='Volts',RANGE=[0,6]
     
     t_last_sci = t_now
  endif
  
  ;;wfs housekeeping
  if (t_now-t_last_wfs) gt 10.1 and set.showwhs then begin
     wset, set.hwwindex
     !P.FONT = 0  
     DEVICE, SET_FONT = set.hwwfont
     !p.multi = [0,0,2,0,0]
     ;;top plot -- temps
     piccgse_plotTwo,  tdata.time_tce_wfs,  tdata.time_ccd_wfs, $
                      tdata.temp_tce_wfs, tdata.temp_ccd_wfs, $
                      TITLE1='White = HS:', TITLE2=' Red = CCD:',$
                      YTITLE='Temp C'
     
     ;;bottom plot -- voltages
     piccgse_plotTwo,  tdata.time_vtec_wfs,  tdata.time_vco_wfs, $
                      tdata.volt_vtec_wfs, tdata.volt_vco_wfs,  $
                      TITLE1='White = VTEC:',TITLE2=' Red = VCO:',$
                      YTITLE='Volts',RANGE=[0,6]
     t_last_wfs = t_now
  endif
  
  
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
     if set.tmserver_addr eq 'picc'       then CMD_SENDDATA = swap_endian('0ABACABB'XUL)
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
;;pro piccgse
;; -- Main program
;; -- Display science products in several windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO piccgse, TMTEST=TMTEST, TMRECORD=TMRECORD, TMPRINT=TMPRINT
  common piccgse_block, set
;*************************************************
;* KEYWORDS
;*************************************************
;; TMTEST   -- Check the TM test pattern data (flight code fake mode 1)
;; TMRECORD -- Record the raw TM stream to disk
;; TMPRINT  -- Print the FIRST WORD of the raw TM stream to screen

;*************************************************
;* Define Settings Structure
;*************************************************
  set = {tmserver_type:'default',tmserver_addr:'default',tmserver_port:0U,$
         tmserver_tmfile:'default',tmserver_idlfile:'default',tmconnect:0,$
         plottype:0,imagesub:'ZERO',$
         saveidl:0,datapath:'',hsklogunit:0,pktlogunit:0,tmrecunit:0,$
         showwfs:0,showsci:0,shownum:0,showshs:0,showwhs:0,showtmp:0,showttp:0,$
         showpass:0,showfail:0,showimsg:0,pztdisp:0,              $
         iwname:'default',iwxsize:800,iwysize:400,iwxpos:800,iwypos:400,iwindex:0,iwfont:'8x13',$
         swname:'default',swxsize:800,swysize:400,swxpos:800,swypos:400,swindex:0,swfont:'8x13',$
         dwname:'default',dwxsize:800,dwysize:400,dwxpos:800,dwypos:400,dwindex:1,dwfont:'8x13',$
         twname:'default',twxsize:800,twysize:400,twxpos:800,twypos:400,twindex:1,twfont:'8x13',$
         pwname:'default',pwxsize:800,pwysize:400,pwxpos:800,pwypos:400,pwindex:2,pwfont:'8x13',    $
         hwsname:'default',hwsxsize:800,hwsysize:400,hwsxpos:800,hwsypos:400,hwsindex:2,hwsfont:'8x13',    $
         hwwname:'default',hwwxsize:800,hwwysize:400,hwwxpos:800,hwwypos:400,hwwindex:3,hwwfont:'8x13'}

;*************************************************
;* General
;*************************************************
  new_line  = ''
  tag       = 0U
  statmask  = '00FF'X
  ntmtest   = 1024
  tmtestmax = 65536UL

;*************************************************
;* Path Setup
;*************************************************
  cd,current=working
  !PATH = working+':'+!PATH
  
;*************************************************
;* TLM Parameters
;*************************************************
  framestr     = ['A','B','C','D']
  phasestr     = ['M','I','V','P','U','R']
  dmstr        = ['DM','DMDIFF']
  TLM_PRESYNC  =    '12345678'XUL
  TLM_POSTSYNC =    'DEADBEEF'XUL
  TLM_SCIENCE  =    'AAAA0000'XUL
  TLM_FRAME    =    'BBBB0000'XUL
  TLM_PHASE    =    'CCCC0000'XUL
  TLM_DATA     =    'DDDD0000'XUL
  TLM_DM       =    'EEEE0000'XUL
  TLM_HSK      =    'FFFF0000'XUL
  TYPE_MASK    =    'FFFF0000'XUL
  INDEX_MASK   =    '0000FFFF'XUL
  CAM_MASK     =    '80000000'XUL

;*************************************************
;* PZT Structure
;*************************************************
  pzt_t        = {pzt,           $
                  a:ulonarr(4), $
                  b:ulonarr(4), $
                  c:ulonarr(4)}

;*************************************************
;* Image Packet Header
;*************************************************
  tlmheader    = {packet_type:0UL, $
                  frame_number:0UL,$
                  exptime:0.0,     $
                  ontime:0.0,      $
                  temp:0.0,        $
                  timestamp:0L,    $
                  imxsize:0UL,      $
                  imysize:0UL,      $
                  state:0UL,       $
                  mode:0UL}


;*************************************************
;* Data Structure
;*************************************************
  tlmdata    = {tip:0.0,        $
                tilt:0.0,       $
                piston:0.0,     $
                chisq:0.0,     $
                Ithresh:0.0,       $
                Vthresh:0.0,       $
                background:0.0,       $
                intensity:0L,       $
                atlocked:0L,       $
                N:pzt_t,          $
                P:pzt_t,          $
                C:pzt_t}

;*************************************************
;* Housekeeping Structure
;*************************************************
  tlmhsk    = {cmd:0UL,val:0UL}
  hskidl    = {cam:0UL,cmd:'',v:0.} ;;for idl savefiles


;*************************************************
;* Load configuration file
;*************************************************
  fconfig = 'piccgse.conf'
  config_props = FILE_INFO(fconfig)
  if config_props.exists EQ 0 then MESSAGE, 'ERROR: Config file '+fconfig+' not found'
  cfg_mod_sec = config_props.mtime
  piccgse_loadConfig, fconfig


;*************************************************
;* Files -- Setup folder paths
;*************************************************
  piccgse_setupFiles,TMRECORD=TMRECORD, STARTUP_TIMESTAMP=STARTUP_TIMESTAMP



;*************************************************
;* Connections
;*************************************************
  tm_connected = 0
  tm_last_connected = -1
  tm_last_data      = -1
  TMUNIT = -1
  

;*************************************************
;* TM Test
;*************************************************
  tm_test_last      = -1L
  tm_test_count     = 0L

;*************************************************
;* Open windows
;*************************************************
  if NOT (keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT)) then piccgse_createWindows

;*************************************************
;* Initialize timers
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
;* SETUP IDLFILE DATA
;*************************************************
  MAKE_MOVIE   = 0  ;;save idlfile frames as jpgs
  ifile        = 0L
  
  if(set.tmserver_type eq 'idlfile') then begin
     ;;get filenames
     idlfiles = file_search(set.tmserver_idlfile,count=nfiles)
     
     print,'Opening idlfile images'
     help,idlfiles
  endif
  
;*************************************************
;* SETUP SHARED MEMORY
;*************************************************
  restore,'shmdef.idl'
  if NOT (keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT)) then begin
     shmmap, 'shm', /byte, shm_size
     ;;NOTE: This creates a file /dev/shm/shm of size shm_size bytes
     ;;      The file does not get deleted when you quit IDL, so if
     ;;      shm_size changes, you must delete this file manualy. 
     
     shm_var = shmvar('shm')
     shm_var[*] = bytarr(shm_size)
     shm_var[SHM_RUN] = 1
     shm_var[SHM_TIMESTAMP:SHM_TIMESTAMP+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
     
     print,'Shared memory mapped'
  endif
  
;*************************************************
;* START CONSOLE WIDGET
;*************************************************
  if NOT (keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT)) then begin
     obridge_up=obj_new("IDL_IDLBridge",output='')
     obridge_up->setvar,'!PATH',!PATH
     obridge_up->execute,'piccgse_uplink_console'
     obridge_dn=obj_new("IDL_IDLBridge",output='')
     obridge_dn->setvar,'!PATH',!PATH
     obridge_dn->execute,'piccgse_downlink_console'
     print,'Console widget started'
  endif

;*************************************************
;* ERROR HANDLER
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
  data1000 = uintarr(1000)+1
  tmcount = 0UL
  movfn = 0UL
  hfn   = 0UL ;;housekeeping packet counter

  while 1 do begin
     ;;What is the time now?
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
           wait,0.01
           parts = strsplit(idlfiles[ifile],'.',/extract)
           restore,idlfiles[ifile]
           if parts[4] ne 'hsk' then begin
              ;;process everything except housekeeping
              t = header.packet_type and TYPE_MASK
              piccgse_processDATA,header,data
              ;;display dmdiff
              if t eq TLM_DM then piccgse_processDATA,header,data,/dmdiff
           endif else begin
              ;;process housekeeping
              hskidl.cam = cam
              hskidl.cmd = cmd
              hskidl.v   = v
              if n_elements(header) eq 0 then header = tlmheader
              piccgse_processHSK,header,hskidl,/idlfile
              t_last_telemetry = t_now
           endelse
           ifile = (ifile+1) mod nfiles
        endelse
     endif

     


     ;;READ DATA FROM NETWORK
     ;;-- Expected data: experiment data with empty codes (0xFADE) stripped out
     if set.tmserver_type eq 'network' then begin
        if set.tmconnect then begin
           if tm_connected then begin
              ;;install error handler
              ON_IOERROR, RESET_CONNECTION
              
              ;;check for TM test pattern 
              if keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT) then begin
                 tmarray = uintarr(ntmtest)
                 if FILE_POLL_INPUT(TMUNIT,TIMEOUT=0.01) then begin
                    readu,TMUNIT,tmarray
                    if keyword_set(TMTEST) then begin 
                       if tm_test_count++ eq 0 then tmcheck=tmarray else begin 
                          tmcheck = lonarr(ntmtest)
                          tmc=0UL
                          for i=0,ntmtest-1 do begin
                             tmcheck[i] = (tmc + tm_test_last + 1) mod tmtestmax
                             tmc++
                             if tmcheck[i] eq 'FADE'XU then begin
                                tmcheck[i]++
                                tmc++
                             endif
                          endfor
                       endelse
                       if array_equal(tmarray,tmcheck) then begin
                          statusline,'TM Test: '+n2s(tm_test_count)+' transfers without error'
                       endif else begin
                          print,''
                          print,'TM Test: ERROR after '+n2s(tm_test_count)+' transfers'
                          for i=0,ntmtest-1 do begin
                             if tmarray[i] ne tmcheck[i] then begin
                                print,'First ERROR occured at index '+n2s(i)+' --> Read: 0x'+n2s(tmarray[i],format='(Z4.4)')+' Expected: 0x'+n2s(tmcheck[i],format='(Z4.4)')
                                break
                             endif
                          endfor
                          tm_test_count=0
                          break
                       endelse
                       tm_test_last = tmarray[ntmtest-1]
                    endif
                    if keyword_set(TMRECORD) then begin 
                       printf,set.tmrecunit,tmarray,format='(Z4.4)'
                    endif
                    if keyword_set(TMPRINT) then begin
                       print,tmarray[0],format='(Z4.4)'
                    endif
                 endif
              endif else begin
                 ;;This is where we read real data
                 ;;set link status
                 shm_var[SHM_LINK] = 1
                 if FILE_POLL_INPUT(TMUNIT,TIMEOUT=0.01) then begin
                    READU, TMUNIT, tag
                    tm_last_data = systime(1)
                    ;;set data status
                    shm_var[SHM_DATA] = 1
                    if tag eq lss(TLM_PRESYNC) then begin
                       READU, TMUNIT, tag
                       if tag eq mss(TLM_PRESYNC) then begin
                          ;;read in header
                          READU, TMUNIT, tlmheader
                          ;;get indicies
                          t   = tlmheader.packet_type and TYPE_MASK
                          i   = tlmheader.packet_type and INDEX_MASK
                          fn  = tlmheader.frame_number
                          sfn = n2s(fn,format='(I8.8)')
                          imxsize = tlmheader.imxsize
                          imysize = tlmheader.imysize
                          
                          ;;identify and process data
                          case t of
                             ;;HSK
                             TLM_HSK: begin
                                shfn=n2s(hfn++,format='(I8.8)')
                                msg1 = gettimestamp('.')+': '+'header.hsk.'+shfn
                                printf,set.pktlogunit,msg1
                                READU, TMUNIT, tlmhsk
                                READU, TMUNIT, tag
                                if(tag eq lss(TLM_POSTSYNC)) then begin
                                   READU, TMUNIT, tag
                                   if(tag eq mss(TLM_POSTSYNC))then begin
                                      ;;get cam
                                      cam = tlmhsk.cmd AND CAM_MASK
                                      cam = ishft(cam,-31)
                                      piccgse_processHSK,tlmheader,tlmhsk
                                      t_last_telemetry = t_now
                                      msg2 = gettimestamp('.')+': '+'packet.hsk.'+n2s(cam)+'.'+shfn
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.hsk.'+shfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                endif else msg2 = gettimestamp('.')+': '+'dropped.hsk.'+shfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                printf,set.pktlogunit,msg2
                                first = strpos(msg2,'dropped')
                                if(first ge 0) then print,msg2
                             end
                             
                             ;;DATA
                             TLM_DATA: begin
                                msg1 = gettimestamp('.')+': '+'header.data.'+sfn
                                printf,set.pktlogunit,msg1
                                READU, TMUNIT, tlmdata
                                READU, TMUNIT, tag
                                if(tag eq lss(TLM_POSTSYNC)) then begin
                                   READU, TMUNIT, tag
                                   if(tag eq mss(TLM_POSTSYNC))then begin
                                      piccgse_processDATA,tlmheader,tlmdata
                                      msg2 = gettimestamp('.')+': '+'packet.data.'+sfn
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.data.'+sfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                endif else msg2 = gettimestamp('.')+': '+'dropped.data.'+sfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                printf,set.pktlogunit,msg2
                                first = strpos(msg2,'dropped')
                                if(first ge 0) then print,msg2
                             end
                             
                             ;;science images
                             TLM_SCIENCE: begin
                                msg1 = gettimestamp('.')+': '+'header.science.'+sfn
                                printf,set.pktlogunit,msg1
                                if imxsize gt 0 and imysize gt 0 then begin 
                                   ims = uintarr(imxsize,imysize)
                                   READU, TMUNIT, ims
                                   READU, TMUNIT, tag
                                   if(tag eq lss(TLM_POSTSYNC)) then begin
                                      READU, TMUNIT, tag
                                      if(tag eq mss(TLM_POSTSYNC))then begin
                                         piccgse_processDATA,tlmheader,ims
                                         msg2 = gettimestamp('.')+': '+'packet.science.'+sfn
                                      endif else msg2 = gettimestamp('.')+': '+'dropped.science.'+sfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.science.'+sfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                   printf,set.pktlogunit,msg2
                                   first = strpos(msg2,'dropped')
                                   if(first ge 0) then print,msg2
                                endif
                             end
                             
                             ;;frame images
                             TLM_FRAME: begin
                                msg1 = gettimestamp('.')+': '+'header.frame.'+framestr[i]+'.'+sfn
                                printf,set.pktlogunit,msg1
                                if imxsize gt 0 and imysize gt 0 then begin 
                                   imf = uintarr(imxsize,imysize)
                                   READU, TMUNIT, imf
                                   READU, TMUNIT, tag
                                   if(tag eq lss(TLM_POSTSYNC)) then begin
                                      READU, TMUNIT, tag
                                      if(tag eq mss(TLM_POSTSYNC))then begin
                                         piccgse_processDATA,tlmheader,imf
                                         msg2 = gettimestamp('.')+': '+'packet.frame.'+framestr[i]+'.'+sfn
                                      endif else msg2 = gettimestamp('.')+': '+'dropped.frame.'+framestr[i]+'.'+sfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.frame.'+framestr[i]+'.'+sfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                   printf,set.pktlogunit,msg2
                                   first = strpos(msg2,'dropped')
                                   if(first ge 0) then print,msg2
                                endif
                             end
                             
                             ;;phase images
                             TLM_PHASE: begin
                                msg1 = gettimestamp('.')+': '+'header.phase.'+phasestr[i]+'.'+sfn
                                printf,set.pktlogunit,msg1
                                if imxsize gt 0 and imysize gt 0 then begin 
                                   imp = fltarr(imxsize,imysize)
                                   READU, TMUNIT, imp
                                   READU, TMUNIT, tag
                                   if(tag eq lss(TLM_POSTSYNC)) then begin
                                      READU, TMUNIT, tag
                                      if(tag eq mss(TLM_POSTSYNC))then begin
                                         piccgse_processDATA,tlmheader,imp
                                         msg2 = gettimestamp('.')+': '+'packet.phase.'+phasestr[i]+'.'+sfn
                                      endif else msg2 = gettimestamp('.')+': '+'dropped.phase.'+phasestr[i]+'.'+sfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.phase.'+phasestr[i]+'.'+sfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                   printf,set.pktlogunit,msg2
                                   first = strpos(msg2,'dropped')
                                   if(first ge 0) then print,msg2
                                endif
                             end

                             ;;dm images
                             TLM_DM: begin
                                msg1 = gettimestamp('.')+': '+'header.dm.'+sfn
                                printf,set.pktlogunit,msg1
                                if imxsize gt 0 and imysize gt 0 then begin 
                                   imdm = fltarr(imxsize,imysize)
                                   READU, TMUNIT, imdm
                                   READU, TMUNIT, tag
                                   if(tag eq lss(TLM_POSTSYNC)) then begin
                                      READU, TMUNIT, tag
                                      if(tag eq mss(TLM_POSTSYNC))then begin
                                         piccgse_processDATA,tlmheader,imdm
                                         ;;display dmdiff 
                                         piccgse_processDATA,tlmheader,imdm,/dmdiff
                                         msg2 = gettimestamp('.')+': '+'packet.dm.'+sfn
                                      endif else msg2 = gettimestamp('.')+': '+'dropped.dm.'+sfn+'.ps2.'+n2s(tag,format='(Z4.4)')
                                   endif else msg2 = gettimestamp('.')+': '+'dropped.dm.'+sfn+'.ps1.'+n2s(tag,format='(Z4.4)')
                                   printf,set.pktlogunit,msg2
                                   first = strpos(msg2,'dropped')
                                   if(first ge 0) then print,msg2
                                endif
                             end
                             else: begin 
                                msg=gettimestamp('.')+': '+'unknown.'+n2s(t)+'.'+n2s(i)
                                printf,set.pktlogunit,msg
                                print,msg
                                print,'TLMHEADER: '+n2s(tlmheader.packet_type,format='(Z)')+'     '+n2s(tlmheader.frame_number,format='(Z)')
                             end
                          endcase
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
        endif
     endif

     
     ;;----------------------------------------------------------
     ;; Make GSE Movie
     ;;----------------------------------------------------------
     if MAKE_MOVIE then begin
        wset,set.iwindex
        im1 = tvrd() ;;wfs
        wset,set.dwindex
        im2 = tvrd() ;;data
        wset,set.swindex
        im3 = tvrd() ;;sci
        s1  = size(im1)
        s2  = size(im2)
        s3  = size(im3)
        im4 = bytarr(s1[1]+s2[1],s1[2])
        im4[0:s1[1]-1,0:s1[2]-1]=im1
        im4[s1[1]:s1[1]+s2[1]-1,0:s3[2]-1]=im3
        im4[s1[1]:s1[1]+s2[1]-1,s3[2]:s3[2]+s2[2]-1]=im2
        write_jpeg,'data/savedata/gsemovie/frame.'+n2s(movfn++)+".jpg",im4,quality=100
     endif
     


     
     ;;----------------------------------------------------------
     ;; Check config file
     ;;----------------------------------------------------------
     ;;Has config file been modified?
     if (t_now-t_last_cfg) GT 0.5 then begin
        
        ;;Get config file properties
        config_props = FILE_INFO(fconfig)
        
        ;;Update last time config file was checked
        t_last_cfg = SYSTIME(1)
        
        ;;If config file has been modified then load the new version
        if config_props.mtime NE cfg_mod_sec then begin
           PRINT, 'Loading modified configuration file'
           cfg_mod_sec = config_props.mtime
           old_set = set
           piccgse_loadConfig, fconfig
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
     if NOT (keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT)) then begin
        if shm_var[SHM_CMD] then begin
           ;;reset command bit
           shm_var[SHM_CMD]=0
           
           ;;exit
           if NOT shm_var[SHM_RUN] then begin
              if TMUNIT gt 0 then free_lun,TMUNIT
              if set.hsklogunit gt 0 then free_lun,set.hsklogunit
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
              piccgse_processHSK,/reset
              print,"Temp window reset"
              print,'Resetting paths...'
              piccgse_setupFiles,STARTUP_TIMESTAMP=STARTUP_TIMESTAMP
              ;;set timestamp in shared memory
              shm_var[SHM_TIMESTAMP:SHM_TIMESTAMP+strlen(STARTUP_TIMESTAMP)-1]=byte(STARTUP_TIMESTAMP)
           endif
        endif
     endif
     
     
     ;;----------------------------------------------------------
     ;; Save loop time
     ;;----------------------------------------------------------
     t_last_loop = t_now
  endwhile

  ;;shutdown
  if TMUNIT gt 0 then free_lun,TMUNIT
  if set.hsklogunit gt 0 then free_lun,set.hsklogunit
  if set.pktlogunit gt 0 then free_lun,set.pktlogunit
  if NOT (keyword_set(TMTEST) OR keyword_set(TMRECORD) OR keyword_set(TMPRINT)) then begin
     obj_destroy,obridge_up
     obj_destroy,obridge_dn
     shmunmap,'shm'
  endif
  print,'Shared memory unmapped'
  while !D.WINDOW ne -1 do wdelete
end
