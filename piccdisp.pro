pro piccdisp,NOSAVE=NOSAVE,PLOT_CENTROIDS=PLOT_CENTROIDS
  close,/all
  
;;**** begin controller.h ****;;
;;Settings
SHK_NCELLS = 256
HEX_NAXES = 6
ALP_NACT = 97
LOWFS_N_ZERNIKE = 23

;;Buffer IDs
SCIEVENT = 0UL
SCIFULL  = 1UL
SHKEVENT = 2UL
SHKFULL  = 3UL
LYTEVENT = 4UL
LYTFULL  = 5UL
ACQEVENT = 6UL
ACQFULL  = 7UL


;;Image packet structure -- aligned on 8 byte boundary
pkthed   = {packet_type:0UL, $
            frame_number:0UL, $
            exptime:0.,$
            ontime:0.,$
            temp:0.,$
            imxsize:0UL,$
            imysize:0UL,$
            mode:0UL,$
            state:0UL,$
            dummy:0UL,$
            start_sec:long64(0),$
            start_nsec:long64(0),$
            end_sec:long64(0),$
            end_nsec:long64(0)}

shkcell_struct = {index:0U,$
                  beam_select:0U,$
                  spot_found:0U,$
                  spot_captured:0U,$
                  ;;--------------
                  maxpix:0UL,$
                  maxval:0UL,$
                  ;;--------------
                  blx:0U,$
                  bly:0U,$
                  trx:0U,$
                  try:0U,$
                  ;;--------------
                  intensity:0d,$
                  background:0d,$
                  origin:dblarr(2),$
                  cenbox_origin:dblarr(2),$
                  centroid:dblarr(2),$
                  deviation:dblarr(2),$
                  command:dblarr(2)}

hex_struct = {axis_cmd:dblarr(HEX_NAXES),$
              zernike_cmd:dblarr(LOWFS_N_ZERNIKE)}

alp_struct = {act_cmd:dblarr(ALP_NACT),$
              zernike_cmd:dblarr(LOWFS_N_ZERNIKE)}

wsp_struct = {pitch_cmd:0d,$
              yaw_cmd:0d}

shkevent = {hed:pkthed, $
            beam_ncells:0UL,$
            boxsize:0UL,$
            hex_calmode:0UL,$
            alp_calmode:0UL,$
            hex_calstep:0UL,$
            alp_calstep:0UL,$
            xtilt:0d,$
            ytilt:0d,$
            kP_alp_cell:0d,$
            kI_alp_cell:0d,$
            kD_alp_cell:0d,$
            kP_alp_zern:0d,$
            kI_alp_zern:0d,$
            kD_alp_zern:0d,$
            kP_hex_zern:0d,$
            kI_hex_zern:0d,$
            kD_hex_zern:0d,$
            cells:replicate(shkcell_struct,SHK_NCELLS),$
            zernike_measured:dblarr(LOWFS_N_ZERNIKE),$
            zernike_target:dblarr(LOWFS_N_ZERNIKE),$
            hex:hex_struct,$
            alp:alp_struct,$
            wsp:wsp_struct}

lytevent = {hed:pkthed, $
            alp_calmode:0UL,$
            alp_calstep:0UL,$
            xtilt:0d,$
            ytilt:0d,$
            kP_alp_zern:0d,$
            kI_alp_zern:0d,$
            kD_alp_zern:0d,$
            zernike_measured:dblarr(LOWFS_N_ZERNIKE),$
            zernike_target:dblarr(LOWFS_N_ZERNIKE),$
            alp:alp_struct}

;;**** end controller.h ****;;


;;Network
CMD_SENDDATA = '0ABACABB'XUL
imserver = 'picture'
import   = 14000


;;Counters
scievent_count = 0UL
shkevent_count = 0UL
lytevent_count = 0UL
acqevent_count = 0UL
scifull_count = 0UL
shkfull_count = 0UL
lytfull_count = 0UL
acqfull_count = 0UL

;;Other window IDs
SHKZERN = 20UL
LYTZERN = 21UL
SHKDATA = 22UL
LYTDATA = 23UL
WPIXMAP = 24UL

;;Display
charsize = 1.5

