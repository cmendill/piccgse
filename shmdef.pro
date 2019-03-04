;;define jplgse shared memory parameters
SHM_SIZE      = 128
SHM_RUN       = 0     ;;0  --> Run/Close GSE
SHM_RESET     = 1     ;;1  --> Reset
SHM_LINK      = 2     ;;2  --> Link status
SHM_DATA      = 3     ;;3  --> Data status
SHM_CMD       = 27    ;;27 --> Command has been given
SHM_TIMESTAMP = 28    ;;28-127--> File timestamp
save,/VARIABLES,file='shmdef.idl'
print,'Wrote: shmdef.idl'
end
