;;IDL Serial console Rx program

;;device settings
dev  = '/dev/ttyUSB0'
baud = '115200'
data = bytarr[128]

;;output device (stdout)
stdout = -1

;;open port to read
openr,unit,dev,/get_lun,error=error,/rawio
if error ne 0 then begin
   stop,'Could not open '+dev
endif

;;configure serial port
spawn,'stty -F '+dev+' '+baud+' cs8 -cstopb -parenb'

;;enter console loop
while 1 do begin
   if file_poll_input(unit) then begin
      ;;read unformatted data
      readu,unit,data,transfer_count=num
      ;;write unformmated data to stdout
      writeu,stdout,data[0:num-1]
   endif
endwhile


end
