;;IDL Serial console Rx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
line = ''

;;open port to read
openr,unit,dev,/get_lun

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(unit) then begin
      readf,unit,line
      print,strcompress(line)
   endif
endwhile


end
