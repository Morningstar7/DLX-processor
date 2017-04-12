library ieee;
use ieee.std_logic_1164.all;
	
package myTypes is
	
	-- Control unit input sizes
	constant OPCODE_SIZE : integer :=  6;		-- OPCODE field size
	constant FUNC_SIZE    : integer :=  11;		-- FUNC field size
	
	-- R-Type instruction -> OPCODE field
	constant RTYPE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "000000";	-- for register-to-register operation
	
	-- R-Type instruction -> FUNC field                             OPERATION OPERAND_1, OPERAND_2, DESTINATION_REG
		constant RTYPE_ADD : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100000";	-- ADD R1, R2, R3	signed addition between registers
		constant RTYPE_ADDU : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100001";	-- ADDU R1, R2, R3	unsigned addition between registers
		constant RTYPE_AND : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100100";	-- AND R1, R2, R3	bitwise AND between registers
		constant RTYPE_OR  : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100101";	-- OR R1, R2, R3	bitwise OR between registers
		constant RTYPE_SEQ : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101000";	-- SEQ R1, R2, R3	if R2 = R3 then R1 = 1; else R1 = 0
		constant RTYPE_SGE : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101101";	-- SGE R1, R2, R3	if R2 >= R3 then R1 = 1; else R1 = 0
		constant RTYPE_SGEU : std_logic_vector(FUNC_SIZE -1 downto 0) := "00000111101";	-- SGEU R1, R2, R3
		constant RTYPE_SGT : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101011";	-- SGT R1, R2, R3	if R2 > R3 then R1 = 1; else R1 = 0
		constant RTYPE_SGTU : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000111011";	-- SGTU R1, R2, R3
		constant RTYPE_SLE : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101100";	-- SLE R1, R2, R3	if R2 <= R3 then R1 = 1; else R1 = 0
		constant RTYPE_SLEU : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000111100";	-- SLEU R1, R2, R3
		constant RTYPE_SLL : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000000100";	-- SLL R1, R2, R3	R2 logic shift left by R3(5 downto 0)
		constant RTYPE_SLT : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101010";	-- SLT R1, R2, R3	if R2 < R2 then R1 = 1; else R1 = 0
		constant RTYPE_SLTU : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000111010";	-- SLTU R1, R2, R3
		constant RTYPE_SNE : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000101001";	-- SNE R1, R2, R3	if R2 != R3 then R1 = 1; else R1 = 0
		constant RTYPE_SRA : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000000111";	-- SRA R1, R2, R3	R2 arith shift right by R3(4 downto 0)
		constant RTYPE_SRL : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000000110";	-- SLR R1, R2, R3	R2 logic shift right by R3(4 downto 0)
		constant RTYPE_SUB : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100010";	-- SUB R1, R2, R3	signed subtraction between registers
		constant RTYPE_SUBU : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100011";	-- SUBU R1, R2, R3	unsigned subtraction between registers
		constant RTYPE_XOR : std_logic_vector(FUNC_SIZE-1 downto 0) := "00000100110";	-- XOR R1, R2, R3	bitwise XOR between registers
	
	-- I-Type instruction -> OPCODE field
	constant ITYPE_ADDI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001000";	-- ADDI R1, R2, INP	signed addition between register and immediate
	constant ITYPE_ADDUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001001";	-- ADDUI R1, R2, INP	unsigned addition between register and immediate
	constant ITYPE_ANDI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001100";	-- ANDI R1, R2, INP	bitwise AND between register and immediate
	constant ITYPE_LHI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001111";	--
	constant ITYPE_ORI  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001101";	-- ORI1 R1, R2, INP	bitwise OR between register and immediate
	constant ITYPE_SEQI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011000";	-- SEQI R1, R2, INP	if R2 = INP then R1 = 1; else R1 = 0
	constant ITYPE_SGEI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011101";	-- SGEI R1, R2, INP	if R2 >= INP then R1 = 1; else R1 = 0
	constant ITYPE_SGEUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "111101";
	constant ITYPE_SGTI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011011";
	constant ITYPE_SGTUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "111011";
	constant ITYPE_SLEI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011100";	-- SLEI R1, R2, INP	if R2 <= INP then R1 = 1; else R1 = 0
	constant ITYPE_SLEUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "111100";
	constant ITYPE_SLLI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "010100";	-- SLLI R1, R2, INP	R2 logically shifted left by INP(4 downto 0)
	constant ITYPE_SLTI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011010";
	constant ITYPE_SLTUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "111010";
	constant ITYPE_SNEI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011001";	-- SNEI R1, R2, INP	if R2 != INP then R1 = 1; else R1 = 0
	constant ITYPE_SRAI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "010111";
	constant ITYPE_SRLI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "010110";	-- SRLI R1, R2, INP	R2 logic shift right by INP(4 downto 0)
	constant ITYPE_SUBI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001010";	-- SUBI R1, R2, INP	signed subtraction between register and immediate
	constant ITYPE_SUBUI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001011";
	constant ITYPE_XORI : std_logic_vector(OPCODE_SIZE-1 downto 0) := "001110";	-- XORI R1, R2, INP	bitwise XOR  between register and immediate
	
	-- S-Type instruction -> OPCODE field
	constant STYPE_SB : std_logic_vector(OPCODE_SIZE-1 downto 0) := "101000";	-- SB INP(R1), R2	save R2 in memory at address INP + R1 (byte)
	constant STYPE_SH : std_logic_vector(OPCODE_SIZE-1 downto 0) := "101001";	-- SH INP(R1), R2	save R2 in memory at address INP + R1 (half word)
	constant STYPE_SW : std_logic_vector(OPCODE_SIZE-1 downto 0) := "101011";	-- SW INP(R1), R2	save R2 in memory at address INP + R1
	
	-- N-Type instruction -> OPCODE field
	constant NTYPE_NOP : std_logic_vector(OPCODE_SIZE-1 downto 0) :=  "010101";	-- NOP			no operation (idle clock cycle)
	
	-- B-Type instruction -> OPCODE field
	constant BTYPE_BEQZ : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000100";	-- BEQ R1, INP		if R1 = 0 then PC = PC + INP + 4
	constant BTYPE_BNEZ : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000101";	-- BNEZ R1, INP		if R1 != 0 then PC = PC + INP + 4
	
	-- J-Type instruction -> OPCODE field
	constant JTYPE_J : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000010";	-- J INP		PC = PC + INP + 4
	constant JTYPE_JAL : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000011";	-- JAL INP		R31 = PC + 8; PC = PC + INP + 4
	constant JTYPE_JALR : std_logic_vector(OPCODE_SIZE-1 downto 0) := "010011";	-- JALR R1		R31 = PC + 8; PC = R1
	constant JTYPE_JR : std_logic_vector(OPCODE_SIZE-1 downto 0) := "010010";	-- JR R1		PC = R1
	
	-- L_Type instruction - OPCODE field
	constant LTYPE_LB : std_logic_vector(OPCODE_SIZE-1 downto 0) := "100000";	-- LB R1, INP(R2)	load in R1 memory at address INP + R2 (byte)
	constant LTYPE_LBU : std_logic_vector(OPCODE_SIZE-1 downto 0) := "100100";	-- LBU R1, INP(R2)	load in R1 memory at address INP + R2 (byte unsigned)
	constant LTYPE_LH : std_logic_vector(OPCODE_SIZE-1 downto 0) := "100001";	-- LH R1, INP(R2)	load in R1 memory at address INP + R2 (half word)
	constant LTYPE_LHU : std_logic_vector(OPCODE_SIZE-1 downto 0) := "100101";	-- LHU R1, INP(R2)	load in R1 memory at address INP + R2 (half unsigned)
	constant LTYPE_LW : std_logic_vector(OPCODE_SIZE-1 downto 0) := "100011";	-- LW R1, INP(R2)	load in R1 memory at address INP + R2
	
	-- F-TYPE instruction - OPCODE field
	constant FTYPE_MULT : std_logic_vector(OPCODE_SIZE-1 downto 0) := "000001";	-- MULT R1, R2, R3	multiplication between R2 and R3 (lower 16 bits)
	constant FTYPE_DIV  : std_logic_vector(OPCODE_SIZE-1 downto 0) := "011111";	-- DIV R1, R2, R3	division between R2 and R3 (lower 16 bits)
	
end myTypes; 
