pro livepsd_event, ev
  common event_block, zlyt1, zlyt2, zshk1, zshk2, ids, twin, start, type, xlog
  if n_elements(zlyt1) eq 0 then begin
     zlyt1 = 0
     zlyt2 = 1
     zshk1 = 0
     zshk2 = 1
     twin  = 10 ;;seconds
     type  = 0  ;;0:PSD, 1:TIME
     xlog  = 1
     start = systime(/seconds)
     widget_control,ev.top,get_uvalue=ids
  endif

  ;;Get dropdown zernike indices
  if ev.id eq ids.lyt1 then zlyt1 = ev.index
  if ev.id eq ids.lyt2 then zlyt2 = ev.index
  if ev.id eq ids.shk1 then zshk1 = ev.index
  if ev.id eq ids.shk2 then zshk2 = ev.index

  ;;Number of packets to plot
  if ev.id eq ids.twin then begin
     widget_control,ev.id,get_value=temp
     twin = long(temp[0])
  endif

  ;;Reset button
  if ev.id eq ids.rest then begin
     print,'reset'
     start = systime(/seconds)
  endif

  ;;Exit button
  if ev.id eq ids.exit then begin
     print,'Exiting'
     widget_control,ev.top,/destroy
     return
  endif
  
  ;;PSD/Time toggle button
  if ev.id eq ids.togg then begin
     if type eq 0 then type=1 else type=0
     return
  endif
  
  ;;XLOG/LIN toggle
  if ev.id eq ids.xlog then begin
     if xlog eq 0 then xlog=1 else xlog=0
     return
  endif
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;Plotting Code
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;Settings
  logbin  = 0.01
  window  = 'hanning'
  renormalize = 1
  detrend = 1
  wpix=5
  charsize=1.5
  !EXCEPT = 0 ;;do not print math errors
  ttyr = [1e-8,2e6]
  ozyr = [1e-12,2e2]

  ;;Symbols
  sym_sq  = '!E2!N'
  sym_sig = greek('sigma')+'!N'
  
  ;;Plot positions
  xbuf = 0.03
  ybuf = 0.045
  xoff = 0.02
  yoff = 0.005
  shk1pos = [0.0,0.5,0.5,1.0]+[xbuf,ybuf,-xbuf,-ybuf]+[xoff,yoff,xoff,yoff]
  shk2pos = [0.0,0.0,0.5,0.5]+[xbuf,ybuf,-xbuf,-ybuf]+[xoff,yoff,xoff,yoff]
  lyt1pos = [0.5,0.5,1.0,1.0]+[xbuf,ybuf,-xbuf,-ybuf]+[xoff,yoff,xoff,yoff]
  lyt2pos = [0.5,0.0,1.0,0.5]+[xbuf,ybuf,-xbuf,-ybuf]+[xoff,yoff,xoff,yoff]

  ;;Get folder
  folders = file_search('data/piccgse/piccgse*',count=nfolders)
  if nfolders gt 1 then path = folders[-1] else stop,'No piccgse data'
  widget_control,ids.path,set_value=strmid(path,13)
  
  ;;Get files
  shkfiles = file_search(path+'/*shkpkt*.idl',count=nshkfiles)
  lytfiles = file_search(path+'/*lytpkt*.idl',count=nlytfiles)

  ;;Do start time cut
  sel = where(file_modtime(shkfiles) gt start,nshkfiles)
  if nshkfiles gt 0 then shkfiles = shkfiles[sel]
  sel = where(file_modtime(lytfiles) gt start,nlytfiles)
  if nlytfiles gt 0 then lytfiles = lytfiles[sel]
    
  ;;Set widow
  wset,ids.wdraw

  ;;Create pixmap window
  window,wpix,/pixmap,xsize=!D.X_SIZE,ysize=!D.Y_SIZE
  wset,wpix
  !P.MULTI=[0,2,2]
  linecolor

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;SHK Plots
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if nshkfiles gt 0 then begin
     trim_last = 0
     last = 0
     for i=0,nshkfiles-1 do begin
        restore,shkfiles[-(i+1)] ;;start with newest, move backwards
        m1 = reform(double(pkt.zernike_measured[zshk1,0:pkt.nsamples-1])*1000)
        m2 = reform(double(pkt.zernike_measured[zshk2,0:pkt.nsamples-1])*1000)
        c1 = reform(double(pkt.alp_zcmd[zshk1,0:pkt.nsamples-1])*1000)
        c2 = reform(double(pkt.alp_zcmd[zshk2,0:pkt.nsamples-1])*1000)
        t1 = (double(pkt.zernike_target[zshk1])*1000)[0] + dblarr(n_elements(m1))
        t2 = (double(pkt.zernike_target[zshk2])*1000)[0] + dblarr(n_elements(m2))
        if i eq 0 then begin
           mes1 = m1
           mes2 = m2
           cmd1 = c1
           cmd2 = c2
           tar1 = t1
           tar2 = t2
           frmtime = hed.frmtime
           tottime = frmtime * n_elements(mes1)
           state   = hed.state
        endif else begin
           ;;Check frame time 
           if (hed.frmtime ne frmtime) then begin
              trim_last = 1
              break
           endif
           ;;Concatinate data, put this file before last
           mes1 = [m1,mes1]
           mes2 = [m2,mes2]
           cmd1 = [c1,cmd1]
           cmd2 = [c2,cmd2]
           tar1 = [t1,tar1]
           tar2 = [t2,tar2]
           last = n_elements(m1)
           ;;Check total time, break if we've collected enough data
           tottime = frmtime * n_elements(mes1)
           if tottime gt twin then break
        endelse
     endfor

     ;;Select data
     npts = n_elements(mes1) < round(twin/frmtime)
     mes1 = mes1[-npts:*]
     mes2 = mes2[-npts:*]
     cmd1 = cmd1[-npts:*]
     cmd2 = cmd2[-npts:*]
     tar1 = tar1[-npts:*]
     tar2 = tar2[-npts:*]
     
     ;;Trim last packet of data to remove mid packet state changes
     if trim_last then begin
        mes1 = mes1[last:*]
        mes2 = mes2[last:*]
        cmd1 = cmd1[last:*]
        cmd2 = cmd2[last:*]
        tar1 = tar1[last:*]
        tar2 = tar2[last:*]
        npts = n_elements(mes1)
     endif
     time = dindgen(n_elements(mes1))*frmtime

     ;;Calculate total time
     total_time = npts * frmtime
     period     = double(frmtime)
     rate       = round(1/period)

     ;;Offset commands to match measured
     cmd1 -= mean(cmd1) - mean(mes1)
     cmd2 -= mean(cmd2) - mean(mes2)

     ;;PSD Plots
     if type eq 0 then begin
        ;;Calc PSD
        mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        
        ;;Plot PSDs
        if zshk1 le 1 then psdyr = ttyr else psdyr = ozyr
        psdxr = [mes1_freq[1],mes1_freq[-1]] 
        
        plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,xlog=xlog,/ylog,position=shk1pos,$
             title='SHK Z['+n2s(zshk1)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz',$
             xtitle='Frequency [Hz]',ytitle='Z['+n2s(zshk1)+'] PSD [nm'+sym_sq+'/Hz]',charsize=charsize
        oplot,cmd1_freq,cmd1_psd,color=3
        oplot,mes1_freq,mes1_int,linestyle=3
        
        if zshk2 le 1 then psdyr = ttyr else psdyr = ozyr
        psdxr = [mes2_freq[1],mes2_freq[-1]] 
        plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,xlog=xlog,/ylog,position=shk2pos,$
             title='SHK Z['+n2s(zshk2)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz',$
             xtitle='Frequency [Hz]',ytitle='Z['+n2s(zshk2)+'] PSD [nm'+sym_sq+'/Hz]',charsize=charsize
        oplot,cmd2_freq,cmd2_psd,color=3
        oplot,mes2_freq,mes2_int,linestyle=3
     endif else begin
        ;;Time series plots
        plot,time,mes1,/xs,/ys,position=shk1pos,xtitle='Time [s]',ytitle='Z['+n2s(zshk1)+'] nm',charsize=charsize,$
             title='SHK Z['+n2s(zshk1)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        oplot,time,cmd1,color=3
        oplot,time,tar1,color=1
        plot,time,mes2,/xs,/ys,position=shk2pos,xtitle='Time [s]',ytitle='Z['+n2s(zshk2)+'] nm',charsize=charsize,$
             title='SHK Z['+n2s(zshk2)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        oplot,time,cmd2,color=3
        oplot,time,tar2,color=1
     endelse
  endif else print,'Waiting for SHK files...'
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;LYT Plots
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if nlytfiles gt 0 then begin
     trim_last = 0
     last = 0
     for i=0,nlytfiles-1 do begin
        restore,lytfiles[-(i+1)] ;;start with newest, move backwards
        m1 = reform(double(pkt.zernike_measured[zlyt1,0:pkt.nsamples-1])*1000)
        m2 = reform(double(pkt.zernike_measured[zlyt2,0:pkt.nsamples-1])*1000)
        c1 = reform(double(pkt.alp_zcmd[zlyt1,0:pkt.nsamples-1])*1000)
        c2 = reform(double(pkt.alp_zcmd[zlyt2,0:pkt.nsamples-1])*1000)
        t1 = (double(pkt.zernike_target[zshk1])*1000)[0] + dblarr(n_elements(m1))
        t2 = (double(pkt.zernike_target[zshk2])*1000)[0] + dblarr(n_elements(m2))
        if i eq 0 then begin
           mes1 = m1
           mes2 = m2
           cmd1 = c1
           cmd2 = c2
           tar1 = t1
           tar2 = t2
           frmtime = hed.frmtime
           tottime = frmtime * n_elements(mes1)
           state   = hed.state
        endif else begin
           ;;Check frame time
           if (hed.frmtime ne frmtime) then begin
              trim_last = 1
              break
           endif
           ;;Concatinate data, put this file before last
           mes1 = [m1,mes1]
           mes2 = [m2,mes2]
           cmd1 = [c1,cmd1]
           cmd2 = [c2,cmd2]
           tar1 = [t1,tar1]
           tar2 = [t2,tar2]
           last = n_elements(m1)
           ;;Check total time, break if we've collected enough data
           tottime = frmtime * n_elements(mes1)
           if tottime gt twin then break
        endelse
     endfor

     ;;Select data
     npts = n_elements(mes1) < round(twin/frmtime)
     mes1 = mes1[-npts:*]
     mes2 = mes2[-npts:*]
     cmd1 = cmd1[-npts:*]
     cmd2 = cmd2[-npts:*]
     tar1 = tar1[-npts:*]
     tar2 = tar2[-npts:*]

     ;;Trim last packet of data to remove mid packet state changes
     if trim_last then begin
        mes1 = mes1[last:*]
        mes2 = mes2[last:*]
        cmd1 = cmd1[last:*]
        cmd2 = cmd2[last:*]
        tar1 = tar1[last:*]
        tar2 = tar2[last:*]
        npts = n_elements(mes1)
     endif
     time = dindgen(n_elements(mes1))*frmtime

     ;;Calculate total time
     total_time = npts * frmtime
     period     = double(frmtime)
     rate       = round(1/period)

     ;;Offset commands to match measured
     cmd1 -= mean(cmd1) - mean(mes1)
     cmd2 -= mean(cmd2) - mean(mes2)

     ;;PSD Plots
     if type eq 0 then begin
        ;;Calc PSD
        mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize

        ;;Plot PSDs
        if zlyt1 le 1 then psdyr = ttyr else psdyr = ozyr
        psdxr = [mes1_freq[1],mes1_freq[-1]] 
        
        plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,xlog=xlog,/ylog,position=lyt1pos,$
             title='LYT Z['+n2s(zlyt1)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz',$
             xtitle='Frequency [Hz]',ytitle='Z['+n2s(zlyt1)+'] PSD [nm'+sym_sq+'/Hz]',charsize=charsize
        oplot,cmd1_freq,cmd1_psd,color=3
        oplot,mes1_freq,mes1_int,linestyle=3
        
        if zlyt2 le 1 then psdyr = ttyr else psdyr = ozyr
        psdxr = [mes2_freq[1],mes2_freq[-1]] 
        plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr,/xs,/ys,xlog=xlog,/ylog,position=lyt2pos,$
             title='LYT Z['+n2s(zlyt2)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz',$
             xtitle='Frequency [Hz]',ytitle='Z['+n2s(zlyt2)+'] PSD [nm'+sym_sq+'/Hz]',charsize=charsize
        oplot,cmd2_freq,cmd2_psd,color=3
        oplot,mes2_freq,mes2_int,linestyle=3
     endif else begin
        ;;Time series plots
        plot,time,mes1,/xs,/ys,position=lyt1pos,xtitle='Time [s]',ytitle='Z['+n2s(zlyt1)+'] nm',charsize=charsize,$
             title='LYT Z['+n2s(zlyt1)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        oplot,time,cmd1,color=3
        oplot,time,tar1,color=1
        plot,time,mes2,/xs,/ys,position=lyt2pos,xtitle='Time [s]',ytitle='Z['+n2s(zlyt2)+'] nm',charsize=charsize,$
             title='LYT Z['+n2s(zlyt2)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        oplot,time,cmd2,color=3
        oplot,time,tar2,color=1
     endelse
  endif else print,'Waiting for LYT files...'



  
  ;;Take snapshot
  snap = TVRD(true=1)
  ;;Delete pixmap window
  wdelete,wpix
  ;;Switch back to real window
  wset,ids.wdraw
  ;;Display image
  tv,snap,true=1
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
  shk1 = widget_droplist(brow,value=zernikes,title='SHK1:')
  shk2 = widget_droplist(brow,value=zernikes,title='SHK2:')
  lyt1 = widget_droplist(brow,value=zernikes,title='LYT1:')
  lyt2 = widget_droplist(brow,value=zernikes,title='LYT2:')
  path = widget_text(brow,xsize=22,ysize=1)
  rest = widget_button(brow,value='Reset')
  exit = widget_button(brow,value='Exit')
  togg = widget_button(brow,value='PSD/Time')
  xlog = widget_button(brow,value='X-Scale')
  lwin = widget_label(brow,value='Time Window:')
  twin = widget_text(brow,xsize=10,ysize=1,/editable)
  draw = widget_draw(base,xsize=ss[0]-6,ysize=ss[1]-bsize)
  widget_control,base,/realize,timer=0
  widget_control,draw,get_value=wdraw
  ids = {lyt1:lyt1,lyt2:lyt2,shk1:shk1,shk2:shk2,path:path,rest:rest,exit:exit,draw:draw,wdraw:wdraw,twin:twin,togg:togg,xlog:xlog}
  widget_control,base,set_uvalue=ids
  xmanager,'livepsd',base,/no_block
end
