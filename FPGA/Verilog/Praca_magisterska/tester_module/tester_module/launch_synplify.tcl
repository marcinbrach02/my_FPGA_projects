#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/tester_module/launch_synplify.tcl
#-- Written on Sat Nov 23 16:05:04 2019

project -close
set filename "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/tester_module/tester_module_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology MACHXO2
set_option -part LCMXO2_4000HC
set_option -package TG144C
set_option -speed_grade -4

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency auto
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -disable_io_insertion false
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	set_option -dup false
	set_option -frequency 1
	set_option -default_enum_encoding default
	
	
	
	set_option -write_apr_constraint 1
	set_option -fix_gated_and_generated_clocks 1
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 0
	
	
}
#-- add_file options
set_option -include_path "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/tester_module.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/SPI_cont.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/card_driver.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/dev_uart_rx.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/dev_uart_tx.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/dev_uart_asy.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/distributed_fifo_shift.v"
add_file -verilog "F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/fifo_dc.v"
#-- top module name
set_option -top_module {tester_module}
project -result_file {F:/dydaktykaNowe/magisterki_inzynierki/2019/Brach - MachXO2 - SD - zaoczne/test333/tester_module/tester_module/tester_module.edi}
project -save "$filename"
