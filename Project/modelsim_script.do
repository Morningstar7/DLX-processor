vcom myTypes.vhd

## Basic Components
vcom DATAPATH/BASIC_COMPONENTS/AND_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/OR_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/INV.vhd
vcom DATAPATH/BASIC_COMPONENTS/NAND_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/N_NAND.vhd
vcom DATAPATH/BASIC_COMPONENTS/N_AND.vhd
vcom DATAPATH/BASIC_COMPONENTS/FD.vhd
vcom DATAPATH/BASIC_COMPONENTS/XOR_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/XNOR_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/HA.vhd
vcom DATAPATH/BASIC_COMPONENTS/FA.vhd
vcom DATAPATH/BASIC_COMPONENTS/N_NOR.vhd
vcom DATAPATH/BASIC_COMPONENTS/FFT.vhd
vcom DATAPATH/BASIC_COMPONENTS/N_OR.vhd
vcom DATAPATH/BASIC_COMPONENTS/NOR_GATE.vhd
vcom DATAPATH/BASIC_COMPONENTS/D_LATCH.vhd

## MUXs
vcom DATAPATH/MUXS/MUX21_GEN.vhd
vcom DATAPATH/MUXS/MUX21.vhd
vcom DATAPATH/MUXS/MUX31_GEN.vhd
vcom DATAPATH/MUXS/MUX41_GEN.vhd
vcom DATAPATH/MUXS/MUX41.vhd
vcom DATAPATH/MUXS/MUX51_GEN.vhd
vcom DATAPATH/MUXS/MUX61_GEN.vhd
vcom DATAPATH/MUXS/MUX61.vhd
vcom DATAPATH/MUXS/MUX81_GEN.vhd

## Registers
vcom DATAPATH/REGISTERS/REG.vhd

## Adders 
vcom DATAPATH/ADDERS/RCA_GEN_NO_C.vhd  
vcom DATAPATH/ADDERS/RCA_GEN.vhd
	## P4
	vcom DATAPATH/ADDERS/P4_ADDER/GENERAL_GENERATE.vhd
	vcom DATAPATH/ADDERS/P4_ADDER/GENERAL_PROPAGATE.vhd  
	vcom DATAPATH/ADDERS/P4_ADDER/PG_BLOCK.vhd
	vcom DATAPATH/ADDERS/P4_ADDER/PG_NETWORK.vhd
	vcom DATAPATH/ADDERS/P4_ADDER/CSA.vhd      
	vcom DATAPATH/ADDERS/P4_ADDER/CARRY_GENERATOR.vhd 
  	vcom DATAPATH/ADDERS/P4_ADDER/SUM_GENERATOR.vhd
  	vcom DATAPATH/ADDERS/P4_ADDER/P4_ADDER.vhd  

## Comparators
vcom DATAPATH/COMPARATORS/COMPARATOR.vhd
vcom DATAPATH/COMPARATORS/EQU_COMPARATOR.vhd

## Counters
vcom DATAPATH/COUNTERS/SYNC_COUNTER_5BIT.vhd
vcom DATAPATH/COUNTERS/SYNC_COUNTER_2BIT.vhd

## Shifter
vcom DATAPATH/SHIFTERS/T2_SHIFTER.vhd

## Logicals
vcom DATAPATH/LOGICALS/T2_LOGICALS.vhd

## Multiplier
vcom DATAPATH/MULTIPLIER/BOOTH_ENCODER.vhd
vcom DATAPATH/MULTIPLIER/BOOTHMUL_COMP_1.vhd
vcom DATAPATH/MULTIPLIER/BOOTHMUL_COMP_2.vhd
vcom DATAPATH/MULTIPLIER/BOOTHMUL_COMP_3.vhd
vcom DATAPATH/MULTIPLIER/BOOTHMUL.vhd

## Divisor
vcom DATAPATH/DIVIDER/DIVISOR_FSM.vhd
vcom DATAPATH/DIVIDER/DIVISOR_DATAPATH.vhd
vcom DATAPATH/DIVIDER/NR_DIVISOR.vhd

## BPU
vcom DATAPATH/BPU/CU_BPU.vhd
vcom DATAPATH/BPU/FSM_BPU.vhd
vcom DATAPATH/BPU/CAM_BPU.vhd
vcom DATAPATH/BPU/CACHE_DATA_BPU.vhd
vcom DATAPATH/BPU/BPU_ENCODER.vhd
vcom DATAPATH/BPU/CACHE_BPU.vhd
vcom DATAPATH/BPU/BPU.vhd

## Fetch
vcom DATAPATH/FETCH/CAM.vhd
vcom DATAPATH/FETCH/CACHE_DATA.vhd
vcom DATAPATH/FETCH/CACHE.vhd
vcom DATAPATH/FETCH/FETCH.vhd

## Decode
vcom DATAPATH/DECODE/REG_FILE.vhd
vcom DATAPATH/DECODE/BRANCH.vhd
vcom DATAPATH/DECODE/DECODE.vhd

## Execute
vcom DATAPATH/EXECUTE/ALU.vhd
vcom DATAPATH/EXECUTE/EXECUTE.vhd

## Memory
vcom DATAPATH/MEMORY/MEMORY.vhd

## WriteBack
vcom DATAPATH/WB/WB.vhd

## FORWARDING UNIT
vcom DATAPATH/FORWARD_UNIT/FORW_FSM.vhd
vcom DATAPATH/FORWARD_UNIT/FORWARD_UNIT.vhd

## Datapath
vcom DATAPATH/DATAPATH.vhd

## CU
vcom CU/CONTROL_UNIT.vhd

## DLX
vcom DLX.vhd

## IRAM
vcom IRAM.vhd

## DATA MEMORY
vcom DATA_MEM.vhd

## Testbench
vcom TB_DLX.vhd

## Simulate
vsim -t 10ps work.tb_dlx

## Add waves
add wave -r \*

## Run 
run 1000 ns

delete wave *
add wave sim:/tb_dlx/alupush/inst_cu/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_fetch/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_decode/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_execute/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_memory/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_wb/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_decode/reg_file_inst/*
add wave sim:/tb_dlx/alupush/datapath_inst/forw_inst/fsm_forward/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_bpu/cache_inst/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_bpu/fsm_inst/*
add wave sim:/tb_dlx/alupush/datapath_inst/inst_bpu/cu_inst/*
radix -hexadecimal