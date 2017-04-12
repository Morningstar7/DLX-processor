library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity FSM_CU is
	generic (	CW_SIZE:	integer;		--29
			FETCH_SIGs:	integer;		--1
			DECODE_SIGs:	integer;		--10
			EXECUTE_SIGs:	integer;		--6
			MEM_SIGs:	integer;		--8
			WB_SIG:		integer;		--3
			ALU_CODE_SIZE:	integer;		--5
			IR_SIZE:	integer;		--32
			OPCODE_SIZE:	integer;		--6
			FUNC_SIZE:	integer);		--11
	port (		CLK:		in	std_logic;
			RST:		in	std_logic;
			STALL_BRANCH:	in	std_logic;
			STALL:		in	std_logic;
			INSTR_HIT_MISS:	in	std_logic;
			WRONG_FETCH:	in	std_logic;
			OPCODE:		in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			FUNC:		in	std_logic_vector(FUNC_SIZE-1 downto 0);
			-- Instruction Register
			-- FETCH Control Signals
			EN_IF:		out		std_logic;		-- Fetch-Decode Pipe regs Enable
			-- DECODE Control signal
			EN_ID:		out	std_logic;			-- Register File Enable
			CONFIRM_JMP:	out	std_logic;
			CONFIRM_BRANCH:	out	std_logic;
			BRANCH_TYPE:	out	std_logic;
			RD1:		out	std_logic;			-- Register File Read Port 1 Enable
			RD2:		out	std_logic;			-- Register File Read Port 2 Enable
			SEL_DEST:	out	std_logic_vector(1 downto 0);	-- Destination Mux
			LHI_SEL:	out	std_logic;
			JMP_SEL:	out	std_logic;
			-- EXECUTE Control signal
			EN_EXE:		out	std_logic;
			ALU_CODE:	out	std_logic_vector(ALU_CODE_SIZE-1 downto 0);			-- ALU op 3
			OP_SEL:		out	std_logic;			-- ALU port Mux
			-- L/S CONTROL SIGNALS
			EN_MEM:		out	std_logic;
			STORE_MASK:	out	std_logic_vector(1 downto 0);
			RM:		out	std_logic;			-- Read Mem Enable
			WM:		out	std_logic;			-- Write Mem Enable
			LOAD_TYPE:	out	std_logic_vector(2 downto 0);
			-- WB Control signals
			WB_SEL:		out	std_logic_vector(1 downto 0);			-- Write Back selector Mux
			WR:		out	std_logic);
end FSM_CU;

