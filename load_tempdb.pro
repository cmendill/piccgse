function load_tempdb
  sensor_struct = {adc:0,ch:0,htr:0,location:'',name:'',abbr:'',min:0, max:0,order:0}
  
  ;;read csv file
  readcol,'tempdb.csv',adc,ch,htr,location,name,abbr,min,max,order,delimit=',',format='I,I,I,A,A,A,F,F,I'
  
  ;;make structure
  tempdb = replicate(sensor_struct,n_elements(adc))

  ;;fill structure
  tempdb.adc      = adc
  tempdb.ch       = ch
  tempdb.htr      = htr
  tempdb.location = location
  tempdb.name     = name
  tempdb.abbr     = abbr
  tempdb.min      = min
  tempdb.max      = max
  tempdb.order    = order

  ;;return structure
  return, tempdb
end
