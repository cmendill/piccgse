pro piccdisp,NOSAVE=NOSAVE,PLOT_CENTROIDS=PLOT_CENTROIDS,NOBOX=NOBOX,ZAUTOSCALE=ZAUTOSCALE
  close,/all
  
;;Flight Software Header File
header='../piccflight/src/controller.h'

;;Buffer IDs -- 
buffer_id = read_c_enum(header,'bufids')
for i=0, n_elements(buffer_id)-1 do void=execute(buffer_id[i]+'='+n2s(i))

;;Build packet structures
pkthed   = read_c_struct(header,'pkthed')
shkfull  = read_c_struct(header,'shkfull')
lytfull  = read_c_struct(header,'lytfull')
scifull  = read_c_struct(header,'scifull')
acqfull  = read_c_struct(header,'acqfull')
thmevent = read_c_struct(header,'thmevent')
mtrevent = read_c_struct(header,'mtrevent')

;;Remove headers from structures -- they are read seperately
struct_delete_field,shkfull,'hed'
struct_delete_field,lytfull,'hed'
struct_delete_field,scifull,'hed'
struct_delete_field,acqfull,'hed'
struct_delete_field,thmevent,'hed'
struct_delete_field,mtrevent,'hed'

;;Network
CMD_SENDDATA = '0ABACABB'XUL
imserver = 'picture'
import   = 14000

;;Counters
scifull_count  = 0UL
shkfull_count  = 0UL
lytfull_count  = 0UL
acqfull_count  = 0UL
thmevent_count = 0UL
mtrevent_count = 0UL

;;Window IDs
WACQFULL = 0UL
WSCIFULL = 1UL
WSHKFULL = 2UL
WLYTFULL = 3UL
WSHKZERN = 4UL
WLYTZERN = 5UL
WSHKDATA = 6UL
WLYTDATA = 7UL
WPIXMAP  = 8UL
WALPMAP  = 9UL
WBMCMAP  = 10UL
WTHMDATA = 11UL

;;Display
charsize = 1.5

;;Windows
wxsize=400
wysize=400
blx = 405
bly = 5
xbuf = 5
ybuf = 60
window,WACQFULL,xpos=blx,ypos=bly,xsize=wxsize,ysize=wysize,title='Acquisition Camera'
window,WSCIFULL,xpos=blx+wxsize+xbuf,ypos=bly,xsize=wxsize,ysize=wysize,title='Science Camera'
window,WSHKFULL,xpos=blx,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='Shack-Hartmann Camera'
window,WLYTFULL,xpos=blx+wxsize+xbuf,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='Lyot LOWFS Camera'
window,WALPMAP ,xpos=blx+(wxsize+xbuf)*2,ypos=bly+wysize+ybuf,xsize=wxsize,ysize=wysize,title='ALPAO DM Command'
window,WBMCMAP ,xpos=blx+(wxsize+xbuf)*2,ypos=bly,xsize=wxsize,ysize=wysize,title='BMC DM Command'
window,WSHKDATA,xpos=0,ypos=1000,xsize=400,ysize=325,title='Shack-Hartmann Data'
window,WLYTDATA,xpos=0,ypos=473,xsize=400,ysize=200,title='Lyot LOWFS Data'
window,WSHKZERN,xpos=0,ypos=250,xsize=400,ysize=195,title='Shack-Hartmann Zernikes'
window,WLYTZERN,xpos=0,ypos=0,xsize=400,ysize=195,title='LLOWFS Zernikes'
window,WTHMDATA,xpos=0,ypos=0,xsize=500,ysize=600,title='Thermal Data'

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

;;Check header size, these should be the same if there is no padding
print,'Header Size: '+n2s(n_tags(pkthed,/length))
print,'Header Data Size: '+n2s(n_tags(pkthed,/data_length))

;;Open console
openr,tty,'/dev/tty',/get_lun

;;Create output path
if not keyword_set(NOSAVE) then begin
   path = 'data/picc_fullimages/piccdisp.'+gettimestamp('.')+'/'
   check_and_mkdir,path
