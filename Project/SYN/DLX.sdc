###################################################################

# Created by write_sdc on Mon Oct 26 04:40:08 2015

###################################################################
set sdc_version 1.7

set_wire_load_model -name 0K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 2  -waveform {0 1}
set_max_delay 2  -from [list [get_ports CLK] [get_ports RST] [get_ports {DATA_IN_INSTR[7]}]    \
[get_ports {DATA_IN_INSTR[6]}] [get_ports {DATA_IN_INSTR[5]}] [get_ports       \
{DATA_IN_INSTR[4]}] [get_ports {DATA_IN_INSTR[3]}] [get_ports                  \
{DATA_IN_INSTR[2]}] [get_ports {DATA_IN_INSTR[1]}] [get_ports                  \
{DATA_IN_INSTR[0]}] [get_ports {DATA_IN_MEM[31]}] [get_ports                   \
{DATA_IN_MEM[30]}] [get_ports {DATA_IN_MEM[29]}] [get_ports {DATA_IN_MEM[28]}] \
[get_ports {DATA_IN_MEM[27]}] [get_ports {DATA_IN_MEM[26]}] [get_ports         \
{DATA_IN_MEM[25]}] [get_ports {DATA_IN_MEM[24]}] [get_ports {DATA_IN_MEM[23]}] \
[get_ports {DATA_IN_MEM[22]}] [get_ports {DATA_IN_MEM[21]}] [get_ports         \
{DATA_IN_MEM[20]}] [get_ports {DATA_IN_MEM[19]}] [get_ports {DATA_IN_MEM[18]}] \
[get_ports {DATA_IN_MEM[17]}] [get_ports {DATA_IN_MEM[16]}] [get_ports         \
{DATA_IN_MEM[15]}] [get_ports {DATA_IN_MEM[14]}] [get_ports {DATA_IN_MEM[13]}] \
[get_ports {DATA_IN_MEM[12]}] [get_ports {DATA_IN_MEM[11]}] [get_ports         \
{DATA_IN_MEM[10]}] [get_ports {DATA_IN_MEM[9]}] [get_ports {DATA_IN_MEM[8]}]   \
[get_ports {DATA_IN_MEM[7]}] [get_ports {DATA_IN_MEM[6]}] [get_ports           \
{DATA_IN_MEM[5]}] [get_ports {DATA_IN_MEM[4]}] [get_ports {DATA_IN_MEM[3]}]    \
[get_ports {DATA_IN_MEM[2]}] [get_ports {DATA_IN_MEM[1]}] [get_ports           \
{DATA_IN_MEM[0]}]]  -to [list [get_ports RM] [get_ports WM] [get_ports {ADDR_MEM[31]}] [get_ports \
{ADDR_MEM[30]}] [get_ports {ADDR_MEM[29]}] [get_ports {ADDR_MEM[28]}]          \
[get_ports {ADDR_MEM[27]}] [get_ports {ADDR_MEM[26]}] [get_ports               \
{ADDR_MEM[25]}] [get_ports {ADDR_MEM[24]}] [get_ports {ADDR_MEM[23]}]          \
[get_ports {ADDR_MEM[22]}] [get_ports {ADDR_MEM[21]}] [get_ports               \
{ADDR_MEM[20]}] [get_ports {ADDR_MEM[19]}] [get_ports {ADDR_MEM[18]}]          \
[get_ports {ADDR_MEM[17]}] [get_ports {ADDR_MEM[16]}] [get_ports               \
{ADDR_MEM[15]}] [get_ports {ADDR_MEM[14]}] [get_ports {ADDR_MEM[13]}]          \
[get_ports {ADDR_MEM[12]}] [get_ports {ADDR_MEM[11]}] [get_ports               \
{ADDR_MEM[10]}] [get_ports {ADDR_MEM[9]}] [get_ports {ADDR_MEM[8]}] [get_ports \
{ADDR_MEM[7]}] [get_ports {ADDR_MEM[6]}] [get_ports {ADDR_MEM[5]}] [get_ports  \
{ADDR_MEM[4]}] [get_ports {ADDR_MEM[3]}] [get_ports {ADDR_MEM[2]}] [get_ports  \
{ADDR_MEM[1]}] [get_ports {ADDR_MEM[0]}] [get_ports {DATA_OUT_MEM[31]}]        \
[get_ports {DATA_OUT_MEM[30]}] [get_ports {DATA_OUT_MEM[29]}] [get_ports       \
{DATA_OUT_MEM[28]}] [get_ports {DATA_OUT_MEM[27]}] [get_ports                  \
{DATA_OUT_MEM[26]}] [get_ports {DATA_OUT_MEM[25]}] [get_ports                  \
{DATA_OUT_MEM[24]}] [get_ports {DATA_OUT_MEM[23]}] [get_ports                  \
{DATA_OUT_MEM[22]}] [get_ports {DATA_OUT_MEM[21]}] [get_ports                  \
{DATA_OUT_MEM[20]}] [get_ports {DATA_OUT_MEM[19]}] [get_ports                  \
{DATA_OUT_MEM[18]}] [get_ports {DATA_OUT_MEM[17]}] [get_ports                  \
{DATA_OUT_MEM[16]}] [get_ports {DATA_OUT_MEM[15]}] [get_ports                  \
{DATA_OUT_MEM[14]}] [get_ports {DATA_OUT_MEM[13]}] [get_ports                  \
{DATA_OUT_MEM[12]}] [get_ports {DATA_OUT_MEM[11]}] [get_ports                  \
{DATA_OUT_MEM[10]}] [get_ports {DATA_OUT_MEM[9]}] [get_ports                   \
{DATA_OUT_MEM[8]}] [get_ports {DATA_OUT_MEM[7]}] [get_ports {DATA_OUT_MEM[6]}] \
[get_ports {DATA_OUT_MEM[5]}] [get_ports {DATA_OUT_MEM[4]}] [get_ports         \
{DATA_OUT_MEM[3]}] [get_ports {DATA_OUT_MEM[2]}] [get_ports {DATA_OUT_MEM[1]}] \
[get_ports {DATA_OUT_MEM[0]}] [get_ports {ADDR_INSTR[31]}] [get_ports          \
{ADDR_INSTR[30]}] [get_ports {ADDR_INSTR[29]}] [get_ports {ADDR_INSTR[28]}]    \
[get_ports {ADDR_INSTR[27]}] [get_ports {ADDR_INSTR[26]}] [get_ports           \
{ADDR_INSTR[25]}] [get_ports {ADDR_INSTR[24]}] [get_ports {ADDR_INSTR[23]}]    \
[get_ports {ADDR_INSTR[22]}] [get_ports {ADDR_INSTR[21]}] [get_ports           \
{ADDR_INSTR[20]}] [get_ports {ADDR_INSTR[19]}] [get_ports {ADDR_INSTR[18]}]    \
[get_ports {ADDR_INSTR[17]}] [get_ports {ADDR_INSTR[16]}] [get_ports           \
{ADDR_INSTR[15]}] [get_ports {ADDR_INSTR[14]}] [get_ports {ADDR_INSTR[13]}]    \
[get_ports {ADDR_INSTR[12]}] [get_ports {ADDR_INSTR[11]}] [get_ports           \
{ADDR_INSTR[10]}] [get_ports {ADDR_INSTR[9]}] [get_ports {ADDR_INSTR[8]}]      \
[get_ports {ADDR_INSTR[7]}] [get_ports {ADDR_INSTR[6]}] [get_ports             \
{ADDR_INSTR[5]}] [get_ports {ADDR_INSTR[4]}] [get_ports {ADDR_INSTR[3]}]       \
[get_ports {ADDR_INSTR[2]}] [get_ports {ADDR_INSTR[1]}] [get_ports             \
{ADDR_INSTR[0]}]]
