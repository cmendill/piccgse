;;define jplgse shared memory parameters
SHM_SIZE      = 128
SHM_RUN       = 0     ;;0  --> Bool, Run/Close GSE
SHM_PTYPE     = 1     ;;1  --> Value, set.plottype
SHM_RESET     = 2     ;;2  --> Bool, Reset temperature plots
SHM_LINK      = 3     ;;3  --> Bool, Link status
SHM_DATA      = 4     ;;4  --> Bool, Data status
SHM_CMD       = 27    ;;27 --> Bool, Command has been given
SHM_TIMESTAMP = 28    ;;28-127--> File timestamp
save,/VARIABLES,file='shmdef.idl'

end
