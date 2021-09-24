pro livetemp, gsepath=gsepath
path=''
;;Setup window  
window,0,title='PICTURE-C Temperatures'
;;Flight software header file
header='../piccflight/src/controller.h'
;;Temperature database
tdb = load_tempdb()
tsort = sort(tdb.abbr)
tdb = tdb[tsort]
ntemp = n_elements(tdb)

;;Initialize data
data  =  dblarr(ntemp)
pkt   =  read_c_struct(header,'thmevent')

;;GSEPATH Keyword
if keyword_set(gsepath) then begin
   path = 'data/piccgse/'+gsepath
   print,'Reading data from: '+path
   last = 0
   data = dblarr(ntemp)
endif

while 1 do begin
   ;;Get data path
   if NOT keyword_set(gsepath) then begin
      folders = file_search('data/piccgse/*',count=nfolders)
      if path ne folders[-1] then begin
         path = folders[-1]
         print,'Reading data from: '+path
         last = 0
         data = dblarr(ntemp)
      endif
   endif
   files = file_search(path+'/*thmevent*.idl',count=nfiles)
   for i=last,nfiles-1 do begin
      restore,files[i]
      if i eq 0 then data = ([pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp])(tsort) else begin
         data = [[data],[([pkt.adc1_temp,pkt.adc2_temp,pkt.adc3_temp])(tsort)]]
      endelse
   endfor
   last = nfiles
   npoints = n_elements(data[0,*])
   window,1,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
   !P.MULTI = [0,2,2]
   loadct,39

   ;;Make 2x2 plots
   for iplot=0,3 do begin
      if iplot eq 0 then begin
         title='Heaters'
         sel    = where(tdb.htr,nsel)
      endif
      if iplot eq 1 then begin
         title='Telescope'
         sel = where((tdb.location eq 'Telescope Truss' OR tdb.location eq 'Primary Mirror' OR $
                      tdb.location eq 'Secondary Mirror' OR tdb.location eq 'Hexapod') AND (tdb.htr eq 0),nsel)
      endif
      if iplot eq 2then begin
         title='Instrument'
         sel = where((tdb.location eq 'Instrument Interior' OR tdb.location eq 'Instrument Exterior') AND (tdb.htr eq 0),nsel)
      endif
      if iplot eq 3 then begin
         title='Electronics'
         sel = where((tdb.location eq 'Electronics') AND (tdb.htr eq 0),nsel)
      endif
      
      items  = tdb[sel].abbr+': '+n2s(data[sel,-1],format='(F10.1)')
      lines  = intarr(nsel)
      color  = bytscl(dindgen(nsel),top=254)
      plot,data[sel[0],*],/nodata,yrange=[min(data[sel,*]) < (-40),max(data[sel,*]) > 80],ystyle=9,/xs,$
           background=255,color=0,xmargin=[4,4],ymargin=[2,2],charsize=1.5,title=title
      axis,yaxis=1,/ys,color=0,charsize=1.5
      for i=0,nsel-1 do begin
         oplot,data[sel[i],*],color=color[i],thick=3
      endfor
      ;;--plot legend
      lsel = indgen(nsel/2) ;;divide into 2 columns
      cbmlegend,items[lsel],lines[lsel],color[lsel],[!x.window[0],!y.window[1]],charthick=1,thick=3,corners=corners
      lsel = indgen(nsel - nsel/2) + nsel/2
      cbmlegend,items[lsel],lines[lsel],color[lsel],[corners[2],!y.window[1]],charthick=1,thick=3
   endfor

   ;;Get window and display
   snap = TVRD(/true)
   wdelete,1
   wset,0
   tv,snap,/true
   loadct,0

   ;;Print data
   help,data
   wait,1
endwhile




end
