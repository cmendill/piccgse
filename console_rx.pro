;;IDL Serial console Rx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
word = 0B

;;output device (stdout)
stdout = -1

;;open port to read
openr,unit,dev,/get_lun,error=error
if error ne 0 then begin
   stop,'Could not open '+dev
endif

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(unit) then begin
      ;;read unformatted data
      readu,unit,word
      ;;write data to stdout
      writeu,stdout,word
   endif
endwhile


end
