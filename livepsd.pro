pro livepsd_event, ev
  common event_block, zlyt1, zlyt2, zshk1, zshk2, ids
  if n_elements(zlyt1) eq 0 then begin
     zlyt1 = 0
     zlyt2 = 1
     zshk1 = 0
     zshk2 = 1
     widget_control,ev.top,get_uvalue=ids
  endif

  ;;Get dropdown zernike indices
  if ev.id eq ids.lyt1 then zlyt1 = ev.index
  if ev.id eq ids.lyt2 then zlyt2 = ev.index
  if ev.id eq ids.shk1 then zshk1 = ev.index
  if ev.id eq ids.shk2 then zshk2 = ev.index

  ;;Reset button
  if ev.id eq ids.rest then print,'reset'

  ;;Exit button
  if ev.id eq ids.exit then begin
     print,'Exiting'
     widget_control,ev.top,/destroy
     return
  endif
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;Plotting Code
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;Settings
  nplot = 30
  logbin  = 0.01
  window  = 'hanning'
  renormalize = 1
  detrend = 1
  wpix=5
  
  ;;Symbols
  sym_sq  = '!E2!N'
  sym_sig = greek('sigma')+'!N'
  
  ;;Get folder
  folders = file_search('data/piccgse/piccgse*',count=nfolders)
  if nfolders gt 1 then path = folders[-1] else stop,'No piccgse data'
  widget_control,ids.path,set_value=strmid(path,13)
  
  ;;Get files
  shkfiles = file_search(path+'/*shkpkt*.idl',count=nshkfiles)
  lytfiles = file_search(path+'/*lytpkt*.idl',count=nlytfiles)

  ;;Set widow
  wset,ids.wdraw

  ;;Create pixmap window
  window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
  wset,wpix
  !P.MULTI=[0,2,2]

  ;;Plot positions
  xbuf = 0.02
  ybuf = 0.05
  shk1pos = [0.0,0.5,0.5,1.0]+[xbuf,ybuf,-xbuf,-ybuf]
  shk2pos = [0.0,0.0,0.5,0.5]+[xbuf,ybuf,-xbuf,-ybuf]
  lyt1pos = [0.5,0.5,1.0,1.0]+[xbuf,ybuf,-xbuf,-ybuf]
  lyt2pos = [0.5,0.0,1.0,0.5]+[xbuf,ybuf,-xbuf,-ybuf]
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;SHK Plots
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if nshkfiles gt 0 then begin
     first = (nshkfiles - nplot) > 0
     files = shkfiles[first:*]
     for i=0,n_elements(files)-1 do begin
        restore,files[i]
        m1 = double(pkt.zernike_measured[zshk1,0:pkt.nsamples-1])*1000
        m2 = double(pkt.zernike_measured[zshk2,0:pkt.nsamples-1])*1000
        c1 = m1*0
        c2 = m2*0
        if i eq 0 then begin
           mes1 = m1
           mes2 = m2
           cmd1 = c1
           cmd2 = c2
        endif else begin
           mes1 = [mes1,m1]
           mes2 = [mes2,m2]
           cmd1 = [cmd1,c1]
           cmd2 = [cmd2,c2]
        endelse
     endfor

     ;;Calc PSD
     period = hed.frmtime
     mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize

     ;;Plot PSDs
     if zshk1 le 1 then psdyr = [1e-6,2e8] else psdyr = [1e-12,2e2]
     psdxr = [mes1_freq[1],mes1_freq[-1]] 
     plot,indgen(100),position=shk1pos,title='shk1'
     ;;plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,/xlog,/ylog,position=[0.0,0.5,0.5,1.0],$
     ;;     title='SHK Z['+n2s(zshk1)+'] RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm',$
     ;;     xtitle='Frequency [Hz]',ytitle='Z['+n2s(zshk1)+'] PSD [nm'+sym_sq+'/Hz]'
     ;;oplot,cmd1_freq,cmd1_psd
     
     if zshk2 le 1 then psdyr = [1e-6,2e8] else psdyr = [1e-12,2e2]
     psdxr = [mes2_freq[1],mes2_freq[-1]] 
     plot,indgen(100),shk2pos,title='shk2'
     ;;plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,/xlog,/ylog,position=[0.0,0.0,0.5,0.5],$
     ;;     title='SHK Z['+n2s(zshk2)+'] RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm',$
     ;;     xtitle='Frequency [Hz]',ytitle='Z['+n2s(zshk2)+'] PSD [nm'+sym_sq+'/Hz]'
     ;;oplot,cmd2_freq,cmd2_psd
     
  endif
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;LYT Plots
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if nlytfiles gt 0 then begin
     first = (nlytfiles - nplot) > 0
     files = lytfiles[first:*]
     for i=0,n_elements(files)-1 do begin
        restore,files[i]
        m1 = double(pkt.zernike_measured[zlyt1,0:pkt.nsamples-1])*1000
        m2 = double(pkt.zernike_measured[zlyt2,0:pkt.nsamples-1])*1000
        c1 = m1*0
        c2 = m2*0
        if i eq 0 then begin
           mes1 = m1
           mes2 = m2
           cmd1 = c1
           cmd2 = c2
        endif else begin
           mes1 = [mes1,m1]
           mes2 = [mes2,m2]
           cmd1 = [cmd1,c1]
           cmd2 = [cmd2,c2]
        endelse
     endfor

     ;;Calc PSD
     period = hed.frmtime
     mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
     mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize

     ;;Plot PSDs
     if zlyt1 le 1 then psdyr = [1e-6,2e8] else psdyr = [1e-12,2e2]
     psdxr = [mes1_freq[1],mes1_freq[-1]]
     plot,indgen(100),position=lyt1pos,title='lyt1'
     ;;plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,/xlog,/ylog,position=[0.5,0.5,0.5,1.0],$
     ;;     title='LYT Z['+n2s(zlyt1)+'] RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm',$
     ;;     xtitle='Frequency [Hz]',ytitle='Z['+n2s(zlyt1)+'] PSD [nm'+sym_sq+'/Hz]'
     ;;oplot,cmd1_freq,cmd1_psd
     
     if zlyt2 le 1 then psdyr = [1e-6,2e8] else psdyr = [1e-12,2e2]
     psdxr = [mes2_freq[1],mes2_freq[-1]] 
     plot,indgen(100),position=lyt2pos,title='lyt2'
     ;;plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,/xlog,/ylog,position=[0.5,0.0,0.5,0.5],$
     ;;     title='LYT Z['+n2s(zlyt2)+'] RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm',$
     ;;     xtitle='Frequency [Hz]',ytitle='Z['+n2s(zlyt2)+'] PSD [nm'+sym_sq+'/Hz]'
     ;;oplot,cmd2_freq,cmd2_psd
     
  endif
  
  ;;Take snapshot
  snap = TVRD()
  ;;Delete pixmap window
  wdelete,wpix
  ;;Switch back to real window
  wset,ids.wdraw
  ;;Set color table
  linecolor
  ;;Display image
  tv,snap
  loadct,0
  !P.MULTI=0
  
  ;;Re-trigger on timer
  widget_control,ev.top,timer=1
end

pro livepsd
  ss = get_screen_size()
  bsize = 76
  zernikes = 'Z'+n2s(indgen(23))

  ;;Fullscreen widget
  base = widget_base(title='PICTURE-C LIVE PSD',xsize=ss[0],ysize=ss[1],/column)
  brow = widget_base(base,/row)
  lyt1 = widget_droplist(brow,value=zernikes,title='LYT1:')
  lyt2 = widget_droplist(brow,value=zernikes,title='LYT2:')
  shk1 = widget_droplist(brow,value=zernikes,title='SHK1:')
  shk2 = widget_droplist(brow,value=zernikes,title='SHK2:')
  path = widget_text(brow,xsize=22,ysize=1)
  rest = widget_button(brow,value='Reset')
  exit = widget_button(brow,value='Exit')
  draw = widget_draw(base,xsize=ss[0]-6,ysize=ss[1]-bsize)
  widget_control,base,/realize,timer=0
  widget_control,draw,get_value=wdraw
  ids = {lyt1:lyt1,lyt2:lyt2,shk1:shk1,shk2:shk2,path:path,rest:rest,exit:exit,draw:draw,wdraw:wdraw}
  widget_control,base,set_uvalue=ids
  xmanager,'livepsd',base,/no_block
end