architecture FSM of FSM_CU is

	-- FSM states

	type TYPE_STATE is (
	-- Fetch states
	RESET_STATE,	-- RESET
	--PREL,		-- PRE LOAD
	-- R-Type Instructions states
	ADD_STATE,	-- ADD
	ADDU_STATE,	-- ADD UNSIGNED
	AND_STATE,	-- AND
	OR_STATE,	-- OR
	SEQ_STATE,	-- SET ON EQUAL
	SGE_STATE,	-- SET ON GREATER OR EQUAL
	SGEU_STATE,	-- SET ON GREATER OR EQUAL UNSIGNED
	SGT_STATE,	-- SET ON GREATER
	SGTU_STATE,	-- SET ON GRETER UNSIGNED
	SLE_STATE,	-- SET ON LESS OR EQUAL
	SLEU_STATE,	-- SET ON LESS OR EQUAL UNSIGNED
	SLL_STATE,	-- SHIFT LOGICAL LEFT
	SLT_STATE,	-- SET ON LOWER
	SLTU_STATE,	-- SET ON LOWER UNSIGNED
	SNE_STATE,	-- SET ON NOT EQUAL
	SRA_STATE,	-- SHIFT RIGHT ARITHMETICAL
	SRL_STATE,	-- SHIFT RIGHT LOGICAL
	SUB_STATE,	-- SUBTRACTION
	SUBU_STATE,	-- SUBTRACTION UNSIGNED
	XOR_STATE,	-- XOR
	-- I-Type Instructions states
	ADDI_STATE,	-- ADD IMMEDIATE
	ADDUI_STATE,	-- ADD IMMEDIATE UNSIGNED
	ANDI_STATE,	-- AND IMMEDIATE
	ORI_STATE,	-- OR IMMEDIATE
	SEQI_STATE,	-- SET ON EQUAL IMMEDIATE
	SGEI_STATE,	-- SET ON GREATER OR EQUAL IMMEFIATE
	SGEUI_STATE,	-- SET ON GREATER OR EQUAL IMMEDIATE UNSIGNED
	SGTI_STATE,	-- SET ON GREATER IMMEDIATE
	SGTUI_STATE,	-- SET ON GREATER IMMEDIATE UNSIGNED
	SLEI_STATE,	-- SET ON LESS OR EQUAL IMMEDIATE
	SLEUI_STATE,	-- SET ON LESS OR EQUAL IMMEDIATE UNSIGNED
	SLLI_STATE,	-- SHIFT LOGICAL LEFT IMMEFIATE
	SLTI_STATE,	-- SET ON LOWER IMMEDIATE
	SLTUI_STATE,	-- SET ON LOWER IMMEDIATE UNSIGNED
	SNEI_STATE,	-- SET ON NOT EQUAL IMMEDIATE
	SRAI_STATE,	-- SHIFT RIGHT ARITHMETICAL IMMEDIATE
	SRLI_STATE,	-- SHIFT RIGHT LOGICAL IMMEDIATE
	SUBI_STATE,	-- SUBTRACT IMMEDIATE
	SUBUI_STATE,	-- SUBTRACT IMMEDIATE UNSIGNED
	XORI_STATE,	-- XOR IMMEDIATE
	-- S-Type Instructions states
	SB_STATE,	-- STORE BYTE
	SH_STATE,	-- STORE HALF WORD
	SW_STATE,	-- STORE WORD
	-- B-Type Instructions states
	BEQZ_STATE,	-- BRANCH EQUAL ZERO
	BNEZ_STATE,	-- BRANCH NOT EQUAL
	-- N-Type Instructions states
	NOP_STATE,	-- NO OPERATION
	-- J-Type Instructions states
	J_STATE,	-- JUMP
	JAL_STATE,	-- JUMP AND SAVE RETURN ADDRESS
	JALR_STATE,	-- ABSOLUTE JUMP TO REGISTER VALUE AND SAVE RETURN ADDRESS TO R31
	JR_STATE,	-- ABSOLUTE JUMP TO REGISTER VALUE
	-- L-Type Instructions states
	LB_STATE,	-- LOAD BYTE
	LBU_STATE,	-- LOAD BYTE UNSIGNED
	LH_STATE,	-- LOAD HALF WORD
	LHI_STATE,	-- LOAD IMMEDIATE VALUE
	LHU_STATE,	-- LOAD HALF WORD UNSIGNED
	LW_STATE,	-- LOAD WORD
	-- F-Type Instructions states
	MULT_STATE,	
	DIV_STATE,
	END_STATE,
	LOAD);	-- LOAD WORD

	-- States Signals
	signal	CURRENT_STATE:	TYPE_STATE;
	--signal  NEXT_STATE:	TYPE_STATE;

	-- Control Word Signals
	signal	CW0:	std_logic_vector(CW_SIZE-1 downto 0);							-- 23
	signal	CW1:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-1 downto 0);				-- 15
	signal	CW2:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-EXECUTE_SIGs-1 downto 0);		-- 9
	signal	CW3:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-EXECUTE_SIGs-MEM_SIGs-1 downto 0);	-- 3

	-- PARTIAL CONTROL WORDS
	signal	IF_CW:	std_logic;
	signal	ID_CW:	std_logic_vector(DECODE_SIGs-1 downto 0);
	signal	EXE_CW:	std_logic_vector(EXECUTE_SIGs-1 downto 0);
	signal	MEM_CW:	std_logic_vector(MEM_SIGs-1 downto 0);
	signal	WB_CW:	std_logic_vector(WB_SIG-1 downto 0);

	signal REG_EN:		std_logic;
	signal DISABLE_WR_1:	std_logic;
	signal DISABLE_WR_2:	std_logic;
	signal DIS_DEC:		std_logic;
	signal DIS_EXE:		std_logic;
	signal DIS_EXE_1:	std_logic;
	signal DIS_MEM:		std_logic;
	signal DIS_WR:		std_logic;

	component REG is
	generic (	N:	integer);
	port (		D: 	in 	std_logic_vector(N-1 downto 0);
			Q: 	out	std_logic_vector(N-1 downto 0);
			EN:	in	std_logic;
			RST:	in 	std_logic;
			CLK: 	in	std_logic);
	end component;

	component FD
		port(	D:	in	std_logic;
			CLK:	in	std_logic;
			EN:	in	std_logic;
			RST:	in	std_logic;
			Q:	out	std_logic);
	end component;

	begin

		REG_EN <= not STALL and not STALL_BRANCH;

		-- FETCH Control Signals
		EN_IF <= CW0(0) and REG_EN and INSTR_HIT_MISS;			-- PC Enable

		-- DECODE Control signal
		EN_ID <= CW0(1) and REG_EN and not DIS_DEC;			-- Register File Enable
		CONFIRM_JMP <= CW0(2);
		CONFIRM_BRANCH <= CW0(3);
		BRANCH_TYPE <= CW0(4);
		RD1 <= CW0(5);					-- Register File Read Port 1 Enable
		RD2 <= CW0(6);					-- Register File Read Port 2 Enable
		SEL_DEST <= CW0(8 downto 7);			-- Destination Mux
		LHI_SEL <= CW0(9);
		JMP_SEL <= CW0(10);

		-- EXECUTE Control signal
		EN_EXE <= CW1(0) and not DIS_EXE;
		ALU_CODE <= CW1(ALU_CODE_SIZE downto 1);	-- ALU op 3
		OP_SEL <= CW1(ALU_CODE_SIZE+1);			-- ALU port Mux

		-- L/S CONTROL SIGNALS
		EN_MEM <= CW2(0);
		STORE_MASK <= CW2(2 downto 1);
		RM <= CW2(3) and not DIS_MEM;			-- Read Mem Enable
		WM <= CW2(4) and not DIS_MEM;			-- Write Mem Enable
		LOAD_TYPE <= CW2(7 downto 5);

		-- WB Control signals
		WB_SEL <= CW3(1 downto 0);			-- Write Back selector Mux
		WR <= CW3(2) and not DISABLE_WR_2 and not DIS_WR;

		CW_01_REG: REG 	generic map (	N	=> EXECUTE_SIGs+MEM_SIGs+WB_SIG)
				port map(	D	=> CW0(FETCH_SIGs+DECODE_SIGs+EXECUTE_SIGs+MEM_SIGs+WB_SIG-1 downto FETCH_SIGs+DECODE_SIGs),
						Q	=> CW1,
						EN	=> REG_EN,
						RST	=> RST,
						CLK	=> CLK);

		CW_02_REG: REG 	generic map (	N	=> MEM_SIGs+WB_SIG)
				port map(	D	=> CW1(EXECUTE_SIGs+MEM_SIGs+WB_SIG-1 downto EXECUTE_SIGs),
						Q	=> CW2,
						EN	=> '1',
						RST	=> RST,
						CLK	=> CLK);

		CW_03_REG: REG 	generic map (	N	=> WB_SIG)
				port map(	D	=> CW2(MEM_SIGs+WB_SIG-1 downto MEM_SIGs),
						Q	=> CW3,
						EN	=> '1',
						RST	=> RST,
						CLK	=> CLK);

		PIPE_DISABLE_WR_1: FD	port map (	D => STALL,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DISABLE_WR_1);

		PIPE_DISABLE_WR_2: FD	port map (	D => DISABLE_WR_1,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DISABLE_WR_2);

		FLUSH_DECODE: FD	port map (	D => WRONG_FETCH,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DIS_DEC);

		FLUSH_PIPE_1: FD	port map (	D => DIS_DEC,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DIS_EXE_1);

		FLUSH_PIPE_2: FD	port map (	D => DIS_EXE_1,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DIS_MEM);

		FLUSH_PIPE_3: FD	port map (	D => DIS_MEM,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DIS_WR);

		FLUSH_EXECUTE: FD	port map (	D => STALL_BRANCH,
							CLK => CLK,
							EN => '1',
							RST => RST,
							Q => DIS_EXE);

	STATE_PROC: process(CLK)
		begin
			if RST='1' then
				CURRENT_STATE <= RESET_STATE;
			elsif rising_edge(CLK) and STALL_BRANCH = '0' then
				case CURRENT_STATE is
					when RESET_STATE =>
						CURRENT_STATE <= LOAD;
					when ADD_STATE to LOAD  =>
						-- R-Type Instructions
						if STALL = '1' then
							CURRENT_STATE <= CURRENT_STATE;
						elsif INSTR_HIT_MISS = '0' then
							CURRENT_STATE <= LOAD;
						elsif  opcode = RTYPE then
							if  	func = RTYPE_ADD then
								CURRENT_STATE <= ADD_STATE;
							elsif	func = RTYPE_ADDU then
								CURRENT_STATE <= ADDU_STATE;
							elsif   func = RTYPE_AND then
								CURRENT_STATE <= AND_STATE;
							elsif   func = RTYPE_OR then
								CURRENT_STATE <= OR_STATE;
							elsif	func = RTYPE_SEQ then
								CURRENT_STATE <= SEQ_STATE;
							elsif   func = RTYPE_SGE then
								CURRENT_STATE <= SGE_STATE;
							elsif	func = RTYPE_SGEU then
								CURRENT_STATE <= SGEU_STATE;
							elsif	func = RTYPE_SGT then
								CURRENT_STATE <= SGT_STATE;
							elsif	func = RTYPE_SGTU then
								CURRENT_STATE <= SGTU_STATE;
							elsif   func = RTYPE_SLE then
								CURRENT_STATE <= SLE_STATE;
							elsif	func = RTYPE_SLEU then
								CURRENT_STATE <= SLEU_STATE;
							elsif   func = RTYPE_SLL then
								CURRENT_STATE <= SLL_STATE;
							elsif	func = RTYPE_SLT then
								CURRENT_STATE <= SLT_STATE;
							elsif	func = RTYPE_SLTU then
								CURRENT_STATE <= SLTU_STATE;
							elsif   func = RTYPE_SNE then
								CURRENT_STATE <= SNE_STATE;
							elsif	func = RTYPE_SRA then
								CURRENT_STATE <= SRA_STATE;
							elsif   func = RTYPE_SRL then
								CURRENT_STATE <= SRL_STATE;
							elsif   func = RTYPE_SUB then
								CURRENT_STATE <= SUB_STATE;
							elsif	func = RTYPE_SUBU then
								CURRENT_STATE <= SUBU_STATE;
							elsif   func = RTYPE_XOR then
								CURRENT_STATE <= XOR_STATE;
							else
								CURRENT_STATE <= END_STATE;
							end if;
						-- I-Type Instructions
						elsif   opcode = ITYPE_ADDI then
							CURRENT_STATE <= ADDI_STATE;
						elsif	opcode = ITYPE_ADDUI then
							CURRENT_STATE <= ADDUI_STATE;
						elsif   opcode = ITYPE_ANDI then
							CURRENT_STATE <= ANDI_STATE;
						elsif	opcode = ITYPE_LHI then
							CURRENT_STATE <= LHI_STATE;
						elsif   opcode = ITYPE_ORI then
							CURRENT_STATE <= ORI_STATE;
						elsif	opcode = ITYPE_SEQI then
							CURRENT_STATE <= SEQI_STATE;
						elsif   opcode = ITYPE_SGEI then
							CURRENT_STATE <= SGEI_STATE;
						elsif	opcode = ITYPE_SGEUI then
							CURRENT_STATE <= SGEUI_STATE;
						elsif   opcode = ITYPE_SLEI then
							CURRENT_STATE <= SLEI_STATE;
						elsif	opcode = ITYPE_SLEUI then
							CURRENT_STATE <= SLEUI_STATE;
						elsif	opcode = ITYPE_SGTI then
							CURRENT_STATE <= SGTI_STATE;
						elsif	opcode = ITYPE_SGTUI then
							CURRENT_STATE <= SGTUI_STATE;
						elsif   opcode = ITYPE_SLLI then
							CURRENT_STATE <= SLLI_STATE;
						elsif	opcode = ITYPE_SLTI then
							CURRENT_STATE <= SLTI_STATE;
						elsif	opcode = ITYPE_SLTUI then
							CURRENT_STATE <= SLTUI_STATE;
						elsif   opcode = ITYPE_SNEI then
							CURRENT_STATE <= SNEI_STATE;
						elsif	opcode = ITYPE_SRAI then
							CURRENT_STATE <= SRAI_STATE;
						elsif   opcode = ITYPE_SRLI then
							CURRENT_STATE <= SRLI_STATE;
						elsif   opcode = ITYPE_SUBI then
							CURRENT_STATE <= SUBI_STATE;
						elsif	opcode = ITYPE_SUBUI then
							CURRENT_STATE <= SUBUI_STATE;
						elsif   opcode = ITYPE_XORI then
							CURRENT_STATE <= XORI_STATE;
						-- S-Type Instructions
						elsif	opcode = STYPE_SB then
							CURRENT_STATE <= SB_STATE;
						elsif	opcode = STYPE_SH then
							CURRENT_STATE <= SH_STATE;
						elsif   opcode = STYPE_SW then
							CURRENT_STATE <= SW_STATE;
						-- B-Type Instructions
						elsif   opcode = BTYPE_BEQZ then
							CURRENT_STATE <= BEQZ_STATE;
						elsif   opcode = BTYPE_BNEZ then
							CURRENT_STATE <= BNEZ_STATE;
						-- N-Type Instructions
						elsif   opcode = NTYPE_NOP then
							CURRENT_STATE <= NOP_STATE;
						-- J-Type Instructions
						elsif   opcode = JTYPE_J then
							CURRENT_STATE <= J_STATE;
						elsif   opcode = JTYPE_JAL then
							CURRENT_STATE <= JAL_STATE;
						elsif	opcode = JTYPE_JALR then
							CURRENT_STATE <= JALR_STATE;
						elsif	opcode = JTYPE_JR then
							CURRENT_STATE <= JR_STATE;
						-- L-Type Instructions
						elsif	opcode = LTYPE_LB then
							CURRENT_STATE <= LB_STATE;
						elsif	opcode = LTYPE_LBU then
							CURRENT_STATE <= LBU_STATE;
						elsif	opcode = LTYPE_LH then
							CURRENT_STATE <= LH_STATE;
						elsif	opcode = LTYPE_LHU then
							CURRENT_STATE <= LHU_STATE;
						elsif   opcode = LTYPE_LW then
							CURRENT_STATE <= LW_STATE;
						-- L-Type Instructions
						elsif   opcode = FTYPE_MULT then
							CURRENT_STATE <= MULT_STATE;
						elsif   opcode = FTYPE_DIV then
							CURRENT_STATE <= DIV_STATE;
						end if;
					when others => 
						CURRENT_STATE <= RESET_STATE;
				end case;
			end if;
	end process STATE_PROC;


