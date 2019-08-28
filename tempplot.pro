folders = file_search('data/piccgse/*',count=nfolders)
path = folders[-1]
last = 0
window,0
while 1 do begin
   files = file_search(path+'/*thmevent*.idl',count=nfiles)
   for i=last,nfiles-1 do begin
      restore,files[i]
      if i eq 0 then data = [pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp] else begin
         data = [[data],[pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp]]
      endelse
   endfor
   last = nfiles
   ntemp = n_elements(data[*,0])
   colors = bytscl(dindgen(ntemp),top=254)
   window,1,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
   plot,data[0,*],/nodata,yrange=[0,80],/ys,/xs,background=255,color=0
   for i=0,ntemp-1 do begin
      oplot,data[i,*],color=colors[i]
   endfor
   snap = TVRD()
   wdelete,1
   wset,0
   loadct,39
   tv,snap
   loadct,0
   help,data
   wait,1
endwhile




end
