pro piccdisp,NOSAVE=NOSAVE, FITS=FITS, SAVE_EVERY=SAVE_EVERY
  close,/all
  shkwid = 0
  
  

;;Network
CMD_SENDDATA = '0ABACABB'XUL
imserver = 'lowfs'
import   = 14000
count    = 0L

;;Buffer IDs
SCIEVENT = 0UL
SCIFULL  = 1UL
SHKEVENT = 2UL
SHKFULL  = 3UL
LYTEVENT = 4UL
LYTFULL  = 5UL
ACQEVENT = 6UL
ACQFULL  = 7UL

;;Windows
xsize=300
ysize=300
blx = 750
bly = 20
xbuf = 5
ybuf = 60
window,ACQFULL,xpos=blx,ypos=bly,xsize=xsize,ysize=ysize,title='Acquisition Camera'
window,SCIFULL,xpos=blx+xsize+xbuf,ypos=bly,xsize=xsize,ysize=ysize,title='Science Camera'
window,SHKFULL,xpos=blx,ypos=bly+ysize+ybuf,xsize=xsize,ysize=ysize,title='Shack-Hartmann Camera'
window,LYTFULL,xpos=blx+xsize+xbuf,ypos=bly+ysize+ybuf,xsize=xsize,ysize=ysize,title='Lyot LOWFS Camera'

;;Image packet structure -- aligned on 8 byte boundary
pkthed   = {packet_type:0UL, $
            frame_number:0UL, $
            exptime:0.,$
            ontime:0.,$
            temp:0.,$
            imxsize:0UL,$
            imysize:0UL,$
            mode:0UL,$
            time_sec:long64(0),$
            time_nsec:long64(0)}

;;Check header size, these should be the same if there is no padding
print,'Header Size: '+n2s(n_tags(pkthed,/length))
print,'Header Data Size: '+n2s(n_tags(pkthed,/data_length))

;;Create path
if not keyword_set(NOSAVE) then begin
   path = 'data/picc_fullimages/piccdisp.'+gettimestamp('.')+'/'
   check_and_mkdir,path
endif

;;File Saving
if NOT keyword_set(SAVE_EVERY) then SAVE_EVERY=1 

;;Open console
openr,tty,'/dev/tty',/get_lun

while 1 do begin
   ;;Create Socket connection
   PRINT, 'Attempting to create Socket connection Image Server to >'+imserver+'< on port '+n2s(import)
   SOCKET, IMUNIT, imserver, import, /GET_LUN, CONNECT_TIMEOUT=3, ERROR=con_status,READ_TIMEOUT=3
   if con_status eq 0 then begin
      PRINT, 'Socket created'
      ;;Ask for images
      WRITEU,IMUNIT,CMD_SENDDATA
      while 1 do begin
         IF FILE_POLL_INPUT(IMUNIT,TIMEOUT=1) GT 0 THEN BEGIN
            gotdata=0
            readu,IMUNIT,pkthed
            if pkthed.packet_type eq SCIFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               iwin=SCIFULL
               tag='scifull'
               gotdata=1
            endif
            if pkthed.packet_type eq SHKFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               iwin=SHKFULL
               tag='shkfull'
               gotdata=1
            endif
            if pkthed.packet_type eq LYTFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               iwin=LYTFULL
               tag='lytfull'
               gotdata=1
            endif
            if pkthed.packet_type eq ACQFULL then begin
               image = uintarr(pkthed.imxsize,pkthed.imysize)
               readu,IMUNIT,image
               iwin=ACQFULL
               tag='acqfull'
               gotdata=1
            endif

            if gotdata then begin 
               ;;display image
               wset,iwin
               imdisp,image
               
               ;;save packet
               if (count mod SAVE_EVERY eq 0) and not keyword_set(NOSAVE) then begin
                  if keyword_set(FITS) then begin
                     writefits,path+tag+'.'+gettimestamp('.')+'.'+n2s(count,format='(I8.8)')+'.fits',image
                  endif else begin
                     save,pkthed,image,filename=path+tag+'.'+gettimestamp('.')+'.'+n2s(count,format='(I8.8)')+'.idl'
                  endelse
               endif
            endif
            count++
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
               if n_elements(IMUNIT) gt 0 then begin
                  if IMUNIT gt 0 then free_lun,IMUNIT
               endif
               if tty gt 0 then free_lun,tty
               while !D.WINDOW ne -1 do wdelete
               ;;exit
               stop
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
         ;;clean up
         if n_elements(IMUNIT) gt 0 then begin
            if IMUNIT gt 0 then free_lun,IMUNIT
         endif
         if tty gt 0 then free_lun,tty
         while !D.WINDOW ne -1 do wdelete
         ;;exit
         stop
      endif
   endif
   wait,1
endwhile


end

