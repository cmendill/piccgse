;;button command database
;;buttons appear in the order they are listed

num_cmd = 200
button_s = {button,$
            id:0,$        ;;Unique identifier
            show:0,$      ;;Show button
            type1:'',$    ;;First type
            type2:'',$    ;;Sub type
            name:'',$     ;;Command name
            cmd:'',$      ;;Actual command
            tooltip:'',$  ;;Hover to show this description 
            igse:0,$      ;;For GSE commands, index of GSE control array
            vgse:0}       ;;For GSE commands, value to set at igse

b = replicate({button},num_cmd)
i=0

;;Nuller Flight Commands
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'NULL',cmd:'null',tooltip:'Start nulling',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'ABCD',cmd:'abcd',tooltip:'Jump back to ABCD',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'LOST',cmd:'lost',tooltip:'Go to LOST state',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'Reset State',cmd:'state reset',tooltip:'Reset current state',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'Reset DM',cmd:'reset dm',tooltip:'Reset DM to flat map',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'Reset Mask',cmd:'reset mask',tooltip:'Reset mask',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'ZERO',cmd:'state zero',tooltip:'Set PZTs and DM to 0V',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'IM->DM: Default',cmd:'dmmap 0',tooltip:'Use default IM->DM mapping',igse:0,vgse:0}
b[i++]={id:i,show:0,type1:'nuller_flight',type2:'',name:'Dither: ON',cmd:'dither on',tooltip:'Turn NPZT dither ON',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'DM AutoPiston: ON',cmd:'dmpiston on',tooltip:'Turn DM AutoPiston ON',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'AT Override: ON',cmd:'atover',tooltip:'Turn TRACKING_LOCK override ON',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'NPZT Gain: HIGH',cmd:'pzth',tooltip:'Switch to NPZT high gain',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'BK Sub: ON',cmd:'bksub on',tooltip:'Turn background subtraction ON',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'Fringe Hop: LEFT',cmd:'hop -1',tooltip:'Hop NPZT -1 fringe',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:' ',cmd:'',tooltip:'Placeholder',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'IM->DM: Poked',cmd:'dmmap 1',tooltip:'Use IM->DM mapping from POKED state',igse:0,vgse:0}
b[i++]={id:i,show:0,type1:'nuller_flight',type2:'',name:'Dither: OFF',cmd:'dither off',tooltip:'Turn NPZT dither OFF',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'DM AutoPiston: OFF',cmd:'dmpiston off',tooltip:'Turn DM AutoPiston OFF',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'AT Override: OFF',cmd:'atwait',tooltip:'Turn TRACKING_LOCK override OFF',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'NPZT Gain: LOW',cmd:'pztl',tooltip:'Switch to NPZT low gain',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'BK Sub: OFF',cmd:'bksub off',tooltip:'Turn background subtraction OFF',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:'Fringe Hop: RIGHT',cmd:'hop +1',tooltip:'Hop NPZT +1 fringe',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'',name:' ',cmd:'',tooltip:'Placeholder',igse:0,vgse:0}

;;WFS image position
;;button mapping: ll->down, rr->up, uu->right, dd->left
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'arrow',name:'bmp/left.bmp',cmd:'dd',tooltip:'Move WFS window 1px left',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'arrow',name:'bmp/right.bmp',cmd:'uu',tooltip:'Move WFS window 1px right',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'arrow',name:'bmp/up.bmp',cmd:'rr',tooltip:'Move WFS window 1px up',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'nuller_flight',type2:'arrow',name:'bmp/down.bmp',cmd:'ll',tooltip:'Move WFS window 1px down',igse:0,vgse:0}


