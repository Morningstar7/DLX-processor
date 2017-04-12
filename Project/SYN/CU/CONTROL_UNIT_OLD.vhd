	library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use IEEE.numeric_std.all;
	use work.myTypes.all;
	
	entity FSM_CU is
	generic (	CW_SIZE:	integer;		--20
			FETCH_SIGs:	integer;		--2	-->	1
			DECODE_SIGs:	integer;		--9	-->	7
			EXECUTE_SIGs:	integer;		--6
			MEM_SIGs:	integer;		--2	-->	3
			WB_SIG:		integer;		--4
			ALU_CODE_SIZE:	integer;
			IR_SIZE:	integer;		--32
			OPCODE_SIZE:	integer;		--6
			FUNC_SIZE:	integer);		--11
	port(	CLK:		in	std_logic;
			RST:		in	std_logic;
			STALL:		in	std_logic; 
			OPCODE:		in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			FUNC:		in	std_logic_vector(FUNC_SIZE-1 downto 0);
			-- Instruction Register
			-- FETCH Control Signals
			EN_IF:	out		std_logic;			-- Fetch-Decode Pipe regs Enable
			-- DECODE Control signal
			EN_ID:		out	std_logic;			-- Register File Enable
			CONFIRM_JMP:	out	std_logic;
			CONFIRM_BRANCH:	out	std_logic;
			BRANCH_TYPE:	out	std_logic;
			RD1:		out	std_logic;			-- Register File Read Port 1 Enable
			RD2:		out	std_logic;			-- Register File Read Port 2 Enable
			SEL_DEST:	out	std_logic;			-- Destination Mux
			-- EXECUTE Control signal
			EN_EXE:		out	std_logic;
			ALU_CODE:	out	std_logic_vector(ALU_CODE_SIZE-1 downto 0);			-- ALU op 3
			OP_SEL:		out	std_logic;			-- ALU port Mux
			-- L/S CONTROL SIGNALS
			EN_MEM:		out	std_logic;
			RM:		out	std_logic;			-- Read Mem Enable
			WM:		out	std_logic;			-- Write Mem Enable
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
		AND_STATE,	-- AND
		OR_STATE,	-- OR
		SGE_STATE,	-- SET ON GREATER OR EQUAL
		SLE_STATE,	-- SET ON LESS OR EQUAL
		SLL_STATE,	-- SHIFT LOGICAL LEFT
		SNE_STATE,	-- SET ON NOT EQUAL
		SRL_STATE,	-- SHIFT RIGHT LOGICAL
		SUB_STATE,	-- SUBTRACT
		XOR_STATE,	-- XOR
		-- I-Type Instructions states
		ADDI_STATE,	-- ADD IMMEDIATE
		ANDI_STATE,	-- AND IMMEDIATE
		ORI_STATE,	-- OR IMMEDIATE
		SGEI_STATE,	-- SET ON GREATER OR EQUAL IMMEFIATE
		SLEI_STATE,	-- SET ON LESS OR EQUAL IMMEDIATE
		SLLI_STATE,	-- SHIFT LOGICAL LEFT IMMEFIATE
		SNEI_STATE,	-- SET ON NOT EQUAL IMMEDIATE
		SRLI_STATE,	-- SHIFT RIGHT LOGICAL IMMEDIATE
		SUBI_STATE,	-- SUBTRACT IMMEDIATE
		XORI_STATE,	-- XOR IMMEDIATE
		-- S-Type Instructions states
		SW_STATE,	-- STORE WORD
		-- B-Type Instructions states
		BEQZ_STATE,	-- BRANCH EQUAL ZERO
		BNEZ_STATE,	-- BRANCH NOT EQUAL
		-- N-Type Instructions states
		NOP_STATE,	-- NO OPERATION
		-- J-Type Instructions states
		J_STATE,	-- JUMP
		JAL_STATE,	-- JUMP AND SAVE RETURN ADDRESS
		-- L-Type Instructions states
		LW_STATE,
		LOAD,
		MULT_STATE);	-- LOAD WORD
	
		-- States Signals
		signal	CURRENT_STATE:	TYPE_STATE;
		--signal  NEXT_STATE:	TYPE_STATE;
	
		-- Control Word Signals
		signal	CW0:	std_logic_vector(CW_SIZE-1 downto 0);                                                   -- 1
		signal	CW1:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-1 downto 0);                            -- 9
		signal	CW2:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-EXECUTE_SIGs-1 downto 0);               -- 3
		signal	CW3:	std_logic_vector(CW_SIZE-FETCH_SIGs-DECODE_SIGs-EXECUTE_SIGs-WB_SIG-1 downto 0);      -- 1
	
		signal REG_EN_FW:		std_logic;
		signal DISABLE_WR_1:	std_logic;
		signal DISABLE_WR_2:	std_logic;
	
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
	
		REG_EN_FW <= not STALL;
	
		-- CW hardwiring signal
	
			-- FETCH Control Signals
			EN_IF <= CW0(0) and REG_EN_FW;			-- PC Enable
	
			-- DECODE Control signal
			EN_ID <= CW0(1) and REG_EN_FW;			-- Register File Enable
			CONFIRM_JMP <= CW0(2);
			CONFIRM_BRANCH <= CW0(3);
			BRANCH_TYPE <= CW0(4);
			RD1 <= CW0(5);				-- Register File Read Port 1 Enable
			RD2 <= CW0(6);				-- Register File Read Port 2 Enable
			SEL_DEST <= CW0(7);				-- Destination Mux
	
			-- EXECUTE Control signal
			EN_EXE <= CW1(0);
			ALU_CODE <= CW1(ALU_CODE_SIZE downto 1);	-- ALU op 3
			OP_SEL <= CW1(ALU_CODE_SIZE+1);			-- ALU port Mux
	
			-- L/S CONTROL SIGNALS
			EN_MEM <= CW2(0);
			RM <= CW2(1);			-- Read Mem Enable
			WM <= CW2(2);			-- Write Mem Enable
	
			-- WB Control signals
			WB_SEL(0) <= CW3(0);
			WB_SEL(1) <= CW3(1);			-- Write Back selector Mux
			WR <= CW3(2) and not DISABLE_WR_2;
			
			
			
	
			CW_01_REG: REG 	generic map (	N	=> EXECUTE_SIGs+MEM_SIGs+WB_SIG)
					port map(	D	=> CW0(FETCH_SIGs+DECODE_SIGs+EXECUTE_SIGs+MEM_SIGs+WB_SIG-1 downto FETCH_SIGs+DECODE_SIGs),
							Q	=> CW1,
							EN	=> REG_EN_FW,
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
	
		STATE_PROC: process(CLK,RST)
			begin
				if RST='1' then
					CURRENT_STATE <= RESET_STATE;
				elsif rising_edge(CLK) then
					case CURRENT_STATE is
						when RESET_STATE =>
							CURRENT_STATE <= LOAD;
						when ADD_STATE to MULT_STATE  =>
							-- R-Type Instructions 10
							if STALL = '1' then
								CURRENT_STATE <= CURRENT_STATE;
							elsif  opcode = RTYPE then
								if  func = RTYPE_ADD then
									CURRENT_STATE <= ADD_STATE;
								elsif   func = RTYPE_AND then
									CURRENT_STATE <= AND_STATE;
								elsif   func = RTYPE_OR then
									CURRENT_STATE <= OR_STATE;
								elsif   func = RTYPE_SGE then
									CURRENT_STATE <= SGE_STATE;
								elsif   func = RTYPE_SLE then
									CURRENT_STATE <= SLE_STATE;
								elsif   func = RTYPE_SLL then
									CURRENT_STATE <= SLL_STATE;
								elsif   func = RTYPE_SNE then
									CURRENT_STATE <= SNE_STATE;
								elsif   func = RTYPE_SRL then
									CURRENT_STATE <= SRL_STATE;
								elsif   func = RTYPE_SUB then
									CURRENT_STATE <= SUB_STATE;
								elsif   func = RTYPE_XOR then
									CURRENT_STATE <= XOR_STATE;
								end if;
							-- I-Type Instructions 10
							elsif   opcode = ITYPE_ADDI then
								CURRENT_STATE <= ADDI_STATE;
							elsif   opcode = ITYPE_ANDI then
								CURRENT_STATE <= ANDI_STATE;
							elsif   opcode = ITYPE_ORI then
								CURRENT_STATE <= ORI_STATE;
							elsif   opcode = ITYPE_SGEI then
								CURRENT_STATE <= SGEI_STATE;
							elsif   opcode = ITYPE_SLEI then
								CURRENT_STATE <= SLEI_STATE;
							elsif   opcode = ITYPE_SLLI then
								CURRENT_STATE <= SLLI_STATE;
							elsif   opcode = ITYPE_SNEI then
								CURRENT_STATE <= SNEI_STATE;
							elsif   opcode = ITYPE_SRLI then
								CURRENT_STATE <= SRLI_STATE;
							elsif   opcode = ITYPE_SUBI then
								CURRENT_STATE <= SUBI_STATE;
							elsif   opcode = ITYPE_XORI then
								CURRENT_STATE <= XORI_STATE;
							-- S-Type Instructions
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
							-- L-Type Instructions
							elsif   opcode = LTYPE_LW then
								CURRENT_STATE <= LW_STATE;
							-- F-ype Instruction	
							elsif	opcode = FTYPE_MULT then
								CURRENT_STATE <= MULT_STATE;
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
	
		when RESET_STATE   	=> CW0 <=	"00000000000000000000";
			when LOAD	=> CW0 <=	"00000000000000000001";
	
		-- R-TYPE 10
		when ADD_STATE       	=> CW0 <=	"11000110000101100011";
		when AND_STATE     	=> CW0 <=	"11000110001101100011";
		when OR_STATE      	=> CW0 <=	"11000110010101100011";
		when SGE_STATE       	=> CW0 <=	"11000110011101100011";
		when SLE_STATE       	=> CW0 <=	"11000110100101100011";
		when SLL_STATE     	=> CW0 <=	"11000110101101100011";
		when SNE_STATE      	=> CW0 <=	"11000110110101100011";
		when SRL_STATE     	=> CW0 <=	"11000110111101100011";
		when SUB_STATE     	=> CW0 <=	"11000111000101100011";
		when XOR_STATE     	=> CW0 <=	"11000111001101100011";
	
		-- I-TYPE 13
		when ADDI_STATE      	=> CW0 <=	"11000100000110100011";
		when ANDI_STATE      	=> CW0 <=	"11000100001110100011";
		when ORI_STATE       	=> CW0 <=	"11000100010110100011";
		when SGEI_STATE      	=> CW0 <=	"11000100011110100011";
		when SLEI_STATE      	=> CW0 <=	"11000100100110100011";
		when SLLI_STATE     	=> CW0 <=	"11000100101110100011";
		when SNEI_STATE      	=> CW0 <=	"11000100110110100011";
		when SRLI_STATE      	=> CW0 <=	"11000100111110100011";
		when SUBI_STATE      	=> CW0 <=	"11000101000110100011";
		when XORI_STATE      	=> CW0 <=	"11000101001110100011";
		
		-- S-TYPE
		when SW_STATE        	=> CW0 <=	"00010100000101100011";
		-- B-TYPE
		when BEQZ_STATE    	=> CW0 <=	"00000000000000101011";
		when BNEZ_STATE      	=> CW0 <=	"00000000000000111011";
	
		-- N_TYPE
		when NOP_STATE		=> CW0 <=	"00000000000000000011";
	
		-- J-TYPE
		when J_STATE         	=> CW0 <=	"00000000000000100111";
		when JAL_STATE	 	=> CW0 <=	"10100100000110000111"; -- CHECK TBing fuck off 
	
		-- L_TYPE
		when LW_STATE        	=> CW0 <=	"11101100000110100011";   
	
		when MULT_STATE		=> CW0 <=	"11000111010101100011";    --1010 
	
		-- Error
		when others   	 	=> CW0 <= 	"00000000000000000000";
	
		end case;
	end process CW_proc;
	
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