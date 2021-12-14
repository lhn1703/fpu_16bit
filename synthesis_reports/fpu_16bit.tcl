# dc-fpu_16bit.tcl script 
#
# 2018/02/15  Added *_ANALYZE_SECTION comments to new Makefile can automatically
#             add .v files to dc-*.tcl. Also updated some comments.
# 2017/02/14  Reduced output_delay to 4% and input_delay to 3% of the clock 
#             cycle time so very short critical paths are visible in timing 
#             reports. Also changed clock_skew from 250ps to 5% of cycle time 
#             so it will scale with clock frequency.
# 2017/02/10  Uncommented "analyze -format verilog ./proc.v" line. It seems to
#             be needed only the first time synthesis is run.
# 2017/02/04  Changes for NanGate 45 nm library including new timing parameters
# 2012/02/22  Changed:
#               ungroup -all -flatten -simple_names
#             to:
#               if { [sizeof_collection [get_cells * -filter 
#                  "is_hierarchical==true"]] > 0 } {
#                  ungroup -all -flatten -simple_names
#                  }
# 2010/02/16  Updated commented path to vtvtlib25.db
# 2009/02/12  Many parts re-written in new tcl version by Zhibin Xiao
# 2006/01/30  Updated /afs/.../vtvtlib25.db path to this quarter's path.
# 2004/02/05  Updated /afs/.../vtvtlib25.db path to this quarter's path.
# 2003/05/22  Increased input_setup from 500 to 6000 (external input delay
#             now 6ns instead of 9.5ns) so input paths don't show up at the
#             top of timing reports so often.
# 2003/05/15  Cleaned up a little
# 2003/05/14  Written
#
# Debugging
# list -designs
# list -libraries
# list -files 
#
# Add if you like:
# Annotates inputs, but doesn't propagate through design to clear warnings.
#   set_switching_activity -toggle_rate 0.25 -clock "clk" { "in31a" }
# More power info
#   report_power -net
#   report_power -hier
#   set_max_delay
#   write -format db -output fpu_16bit.db
#
# Doesn't work quite the way I expect
#   NameDesign = fpu_16bit    Set variable ok, but how to concatenate?
#   write_rtl -format verilog -output fpu_16bit.vg


#===== Set: make sure you change design name elsewhere in this file
set NameDesign "fpu_16bit"

#===== Set some timing parameters
set CLK "clk"

#===== All values are in units of ns for NanGate 45 nm library
set clk_period      1.5

set clock_skew      [expr {$clk_period} * 0.05 ]
set input_setup     [expr {$clk_period} * 0.97 ]
set output_delay    [expr {$clk_period} * 0.04 ]
set input_delay     [expr {$clk_period} - {$input_setup}]

# It appears one "analyze" command is needed for each .v file. This works best
# (only?) with one command line per module.
analyze -format verilog addSubCircuit.v
analyze -format verilog mulDivCircuit.v
analyze -format verilog comparator.v
analyze -format verilog fpu_16bit.v

elaborate $NameDesign
current_design $NameDesign
link
uniquify
if { [sizeof_collection [get_cells * -filter "is_hierarchical==true"]] > 0 } {
   ungroup -all -flatten -simple_names
   }
set_max_area 0.0

#===== Timing and input/output load constraints
create_clock $CLK -name $CLK -period $clk_period -waveform [list 0.0 [expr {$clk_period} / 2.0 ] ] 

set_clock_uncertainty $clock_skew $CLK
#set_clock_skew -plus_uncertainty $clock_skew $CLK
#set_clock_skew -minus_uncertainty $clock_skew $CLK

set_input_delay     $input_delay  -clock $CLK [all_inputs]
#remove_input_delay               -clock $CLK [all_inputs] 
set_output_delay    $output_delay -clock $CLK [all_outputs]

set_load 1.5 [all_outputs]

compile -map_effort medium

# Comment "ungroup" line to maybe see some submodules
if { [sizeof_collection [get_cells * -filter "is_hierarchical==true"]] > 0 } {
   ungroup -all -flatten -simple_names
   }
# compile -map_effort medium    # May help, or maybe not

#===== Reports
write -format verilog -output fpu_16bit.vg -hierarchy $NameDesign

report_area               > fpu_16bit.area
report_cell               > fpu_16bit.cell
report_hierarchy          > fpu_16bit.hier
report_net                > fpu_16bit.net
report_power              > fpu_16bit.pow
report_timing -nworst 10  > fpu_16bit.tim

check_timing
check_design

exit

