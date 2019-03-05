;;define piccgse shared memory parameters
;;NOTE: SHMEM creates a file /dev/shm/shm of size shm_size bytes
;;      The file does not get deleted when you quit IDL, so if
;;      shm_size changes, you must delete this file manualy. 
SHM_SIZE      = 128
SHM_RUN       = 0     ;;0  --> Run/Close GSE
SHM_RESET     = 1     ;;1  --> Reset
SHM_LINK      = 2     ;;2  --> Link status
SHM_DATA      = 3     ;;3  --> Data status
SHM_ACQ       = 4     ;;4  --> Show/Hide ACQ camera
SHM_UPLINK    = 5     ;;5  --> Enable/Disable CMD uplink
SHM_CMD       = 27    ;;27 --> Command has been given
SHM_TIMESTAMP = 28    ;;28-127--> File timestamp
save,/VARIABLES,file='shmdef.idl'
print,'Wrote: shmdef.idl'
end