;;Windows
xsize=450
ysize=450
blx = 500
bly = 20
xbuf = 5
ybuf = 60
ddy=0.05
dsy=0.95
dsx=0.05
window,ACQFULL,xpos=blx,ypos=bly,xsize=xsize,ysize=ysize,title='Acquisition Camera'
window,SCIFULL,xpos=blx+xsize+xbuf,ypos=bly,xsize=xsize,ysize=ysize,title='Science Camera'
window,SHKFULL,xpos=blx,ypos=bly+ysize+ybuf,xsize=xsize,ysize=ysize,title='Shack-Hartmann Camera'
window,LYTFULL,xpos=blx+xsize+xbuf,ypos=bly+ysize+ybuf,xsize=xsize,ysize=ysize,title='Lyot LOWFS Camera'
window,SHKZERN,xpos=0,ypos=0,xsize=400,ysize=400,title='Shack-Hartmann Zernikes'
window,SHKDATA,xpos=0,ypos=600,xsize=400,ysize=400,title='Shack-Hartmann Data'
window,LYTDATA,xpos=0,ypos=600,xsize=400,ysize=400,title='Lyot LOWFS Data'

;;Get states from flight code (states.h)
states = getstates()

;;Check header size, these should be the same if there is no padding
print,'Header Size: '+n2s(n_tags(pkthed,/length))
print,'Header Data Size: '+n2s(n_tags(pkthed,/data_length))

;;Create path
if not keyword_set(NOSAVE) then begin

   path = 'data/picc_fullimages/piccdisp.'+gettimestamp('.')+'/'
   check_and_mkdir,path
endif

;;File saving
dosave=1
if keyword_set(NOSAVE) then dosave=0

