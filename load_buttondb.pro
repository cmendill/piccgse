;;button command database
;;buttons appear in the order they are listed
function load_buttondb
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

;;LYT image position
b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/left.bmp',cmd:'lyt shift origin +x',tooltip:'Move LYT window 1px left',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/right.bmp',cmd:'lyt shift origin -x',tooltip:'Move LYT window 1px right',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/up.bmp',cmd:'lyt shift origin -y',tooltip:'Move LYT window 1px up',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'lyt',type2:'arrow',name:'bmp/down.bmp',cmd:'lyt shift origin +x',tooltip:'Move LYT window 1px down',igse:0,vgse:0}


;;GSE Commands
b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Exit',cmd:'',tooltip:'Close GSE',igse:0,vgse:0}
b[i++]={id:i,show:1,type1:'gse',type2:'',name:'Reset',cmd:'',tooltip:'Reset GSE',igse:2,vgse:1}

;;Trim database
buttondb = b[0:i-1]

;;Return buttons
return, buttondb
end
