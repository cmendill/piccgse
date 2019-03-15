;;IDL Serial console Tx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
line = ''

;;open port to write
openw,unit,dev,/get_lun

;;open user input console
openr,tty,'/dev/tty',/get_lun

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(tty) then begin
      readf,tty,line
      writeu,unit,line
   endif
endwhile


end
