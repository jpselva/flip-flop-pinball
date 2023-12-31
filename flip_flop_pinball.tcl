# Copyright (C) 2020  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: flip_flop_pinball.tcl
# Generated on: Fri Dec 08 12:52:48 2023

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "flip_flop_pinball"]} {
		puts "Project flip_flop_pinball is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists flip_flop_pinball]} {
		project_open -revision flip_flop_pinball flip_flop_pinball
	} else {
		project_new -revision flip_flop_pinball flip_flop_pinball
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CEBA4F23C7
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 20.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:58:45  NOVEMBER 06, 2023"
	set_global_assignment -name LAST_QUARTUS_VERSION "20.1.1 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_timing
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_symbol
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_signal_integrity
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_boundary_scan
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VHDL_FILE src/tx_serial_uc.vhd
	set_global_assignment -name VHDL_FILE src/tx_serial_7O1_fd.vhd
	set_global_assignment -name VHDL_FILE src/tx_serial_7O1.vhd
	set_global_assignment -name VHDL_FILE src/timed_edge_detector_uc.vhd
	set_global_assignment -name VHDL_FILE src/timed_edge_detector.vhd
	set_global_assignment -name VHDL_FILE src/somador_rc.vhd
	set_global_assignment -name VHDL_FILE src/medidor_largura.vhd
	set_global_assignment -name VHDL_FILE src/interface_hcsr04_uc.vhd
	set_global_assignment -name VHDL_FILE src/interface_hcsr04_fd.vhd
	set_global_assignment -name VHDL_FILE src/interface_hcsr04.vhd
	set_global_assignment -name VHDL_FILE src/hexa7seg.vhd
	set_global_assignment -name VHDL_FILE src/gerador_pulso.vhd
	set_global_assignment -name VHDL_FILE src/gerador_freq.vhd
	set_global_assignment -name VHDL_FILE src/full_adder.vhd
	set_global_assignment -name VHDL_FILE src/flip_flop_pinball_uc.vhd
	set_global_assignment -name VHDL_FILE src/flip_flop_pinball_fd.vhd
	set_global_assignment -name VHDL_FILE src/flip_flop_pinball.vhd
	set_global_assignment -name VHDL_FILE src/exp3_sensor.vhd
	set_global_assignment -name VHDL_FILE src/envia_pontuacao_uc.vhd
	set_global_assignment -name VHDL_FILE src/envia_pontuacao_fd.vhd
	set_global_assignment -name VHDL_FILE src/envia_pontuacao.vhd
	set_global_assignment -name VHDL_FILE src/edge_detector.vhd
	set_global_assignment -name VHDL_FILE src/detector_pontos.vhd
	set_global_assignment -name VHDL_FILE src/detector_bola_uc.vhd
	set_global_assignment -name VHDL_FILE src/detector_bola_fd.vhd
	set_global_assignment -name VHDL_FILE src/detector_bola.vhd
	set_global_assignment -name VHDL_FILE src/deslocador_n.vhd
	set_global_assignment -name VHDL_FILE src/controle_servo.vhd
	set_global_assignment -name VHDL_FILE src/controle_led_buzzer_uc.vhd
	set_global_assignment -name VHDL_FILE src/controle_led_buzzer_fd.vhd
	set_global_assignment -name VHDL_FILE src/controle_led_buzzer.vhd
	set_global_assignment -name VHDL_FILE src/contador_q.vhd
	set_global_assignment -name VHDL_FILE src/contador_multiplo.vhd
	set_global_assignment -name VHDL_FILE src/contador_m_maior.vhd
	set_global_assignment -name VHDL_FILE src/contador_m.vhd
	set_global_assignment -name VHDL_FILE src/contador_bcd_3digitos.vhd
	set_global_assignment -name VHDL_FILE src/codificador_digito_ascii.vhd
	set_global_assignment -name VHDL_FILE src/circuito_pwm.vhd
	set_global_assignment -name VHDL_FILE ./src/flip_flop_pinball_uc.vhd
	set_global_assignment -name VHDL_FILE ./src/medidor_largura.vhd
	set_global_assignment -name VHDL_FILE ./src/interface_hcsr04_uc.vhd
	set_global_assignment -name VHDL_FILE ./src/interface_hcsr04_fd.vhd
	set_global_assignment -name VHDL_FILE ./src/interface_hcsr04.vhd
	set_global_assignment -name VHDL_FILE ./src/hexa7seg.vhd
	set_global_assignment -name VHDL_FILE ./src/gerador_pulso.vhd
	set_global_assignment -name VHDL_FILE ./src/flip_flop_pinball_fd.vhd
	set_global_assignment -name VHDL_FILE ./src/flip_flop_pinball.vhd
	set_global_assignment -name VHDL_FILE ./src/exp3_sensor.vhd
	set_global_assignment -name VHDL_FILE ./src/edge_detector.vhd
	set_global_assignment -name VHDL_FILE ./src/detector_bola_uc.vhd
	set_global_assignment -name VHDL_FILE ./src/detector_bola_fd.vhd
	set_global_assignment -name VHDL_FILE ./src/detector_bola.vhd
	set_global_assignment -name VHDL_FILE ./src/controle_servo.vhd
	set_global_assignment -name VHDL_FILE ./src/contador_m.vhd
	set_global_assignment -name VHDL_FILE ./src/contador_bcd_3digitos.vhd
	set_global_assignment -name VHDL_FILE ./src/circuito_pwm.vhd
	set_location_assignment PIN_G13 -to botao1
	set_location_assignment PIN_G12 -to botao2
	set_location_assignment PIN_M9 -to clock
	set_location_assignment PIN_B12 -to echo
	set_location_assignment PIN_A12 -to trigger
	set_location_assignment PIN_K16 -to iniciar
	set_location_assignment PIN_J17 -to reset
	set_location_assignment PIN_D17 -to pwm_flipper1
	set_location_assignment PIN_K20 -to pwm_flipper2
	set_location_assignment PIN_U21 -to db_estado[0]
	set_location_assignment PIN_V21 -to db_estado[1]
	set_location_assignment PIN_W22 -to db_estado[2]
	set_location_assignment PIN_W21 -to db_estado[3]
	set_location_assignment PIN_Y22 -to db_estado[4]
	set_location_assignment PIN_Y21 -to db_estado[5]
	set_location_assignment PIN_AA22 -to db_estado[6]
	set_location_assignment PIN_AA20 -to db_detector_bola_estado[0]
	set_location_assignment PIN_AB20 -to db_detector_bola_estado[1]
	set_location_assignment PIN_AA19 -to db_detector_bola_estado[2]
	set_location_assignment PIN_AA18 -to db_detector_bola_estado[3]
	set_location_assignment PIN_AB18 -to db_detector_bola_estado[4]
	set_location_assignment PIN_AA17 -to db_detector_bola_estado[5]
	set_location_assignment PIN_U22 -to db_detector_bola_estado[6]
	set_location_assignment PIN_AA2 -to db_bola_caiu
	set_location_assignment PIN_AB21 -to pontos0[6]
	set_location_assignment PIN_AB22 -to pontos0[5]
	set_location_assignment PIN_V14 -to pontos0[4]
	set_location_assignment PIN_Y14 -to pontos0[3]
	set_location_assignment PIN_AA10 -to pontos0[2]
	set_location_assignment PIN_AB17 -to pontos0[1]
	set_location_assignment PIN_Y19 -to pontos0[0]
	set_location_assignment PIN_V19 -to pontos1[6]
	set_location_assignment PIN_V18 -to pontos1[5]
	set_location_assignment PIN_U17 -to pontos1[4]
	set_location_assignment PIN_V16 -to pontos1[3]
	set_location_assignment PIN_Y17 -to pontos1[2]
	set_location_assignment PIN_W16 -to pontos1[1]
	set_location_assignment PIN_Y16 -to pontos1[0]
	set_location_assignment PIN_P9 -to pontos2[6]
	set_location_assignment PIN_Y15 -to pontos2[5]
	set_location_assignment PIN_U15 -to pontos2[4]
	set_location_assignment PIN_U16 -to pontos2[3]
	set_location_assignment PIN_V20 -to pontos2[2]
	set_location_assignment PIN_Y20 -to pontos2[1]
	set_location_assignment PIN_U20 -to pontos2[0]
	set_location_assignment PIN_T17 -to saida_serial
	set_location_assignment PIN_T19 -to sinal_buzzer
	set_location_assignment PIN_R16 -to sinal_led
	set_location_assignment PIN_L17 -to alvos[0]
	set_location_assignment PIN_M18 -to alvos[1]
	set_location_assignment PIN_P17 -to alvos[2]
	set_location_assignment PIN_P19 -to alvos[3]
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