;;Camera Flight Commands
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Load SCI',cmd:'load sci',tooltip:'Load SCI camera pattern',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Load WFS',cmd:'load wfs',tooltip:'Load WFS camera pattern',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Start',cmd:'start',tooltip:'Start SCI & WFS exposures',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Stop',cmd:'stop',tooltip:'Stop SCI & WFS exposures',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Restart PIX',cmd:'mpuf com/restartpix.com',tooltip:'Restart CTU pixel server',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Exit',cmd:'exit',tooltip:'Exit JPL watchdog',igse:0,vgse:0}
;b[i++]={id:i,show:1,type1:'camera_flight',type2:'',name:'Quit',cmd:'Quit',tooltip:'Shutdown cameras and exit JPL watchdog',igse:0,vgse:0}



;;FPS Flight Commands
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 1',cmd:'bucmd boxsize 1',tooltip:'Set centroid boxsize = 1',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 2',cmd:'bucmd boxsize 2',tooltip:'Set centroid boxsize = 2',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 3',cmd:'bucmd boxsize 3',tooltip:'Set centroid boxsize = 3',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 5',cmd:'bucmd boxsize 5',tooltip:'Set centroid boxsize = 5',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 10',cmd:'bucmd boxsize 10',tooltip:'Set centroid boxsize = 10',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 15',cmd:'bucmd boxsize 15',tooltip:'Set centroid boxsize = 15',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Box: 20',cmd:'bucmd boxsize 20',tooltip:'Set centroid boxsize = 20',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Target: LEFT',cmd:'target left',tooltip:'Move tracking target 10px left',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 0',cmd:'bucmd gain 0',tooltip:'Switch to FSM gain 0',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 1',cmd:'bucmd gain 1',tooltip:'Switch to FSM gain 1',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 2',cmd:'bucmd gain 2',tooltip:'Switch to FSM gain 2',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 3',cmd:'bucmd gain 3',tooltip:'Switch to FSM gain 3',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 4',cmd:'bucmd gain 4',tooltip:'Switch to FSM gain 4',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Gain: 5',cmd:'bucmd gain 5',tooltip:'Switch to FSM gain 5',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Target: RIGHT',cmd:'target right',tooltip:'Move tracking target 10px right',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'AT Start',cmd:'bucmd start',tooltip:'Start angle tracker camera',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'AT Stop',cmd:'bucmd stop',tooltip:'Stop angle tracker camera',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Faster',cmd:'bucmd faster',tooltip:'Increase AT exposure time by factor of 2',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Slower',cmd:'bucmd slower',tooltip:'Decrease AT exposure time by factor of 2',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'Reset PID',cmd:'bucmd reset pid',tooltip:'Clear PID integrators, set FSM to midrange',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'fps_flight',type2:'',name:'FPS Exit',cmd:'bucmd exit',tooltip:'Kill FPS watchdog, init will restart',igse:0,vgse:0}


;;GSE Commands
b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Exit',cmd:'',tooltip:'Close GSE',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Reset',cmd:'',tooltip:'Reset GSE',igse:2,vgse:1}
b[i++]={id:i,show:1,type1:'gse',type2:'plottype',name:'Image',cmd:'',tooltip:'Display images',igse:1,vgse:0}
b[i++]={id:i,show:1,type1:'gse',type2:'plottype',name:'X-Profile',cmd:'',tooltip:'Display X-Profile',igse:1,vgse:1}
b[i++]={id:i,show:1,type1:'gse',type2:'plottype',name:'Y-Profile',cmd:'',tooltip:'Display Y-Profile',igse:1,vgse:2}
b[i++]={id:i,show:1,type1:'gse',type2:'plottype',name:'I-Histogram',cmd:'',tooltip:'Display intensity histogram',igse:1,vgse:3}

;;Test States
states = getstates()
for s=0,n_elements(states)-1 do begin
   b[i++]={id:i,show:1,type1:'states',type2:'',name:states[s],cmd:'state '+strlowcase(states[s]),tooltip:'Switch to STATE_'+states[s],igse:0,vgse:0}
endfor



;;trim database
buttondb = b[0:i-1]


save,buttondb,filename='buttondef.idl'

end
