pro piccdisp,NOSAVE=NOSAVE,PLOT_CENTROIDS=PLOT_CENTROIDS,NOBOX=NOBOX,ZAUTOSCALE=ZAUTOSCALE
  close,/all
  
;;Flight Software Header File
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

;;Network
CMD_SENDDATA = '0ABACABB'XUL
imserver = 'picture'
import   = 14000

;;Counters
shkfull_count  = 0UL
acqfull_count  = 0UL
lytevent_count = 0UL
scievent_count = 0UL
thmevent_count = 0UL
mtrevent_count = 0UL

;;Window IDs
WACQIMAGE = 0UL
WSCIIMAGE = 1UL
WSHKIMAGE = 2UL
WLYTIMAGE = 3UL
WSHKZERN  = 4UL
WLYTZERN  = 5UL
WSHKDATA  = 6UL
WLYTDATA  = 7UL
WPIXMAP   = 8UL
WALPMAP   = 9UL
WBMCMAP   = 10UL
WTHMDATA  = 11UL

;;Display
charsize = 1.5

;;Windows
wxsize=400
wysize=400
blx = 405
bly = 5
xbuf = 5
ybuf = 60
window,WACQIMAGE,xpos=blx,ypos=bly,xsize=wxsize,ysize=wysize,title='Acquisition Camera'
window,WSCIIMAGE,xpos=blx+wxsize+xbuf,ypos=bly,xsize=wxsize,ysize=wysize,title='Science Camera'
window,WSHKIMAGE,xpos=blx,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='Shack-Hartmann Camera'
window,WLYTIMAGE,xpos=blx+wxsize+xbuf,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='Lyot LOWFS Camera'
window,WALPMAP ,xpos=blx+(wxsize+xbuf)*2,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='ALPAO DM Command'
window,WBMCMAP ,xpos=blx+(wxsize+xbuf)*2,ypos=bly,xsize=wxsize,ysize=wysize,title='BMC DM Command'
window,WSHKDATA,xpos=0,ypos=1000,xsize=400,ysize=325,title='Shack-Hartmann Data'
window,WLYTDATA,xpos=0,ypos=473,xsize=400,ysize=200,title='Lyot LOWFS Data'
window,WSHKZERN,xpos=0,ypos=250,xsize=400,ysize=195,title='Shack-Hartmann Zernikes'
window,WLYTZERN,xpos=0,ypos=0,xsize=400,ysize=195,title='LLOWFS Zernikes'
window,WTHMDATA,xpos=0,ypos=0,xsize=600,ysize=530,title='Thermal Data'

;;Text line spacing
ddy=16 ;;pixels

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
alpimage = mask * 0d

;;Open console
openr,tty,'/dev/tty',/get_lun

;;Create output path
if not keyword_set(NOSAVE) then begin
   path = 'data/piccdisp/piccdisp.'+gettimestamp('.')+'/'
   check_and_mkdir,path
endif

;;Load temperature sensor database
t = load_tempdb()
adc1 = t[where(t.adc eq 1)]
adc2 = t[where(t.adc eq 2)]
adc3 = t[where(t.adc eq 3)]

;;File saving
dosave=1
if keyword_set(NOSAVE) then dosave=0

