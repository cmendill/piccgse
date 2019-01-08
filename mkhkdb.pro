;;command database
num_hk = 200                      
command_s = {command,$
             name:'',$
             cmd:'',$
             desc:'',$
             a:0., $
             b:0., $
             unit:'',$             
             min:0.,   $
             max:0.}

hkdb = replicate({command},num_hk)
i   = 0
;;Housekeeping Channel Assignments
a={name:'C_HK_CHAN0',cmd:'3D0000',desc:'Controller +5',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.66,max:5.15}
hkdb[i++]=a
a={name:'C_HK_CHAN1',cmd:'3D0100',desc:'Controller -5',a:5.0000e-4,b:-16.38,unit:'Volts',min:-5.25,max:-4.75}
hkdb[i++]=a
a={name:'C_HK_CHAN2',cmd:'3D0200',desc:'Controller +18',a:1.5000e-3,b:-49.15,unit:'Volts',min:18.05,max:19.95}
hkdb[i++]=a
a={name:'C_HK_CHAN3',cmd:'3D0300',desc:'Controller -12',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'C_HK_CHAN4',cmd:'3D0400',desc:'Controller +24',a:1.5000e-3,b:-49.15,unit:'Volts',min:22.80,max:25.20}
hkdb[i++]=a
a={name:'C_HK_CHAN5',cmd:'3D0500',desc:'Controller +5CL',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'C_HK_CHAN6',cmd:'3D0600',desc:'Controller +5M',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.66,max:5.15}
hkdb[i++]=a
a={name:'C_HK_CHAN7',cmd:'3D0700',desc:'Controller -5CL',a:5.0000e-4,b:-16.38,unit:'Volts',min:-5.04,max:-4.56}
hkdb[i++]=a
a={name:'C_HK_CHAN8',cmd:'3D0800',desc:'Controller +18CL',a:1.5000e-3,b:-49.15,unit:'Volts',min:17.10,max:18.90}
hkdb[i++]=a
a={name:'C_HK_CHAN9',cmd:'3D0900',desc:'Controller -12CL',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'C_HK_CHAN12',cmd:'3D0C00',desc:'Controller Temp',a:2.6600e-1,b:-8988.,unit:'Deg(C)',min:20.,max:35.}
hkdb[i++]=a
a={name:'C_HK_CHAN13',cmd:'3D0D00',desc:'Controller +2.5R',a:5.0000e-4,b:-16.38,unit:'Volts',min:2.38,max:2.62}
hkdb[i++]=a
a={name:'C_HK_CHAN14',cmd:'3D0E00',desc:'Controller VCO_CV',a:5.0000e-4,b:-16.38,unit:'Volts',min:1.5,max:3.5}
hkdb[i++]=a
a={name:'C_HK_CHAN15',cmd:'3D0F00',desc:'Controller Gnd',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.1,max:0.1}
hkdb[i++]=a

