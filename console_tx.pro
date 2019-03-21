;;IDL Serial console Tx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
line = ''

;;input device
openr,tty,'/dev/tty',/get_lun

;;open port to write
openw,unit,dev,/get_lun

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(tty) then begin
      ;;read data from console
      readf,tty,line
      ;;write unformatted data to serial port
      writeu,unit,[byte(line),10B]
   endif
endwhile


end
