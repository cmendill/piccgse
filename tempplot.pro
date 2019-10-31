path=''
window,0
;;Temperature database
t = load_tempdb()
adc1 = t[where(t.adc eq 1)]
adc2 = t[where(t.adc eq 2)]
adc3 = t[where(t.adc eq 3)]
adc  = [adc1,adc2,adc3]
items = adc.abbr
lines = intarr(n_elements(items))

while 1 do begin
   folders = file_search('data/piccgse/*',count=nfolders)
   if path ne folders[-1] then begin
      path = folders[-1]
      print,'Reading data from: '+path
      last = 0
      data = 0
   endif
   files = file_search(path+'/*thmevent*.idl',count=nfiles)
   for i=last,nfiles-1 do begin
      restore,files[i]
      if i eq 0 then data = [pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp] else begin
         data = [[data],[pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp]]
      endelse
   endfor
   last = nfiles
   ntemp = n_elements(data[*,0])
   npoints = n_elements(data[0,*])
   if npoints ge 2 then begin 
      colors = bytscl(dindgen(ntemp),top=254)
      window,1,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
      plot,data[0,*],/nodata,yrange=[min(data) < (-40),max(data) > 80],ystyle=9,/xs,background=255,color=0,position=[0.03,0.05,0.97,0.95],charsize=1.5
      axis,yaxis=1,/ys,color=0,charsize=1.5
      for i=0,ntemp-1 do begin
         oplot,data[i,*],color=colors[i]
      endfor
      temps=n2s([pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp],format='(F10.1)')
      cbmlegend,items+': '+temps,lines,colors,[0.1,0.98],charthick=1,thick=3
      snap = TVRD()
      wdelete,1
      wset,0
      loadct,39
      tv,snap
      loadct,0
   endif
   help,data
   wait,1
endwhile




end