;;Housekeeping Channel Assignments 
a={name:'D_HK_CHAN0',cmd:'380000',desc:'Image Area Para Clk Hi',a:5.000e-4,b:-16.38,unit:'Volts',min:14.25,max:15.75}
hkdb[i++]=a
a={name:'D_HK_CHAN1',cmd:'380100',desc:'Image Area Para Clk Lo',a:5.000e-4,b:-16.38,unit:'Volts',min:-1.58,max:-1.42}
hkdb[i++]=a
a={name:'D_HK_CHAN2',cmd:'380200',desc:'Serial Clk Hi',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN3',cmd:'380300',desc:'Serial Clk Lo',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.73,max:-4.27}
hkdb[i++]=a
a={name:'D_HK_CHAN4',cmd:'380400',desc:'Reset Clk Hi',a:5.0000e-4,b:-16.38,unit:'Volts',min:8.55,max:9.45}
hkdb[i++]=a
a={name:'D_HK_CHAN5',cmd:'380500',desc:'Reset Clk Lo',a:5.0000e-4,b:-16.38,unit:'Volts',min:3.42,max:3.78}
hkdb[i++]=a
a={name:'D_HK_CHAN6',cmd:'380600',desc:'Scupper Driver',a:5.0000e-4,b:-16.38,unit:'Volts',min:11.,max:13.}
hkdb[i++]=a
a={name:'D_HK_CHAN7',cmd:'380700',desc:'Output Gate Driver',a:5.0000e-4,b:-16.38,unit:'Volts',min:0.1,max:1.1}
hkdb[i++]=a
a={name:'D_HK_CHAN8',cmd:'380800',desc:'Frame Store Para Clk Hi',a:5.0000e-4,b:-16.38,unit:'Volts',min:5.03,max:5.57}
hkdb[i++]=a
a={name:'D_HK_CHAN9',cmd:'380900',desc:'Frame Store Para Clk Lo',a:5.00000e-4,b:-16.38,unit:'Volts',min:-4.73,max:-4.27}
hkdb[i++]=a
a={name:'D_HK_CHAN10',cmd:'380A00',desc:'Reset Diode Driver',a:5.0000e-4,b:-16.38,unit:'Volts',min:11.,max:13.}
hkdb[i++]=a
a={name:'D_HK_CHAN12',cmd:'380C00',desc:'Drain 0',a:1.5000e-3,b:-49.15,unit:'Volts',min:19.00,max:21.00}
hkdb[i++]=a
a={name:'D_HK_CHAN13',cmd:'380D00',desc:'Drain 1',a:1.5000e-3,b:-49.15,unit:'Volts',min:19.00,max:21.00}
hkdb[i++]=a
a={name:'D_HK_CHAN14',cmd:'380E00',desc:'Drain 2',a:1.5000e-3,b:-49.15,unit:'Volts',min:19.00,max:21.00}
hkdb[i++]=a
a={name:'D_HK_CHAN15',cmd:'380F00',desc:'Drain 3',a:1.5000e-3,b:-49.15,unit:'Volts',min:19.00,max:21.00}
hkdb[i++]=a
a={name:'D_HK_CHAN16',cmd:'381000',desc:'P1-IA Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-1.58,max:-1.42}
hkdb[i++]=a
a={name:'D_HK_CHAN17',cmd:'381100',desc:'P2-IA Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-1.58,max:-1.42}
hkdb[i++]=a
a={name:'D_HK_CHAN18',cmd:'381200',desc:'P3-IA Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-1.58,max:-1.42}
hkdb[i++]=a
a={name:'D_HK_CHAN19',cmd:'381300',desc:'P1-FS Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.73,max:-4.27}
hkdb[i++]=a
a={name:'D_HK_CHAN20',cmd:'381400',desc:'P2-FS Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.73,max:-4.27}
hkdb[i++]=a
a={name:'D_HK_CHAN21',cmd:'381500',desc:'P3-FS Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.73,max:-4.27}
hkdb[i++]=a
a={name:'D_HK_CHAN22',cmd:'381600',desc:'P1-OR-AC Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN23',cmd:'381700',desc:'P2-OR-AC Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN24',cmd:'381800',desc:'P3-OR Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.18,max:4.62}
hkdb[i++]=a
a={name:'D_HK_CHAN25',cmd:'381900',desc:'P2-OR-BD Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN26',cmd:'381A00',desc:'P1-OR-BD Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN27',cmd:'381B00',desc:'Reset Driver Out',a:5.0000e-4,b:-16.38,unit:'Volts',min:8.46,max:9.35}
hkdb[i++]=a
a={name:'D_HK_CHAN28',cmd:'381C00',desc:'CIIG DAC Voltage',a:5.0000e-4,b:-16.38,unit:'Volts',min:8.55,max:9.45}
hkdb[i++]=a
a={name:'D_HK_CHAN29',cmd:'381D00',desc:'Driver 2.5V Reference',a:5.0000e-4,b:-16.38,unit:'Volts',min:2.38,max:2.62}
hkdb[i++]=a
a={name:'D_HK_CHAN30',cmd:'381E00',desc:'Driver Board Temp',a:2.6600e-1,b:-8988.,unit:'Deg(C)',min:20.,max:34.65}
hkdb[i++]=a
a={name:'D_HK_CHAN31',cmd:'381F00',desc:'Driver Board Ground',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.1,max:0.1}
hkdb[i++]=a
a={name:'D_HK_CHAN32',cmd:'382000',desc:'Driver +5 CL',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.27,max:4.73}
hkdb[i++]=a
a={name:'D_HK_CHAN33',cmd:'382100',desc:'Driver +18 FS',a:1.5000e-3,b:-49.15,unit:'Volts',min:17.10,max:18.90}
hkdb[i++]=a
a={name:'D_HK_CHAN34',cmd:'382200',desc:'Driver +18 IA',a:1.5000e-3,b:-49.15,unit:'Volts',min:18.05,max:19.95}
hkdb[i++]=a
a={name:'D_HK_CHAN35',cmd:'382300',desc:'Driver -5 CL',a:5.0000e-4,b:-16.38,unit:'Volts',min:-5.,max:-4.}
hkdb[i++]=a
a={name:'D_HK_CHAN36',cmd:'382400',desc:'Driver -12 FS',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'D_HK_CHAN37',cmd:'382500',desc:'Driver -12 IA',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'D_HK_CHAN38',cmd:'382600',desc:'Driver +24',a:1.5000e-3,b:-49.15,unit:'Volts',min:21.85,max:24.15}
hkdb[i++]=a
a={name:'D_HK_CHAN39',cmd:'382700',desc:'Driver CI ID_SwV',a:2.5000e-3,b:-81.90,unit:'Volts',min:37.05,max:40.95}
hkdb[i++]=a

;;DACChannelAssignments
a={name:'D_DAC_CHAN0',cmd:'180000',desc:'Frame Store Clk Hi',a:6e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN1',cmd:'180100',desc:'Frame Store Clk Lo +',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN2',cmd:'180200',desc:'Frame Store Clk Lo -',a:-5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN3',cmd:'180300',desc:'Image Area Clk Hi',a:6e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN4',cmd:'180400',desc:'Image Area Clk Lo +',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN5',cmd:'180500',desc:'Image Area Clk Lo -',a:-5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN6',cmd:'180600',desc:'Serial Clk Hi',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN7',cmd:'180700',desc:'Serial Clk Lo',a:-5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN8',cmd:'180800',desc:'Reset Gate +',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN9',cmd:'180900',desc:'Reset Gate -',a:-5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN10',cmd:'180A00',desc:'Reset Diode',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN11',cmd:'180B00',desc:'Injection Gate DAC',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN12',cmd:'180C00',desc:'Drain 0',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN13',cmd:'180D00',desc:'Drain 1',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN14',cmd:'180E00',desc:'Drain 2',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a
a={name:'D_DAC_CHAN15',cmd:'180F00',desc:'Drain 3',a:5e-2,b:-999.999,unit:'Volts',min:0.,max:0.}
hkdb[i++]=a


;;-------------------------------------------------------------------------------
;;[4]CommandsforVideoCard(CARD=4)
;;-------------------------------------------------------------------------------

;;HousekeepingChannelAssignments
a={name:'V_HK_CHAN0',cmd:'340000',desc:'CCD Output Current A',a:1.667e-5,b:-0.546,unit:'mAmps',min:0.1,max:0.3}
hkdb[i++]=a
a={name:'V_HK_CHAN1',cmd:'340100',desc:'CCD Output Current B',a:1.667e-5,b:-0.546,unit:'mAmps',min:0.1,max:0.3}
hkdb[i++]=a
a={name:'V_HK_CHAN2',cmd:'340200',desc:'CCD Output Current C',a:1.667e-5,b:-0.546,unit:'mAmps',min:0.1,max:0.3}
hkdb[i++]=a
a={name:'V_HK_CHAN3',cmd:'340300',desc:'CCD Output Current D',a:1.667e-5,b:-0.546,unit:'mAmps',min:0.1,max:0.3}
hkdb[i++]=a
a={name:'V_HK_CHAN4',cmd:'340400',desc:'Video +24 S-AC',a:1.5000e-3,b:-49.15,unit:'Volts',min:22.80,max:25.20}
hkdb[i++]=a
a={name:'V_HK_CHAN5',cmd:'340500',desc:'Video +5 S-AC',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.46,max:4.94}
hkdb[i++]=a
a={name:'V_HK_CHAN6',cmd:'340600',desc:'Video -5 S-AC',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.83,max:-4.37}
hkdb[i++]=a
a={name:'V_HK_CHAN7',cmd:'340700',desc:'Video -12 S-AC',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'V_HK_CHAN8',cmd:'340800',desc:'Video +2.5 RS-AC',a:5.0000e-4,b:-16.38,unit:'Volts',min:2.38,max:2.62}
hkdb[i++]=a
a={name:'V_HK_CHAN9',cmd:'340900',desc:'Video +24 S-BD',a:1.5000e-3,b:-49.15,unit:'Volts',min:22.80,max:25.20}
hkdb[i++]=a
a={name:'V_HK_CHAN10',cmd:'340A00',desc:'Video +5 S-BD',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.46,max:4.94}
hkdb[i++]=a
a={name:'V_HK_CHAN11',cmd:'340B00',desc:'Video -5 S-BD',a:5.0000e-4,b:-16.38,unit:'Volts',min:-4.83,max:-4.37}
hkdb[i++]=a
a={name:'V_HK_CHAN12',cmd:'340C00',desc:'Video -12 S-BD',a:1.5000e-3,b:-49.15,unit:'Volts',min:-12.60,max:-11.40}
hkdb[i++]=a
a={name:'V_HK_CHAN13',cmd:'340D00',desc:'Video +2.5 RS-BD',a:5.0000e-4,b:-16.38,unit:'Volts',min:2.38,max:2.62}
hkdb[i++]=a
a={name:'V_HK_CHAN14',cmd:'340E00',desc:'Video +5 CL',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.56,max:5.04}
hkdb[i++]=a
a={name:'V_HK_CHAN15',cmd:'340F00',desc:'Video Gnd',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.1,max:0.1}
hkdb[i++]=a
a={name:'V_HK_CHAN16',cmd:'341000',desc:'Video +18 CL',a:1.5000e-3,b:-49.15,unit:'Volts',min:18.05,max:19.95}
hkdb[i++]=a
a={name:'V_HK_CHAN17',cmd:'341100',desc:'Video -12 CL',a:1.5000e-3,b:-49.15,unit:'Volts',min:-11.55,max:-10.45}
hkdb[i++]=a
a={name:'V_HK_CHAN18',cmd:'341200',desc:'Video Board Temp',a:1.661e-2,b:-817.3,unit:'Deg(C)',min:20.,max:38.}
hkdb[i++]=a

;;--------------------------------------------------------------------------------
;;[5]CommandsforTCECard(CARD=1)
;;--------------------------------------------------------------------------------

;;ControlRegisterChannelAssignments
a={name:'T_CR_CHAN0',cmd:'210000',desc:'Operating Mode',a:-999.999,b:-999.999,unit:'Cooling:00 Anealing:7f',min:0.,max:0.}
hkdb[i++]=a
a={name:'T_CR_CHAN1',cmd:'210100',desc:'CCD Temp',a:4.539444e-3,b:-257.79,unit:'Deg(C)',min:-71.,max:-69.}
hkdb[i++]=a
a={name:'T_CR_CHAN2',cmd:'210200',desc:'Heat Sink Temp',a:4.608841e-3,b:-255.77,unit:'Deg(C)',min:-70.,max:-60.}
hkdb[i++]=a
a={name:'T_CR_CHAN4',cmd:'210400',desc:'CCD Temp Set Point',a:1.714,b:177.26,unit:'Deg(C)',min:-65.,max:-35.}
hkdb[i++]=a
a={name:'T_CR_CHAN5',cmd:'210500',desc:'TEC Current Limit',a:1.0,b:-1280.0,unit:'%',min:100.,max:100.}
hkdb[i++]=a
a={name:'T_CR_CHAN6',cmd:'210600',desc:'TEC Enable',a:-999.999,b:-999.999,unit:'StartCooling:80 StartAnnealing:ff Poweroff:00',min:0.,max:0.}
hkdb[i++]=a

;;HousekeepingChannelAssignments
a={name:'T_HK_CHAN0',cmd:'310000',desc:'SC Bus Voltage',a:3.0000e-3,b:-98.3,unit:'Volts',min:26.60,max:29.40}
hkdb[i++]=a
a={name:'T_HK_CHAN1',cmd:'310100',desc:'SC GND',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.1,max:0.1}
hkdb[i++]=a
a={name:'T_HK_CHAN2',cmd:'310200',desc:'TCE +12',a:1.500e-3,b:-49.15,unit:'Volts',min:11.40,max:12.60}
hkdb[i++]=a
a={name:'T_HK_CHAN3',cmd:'310300',desc:'TCE +5',a:5.0000e-4,b:-16.38,unit:'Volts',min:4.56,max:5.04}
hkdb[i++]=a
a={name:'T_HK_CHAN4',cmd:'310400',desc:'TEC Voltage',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.2,max:5.}
hkdb[i++]=a
a={name:'T_HK_CHAN5',cmd:'310500',desc:'TCE +24',a:1.500e-3,b:-49.15,unit:'Volts',min:22.80,max:25.20}
hkdb[i++]=a
a={name:'T_HK_CHAN6',cmd:'310600',desc:'TCE GND',a:5.0000e-4,b:-16.38,unit:'Volts',min:-0.1,max:0.1}
hkdb[i++]=a
a={name:'T_HK_CHAN7',cmd:'310700',desc:'TCE Board Temp',a:2.5000e-1,b:-8465.,unit:'Deg(C)',min:20.,max:35.}
hkdb[i++]=a
num_hk = i
hkdb = hkdb[0:num_hk-1]
print,'there are '+n2s(i)+' commands.'
print,'saving: hkdb.idl'


save,hkdb,filename='hkdb.idl'
end