IMUNIT=0
while 1 do begin
   RESET_CONNECTION: PRINT, !ERR_STRING ;;Jump here if an IO error occured
   if IMUNIT gt 0 then free_lun,IMUNIT
   ;;Create Socket connection
   PRINT, 'Attempting to create Socket connection Image Server to >'+imserver+'< on port '+n2s(import)
   SOCKET, IMUNIT, imserver, import, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status,READ_TIMEOUT=3
   if con_status eq 0 then begin
      PRINT, 'Socket created'
      ;;Ask for images
      WRITEU,IMUNIT,CMD_SENDDATA
      while 1 do begin
         ;;install error handler
         ON_IOERROR, RESET_CONNECTION
          IF FILE_POLL_INPUT(IMUNIT,TIMEOUT=5) GT 0 THEN BEGIN
            dc=0
            shk_toff=0L
            lyt_toff=0L
            readu,IMUNIT,pkthed
            if pkthed.type eq BUFFER_SCIEVENT then begin
               readu,IMUNIT,scievent
               tag='scievent'
               wset,WSCIIMAGE
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               if n_elements(scievent.image) gt 1 then !P.Multi = [0, 3, 2]
               for i=0,n_elements(scievent.image)-1 do begin
                  image  = reform(scievent.image[i].data)
                  simage = reform(scievent.image[i].data)
                  ;;do photometry
                  m=max(simage,imax)
                  xy=array_indices(simage,imax)
                  bgr=mean(simage[10:50,10:50])
                  xmin = xy[0]-3 > 0
                  xmax = xy[0]+3 < n_elements(simage[*,0])-1
                  ymin = xy[1]-3 > 0
                  ymax = xy[1]+3 < n_elements(simage[0,*])-1
                  avg=mean(double(simage[xmin:xmax,ymin:ymax]))-bgr
                  wset,WPIXMAP
                  ;;scale image
                  greyrscale,simage,65535
                  ;;display
                  pcs = 1
                  if(!D.X_SIZE gt wxsize) then pcs = 0.7* double(!D.X_SIZE) / double(wxsize)
                  imdisp,simage,/noscale,/axis,title='Band '+n2s(i)+' Exp: '+n2s(pkthed.exptime,format='(F10.3)')+' Max: '+n2s(max(image))+' Avg: '+n2s(avg,format='(I)'),charsize=pcs
               endfor
               !P.Multi = 0
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WSCIIMAGE
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               ;;save packet
               if dosave then save,pkthed,scievent,filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(scievent_count,format='(I8.8)')+'.idl'
               scievent_count++
          endif
            if pkthed.type eq BUFFER_SHKFULL then begin
               readu,IMUNIT,shkfull
               tag='shkfull'
               shkevent = shkfull.shkevent

               ;;scale image
               simage = shkfull.image.data
               greyrscale,simage,4092
               
               ;;****** DISPLAY IMAGE ******
               wset,WSHKIMAGE
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'+' CCD: '+n2s(shkevent.ccd_temp,format='(F10.1)')+' C'
               for i=0,n_elements(shkevent.cells)-1 do begin
                  if NOT keyword_set(NOBOX) then begin
                     color = 254
                     if shkevent.cells[i].spot_found then color = 253
                     blx = floor((shkevent.cells[i].xtarget - shkevent.cells[i].boxsize)/SHKBIN)
                     bly = floor((shkevent.cells[i].ytarget - shkevent.cells[i].boxsize)/SHKBIN)
                     trx = floor((shkevent.cells[i].xtarget + shkevent.cells[i].boxsize)/SHKBIN)
                     try = floor((shkevent.cells[i].ytarget + shkevent.cells[i].boxsize)/SHKBIN)
                     ;;bottom
                     oplot,[blx,trx],[bly,bly],color=color
                     ;;top
                     oplot,[blx,trx],[try,try],color=color
                     ;;left
                     oplot,[blx,blx],[bly,try],color=color
                     ;;right
                     oplot,[trx,trx],[bly,try],color=color
                  endif
                  ;;centroid
                  if keyword_set(plot_centroids) AND shkevent.cells[i].spot_found then begin
                     xcentroid = shkevent.cells[i].xcentroid/SHKBIN
                     ycentroid = shkevent.cells[i].ycentroid/SHKBIN
                     oplot,[xcentroid],[ycentroid],color=254,psym=2
                  endif
               endfor
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WSHKIMAGE
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               ;;display zernikes
               wset,WSHKZERN
               linecolor
               yrange=[-2,2]
               mm = max(abs(minmax(shkevent.zernike_measured[*,0])))*1.05 > 0.1
               if keyword_set(ZAUTOSCALE) then yrange=[-mm,mm]
               plot,shkevent.zernike_measured[*,0],/xs,psym=10,yrange=yrange,/ys,xtitle='Zernike',ytitle='um RMS',/nodata
               oplot,shkevent.zernike_target,psym=10,color=1,thick=3
               oplot,shkevent.zernike_measured[*,0],psym=10,color=255
               loadct,0
               
               ;;****** DISPLAY ALP DM ******
               wset,WALPMAP
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;fill out image
               alpimage[alpsel] = shkevent.alp.acmd
               ;;display image
               implot,alpimage,ctable=0,blackout=alpnotsel,range=[-1,1],/erase,$
                      cbtitle=' ',cbformat='(F4.1)',ncolors=254,title='ALPAO DM Command'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WALPMAP
               ;;set color table
               loadct,39
               ;;display image
               tv,snap
               loadct,0

               
               ;;****** WRITE TO DATA WINDOW ******
               if shk_toff eq 0 then shk_toff = pkthed.start_sec
               wset,WSHKDATA
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;set text origin
               dsx = 5
               dsy = !D.Y_SIZE - 14
               xyouts,dsx,dsy-ddy*dc++,'-------Shack-Hartmann-------',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'State: '+states[pkthed.state],/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Frame Number: '+n2s(pkthed.frame_number),/device,charsize=charsize
               st = double(shkevent.hed.start_sec-shk_toff) + double(shkevent.hed.start_nsec)/1e9
               et = double(shkevent.hed.end_sec-shk_toff) + double(shkevent.hed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Event Time: '+n2s(dt)+' us',/device,charsize=charsize
               st = double(pkthed.start_sec-shk_toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-shk_toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Full Time: '+n2s(dt)+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Meas. Exp: '+n2s(long(pkthed.ontime*1e6))+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'CCD Temp: '+n2s(shkevent.ccd_temp,format='(F10.3)')+' C',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+alpcalmodes[shkevent.hed.alp_calmode],/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Hex Cal Mode: '+hexcalmodes[shkevent.hed.hex_calmode],/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'SHK Boxsize: '+n2s(shkevent.boxsize),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cell PID: '+string(shkevent.gain_alp_cell,format='(3F10.3)'),/device,charsize=charsize
               gain_alp_zern = reform(shkevent.gain_alp_zern,LOWFS_N_PID,LOWFS_N_ZERNIKE)
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+$
                      string(gain_alp_zern[0,0],gain_alp_zern[1,0],gain_alp_zern[2,0],format='(3F10.3)'),$
                      /device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'HEX Zern PID: '+string(shkevent.gain_hex_zern,format='(3F10.3)'),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'MAX Max Pixel: '+n2s(long(max(shkevent.cells.maxval)))+' counts',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Max Pixel: '+n2s(long(mean(shkevent.cells.maxval)))+' counts',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Intensity: '+n2s(long(mean(shkevent.cells.intensity)))+' counts/cell',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'MAX Intensity: '+n2s(long(max(shkevent.cells.intensity)))+' counts/cell',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'BKG Intensity: '+n2s(mean(shkevent.cells.background),format='(F10.2)')+' counts/px',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'TOT Intensity: '+n2s(long(total(shkevent.cells.intensity)),format='(E10.3)')+' counts',/device,charsize=charsize
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WSHKDATA
               tv,snap
               ;;save packet
               if dosave then save,pkthed,shkfull,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(shkfull_count,format='(I8.8)')+'.idl'
               
               shkfull_count++
            endif
            if pkthed.type eq BUFFER_LYTEVENT then begin
               readu,IMUNIT,lytevent
               tag='lytevent'
                            
               ;;****** DISPLAY IMAGE ******
               wset,WLYTIMAGE
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;scale image
               simage = lytevent.image.data
               greyrscale,simage,4092
               ;;display image
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'+' CCD: '+n2s(lytevent.ccd_temp,format='(F10.1)')+' C'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WLYTIMAGE
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               
               ;;****** DISPLAY DATA ******
               wset,WLYTZERN
               linecolor
               yrange=[-500,500]
               mm=max(abs(minmax(lytevent.zernike_measured[*,0]*1000)))*1.05 > 10
               if keyword_set(ZAUTOSCALE) then yrange=[-mm,mm]
               plot,lytevent.zernike_measured[*,0]*1000,/xs,psym=10,yrange=yrange,/ys,xtitle='Zernike',ytitle='nm RMS',/nodata
               oplot,lytevent.zernike_target*1000,psym=10,color=1,thick=3
               oplot,lytevent.zernike_measured[*,0]*1000,psym=10,color=255
               loadct,0
              
               ;;****** DISPLAY DATA ******
               if lyt_toff eq 0 then lyt_toff = pkthed.start_sec
               wset,WLYTDATA
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;set text origin
               dsx = 5
               dsy = !D.Y_SIZE - 14 
               ;;Write data to data window
               xyouts,dsx,dsy-ddy*dc++,'-------Lyot LOWFS-------',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'State: '+states[pkthed.state],/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Frame Number: '+n2s(pkthed.frame_number),/device,charsize=charsize
               st = double(pkthed.start_sec-lyt_toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-lyt_toff)   + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Event Time: '+n2s(dt)+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Meas. Exp: '+n2s(long(pkthed.ontime*1e6))+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'CCD Temp: '+n2s(lytevent.ccd_temp,format='(F10.3)')+' C',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+alpcalmodes[pkthed.alp_calmode],/device,charsize=charsize
               gain_alp_zern = reform(lytevent.gain_alp_zern,LOWFS_N_PID,LOWFS_N_ZERNIKE)
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+$
                      string(gain_alp_zern[0,0],gain_alp_zern[1,0],gain_alp_zern[2,0],format='(3F10.3)'),$
                      /device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'LYT MAX Pixel: '+n2s(max(lytevent.image.data)),/device,charsize=charsize
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WLYTDATA
               tv,snap
               ;;save packet
               if dosave then save,pkthed,lytevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(lytevent_count,format='(I8.8)')+'.idl'
               lytevent_count++

             endif
            if pkthed.type eq BUFFER_ACQFULL then begin
               readu,IMUNIT,acqfull
               tag='acqfull'
               ;;****** DISPLAY IMAGE ******
               wset,WACQIMAGE
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;scale image
               simage = acqfull.image.data
               greyrscale,simage,2L^14 - 1
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WACQIMAGE
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               ;;save packet
               if dosave then save,pkthed,acqfull,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(acqfull_count,format='(I8.8)')+'.idl'
               acqfull_count++
            endif
            if pkthed.type eq BUFFER_THMEVENT then begin
               tag='thmevent'
               readu,IMUNIT,thmevent
               wset,WTHMDATA
                ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;set text origin
               dsx = 5
               dsy = !D.Y_SIZE - 14 
               red=1
               green=2
               blue=3
               ;;Write data to data window
               for i=0,31 do begin
                  color = green
                  if thmevent.adc1_temp[i<15] lt adc1[i<15].min then color = blue
                  if thmevent.adc1_temp[i<15] gt adc1[i<15].max then color = red
                  if (i mod 2 eq 1) OR i gt 8 then color = 255
                  xyouts,dsx,dsy-ddy*dc,string(adc1[i<15].abbr+': ',thmevent.adc1_temp[i<15],format='(A,F-+25.3)'),/device,charsize=charsize,color=color
                  color = green
                  if thmevent.adc2_temp[i] lt adc2[i].min then color = blue
                  if thmevent.adc2_temp[i] gt adc2[i].max then color = red
                  xyouts,dsx,dsy-ddy*dc,string(adc2[i].abbr+': ',thmevent.adc2_temp[i],format='(T35,A,F-+15.3)'),/device,charsize=charsize,color=color
                  color = green
                  if thmevent.adc3_temp[i] lt adc3[i].min then color = blue
                  if thmevent.adc3_temp[i] gt adc3[i].max then color = red
                  xyouts,dsx,dsy-ddy*dc,string(adc3[i].abbr+': ',thmevent.adc3_temp[i],format='(T55,A,F-+15.3)'),/device,charsize=charsize,color=color
                  dc++
               endfor
               ;;blackout lower half of adc1
               blackout = intarr(180,272)
               tvscl,blackout,0,0
               ;;Write heater data
               dc-=16
               for i=0,15 do begin
                  str=string(string(thmevent.htr[i].name)+'['+n2s(i,format='(I2.2)')+']: ',thmevent.htr[i].power,' ',$
                             thmevent.htr[i].temp,' ',$
                             thmevent.htr[i].setpoint,format='(A,I-4,A,F-+6.1,A,F-+6.1)')
                  xyouts,dsx,dsy-ddy*dc++,str,/device,charsize=charsize,color=255
               endfor
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WTHMDATA
               linecolor
               tv,snap
               loadct,0
               ;;save packet
               if dosave then save,pkthed,thmevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(thmevent_count,format='(I8.8)')+'.idl'
              
               thmevent_count++
            endif
            if pkthed.type eq BUFFER_MTREVENT then begin
               tag='mtrevent'
               readu,IMUNIT,mtrevent
               ;;save packet
               if dosave then save,pkthed,mtrevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(thmevent_count,format='(I8.8)')+'.idl'
              
               mtrevent_count++
            endif
         endif else begin
            if n_elements(IMUNIT) gt 0 then begin
               if IMUNIT gt 0 then free_lun,IMUNIT
            endif
            break
         endelse

         ;;Pause for just a bit to handle I/O with user
         wait, 0.000001d
         cmdline = ''
         if(FILE_POLL_INPUT(tty,TIMEOUT=0.000001D)) then begin
            readf,tty,cmdline
            if cmdline eq 'reset' then begin
               ;;Create path
               if not keyword_set(NOSAVE) then begin
                  path = 'data/piccdisp/piccdisp.'+gettimestamp('.')+'/'
                  check_and_mkdir,path
               endif
            endif
            if cmdline eq 'exit' or cmdline eq 'quit' then begin
               ;;clean up
               goto, cleanup
            endif
         endif
         
      endwhile
      
   endif else begin
      MESSAGE, !ERR_STRING, /INFORM
   endelse

   ;;Pause for just a bit to handle I/O with user
   wait, 0.000001d
   cmdline = ''
   if(FILE_POLL_INPUT(tty,TIMEOUT=0.000001D)) then begin
      readf,tty,cmdline
      if cmdline eq 'reset' then begin
         ;;Create path
         if not keyword_set(NOSAVE) then begin
            path = 'data/piccdisp/piccdisp.'+gettimestamp('.')+'/'
            check_and_mkdir,path
         endif
      endif
      if cmdline eq 'exit' or cmdline eq 'quit' then begin
         cleanup:
         ;;clean up
         if n_elements(IMUNIT) gt 0 then begin
            if IMUNIT gt 0 then free_lun,IMUNIT
         endif
         if tty gt 0 then free_lun,tty
         while !D.WINDOW ne -1 do wdelete
         ;;print status
         print,'**********Packets received**********'
         print,'SHKFULL: '+n2s(shkfull_count)
         print,'ACQFULL: '+n2s(acqfull_count)
         print,'LYTEVENT: '+n2s(lytevent_count)
         print,'SCIEVENT: '+n2s(scievent_count)
         print,'THMEVENT: '+n2s(thmevent_count)
         print,'MTREVENT: '+n2s(mtrevent_count)
         ;;exit
         stop
      endif
   endif
   wait,0.2
endwhile


end