;;Open console
openr,tty,'/dev/tty',/get_lun

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
          IF FILE_POLL_INPUT(IMUNIT,TIMEOUT=1) GT 0 THEN BEGIN
            dc=0
            toff=0L
            readu,IMUNIT,pkthed
            if pkthed.packet_type eq SCIFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               tag='scifull'
               scifull_count++
               ;;****** DISPLAY IMAGE ******
               wset,SCIFULL
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,wpixmap
               ;;scale image
               simage = image
               greyrscale,simage,65535
               ;;display
               imdisp,simage,/axis,title='SCI Temp: '+n2s(pkthed.temp,format='(F10.1)')+' C'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,wpixmap
               ;;switch back to real window
               wset,SCIFULL
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
          endif
            if pkthed.packet_type eq SHKFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               readu,IMUNIT,shkevent
               tag='shkfull'
               ;;scale image
               simage = image
               greyrscale,simage,4092
               
               ;;****** DISPLAY IMAGE ******
               wset,SHKFULL
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,wpixmap
               imdisp,simage,/noscale,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               for i=0,n_elements(shkevent.cells)-1 do begin
                  if(shkevent.cells[i].beam_select) then begin
                     ;;bottom
                     oplot,[shkevent.cells[i].blx,shkevent.cells[i].trx],[shkevent.cells[i].bly,shkevent.cells[i].bly],color=253
                     ;;top
                     oplot,[shkevent.cells[i].blx,shkevent.cells[i].trx],[shkevent.cells[i].try,shkevent.cells[i].try],color=253
                     ;;left
                     oplot,[shkevent.cells[i].blx,shkevent.cells[i].blx],[shkevent.cells[i].bly,shkevent.cells[i].try],color=253
                     ;;right
                     oplot,[shkevent.cells[i].trx,shkevent.cells[i].trx],[shkevent.cells[i].bly,shkevent.cells[i].try],color=253
                     ;;centroid
                     if keyword_set(plot_centroids) then if(shkevent.cells[i].spot_found) then oplot,[shkevent.cells[i].centroid[0]],[shkevent.cells[i].centroid[1]],color=254,psym=2
                  endif
               endfor
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,wpixmap
               ;;switch back to real window
               wset,SHKFULL
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
               ;;display zernikes
               wset,SHKZERN
               plot,shkevent.zernike_measured,/xs,psym=10,yrange=[-2.0,2.0]
               
               ;;write data to data window
               if toff eq 0 then toff = pkthed.start_sec
               wset,SHKDATA
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
                             
               xyouts,dsx,dsy-ddy*dc++,'-------Shack-Hartmann-------',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'State: '+states[pkthed.state],/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Frame Number: '+n2s(pkthed.frame_number),/normal,charsize=charsize
               st = double(pkthed.start_sec-toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Event Time: '+n2s(dt)+' us',/normal,charsize=charsize
               st = double(pkthed.start_sec-toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Full Time: '+n2s(dt)+' us',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Meas. Exp: '+n2s(long(pkthed.ontime*1e6))+' us',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+n2s(shkevent.alp_calmode),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Hex Cal Mode: '+n2s(shkevent.hex_calmode),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'SHK Boxsize: '+n2s(shkevent.boxsize),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'X-Tilt: '+n2s(shkevent.xtilt,format='(F10.2)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Y-Tilt: '+n2s(shkevent.ytilt,format='(F10.2)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cell PID: '+string(shkevent.kP_alp_cell,shkevent.kI_alp_cell,shkevent.kD_alp_cell,format='(3F10.3)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+string(shkevent.kP_alp_zern,shkevent.kI_alp_zern,shkevent.kD_alp_zern,format='(3F10.3)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'HEX Zern PID: '+string(shkevent.kP_hex_zern,shkevent.kI_hex_zern,shkevent.kD_hex_zern,format='(3F10.3)'),/normal,charsize=charsize

               sel = where(shkevent.cells.beam_select)
               xyouts,dsx,dsy-ddy*dc++,'MAX Max Pixel: '+n2s(long(max(shkevent.cells[sel].maxval)))+' counts',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Max Pixel: '+n2s(long(mean(shkevent.cells[sel].maxval)))+' counts',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'AVG Intensity: '+n2s(long(mean(shkevent.cells[sel].intensity)))+' counts/cell',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'MAX Intensity: '+n2s(long(max(shkevent.cells[sel].intensity)))+' counts/cell',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'BKG Intensity: '+n2s(long(mean(shkevent.cells[sel].background)))+' counts/px',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'TOT Intensity: '+n2s(long(total(shkevent.cells[sel].intensity)),format='(E10.3)')+' counts',/normal,charsize=charsize
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,SHKDATA
               tv,snap
               ;;save packet
               if dosave then save,pkthed,image,shkevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(shkfull_count,format='(I8.8)')+'.idl'
               
               shkfull_count++
            endif
            if pkthed.packet_type eq LYTFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               readu,IMUNIT,lytevent
               event_image = uintarr(lytevent.hed.imxsize,lytevent.hed.imysize)
               readu,IMUNIT,event_image
               tag='lytfull'
               lytfull_count++
               ;;****** DISPLAY IMAGE ******
               wset,LYTFULL
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,wpixmap
               ;;scale image
               simage = image
               greyrscale,simage,2L^14 - 1
               imdisp,simage,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,wpixmap
               ;;switch back to real window
               wset,LYTFULL
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0

               
               ;;****** DISPLAY DATA ******
               if toff eq 0 then toff = pkthed.start_sec
               wset,LYTDATA
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
                             
               ;;Write data to data window
               xyouts,dsx,dsy-ddy*dc++,'-------Lyot LOWFS-------',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'State: '+states[pkthed.state],/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Frame Number: '+n2s(pkthed.frame_number),/normal,charsize=charsize
               st = double(pkthed.start_sec-toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Event Time: '+n2s(dt)+' us',/normal,charsize=charsize
               st = double(pkthed.start_sec-toff) + double(pkthed.start_nsec)/1e9
               et = double(pkthed.end_sec-toff) + double(pkthed.end_nsec)/1e9
               dt = long((et-st)*1e6)
               xyouts,dsx,dsy-ddy*dc++,'Full Time: '+n2s(dt)+' us',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Meas. Exp: '+n2s(long(pkthed.ontime*1e6))+' us',/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Cal Mode: '+n2s(lytevent.alp_calmode),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'X-Tilt: '+n2s(lytevent.xtilt,format='(F10.2)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'Y-Tilt: '+n2s(lytevent.ytilt,format='(F10.2)'),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'ALP Zern PID: '+string(lytevent.kP_alp_zern,lytevent.kI_alp_zern,lytevent.kD_alp_zern,format='(3F10.3)'),/normal,charsize=charsize
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,WPIXMAP
               ;;switch back to real window
               wset,LYTDATA
               tv,snap
           endif
            if pkthed.packet_type eq ACQFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               tag='acqfull'
               acqfull_count++
               ;;****** DISPLAY IMAGE ******
               wset,ACQFULL
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,wpixmap
               ;;scale image
               simage = image
               greyrscale,simage,2L^14 - 1
               imdisp,simage,/axis,/erase,title='Exp: '+n2s(pkthed.ontime*1000,format='(F10.1)')+' ms'
               ;;take snapshot
               snap = TVRD()
               ;;delete pixmap window
               wdelete,wpixmap
               ;;switch back to real window
               wset,ACQFULL
               ;;set color table
               greyr
               ;;display image
               tv,snap
               loadct,0
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
         ;;exit
         stop
      endif
   endif
   wait,0.2
endwhile


end

