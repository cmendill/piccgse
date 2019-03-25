;;button command database
;;buttons appear in the order they are listed
function load_buttondb
  ;;load settings
  restore,'settings.idl'

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

  ;;State commands
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'LOW POW' ,cmd:'state lpw',tooltip:'STATE_LOW_POWER',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'STANDBY' ,cmd:'state stb',tooltip:'STATE_STANDBY',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'ACQUIRE' ,cmd:'state acq',tooltip:'STATE_ACQUIRE_TARGET',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'SPIRAL'  ,cmd:'state sps',tooltip:'STATE_SPIRAL_SEARCH',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'M2 ALIGN',cmd:'state m2a',tooltip:'STATE_M2_ALIGN',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'SHK ZERN',cmd:'state szc',tooltip:'STATE_SHK_ZERN_LOWFC',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'SHK CELL',cmd:'state scc',tooltip:'STATE_SHK_CELL_LOWFC',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'LYT TILT',cmd:'state ltt',tooltip:'STATE_LYT_TT_LOWFC',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'state',type2:'',name:'LYT ZERN',cmd:'state lzc',tooltip:'STATE_LYT_ZERN_LOWFC',igse:0,vgse:0}

  ;;Hexapod commands
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'GO HOME' ,cmd:'hex gohome',tooltip:'Go to hex home position',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'GO DEF' ,cmd:'hex godef',tooltip:'Go to hex default position',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'SPIRAL ON' ,cmd:'hex calmode spiral',tooltip:'Start hex spiral search',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'SPIRAL OFF' ,cmd:'hex calmode none',tooltip:'Stop hex spiral search',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'SPIRAL RST' ,cmd:'acq reset',tooltip:'Reset spiral search',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'STEP +' ,cmd:'hex inc step',tooltip:'Increase hexapod step size',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'STEP -' ,cmd:'hex dec step',tooltip:'Decrease hexapod step size',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'',name:'STEP RST' ,cmd:'hex rst step',tooltip:'Reset hexapod step size',igse:0,vgse:0}

  ;;Door commands
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Open M1' ,cmd:'open door 1',tooltip:'Open M1 door',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Close M1' ,cmd:'close door 1',tooltip:'Close M1 door',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Open M2' ,cmd:'open door 2',tooltip:'Open M2 door',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Close M2' ,cmd:'close door 2',tooltip:'Close M2 door',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Open INST' ,cmd:'open door 3',tooltip:'Open instrument door',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'door',type2:'',name:'Close INST' ,cmd:'close door 3',tooltip:'Close instrument door',igse:0,vgse:0}
 
  ;;HEX tilt commands
  b[i++]={id:i,show:1,type1:'hex',type2:'arrow',name:'bmp/left.bmp',cmd:'hex move -v',tooltip:'Move spot left on ACQ',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'arrow',name:'bmp/right.bmp',cmd:'hex move +v',tooltip:'Move spot right on ACQ',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'arrow',name:'bmp/up.bmp',cmd:'hex move +u',tooltip:'Move spot up on ACQ',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'arrow',name:'bmp/down.bmp',cmd:'hex move -u',tooltip:'Move spot down on ACQ',igse:0,vgse:0}

  ;;HEX Z commands
  b[i++]={id:i,show:1,type1:'hex',type2:'z',name:'+Z',cmd:'hex move +Z',tooltip:'Move HEX +Z',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'hex',type2:'z',name:'-Z',cmd:'hex move -Z',tooltip:'Move HEX -Z',igse:0,vgse:0}

  ;;Camera commands
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SHK +',cmd:'shk frmtime +',tooltip:'Increase SHK frame time',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SHK -',cmd:'shk frmtime -',tooltip:'Decrease SHK frame time',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'LYT +',cmd:'lyt frmtime +',tooltip:'Increase LYT frame time',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'LYT -',cmd:'lyt frmtime -',tooltip:'Increase LYT frame time',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SCI +',cmd:'sci exptime +',tooltip:'Increase SCI exposure time',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SCI -',cmd:'sci exptime -',tooltip:'Decrease SCI exposure time',igse:0,vgse:0}

  ;;Other commands
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'LED ON',cmd:'led on 2.8',tooltip:'Turn LED on',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'LED OFF',cmd:'led off',tooltip:'Turn LED off',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'ALP FLAT',cmd:'alp load flat',tooltip:'Reload ALP flat',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'ALP +TILT',cmd:'shk target 0 1',tooltip:'Set SHK Z0 target to 1 micron',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'ALP -TILT',cmd:'shk target 0 0',tooltip:'Set SHK Z0 target to 0',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'SCI SET',cmd:'sci set origin',tooltip:'Set SCI image origins',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'SCI FIND',cmd:'sci find origin',tooltip:'Find SCI image origins',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'SCI LOAD',cmd:'sci load origin',tooltip:'Load SCI image origins',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'other',type2:'',name:'SCI REVERT',cmd:'sci revert origin',tooltip:'Revert SCI image origins',igse:0,vgse:0}

  ;;LYT image position
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/left.bmp',cmd:'lyt shift origin +y',tooltip:'Move LYT window 1px left',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/right.bmp',cmd:'lyt shift origin -y',tooltip:'Move LYT window 1px right',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/up.bmp',cmd:'lyt shift origin -x',tooltip:'Move LYT window 1px up',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/down.bmp',cmd:'lyt shift origin +x',tooltip:'Move LYT window 1px down',igse:0,vgse:0}

  ;;GSE Commands
  b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Exit',cmd:'',tooltip:'Close GSE',igse:SHM_RUN,vgse:0}
  b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Reset',cmd:'',tooltip:'Reset GSE',igse:SHM_RESET,vgse:1}

  ;;Trim database
  buttondb = b[0:i-1]
  
  ;;Return buttons
  return, buttondb
end
