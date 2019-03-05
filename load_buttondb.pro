;;button command database
;;buttons appear in the order they are listed
function load_buttondb
  ;;open shmem defs
  restore,'shmdef.idl'

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

  ;;Camera commands
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SHK Stop',cmd:'shk_proc off',tooltip:'Stop SHK Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SHK Start',cmd:'shk_proc on',tooltip:'Start SHK Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'LYT Stop',cmd:'lyt_proc off',tooltip:'Stop LYT Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'LYT Start',cmd:'lyt_proc on',tooltip:'Start LYT Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'ACQ Stop',cmd:'acq_proc off',tooltip:'Stop ACQ Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'ACQ Start',cmd:'acq_proc on',tooltip:'Start ACQ Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SCI Stop',cmd:'sci_proc off',tooltip:'Stop SCI Camera',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'camera',type2:'',name:'SCI Start',cmd:'sci_proc on',tooltip:'Start SCI Camera',igse:0,vgse:0}

  ;;LYT image position
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/left.bmp',cmd:'lyt shift origin +x',tooltip:'Move LYT window 1px left',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/right.bmp',cmd:'lyt shift origin -x',tooltip:'Move LYT window 1px right',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/up.bmp',cmd:'lyt shift origin -y',tooltip:'Move LYT window 1px up',igse:0,vgse:0}
  b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/down.bmp',cmd:'lyt shift origin +x',tooltip:'Move LYT window 1px down',igse:0,vgse:0}


  ;;GSE Commands
  b[i++]={id:i,show:1,type1:'gse',type2:'toggle',name:'Show ACQ',cmd:'',tooltip:'Show/Hide ACQ Camera',igse:SHM_ACQ,vgse:0}
  b[i++]={id:i,show:1,type1:'gse',type2:'toggle',name:'CMD Uplink',cmd:'',tooltip:'Use command uplink',igse:SHM_UPLINK,vgse:0}
  b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Exit',cmd:'',tooltip:'Close GSE',igse:SHM_RUN,vgse:0}
  b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Reset',cmd:'',tooltip:'Reset GSE',igse:SHM_RESET,vgse:1}

  ;;Trim database
  buttondb = b[0:i-1]
  
  ;;Return buttons
  return, buttondb
end
