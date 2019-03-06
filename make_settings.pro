;;PICCGSE Static Settings

;;Serial Ports
uplink_dev  = '/dev/ttyUSB1'
uplink_baud = '2400' 
dnlink_dev  = '/dev/ttyUSB0'
dnlink_baud = '115200'

;;Shared Memory
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
save,/variables,file='settings.idl'
print,'Wrote: settings.idl'
end