-- Control Word Output Process

	CW_proc: process(CURRENT_STATE)
		begin
			case CURRENT_STATE is
			--SIGNALS FROM RIGHT TO LEFT ARE WB, MEM, EXE, ID, IF
			--	FOR WB:		CW0(25) = WR			1 TO WRITE IN REGISTER FILE
			--			CW0(24 DOWNTO 23) = WB_SEL	11 FOR MEM, 10 FOR ALU, 01 FOR PC
			--	FOR MEM:	CW0(22 DOWNTO 20) = LOAD_TYPE	111 FOR LBU, 110 FOR LB, 101 FOR LHU, 100 FOR LH, ELSE FOR LW
			--			CW0(19) = WM			1 TO WRITE IN MEMORY
			--			CW0(18) = RM			1 TO READ FROM MEMORY
			--			CW0(17 downto 16) = STORE_MASK	11 for SW, 10 for SH, 00 for SB
			--			CW0(15) = EN_MEM		1 ENABLE THE MEM STAGE
			--	FOR EXE:	CW0(14) = ALU_MUX_SEL		1 FOR REG OR FORWARD AND 0 FOR IMMEDIATE
			--			CW0(13 DOWNTO 9) = ALU_OPCODE	OPCODES OF THE VARIOUS OPERATIONS
			--			CW0(8) = EN_EXE			1 TO ENABLE THE EXE STAGE
			--	FOR ID:		CW0(7) = SEL_DEST		1 FOR I-TYPE AND 0 FOR R-TYPE DESTINATIONS
			--			CW0(6) = RD2			1 TO READ REG B
			--			CW0(5) = RD1			1 TO READ REG A
			--			CW0(4) = BRANCH_TYPE		1 FOR BNEZ AND 0 FOR BEQZ
			--			CW0(3) = CONFIRM_BRANCH		1 TO CONFIRM THE BRANCH
			--			CW0(2) = CONFIRM_JUMP		1 TO CONFIRM THE JUMP
			--			CW0(1) = EN_ID			1 TO ENABLE THE DECODE STAGE
			--	FOR IF:		CW0(0) = EN_IF			1 TO ENABLE THE FETCH STAGE

				when RESET_STATE	=> 	IF_CW <=	'0';
								ID_CW <=	"0010000000";
								EXE_CW <=	"0111110";
								MEM_CW <=	"00000000";
								WB_CW <=	"000";

				when LOAD		=> 	IF_CW <=	'1';
								ID_CW <=	"0010000000";
								EXE_CW <=	"0111110";
								MEM_CW <=	"00000000";
								WB_CW <=	"000";

				-- R-TYPE 10
				when ADD_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1000001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when ADDU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1000001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when AND_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1000011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when OR_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1000101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SEQ_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1000111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGE_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1001001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGEU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1001011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGT_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1001101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGTU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1001111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLE_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1010001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLEU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1010011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLL_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1010101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLT_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1010111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLTU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1011001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SNE_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1011011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SRA_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1011101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SRL_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1011111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SUB_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1100001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SUBU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1100001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when XOR_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1100011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";

				-- I-TYPE 13
				when ADDI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when ADDUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when ANDI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when LHI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0111010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when ORI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SEQI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGEI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0001001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGEUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0001011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGTI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0001101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SGTUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0001111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLEI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0010001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLEUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0010011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLLI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0010101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLTI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0010111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SLTUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0011001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SNEI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0011011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SRAI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0011101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SRLI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0011111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SUBI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0100001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when SUBUI_STATE	=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0100001";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when XORI_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0100011";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";

				-- S-TYPE
				when SB_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00010001";
								WB_CW <=	"000";
				when SH_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00010101";
								WB_CW <=	"000";
				when SW_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"00010111";
								WB_CW <=	"000";

				-- B-TYPE
				when BEQZ_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010010101";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"000";
				when BNEZ_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010011101";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"000";

				-- N_TYPE
				when NOP_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010000001";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"000";

				-- J-TYPE
				when J_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010010011";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"000";
				when JAL_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0001000011";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"101";
				when JALR_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"1001010011";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"101";
				when JR_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"1010010011";
								EXE_CW <=	"0111111";
								MEM_CW <=	"00000001";
								WB_CW <=	"000";

				-- L_TYPE
				when LB_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"11001001";
								WB_CW <=	"111";
				when LBU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"11101001";
								WB_CW <=	"111";
				when LH_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"10001001";
								WB_CW <=	"111";
				when LHU_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"10101001";
								WB_CW <=	"111";
				when LW_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0011010001";
								EXE_CW <=	"0000001";
								MEM_CW <=	"01001001";
								WB_CW <=	"111";

				-- F_TYPE
				when MULT_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1100101";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";
				when DIV_STATE		=> 	IF_CW <=	'1';
								ID_CW <=	"0010110001";
								EXE_CW <=	"1100111";
								MEM_CW <=	"00000001";
								WB_CW <=	"110";

				when END_STATE		=>	IF_CW <=	'0';
								ID_CW <=	"0010000000";
								EXE_CW <=	"0111110";
								MEM_CW <=	"00000000";
								WB_CW <=	"000";

				-- Error
				when others		=> 	IF_CW <=	'0';
								ID_CW <=	"0010000000";
								EXE_CW <=	"0111110";
								MEM_CW <=	"00000000";
								WB_CW <=	"000";
			end case;
	end process CW_proc;
	CW0 <= WB_CW & MEM_CW & EXE_CW & ID_CW & IF_CW;
end FSM;

configuration CFG_FSM_CU_FSM of FSM_CU is
	for FSM
	end for;
end CFG_FSM_CU_FSM;


--APPUNTI

-- IL WRITE ENABLE DEL REGISTER FILE DOVREBBE ESSERE PILOTATO DALLA PIPE DI WB, IN CASO R E W POSSONO ESSERE SFASATI DI 180
-- ATTENZIONE AI SEGNALI DI SELEZIONE DEI MUX
-- 
--
--
--
--