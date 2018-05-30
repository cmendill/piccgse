pro piccdisp,NOSAVE=NOSAVE
  close,/all
  shkwid = 0
  
  
;;Network
CMD_SENDDATA = '0ABACABB'XUL
imserver = 'lowfs'
import   = 14000

;;Buffer IDs
SCIEVENT = 0UL
SCIFULL  = 1UL
SHKEVENT = 2UL
SHKFULL  = 3UL
LYTEVENT = 4UL
LYTFULL  = 5UL
ACQEVENT = 6UL
ACQFULL  = 7UL

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
DATAWIN = 22UL
WPIXMAP = 23UL

;;Settings
SHK_NCELLS = 256
IWC_NSPA = 76
IWC_NTTP = 3
HEX_NAXES = 6
ALP_NACT = 97
LOWFS_N_ZERNIKE = 24 ;;from controller.h

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
window,DATAWIN,xpos=0,ypos=600,xsize=400,ysize=400,title='Data'

;;Image packet structure -- aligned on 8 byte boundary
pkthed   = {packet_type:0UL, $
            frame_number:0UL, $
            exptime:0.,$
            ontime:0.,$
            temp:0.,$
            imxsize:0UL,$
            imysize:0UL,$
            mode:0UL,$
            start_sec:long64(0),$
            start_nsec:long64(0),$
            end_sec:long64(0),$
            end_nsec:long64(0)}

shkcell_struct = {index:0U,$
                  beam_select:0U,$
                  spot_found:0U,$
                  spot_captured:0U,$
                  maxpix:0UL,$
                  maxval:0UL,$
                  blx:0U,$
                  bly:0U,$
                  trx:0U,$
                  try:0U,$
                  intensity:0d,$
                  background:0d,$
                  origin:dblarr(2),$
                  cenbox_origin:dblarr(2),$
                  centroid:dblarr(2),$
                  deviation:dblarr(2),$
                  command:dblarr(2)}

iwc_struct = {spa:uintarr(IWC_NSPA),$
              ttp:uintarr(IWC_NTTP),$
              calmode:0U}
              
hex_struct = {axs:dblarr(HEX_NAXES),$
              calmode:0ULL}
              
alp_struct = {act_cmd:dblarr(ALP_NACT),$
              act_now:dblarr(ALP_NACT),$
              zern_now:dblarr(LOWFS_N_ZERNIKE),$
              zern_cmd:dblarr(LOWFS_N_ZERNIKE),$
              zern_trg:dblarr(LOWFS_N_ZERNIKE),$
              calmode:0ULL}   

shkevent = {hed:pkthed, $
            beam_ncells:0UL,$
            boxsize:0UL,$
            xtilt:0d,$
            ytilt:0d,$
            kP:0d,$
            kI:0d,$
            kD:0d,$
            kH:0d,$
            cells:replicate(shkcell_struct,SHK_NCELLS),$
            zernikes:dblarr(LOWFS_N_ZERNIKE),$
            iwc_spa_matrix:dblarr(IWC_NSPA),$
            alp_act_matrix:dblarr(ALP_NACT),$
            hex_axs_matrix:dblarr(HEX_NAXES),$
            iwc:iwc_struct,$
            alp:alp_struct,$
            hex:hex_struct}



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
            endif
            if pkthed.packet_type eq SHKFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               readu,IMUNIT,shkevent
               tag='shkfull'
               ;;scale image
               simage = image
               greyrscale,simage,4093
               
               ;;****** DISPLAY IMAGE ******
               wset,SHKFULL
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,wpixmap
               imdisp,simage,/noscale,/axis,/erase
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
               plot,shkevent.zernikes,/xs,psym=10, yrange=[-5.0,5.0]
               
               ;;write data to data window
               if toff eq 0 then toff = pkthed.start_sec
               wset,DATAWIN
               ;;create pixmap window
               window,wpixmap,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
               wset,WPIXMAP
                             
               xyouts,dsx,dsy-ddy*dc++,'-------Shack-Hartmann-------',/normal,charsize=charsize
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
               xyouts,dsx,dsy-ddy*dc++,'IWC Cal Mode: '+n2s(shkevent.iwc.calmode),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'SHK Boxsize: '+n2s(shkevent.boxsize),/normal,charsize=charsize
               xyouts,dsx,dsy-ddy*dc++,'PID Gains: '+string(shkevent.kP,shkevent.kI,shkevent.kD,format='(3F10.3)'),/normal,charsize=charsize

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
               wset,DATAWIN
               tv,snap
               ;;save packet
               if dosave then save,pkthed,image,shkevent,$
                                   filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(shkfull_count,format='(I8.8)')+'.idl'
               
               shkfull_count++
            endif
            if pkthed.packet_type eq LYTFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               tag='lytfull'
               lytfull_count++
            endif
            if pkthed.packet_type eq ACQFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               tag='acqfull'
               acqfull_count++
               ;;****** DISPLAY IMAGE ******
               wset,ACQFULL
               imdisp,image,/axis,/erase
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

