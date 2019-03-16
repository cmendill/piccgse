;;IDL Serial console Tx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
line = ''

;;input device (stdin)
stdin = 0

;;open port to write
openw,unit,dev,/get_lun

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(stdin) then begin
      ;;read data from stdin
      readf,stdin,line
      ;;write unformatted data to serial port
      writeu,unit,line
   endif
endwhile


end
