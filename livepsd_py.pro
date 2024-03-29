pro livepsd_event, ev
  common event_block, zlyt1, zlyt2, zshk1, zshk2, ids, twin, start, type, xlog, zreq_freq, zreq_psd, wreq_freq, wreq_psd

  ;;Zernike surface tilt to sky arcsec conversion
  ;;Telescope tilts 1", DM tilts half this amount to compensate
  ;;1" DM == 2" sky (divided by beam expansion)
  ;;         RAD->AS    RMS->PEAK   PEAK->PV   REFLECTION   BEAM DIAMETER IN NM
  zern2as  = 206265d * (2d        * 2d       * 2d         / 0.5969e9) 
  as2zern  = 1d / zern2as

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

     ;;Zernike surface tilt to sky arcsec conversion
     ;;Telescope tilts 1", DM tilts half this amount to compensate
     ;;1" DM == 2" sky (divided by beam expansion)
     ;;         RAD->AS    RMS->PEAK   PEAK->PV   REFLECTION   BEAM DIAMETER IN NM
     zern2as  = 206265d * (2d        * 2d       * 2d         / 0.5969e9) 
     as2zern  = 1d / zern2as

     ;;Generate pointing Requirement
     dt     = 0.002
     tt     = 600.0
     n      = round(tt/dt)
     if n mod 2 then n++
     df     = 1./(n*dt)
     k      = dindgen(n/2)*df
     reqt   = dindgen(n)*dt
     reqdt  = dt
     ;;--psd parameters
     a = 0.35   ;;Amplitude
     b = 0.08   ;;1st knee frequency
     c = 1.4    ;;1st power law
     d = 4.0    ;;1st power law rolloff parameter
     e = 2.9    ;;2nd knee frequency
     f = 5.0    ;;2nd power law
     g = 6.0    ;;2nd power law rolloff parameter
     wreq_psd = a * (1./(1. + (k/b)^d)^(c/d)) * (1./(1. + (k/e)^g)^(f/g))
     ;;--add spectral features [amp,freq,sigma,offset]
     wreq_psd *= gaussian(k,[35,0.134,0.007,1])
     wreq_freq = k
     ;;--remove DC component
     wreq_psd[0]=0 
     ;;--integrate
     wreq_int = total(wreq_psd*df,/cumulative)
     wreq_rms = sqrt(max(wreq_int))
     zreq_freq = wreq_freq
     zreq_psd  = wreq_psd * as2zern * as2zern
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
  ttyr = [1e-8,2e6]  ;;z0,z1 yrange
  ozyr = [1e-12,2e2] ;;z>1 yrange
  pyyr = [1e-12,1e3] ;;pitch,yaw yrange
  ipch = 23
  iyaw = 24
  zpch = 1
  zyaw = 0

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
     ;;Recast zernike indices
     zshk1r = zshk1
     zshk2r = zshk2
     if zshk1r eq ipch then zshk1r = zpch
     if zshk1r eq iyaw then zshk1r = zyaw
     if zshk2r eq ipch then zshk2r = zpch
     if zshk2r eq iyaw then zshk2r = zyaw
     plot_zreq1 = 0
     plot_wreq1 = 0
     plot_zreq2 = 0
     plot_wreq2 = 0
     psdyr1 = ozyr
     psdyr2 = ozyr
     timyr1 = 500
     timyr2 = 500
     if zshk1 le 1 then begin
        plot_zreq1 = 1
        psdyr1 = ttyr
     endif
     if zshk2 le 1 then begin
        plot_zreq2 = 1
        psdyr2 = ttyr
     endif
     if zshk1 ge 23 then begin
        plot_wreq1 = 1
        psdyr1 = pyyr
        timyr1 = 1
     endif
     if zshk2 ge 23 then begin
        plot_wreq2 = 1
        psdyr2 = pyyr
        timyr2 = 1
     endif
     
     ;;Convert to pitch & yaw
     if (zshk1 eq ipch) OR (zshk1 eq iyaw) then scale = zern2as else scale = 1
     if (zshk2 eq ipch) OR (zshk2 eq iyaw) then scale = zern2as else scale = 1
     for i=0,nshkfiles-1 do begin
        restore,shkfiles[-(i+1)] ;;start with newest, move backwards
        m1 = reform(double(pkt.zernike_measured[zshk1,0:pkt.nsamples-1])*1000) * scale
        m2 = reform(double(pkt.zernike_measured[zshk2,0:pkt.nsamples-1])*1000) * scale
        c1 = reform(double(pkt.alp_zcmd[zshk1,0:pkt.nsamples-1])*1000) * scale
        c2 = reform(double(pkt.alp_zcmd[zshk2,0:pkt.nsamples-1])*1000) * scale
        t1 = (double(pkt.zernike_target[zshk1])*1000)[0] + dblarr(n_elements(m1)) * scale
        t2 = (double(pkt.zernike_target[zshk2])*1000)[0] + dblarr(n_elements(m2)) * scale
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
        ;;Setup plot titles
        title1  = 'SHK Z['+n2s(zshk1r)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle1 = 'Frequency [Hz]'
        ytitle1 = 'Z['+n2s(zshk1r)+'] PSD [nm'+sym_sq+'/Hz]'
        if zshk1 eq ipch then begin
           title1  = 'SHK Pitch | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Pitch PSD [as'+sym_sq+'/Hz]'
        endif
        if zshk1 eq iyaw then begin
           title1  = 'SHK Yaw | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Yaw PSD [as'+sym_sq+'/Hz]'
        endif
        title2  = 'SHK Z['+n2s(zshk2r)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle2 = 'Frequency [Hz]'
        ytitle2 = 'Z['+n2s(zshk2r)+'] PSD [nm'+sym_sq+'/Hz]'
        if zshk2 eq ipch then begin
           title2  = 'SHK Pitch | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Pitch PSD [as'+sym_sq+'/Hz]'
        endif
        if zshk2 eq iyaw then begin
           title2  = 'SHK Yaw | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Yaw PSD [as'+sym_sq+'/Hz]'
        endif
        
        ;;Calc PSD
        mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize

        ;;Plot PSDs
        psdxr = [mes1_freq[1],mes1_freq[-1]] 
        plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr1,/xs,/ys,xlog=xlog,/ylog,position=shk1pos,title=title1,xtitle=xtitle1,ytitle=ytitle1,charsize=charsize
        oplot,cmd1_freq,cmd1_psd,color=3
        oplot,mes1_freq,mes1_int,linestyle=3
        if plot_zreq1 then oplot,zreq_freq,zreq_psd,color=2
        if plot_wreq1 then oplot,wreq_freq,wreq_psd,color=2

        psdxr = [mes2_freq[1],mes2_freq[-1]] 
        plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr2,/xs,/ys,xlog=xlog,/ylog,position=shk2pos,title=title2,xtitle=xtitle2,ytitle=ytitle2,charsize=charsize
        oplot,cmd2_freq,cmd2_psd,color=3
        oplot,mes2_freq,mes2_int,linestyle=3
        if plot_zreq2 then oplot,zreq_freq,zreq_psd,color=2
        if plot_wreq2 then oplot,wreq_freq,wreq_psd,color=2
        
     endif else begin
        ;;Time series plots
        ;;Setup plot titles
        title1  = 'SHK Z['+n2s(zshk1r)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle1 = 'Time [s]'
        ytitle1 = 'Z['+n2s(zshk1r)+'] nm'
        if zshk1 eq ipch then begin
           title1  = 'SHK Pitch | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Pitch [as]'
        endif
        if zshk1 eq iyaw then begin
           title1  = 'SHK Yaw | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Yaw [as]'
        endif
        title2  = 'SHK Z['+n2s(zshk2r)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle2 = 'Frequency [Hz]'
        ytitle2 = 'Z['+n2s(zshk2r)+'] nm'
        if zshk2 eq ipch then begin
           title2  = 'SHK Pitch | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Pitch [as]'
        endif
        if zshk2 eq iyaw then begin
           title2  = 'SHK Yaw | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Yaw [as]'
        endif
        
        plot,time,mes1,/xs,/ys,position=shk1pos,xtitle=xtitle1,ytitle=ytitle1,title=title1,yrange=[tar1[0]-timyr1,tar1[0]+timyr1]
        oplot,time,cmd1,color=3
        oplot,time,tar1,color=1
        plot,time,mes2,/xs,/ys,position=shk2pos,xtitle=xtitle2,ytitle=ytitle2,title=title2,yrange=[tar2[0]-timyr2,tar2[0]+timyr2]
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
     ;;Recast zernike indices
     zlyt1r = zlyt1
     zlyt2r = zlyt2
     if zlyt1r eq ipch then zlyt1r = zpch
     if zlyt1r eq iyaw then zlyt1r = zyaw
     if zlyt2r eq ipch then zlyt2r = zpch
     if zlyt2r eq iyaw then zlyt2r = zyaw
     plot_zreq1 = 0
     plot_wreq1 = 0
     plot_zreq2 = 0
     plot_wreq2 = 0
     psdyr1     = ozyr
     timyr1 = 20
     timyr2 = 20
     if zlyt1 le 1 then begin
        plot_zreq1 = 1
        psdyr1 = ttyr
     endif
     if zlyt2 le 1 then begin
        plot_zreq2 = 1
        psdyr2 = ttyr
     endif
     if zlyt1 ge 23 then begin
        plot_wreq1 = 1
        psdyr1 = pyyr
        timyr1 = 1
     endif
     if zlyt2 ge 23 then begin
        plot_wreq2 = 1
        psdyr2 = pyyr
        timyr2 = 1
     endif
     ;;Convert to pitch & yaw
     if (zlyt1 eq ipch) OR (zlyt1 eq iyaw) then scale = zern2as else scale = 1
     if (zlyt2 eq ipch) OR (zlyt2 eq iyaw) then scale = zern2as else scale = 1

      for i=0,nlytfiles-1 do begin
        restore,lytfiles[-(i+1)] ;;start with newest, move backwards
        m1 = reform(double(pkt.zernike_measured[zlyt1r,0:pkt.nsamples-1])*1000) * scale
        m2 = reform(double(pkt.zernike_measured[zlyt2r,0:pkt.nsamples-1])*1000) * scale
        c1 = reform(double(pkt.alp_zcmd[zlyt1r,0:pkt.nsamples-1])*1000) * scale
        c2 = reform(double(pkt.alp_zcmd[zlyt2r,0:pkt.nsamples-1])*1000) * scale
        t1 = (double(pkt.zernike_target[zlyt1r])*1000)[0] + dblarr(n_elements(m1)) * scale
        t2 = (double(pkt.zernike_target[zlyt2r])*1000)[0] + dblarr(n_elements(m2)) * scale
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
        ;;Setup plot titles
        title1  = 'LYT Z['+n2s(zlyt1r)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle1 = 'Frequency [Hz]'
        ytitle1 = 'Z['+n2s(zlyt1r)+'] PSD [nm'+sym_sq+'/Hz]'
        if zlyt1 eq ipch then begin
           title1  = 'LYT Pitch | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Pitch PSD [as'+sym_sq+'/Hz]'
        endif
        if zlyt1 eq iyaw then begin
           title1  = 'LYT Yaw | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Yaw PSD [as'+sym_sq+'/Hz]'
        endif
        title2  = 'LYT Z['+n2s(zlyt2r)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle2 = 'Frequency [Hz]'
        ytitle2 = 'Z['+n2s(zlyt2r)+'] PSD [nm'+sym_sq+'/Hz]'
        if zlyt2 eq ipch then begin
           title2  = 'LYT Pitch | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Pitch PSD [as'+sym_sq+'/Hz]'
        endif
        if zlyt2 eq iyaw then begin
           title2  = 'LYT Yaw | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Yaw PSD [as'+sym_sq+'/Hz]'
        endif
        
        ;;Calc PSD
        mkpsd,mes1,mes1_freq,mes1_psd,mes1_int,mes1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,mes2,mes2_freq,mes2_psd,mes2_int,mes2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd1,cmd1_freq,cmd1_psd,cmd1_int,cmd1_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize
        mkpsd,cmd2,cmd2_freq,cmd2_psd,cmd2_int,cmd2_df,period=period,detrend=detrend,logbin=logbin,window=window,renormalize=renormalize

        ;;Plot PSDs
        psdxr = [mes1_freq[1],mes1_freq[-1]] 
        plot,mes1_freq,mes1_psd,xrange=psdxr,yrange=psdyr1,/xs,/ys,xlog=xlog,/ylog,position=lyt1pos,title=title1,xtitle=xtitle1,ytitle=ytitle1,charsize=charsize
        oplot,cmd1_freq,cmd1_psd,color=3
        oplot,mes1_freq,mes1_int,linestyle=3
        if plot_zreq1 then oplot,zreq_freq,zreq_psd,color=2
        if plot_wreq1 then oplot,wreq_freq,wreq_psd,color=2

        psdxr = [mes2_freq[1],mes2_freq[-1]] 
        plot,mes2_freq,mes2_psd,xrange=psdxr,yrange=psdyr2,/xs,/ys,xlog=xlog,/ylog,position=lyt2pos,title=title2,xtitle=xtitle2,ytitle=ytitle2,charsize=charsize
        oplot,cmd2_freq,cmd2_psd,color=3
        oplot,mes2_freq,mes2_int,linestyle=3
        if plot_zreq2 then oplot,zreq_freq,zreq_psd,color=2
        if plot_wreq2 then oplot,wreq_freq,wreq_psd,color=2
        
     endif else begin
        ;;Time series plots
        ;;Setup plot titles
        title1  = 'LYT Z['+n2s(zlyt1r)+'] | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle1 = 'Time [s]'
        ytitle1 = 'Z['+n2s(zlyt1r)+'] nm'
        if zlyt1 eq ipch then begin
           title1  = 'LYT Pitch | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Pitch [as]'
        endif
        if zlyt1 eq iyaw then begin
           title1  = 'LYT Yaw | RMS: '+n2s(stdev(mes1),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle1 = 'Yaw [as]'
        endif
        title2  = 'LYT Z['+n2s(zlyt2r)+'] | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' nm | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
        xtitle2 = 'Frequency [Hz]'
        ytitle2 = 'Z['+n2s(zlyt2r)+'] nm'
        if zlyt2 eq ipch then begin
           title2  = 'LYT Pitch | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Pitch [as]'
        endif
        if zlyt2 eq iyaw then begin
           title2  = 'LYT Yaw | RMS: '+n2s(stdev(mes2),format='(F10.2)')+' as | Window: '+n2s(total_time,format='(I)')+' sec | Rate: '+n2s(rate,format='(I)')+' Hz'
           ytitle2 = 'Yaw [as]'
        endif
        
        plot,time,mes1,/xs,/ys,position=lyt1pos,xtitle=xtitle1,ytitle=ytitle1,title=title1,yrange=[tar1[0]-timyr1,tar1[0]+timyr1]
        oplot,time,cmd1,color=3
        oplot,time,tar1,color=1
        plot,time,mes2,/xs,/ys,position=lyt2pos,xtitle=xtitle2,ytitle=ytitle2,title=title2,yrange=[tar2[0]-timyr2,tar2[0]+timyr2]
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

pro livepsd_py
  ss = get_screen_size()
  bsize = 76
  zernikes = ['Z'+n2s(indgen(23)),'Pitch','Yaw']

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
