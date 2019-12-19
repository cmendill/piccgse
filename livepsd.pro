pro livepsd_event, ev
  common event_block, il1, il2, is1, is2, ids
  if n_elements(il1) eq 0 then begin
     il1 = 0
     il2 = 1
     is1 = 0
     is2 = 1
     widget_control,ev.top,get_uvalue=ids
  endif
  
  ;;Get dropdown zernike indices
  if ev.id eq ids.lyt1 then il1 = ev.index
  if ev.id eq ids.lyt2 then il2 = ev.index
  if ev.id eq ids.shk1 then is1 = ev.index
  if ev.id eq ids.shk2 then is2 = ev.index

  ;;Reset button
  if ev.id eq ids.rest then print,'rest'

  ;;Exit button
  if ev.id eq ids.exit then print,'exit'

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
  xmanager,'livepsd',base,/no_block
  ids = {lyt1:lyt1,lyt2:lyt2,shk1:shk1,shk2:shk2,path:path,rest:rest,exit:exit,draw:draw}
  widget_control,base,/realize,timer=0,set_uvalue=ids
end
