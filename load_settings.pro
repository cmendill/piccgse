function load_settings
;;PICCGSE Static Settings
settings = {uplink_dev: '/dev/ttyUSB1',$
            dnlink_dev: '/dev/ttyUSB0',$
            config_file: 'piccgse.conf',$
            scitype_image:    0,$
            scitype_real:     1,$
            scitype_imaginary:2,$
            scitype_amplitude:3,$
            scitype_phase:    4,$
            scitype_log:      5,$
            bmctype_cmd:      0,$
            bmctype_dif:      1,$
            cmdlength:      256,$
            remote_port:  10000,$
            uplink_port:  10001,$
            dnlink_port:  10002,$
            SHM_SIZE:       128,$
            SHM_RUN:        0,$  ;;0      --> Run/Close GSE
            SHM_RESET:      1,$  ;;1      --> Reset
            SHM_LINK:       2,$  ;;2      --> Link status
            SHM_DATA:       3,$  ;;3      --> Data status
            SHM_UPLINK:     4,$  ;;4      --> Enable/Disable CMD uplink
            SHM_ACQ_DX:     5,$  ;;5-6    --> ACQ camera star-hole delta x [px]
            SHM_ACQ_DY:     7,$  ;;7-8    --> ACQ camera star-hole delta x [px]
            SHM_SCITYPE:    9,$  ;;9      --> SCI camera display type [0:images, 1:real, 2:imaginary, 3:amplitude, 4:phase]
            SHM_BMCTYPE:   10,$  ;;10     --> BMC display type [0:cmd, 1:difference]
            SHM_REMOTE:    11,$  ;;11     --> piccgse running in remote mode
            SHM_UP_RUN:    12,$  ;;12     --> UPLINK running
            SHM_DN_RUN:    13,$  ;;13     --> DNLINK running
            SHM_STATE:     14,$  ;;13     --> Flight state index
            SHM_CMD:       27,$  ;;27     --> Command has been given
            SHM_TIMESTAMP: 28}   ;;28-127 --> File timestamp
;;Shared Memory
;;NOTE: SHMEM creates a file /dev/shm/shm of size shm_size bytes
;;      The file does not get deleted when you quit IDL, so if
;;      shm_size changes, you must delete this file manualy. 
return,settings
end
