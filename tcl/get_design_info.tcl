
proc bonfire_get_port_info {} {
  set lastb ""
  set buses ""
  set bdict nil

  foreach i [get_ports] {
    set b [get_property BUS_NAME $i]
    set w [get_property BUS_WIDTH $i]
    if {$w>0 && $lastb != $b} {
      #dict set bdict $b $w
      lappend buses $b $w

    }
    set lastb $b
  }

  set bdict [dict create  {*}$buses]


  set res "\{ports=\{"
  foreach i [dict keys $bdict] {
     append res  $i "=" [dict get $bdict $i] ","
  }
  append res "\}\}"
  return $res
}