endif

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
            if pkthed.type eq BUFFER_SCIFULL then begin
               readu,IMUNIT,scifull
               tag='scifull'
               wset,WSCIFULL
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               if n_elements(scifull.image) gt 1 then !P.Multi = [0, 3, 2]
               for i=0,n_elements(scifull.image)-1 do begin
                  image  = reform(scifull.image[i].data)
                  simage = reform(scifull.image[i].data)
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
               wset,WSCIFULL
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               ;;save packet
               if dosave then save,pkthed,scifull,filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(scifull_count,format='(I8.8)')+'.idl'
               scifull_count++
          endif
            if pkthed.type eq BUFFER_SHKFULL then begin
               readu,IMUNIT,shkfull
               tag='shkfull'
               shkevent = shkfull.shkevent

               ;;scale image
               simage = shkfull.image.data
               greyrscale,simage,4092
               
               ;;****** DISPLAY IMAGE ******
               wset,WSHKFULL
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               for i=0,n_elements(shkevent.cells)-1 do begin
                  ;;bottom
                  if NOT keyword_set(NOBOX) then oplot,[shkevent.cells[i].blx,shkevent.cells[i].trx],[shkevent.cells[i].bly,shkevent.cells[i].bly],color=253
                  ;;top
                  if NOT keyword_set(NOBOX) then oplot,[shkevent.cells[i].blx,shkevent.cells[i].trx],[shkevent.cells[i].try,shkevent.cells[i].try],color=253
                  ;;left
                  if NOT keyword_set(NOBOX) then oplot,[shkevent.cells[i].blx,shkevent.cells[i].blx],[shkevent.cells[i].bly,shkevent.cells[i].try],color=253
                  ;;right
                  if NOT keyword_set(NOBOX) then oplot,[shkevent.cells[i].trx,shkevent.cells[i].trx],[shkevent.cells[i].bly,shkevent.cells[i].try],color=253
                  ;;centroid
                  if keyword_set(plot_centroids) then if(shkevent.cells[i].spot_found) then begin
                     xcentroid = shkevent.cells[i].xtarget + shkevent.cells[i].xtarget_deviation[0]
                     ycentroid = shkevent.cells[i].ytarget + shkevent.cells[i].ytarget_deviation[0]
                     oplot,[xcentroid],[ycentroid],color=254,psym=2
                  endif
               endfor
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WSHKFULL
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
               alpimage[alpsel] = shkevent.alp_acmd[*,0]
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
               xyouts,dsx,dsy-ddy*dc++,'State: '+string(pkthed.state_name),/device,charsize=charsize
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
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+string(shkevent.hed.alp_calmode_name),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Hex Cal Mode: '+string(shkevent.hed.hex_calmode_name),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'SHK Boxsize: '+n2s(shkevent.boxsize),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cell PID: '+string(shkevent.gain_alp_cell,format='(3F10.3)'),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+string(shkevent.gain_alp_zern,format='(3F10.3)'),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'HEX Zern PID: '+string(shkevent.gain_hex_zern,format='(3F10.3)'),/device,charsize=charsize

               xyouts,dsx,dsy-ddy*dc++,'MAX Max Pixel: '+n2s(long(max(shkevent.cells.maxval)))+' counts',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Max Pixel: '+n2s(long(mean(shkevent.cells.maxval)))+' counts',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Intensity: '+n2s(long(mean(shkevent.cells.intensity)))+' counts/cell',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'MAX Intensity: '+n2s(long(max(shkevent.cells.intensity)))+' counts/cell',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'BKG Intensity: '+n2s(long(mean(shkevent.cells.background)))+' counts/px',/device,charsize=charsize
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
            if pkthed.type eq BUFFER_LYTFULL then begin
               readu,IMUNIT,lytfull
               tag='lytfull'
               lytevent = lytfull.lytevent
               
               ;;****** DISPLAY IMAGE ******
               wset,WLYTFULL
               ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;scale image
               simage = lytfull.image.data
               greyrscale,simage,4092
               ;;display image
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WLYTFULL
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
               xyouts,dsx,dsy-ddy*dc++,'State: '+string(pkthed.state_name),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Frame Number: '+n2s(pkthed.frame_number),/device,charsize=charsize
               st = double(lytevent.hed.start_sec-lyt_toff) + double(lytevent.hed.start_nsec)/1e9
               et = double(lytevent.hed.end_sec-lyt_toff)   + double(lytevent.hed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Event Time: '+n2s(dt)+' us',/device,charsize=charsize
               st = double(pkthed.start_sec-lyt_toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-lyt_toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Full Time: '+n2s(dt)+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Meas. Exp: '+n2s(long(pkthed.ontime*1e6))+' us',/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+string(lytevent.hed.alp_calmode_name),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+string(lytevent.gain_alp_zern[0,0],lytevent.gain_alp_zern[1,0],lytevent.gain_alp_zern[2,0],format='(3F10.3)'),/device,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'LYT MAX Pixel: '+n2s(max(lytfull.image.data)),/device,charsize=charsize
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WLYTDATA
               tv,snap
               ;;save packet
               if dosave then save,pkthed,lytfull,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(lytfull_count,format='(I8.8)')+'.idl'
               lytfull_count++

             endif
            if pkthed.type eq BUFFER_ACQFULL then begin
               readu,IMUNIT,acqfull
               tag='acqfull'
               ;;****** DISPLAY IMAGE ******
               wset,WACQFULL
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
               wset,WACQFULL
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
               readu,IMUNIT,thmevent
               wset,WTHMDATA
                ;;create pixmap window
               window,WPIXMAP,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
               ;;set text origin
               dsx = 5
               dsy = !D.Y_SIZE - 14 
               ;;Write data to data window
               for i=0,31 do begin
                  if i lt 16 then begin
                     str=string('ADC1['+n2s(i,format='(I2.2)')+']: ',thmevent.adc1_temp[i],$
                                'ADC2['+n2s(i,format='(I2.2)')+']: ',thmevent.adc2_temp[i],$
                                'ADC3['+n2s(i,format='(I2.2)')+']: ',thmevent.adc3_temp[i],format='(A,F-+10.3,A,F-+10.3,A,F-+10.3)')
                     xyouts,dsx,dsy-ddy*dc++,str,/device,charsize=charsize
                  endif else begin
                     if thmevent.htr_override[i-16] then htr=' OVR' else htr=' HTR'
                     str=string(htr+'['+n2s(i-16,format='(I2.2)')+']: ',thmevent.htr_power[i-16],$
                                'ADC2['+n2s(i,format='(I2.2)')+']: ',thmevent.adc2_temp[i],$
                                'ADC3['+n2s(i,format='(I2.2)')+']: ',thmevent.adc3_temp[i],format='(A,I-10,A,F-+10.3,A,F-+10.3)')
                     xyouts,dsx,dsy-ddy*dc++,str,/device,charsize=charsize
                  endelse
               endfor
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,WTHMDATA
               tv,snap
               ;;save packet
               if dosave then save,pkthed,thmevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(thmevent_count,format='(I8.8)')+'.idl'
              
               thmevent_count++
            endif
            if pkthed.type eq BUFFER_MTREVENT then begin
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
                  path = 'data/picc_fullimages/piccdisp.'+gettimestamp('.')+'/'
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
            path = 'data/picc_fullimages/piccdisp.'+gettimestamp('.')+'/'
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
         print,'SCIFULL: '+n2s(scifull_count)
         print,'SHKFULL: '+n2s(shkfull_count)
         print,'LYTFULL: '+n2s(lytfull_count)
         print,'ACQFULL: '+n2s(acqfull_count)
         print,'THMEVENT: '+n2s(thmevent_count)
         print,'MTREVENT: '+n2s(mtrevent_count)
         ;;exit
         stop
      endif
   endif
   wait,0.2
endwhile


end

