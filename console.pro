pro console
openu,tty,'/dev/tty',/get_lun
openu,ser,'/dev/ttyUSB0',/get_lun,/rawio
spawn,'stty -F /dev/ttyUSB0 115200 cs8 cread clocal ignpar brkint'
out  = -1
word = 0B
data = bytarr(128)
line = ''
while 1 do begin
   ret = file_poll_input([tty,ser])
   ;;tty
   if ret[0] then begin
      readf,tty,line
      if strlen(line) eq 0 then output=10B else output=[byte(line),10B]
      writeu,ser,output
   endif
   ;;ser
   if ret[1] then begin
      readu,ser,word
      ;;print word to screen
      writeu,out,word
   endif
endwhile

end
