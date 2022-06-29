pro liveshk, gsepath
  n=0L
  while 1 do begin
     files=file_search('data/piccgse/'+gsepath+'/*shkfull*.idl',count=nfiles)
     if nfiles gt n then begin
        restore,files[-1]
        imdisp,pkt.image.data,/axis
        n=nfiles
     endif

  endwhile

end
