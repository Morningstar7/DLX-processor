library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;

entity DATAPATH is
	generic (	N:		integer;
			N_ADDR:		integer;
			IMM_SIZE:	integer;
			OP_CODE_SIZE:	integer;
			M:		integer;
			ALUSIZE:	integer);
	port	(	CLK:		in	std_logic;
			RST:		in	std_logic;
			--FETCH SIGNALS
			EN_PC:		in	std_logic;
			EN_1:		in	std_logic;
			--DECODE SIGNALS
			EN_2:		in	std_logic;
			CONFIRM_JMP:	in	std_logic;
			CONFIRM_BRANCH:	in	std_logic;
			BRANCH_TYPE:	in	std_logic;
			RD1:		in	std_logic;
			RD2:		in	std_logic;
			WR:		in	std_logic;
			SEL_DEST:	in	std_logic_vector(1 downto 0);
			LHI_SEL:	in	std_logic;
			JMP_SEL:	in	std_logic;
			--EXECUTE SIGNALS
			EN_3:		in	std_logic;
			ALU_CODE:	in 	std_logic_vector(ALUSIZE-1 downto 0); 
			OP_SEL:		in	std_logic; 
			--MEMORY SIGNALS
			EN_4:		in	std_logic;
			STORE_MASK:	in	std_logic_vector(1 downto 0);
			LOAD_TYPE:	in	std_logic_vector(2 downto 0);
			--WB SIGNALS
			SEL:		in	std_logic_vector(1 downto 0);
			DATA_IN_IRAM:	in	std_logic_vector(7 downto 0);
			DATA_IN_MEM:	in	std_logic_vector(N-1 downto 0);
			DATA_OUT_MEM:	out	std_logic_vector(N-1 downto 0);
			ADDR_MEM:	out	std_logic_vector(N-1 downto 0);
			INSTR_CACHE_H_M:	out	std_logic;
			ADDR_IRAM:	out	std_logic_vector(N-1 downto 0);
			INSTR:		out	std_logic_vector(N-1 downto 0);
			--FORWARDING UNIT SIGNALS
			STALL:		out	std_logic;
			STALL_BRANCH:	out	std_logic;
			--BRANCH SIGNALS
			WRONG_FETCH:	out	std_logic);
end DATAPATH;

architecture RTL of DATAPATH is

	component FETCH
		generic (	N:		integer);
		port (		JUMP_ADDR:	in 	std_logic_vector(N-1 downto 0);		--ADDRESS FOR BRANCHING AND JUMPING
				BPU_ADDR:	in	std_logic_vector(N-1 downto 0);
				NPC_IN:		in	std_logic_vector(N-1 downto 0);
				BRANCH_SEL:	in	std_logic;
				BRANCH_SEL_BPU:	in	std_logic;
				SEL_N_TAKEN:	in	std_logic;
				EN:		in	std_logic;
				RST:		in	std_logic;
				CLK:		in	std_logic;
				DATA_IN_INSTR:	in	std_logic_vector(7 downto 0);
				H_M_CACHE:	out	std_logic;
				ADDR_IRAM:	out	std_logic_vector(N-1 downto 0);
				PC_OUT:		out	std_logic_vector(N-1 downto 0);
				NPC: 		out	std_logic_vector(N-1 downto 0);		--NEW PROGRAM COUNTER
				INSTRUCTION:	out	std_logic_vector(n-1 downto 0));	--INSTRUCTION OUT
	end component;

	component DECODE
		generic (	N:		integer;
				N_ADDR:		integer;
				IMM_SIZE:	integer;
				OP_CODE_SIZE:	integer);
		port	(	CLK:		in	std_logic;
				INSTRUCTION:	in	std_logic_vector(N-1 downto 0);
				NPC:		in	std_logic_vector(N-1 downto 0);
				CONFIRM_JMP:	in	std_logic;
				CONFIRM_BRANCH:	in	std_logic;
				BRANCH_TYPE:	in	std_logic;
				EN:		in	std_logic;
				RST:		in	std_logic;
				RD1:		in	std_logic;
				RD2:		in	std_logic;
				WR:		in	std_logic;
				SEL_DEST:	in	std_logic_vector(1 downto 0);
				LHI_SEL:	in	std_logic;
				JMP_SEL:	in	std_logic;
				SEL_MUX_BRANCH:	in	std_logic_vector(1 downto 0);
				FORW_ALU_MEM:	in	std_logic_vector(N-1 downto 0);
				FORW_ALU_WB:	in	std_logic_vector(N-1 downto 0);
				FORW_MEM_WB:	in	std_logic_vector(N-1 downto 0);
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				ADDR_WR:	in	std_logic_vector(N_ADDR-1 downto 0);
				PC_SEL_MUX:	out	std_logic;
				NPC_OUT:	out	std_logic_vector(N-1 downto 0);
				NPC_ADDED:	out	std_logic_vector(N-1 downto 0);
				REG_A:		out	std_logic_vector(N-1 downto 0);
				REG_B:		out	std_logic_vector(N-1 downto 0);
				IMMEDIATE:	out	std_logic_vector(N-1 downto 0);
				DEST_REG:	out	std_logic_vector(N_ADDR-1 downto 0));
	end component;

	component EXECUTE
		generic (	N:		integer;
				N_ADDR:		integer;
				ALUSIZE:	integer);
		port	(	REG_A:		in	std_logic_vector(N-1 downto 0);
				REG_B:		in	std_logic_vector(N-1 downto 0);
				IMMEDIATE:	in	std_logic_vector(N-1 downto 0);
				FORW_ALU_MEM:	in	std_logic_vector(N-1 downto 0);
				FORW_ALU_WB:	in	std_logic_vector(N-1 downto 0);
				FORW_MEM_WB:	in	std_logic_vector(N-1 downto 0);
				DEST_REG_IN:	in	std_logic_vector(N_ADDR-1 downto 0);
				ALU_CODE:	in 	std_logic_vector(ALUSIZE-1 downto 0);
				OP_SEL_A:	in	std_logic_vector(1 downto 0);
				OP_SEL_B:	in	std_logic_vector(2 downto 0);
				CLK:		in	std_logic;
				RST:		in	std_logic;
				DEST_REG_OUT:	out	std_logic_vector(N_ADDR-1 downto 0);
				OUTPUT_ALU:	out	std_logic_vector(N-1 downto 0);
				RST_DIV: 	in 	std_logic;
				REG_B_OUT:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MEMORY
		generic (	N:	integer;
				N_ADDR:	integer);
		port	(	IN_ALU:		in	std_logic_vector(N-1 downto 0);
				DEST_REG_IN:	in	std_logic_vector(N_ADDR-1 downto 0);
				REG_B_IN:	in	std_logic_vector(N-1 downto 0);
				FORW_ALU_WB:	in	std_logic_vector(N-1 downto 0);
				FORW_MEM_WB:	in	std_logic_vector(N-1 downto 0);
				FORW_REG:	in	std_logic_vector(N-1 downto 0);
				SEL_DATA:	in	std_logic_vector(1 downto 0);
				RESET:		in	std_logic;
				ENABLE:		in	std_logic;
				DATA_IN_MEM:	in	std_logic_vector(N-1 downto 0);
				LOAD_TYPE:	in	std_logic_vector(2 downto 0);
				STORE_MASK:	in	std_logic_vector(1 downto 0);
				ADDR_MEM:	out	std_logic_vector(N-1 downto 0);
				DATA_OUT_MEM:	out	std_logic_vector(N-1 downto 0);
				DEST_REG_OUT:	out	std_logic_vector(N_ADDR-1 downto 0);
				MEMORY_OUT:	out	std_logic_vector(N-1 downto 0);
				OUT_ALU:	out	std_logic_vector(N-1 downto 0));
	end component;

	component WB
		generic (	N: 	integer;
				N_ADDR:	integer);
		port (		IN_MEM:		in	std_logic_vector(N-1 downto 0);
				IN_ALU:		in	std_logic_vector(N-1 downto 0);
				IN_NPC:		in	std_logic_vector(N-1 downto 0);
				SEL:		in	std_logic_vector(1 downto 0);
				DEST_REG_IN:	in	std_logic_vector(N_ADDR-1 downto 0);
				DEST_REG_OUT:	out	std_logic_vector(N_ADDR-1 downto 0);
				OUT_WB:		out	std_logic_vector(N-1 downto 0));
	end component;

	component FORWARD_UNIT
		generic (	OPCODE_SIZE:	integer;
				N_ADDR:		integer);
		port (		CLK :		in	std_logic;
				RST :		in	std_logic;
				OPCODE_IF:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				REG_A_IF:	in	std_logic_vector(N_ADDR-1 downto 0);
				OPCODE_ID:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				REG_DEST_ID:	in	std_logic_vector(N_ADDR-1 downto 0);
				REG_DEST_EXE:	in	std_logic_vector(N_ADDR-1 downto 0);
				REG_DEST_MEM:	in	std_logic_vector(N_ADDR-1 downto 0);
				REG_A:		in	std_logic_vector(N_ADDR-1 downto 0); 
				REG_B:		in	std_logic_vector(N_ADDR-1 downto 0);
				MUX_A:		out	std_logic_vector(1 downto 0);
				MUX_B:		out	std_logic_vector(1 downto 0);
				MUX_C:		out	std_logic_vector(1 downto 0);
				MUX_D:		out	std_logic_vector(1 downto 0);
				RST_DIV:	out	std_logic;
				STALL_BRANCH:	out	std_logic;
				STALL:		out	std_logic);
	end component;

	component BPU
		generic (	N:		integer;
				OP_CODE_SIZE:	integer;
				SET_BIT:	integer);
		port (		CLK:		in	std_logic;
				RST:		in	std_logic;
				STALL_BRANCH:	in	std_logic;
				BRANCH_DEC:	in	std_logic;
				BRANCH_FETCH:	in	std_logic_vector(OP_CODE_SIZE-1 downto 0);
				DEST_DEC:	in	std_logic_vector(N-1 downto 0);
				PC_IN:		in	std_logic_vector(N-1 downto 0);
				PC_OUT:		out	std_logic_vector(N-1 downto 0);
				MUX_SEL:	out	std_logic);
	end component;

	component REG
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

	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component XOR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	-- FETCH SIGNALS
	signal BRANCH_SEL_DECODE_FETCH:	std_logic;
	signal BPU_SEL_SIG:		std_logic;
	signal NPC_DECODE_OUT_FETCH_IN:	std_logic_vector(N-1 downto 0);
	signal NPC_DECODE_OUT_FETCH_IN_OLD:	std_logic_vector(N-1 downto 0);
	signal NPC_FETCH_OUT:		std_logic_vector(N-1 downto 0);
	signal INSTRUCTION_FETCH_OUT:	std_logic_vector(N-1 downto 0);
	signal SEL_N_TAKEN:		std_logic;

	-- DECODE SIGNALS
	signal INSTRUCTION_DECODE_IN:	std_logic_vector(N-1 downto 0);
	signal NPC_DECODE_IN:		std_logic_vector(N-1 downto 0);
	signal DATA_DECODE_IN:		std_logic_vector(N-1 downto 0);
	signal ADDR_WR_DECODE_IN:	std_logic_vector(N_ADDR-1 downto 0);
	signal REG_A_DECODE_OUT:	std_logic_vector(N-1 downto 0);
	signal REG_B_DECODE_OUT:	std_logic_vector(N-1 downto 0);
	signal IMMEDIATE_DECODE_OUT:	std_logic_vector(N-1 downto 0);
	signal DEST_REG_DECODE_OUT:	std_logic_vector(N_ADDR-1 downto 0);
	signal BPU_ID:			std_logic;
	signal BRANCH_SEL_ID:		std_logic;
	signal N_BPU_ID:		std_logic;
	
	-- EXECUTE SIGNALS
	signal REG_A_EXECUTE_IN:	std_logic_vector(N-1 downto 0);
	signal REG_B_EXECUTE_IN:	std_logic_vector(N-1 downto 0);
	signal IMMEDIATE_EXECUTE_IN:	std_logic_vector(N-1 downto 0);
	signal DEST_REG_EXECUTE_IN:	std_logic_vector(N_ADDR-1 downto 0);
	signal DEST_REG_EXECUTE_OUT:	std_logic_vector(N_ADDR-1 downto 0);
	signal ALU_EXECUTE_OUT:		std_logic_vector(N-1 downto 0);
	signal REG_B_EXECUTE_OUT:	std_logic_vector(N-1 downto 0);
	signal NPC_OUT_EX_IN_MEM: 	std_logic_vector(N-1 downto 0);
	signal OP_SEL_B_SIG:		std_logic_vector(2 downto 0);
	
	-- MEMORY SIGNALS
	signal DEST_REG_MEM_IN:		std_logic_vector(N_ADDR-1 downto 0);
	signal ALU_MEM_IN:		std_logic_vector(N-1 downto 0);
	signal REG_B_MEM_IN:		std_logic_vector(N-1 downto 0);
	signal DEST_REG_MEM_OUT:	std_logic_vector(N_ADDR-1 downto 0);
	signal MEMORY_OUT_MEM_OUT:	std_logic_vector(N-1 downto 0);
	signal OUT_ALU_MEM_OUT:		std_logic_vector(N-1 downto 0);
	signal NPC_OUT_MEM_IN_WB:	std_logic_vector(N-1 downto 0); 
	
	-- WRITEBACK SIGNALS
	signal DEST_REG_WB_IN:		std_logic_vector(N_ADDR-1 downto 0);
	signal MEMORY_OUT_WB_IN:	std_logic_vector(N-1 downto 0);
	signal OUT_ALU_WB_IN:		std_logic_vector(N-1 downto 0);
	signal NPC_OUT_WB_IN:		std_logic_vector(N-1 downto 0);

	-- AFTER WRITEBACK SIGNALS
	signal WB_OUT_REG_B:		std_logic_vector(N-1 downto 0);

	--FORWARDING SIGNALS
	signal STALL_SIG:		std_logic;
	signal STALL_BRANCH_SIG:	std_logic;
	signal FORW_SEL_A:		std_logic_vector(1 downto 0);
	signal FORW_SEL_B:		std_logic_vector(1 downto 0);
	signal FORW_SEL_C:		std_logic_vector(1 downto 0);
	signal FORW_SEL_D:		std_logic_vector(1 downto 0);

	--BPU SIGNALS
	signal PC_BPU_IN:		std_logic_vector(N-1 downto 0);
	signal PC_BPU_OUT:		std_logic_vector(N-1 downto 0);
	signal BPU_SEL:			std_logic;
	signal WRONG_FETCH_SIG:		std_logic;
	signal WRONG_FETCH_SIG_1:	std_logic;

	--INTERNAL SIGNALS
	signal REG_EN:			std_logic;

	-- DIVISOR RST
	signal RST_DIV_SIG: 		std_logic;

	begin

		REG_EN <= not STALL_SIG;
		STALL <= STALL_SIG;
		OP_SEL_B_SIG <= OP_SEL & FORW_SEL_B;
		STALL_BRANCH <= STALL_BRANCH_SIG;
		WRONG_FETCH <= WRONG_FETCH_SIG;
		BPU_SEL_SIG <= BPU_SEL and not WRONG_FETCH_SIG_1;

		--INSTANCE OF THE FETCH
		INST_FETCH: FETCH	generic map (	N => N)
					port map (	JUMP_ADDR => NPC_DECODE_OUT_FETCH_IN,
							BPU_ADDR => PC_BPU_OUT,
							NPC_IN => NPC_DECODE_OUT_FETCH_IN_OLD,
							BRANCH_SEL => BRANCH_SEL_DECODE_FETCH,
							BRANCH_SEL_BPU => BPU_SEL_SIG,
							SEL_N_TAKEN => SEL_N_TAKEN,
							EN => EN_1,
							RST => RST,
							CLK => CLK,
							DATA_IN_INSTR => DATA_IN_IRAM,
							H_M_CACHE => INSTR_CACHE_H_M,
							ADDR_IRAM => ADDR_IRAM,
							PC_OUT => PC_BPU_IN,
							NPC => NPC_FETCH_OUT,
							INSTRUCTION => INSTRUCTION_FETCH_OUT);

		INSTR <= INSTRUCTION_FETCH_OUT;

		--INSTANCE OF THE BPU
		INST_BPU: BPU	generic map (	N => N,
						OP_CODE_SIZE => OP_CODE_SIZE,
						SET_BIT => 2)
				port map (	CLK => CLK,
						RST => RST,
						STALL_BRANCH => STALL_BRANCH_SIG,
						BRANCH_DEC => BRANCH_SEL_ID,
						BRANCH_FETCH => INSTRUCTION_FETCH_OUT(N-1 downto N-OP_CODE_SIZE),
						DEST_DEC => NPC_DECODE_OUT_FETCH_IN,
						PC_IN => PC_BPU_IN,
						PC_OUT => PC_BPU_OUT,
						MUX_SEL => BPU_SEL);
		--PIPELINE FETCH DECODE
		PIPE_IF_ID_NPC: REG	generic map (	N => N)
					port map (	D => NPC_FETCH_OUT,
							Q => NPC_DECODE_IN,
							EN => EN_1,
							RST => RST,
							CLK => CLK);

		PIPE_IF_ID_INSTRUCTION: REG	generic map (	N => N)
						port map (	D => INSTRUCTION_FETCH_OUT,
								Q => INSTRUCTION_DECODE_IN,
								EN => EN_1,
								RST => RST,
								CLK => CLK);

		PIPE_IF_ID_BPU: FD	port map (	D => BPU_SEL,
							CLK => CLK,
							EN => EN_1,
							RST => RST,
							Q => BPU_ID);

		--INSTANCE OF THE DECODE
		INST_DECODE: DECODE	generic map (	N => N,
							N_ADDR => N_ADDR,
							IMM_SIZE => IMM_SIZE,
							OP_CODE_SIZE => OP_CODE_SIZE)
					port map (	CLK => CLK,
							INSTRUCTION => INSTRUCTION_DECODE_IN,
							NPC => NPC_DECODE_IN,
							CONFIRM_JMP => CONFIRM_JMP,
							CONFIRM_BRANCH => CONFIRM_BRANCH,
							BRANCH_TYPE => BRANCH_TYPE,
							EN => EN_2,
							RST => RST,
							RD1 => RD1,
							RD2 => RD2,
							WR => WR,
							SEL_DEST => SEL_DEST,
							LHI_SEL => LHI_SEL,
							JMP_SEL => JMP_SEL,
							SEL_MUX_BRANCH => FORW_SEL_D,
							FORW_ALU_MEM => ALU_MEM_IN,
							FORW_ALU_WB => OUT_ALU_WB_IN,
							FORW_MEM_WB => MEMORY_OUT_WB_IN,
							DATA_IN => DATA_DECODE_IN,
							ADDR_WR => ADDR_WR_DECODE_IN,
							PC_SEL_MUX => BRANCH_SEL_ID,
							NPC_OUT => NPC_DECODE_OUT_FETCH_IN_OLD,
							NPC_ADDED => NPC_DECODE_OUT_FETCH_IN,
							REG_A => REG_A_DECODE_OUT,
							REG_B => REG_B_DECODE_OUT,
							IMMEDIATE => IMMEDIATE_DECODE_OUT,
							DEST_REG => DEST_REG_DECODE_OUT);

		--CHECKING THE BRANCH
		INV_BPU: INV	port map (	A => BPU_ID,
						Y => N_BPU_ID);

		CORR_BRANCH: AND_GATE	port map (	A => N_BPU_ID,
							B => BRANCH_SEL_ID,
							Y => BRANCH_SEL_DECODE_FETCH);

		SEL_MUX_N_TAKEN: AND_GATE	port map (	A => WRONG_FETCH_SIG,
								B => BPU_ID,
								Y => SEL_N_TAKEN);

		--CHECKING IF THE BPU HAS PREDICTED WRONG
		PREDICTION: XOR_GATE	port map (	A => BPU_ID,
							B => BRANCH_SEL_ID,
							Y => WRONG_FETCH_SIG);

		DELAY_MUX: FD	port map (	D => WRONG_FETCH_SIG,
						CLK => CLK,
						EN => '1',
						RST => RST,
						Q => WRONG_FETCH_SIG_1);

		--BEGIN PIPELINE DECODE EXECUTE
		--**********************
		PIPE_ID_EX_REG_A: REG	generic map (	N => N)
					port map (	D => REG_A_DECODE_OUT,
							Q => REG_A_EXECUTE_IN,
							EN => EN_2,
							RST => RST,
							CLK => CLK);

		PIPE_ID_EX_REG_B: REG	generic map (	N => N)
					port map (	D => REG_B_DECODE_OUT,
							Q => REG_B_EXECUTE_IN,
							EN => EN_2,
							RST => RST,
							CLK => CLK);

		PIPE_ID_EX_IMMEDIATE: REG	generic map (	N => N)
						port map (	D => IMMEDIATE_DECODE_OUT,
								Q => IMMEDIATE_EXECUTE_IN,
								EN => EN_2,
								RST => RST,
								CLK => CLK);

		PIPE_ID_EX_DEST_REG: REG	generic map (	N => N_ADDR)
						port map (	D => DEST_REG_DECODE_OUT,
								Q => DEST_REG_EXECUTE_IN,
								EN => EN_2,
								RST => RST,
								CLK => CLK);

		PIPE_ID_EX_OUT_NPC: REG		generic map (	N => N)
						port map (	D => NPC_DECODE_IN,
								Q => NPC_OUT_EX_IN_MEM,
								EN => EN_2,
								RST => RST,
								CLK => CLK);

		
		--**********************
		--END PIPELINE DECODE EXECUTE

		--INSTANCE OF THE EXECUTE
		INST_EXECUTE: EXECUTE	generic map (	N => N,
							N_ADDR => N_ADDR,
							ALUSIZE => ALUSIZE)
					port map (	REG_A => REG_A_EXECUTE_IN,
							REG_B => REG_B_EXECUTE_IN,
							IMMEDIATE => IMMEDIATE_EXECUTE_IN,
							FORW_ALU_MEM => ALU_MEM_IN,
							FORW_ALU_WB => OUT_ALU_WB_IN,
							FORW_MEM_WB => MEMORY_OUT_WB_IN,
							DEST_REG_IN => DEST_REG_EXECUTE_IN,
							ALU_CODE => ALU_CODE,
							OP_SEL_A => FORW_SEL_A,
							OP_SEL_B => OP_SEL_B_SIG,
							CLK => CLK,
							RST => RST,
							DEST_REG_OUT => DEST_REG_EXECUTE_OUT,
							OUTPUT_ALU => ALU_EXECUTE_OUT,
							RST_DIV => RST_DIV_SIG,
							REG_B_OUT => REG_B_EXECUTE_OUT);

		--BEGIN PIPELINE EXECUTE MEMORY
		--**********************
		PIPE_EX_MEM_DEST_REG: REG	generic map (	N => N_ADDR)
						port map (	D => DEST_REG_EXECUTE_OUT,
								Q => DEST_REG_MEM_IN,
								EN => EN_3,
								RST => RST,
								CLK => CLK);

		PIPE_EX_MEM_OUTPUT_ALU: REG	generic map (	N => N)
						port map (	D => ALU_EXECUTE_OUT,
								Q => ALU_MEM_IN,
								EN => EN_3,
								RST => RST,
								CLK => CLK);

		PIPE_EX_MEM_REG_B: REG	generic map (	N => N)
					port map (	D => REG_B_EXECUTE_OUT,
							Q => REG_B_MEM_IN,
							EN => EN_3,
							RST => RST,
							CLK => CLK);

		PIPE_EX_MEM_OUT_NPC : REG  generic map (N => N)
					port map (	D => NPC_OUT_EX_IN_MEM,
							Q => NPC_OUT_MEM_IN_WB,
							EN => EN_3,
							RST => RST,
							CLK => CLK);
		--**********************
		--END PIPELINE EXECUTE MEMORY

		--INSTANCE OF THE MEMORY
		INST_MEMORY: MEMORY	generic map (	N => N,
							N_ADDR => N_ADDR)
					port map (	IN_ALU => ALU_MEM_IN,
							DEST_REG_IN => DEST_REG_MEM_IN,
							REG_B_IN => REG_B_MEM_IN,
							FORW_ALU_WB => OUT_ALU_WB_IN,
							FORW_MEM_WB => MEMORY_OUT_WB_IN,
							FORW_REG => WB_OUT_REG_B,
							SEL_DATA => FORW_SEL_C,
							RESET => RST,
							ENABLE => EN_4,
							DATA_IN_MEM => DATA_IN_MEM,
							LOAD_TYPE => LOAD_TYPE,
							STORE_MASK => STORE_MASK,
							ADDR_MEM => ADDR_MEM,
							DATA_OUT_MEM => DATA_OUT_MEM,
							DEST_REG_OUT => DEST_REG_MEM_OUT,
							MEMORY_OUT => MEMORY_OUT_MEM_OUT,
							OUT_ALU => OUT_ALU_MEM_OUT);

		--BEGIN PIPELINE MEMORY WRITEBACK
		--**********************
		PIPE_MEM_WB_DEST_REG: REG	generic map (	N => N_ADDR)
						port map (	D => DEST_REG_MEM_OUT,
								Q => DEST_REG_WB_IN,
								EN => EN_4,
								RST => RST,
								CLK => CLK);

		PIPE_MEM_WB_MEMORY_OUT: REG	generic map (	N => N)
						port map (	D => MEMORY_OUT_MEM_OUT,
								Q => MEMORY_OUT_WB_IN,
								EN => EN_4,
								RST => RST,
								CLK => CLK);

		PIPE_MEM_WB_OUT_ALU: REG	generic map (	N => N)
						port map (	D => OUT_ALU_MEM_OUT,
								Q => OUT_ALU_WB_IN,
								EN => EN_4,
								RST => RST,
								CLK => CLK);
		
		PIPE_MEM_WB_OUT_NPC: REG	generic map (	N => N)
						port map (	D => NPC_OUT_MEM_IN_WB,
								Q => NPC_OUT_WB_IN,
								EN => EN_4,
								RST => RST,
								CLK => CLK);
		--**********************
		--END PIPELINE MEMORY WRITEBACK

		--INSTANCE OF THE WRITEBACK
		INST_WB: WB	generic map (	N => N,
						N_ADDR => N_ADDR)
				port map (	IN_MEM => MEMORY_OUT_WB_IN,
						IN_ALU => OUT_ALU_WB_IN,
						IN_NPC => NPC_OUT_WB_IN,
						SEL => SEL,
						DEST_REG_IN => DEST_REG_WB_IN,
						DEST_REG_OUT => ADDR_WR_DECODE_IN,
						OUT_WB => DATA_DECODE_IN);

		PIPE_WB_OUT: REG		generic map (	N => N)
						port map (	D => DATA_DECODE_IN,
								Q => WB_OUT_REG_B,
								EN => '1',		---OOOOOOOOHHHHHHHHHH RICORDA QUI!!!!!
								RST => RST,
								CLK => CLK);

		--ASSOCIATING THE FORWARD SIGNALS
		--######################

		--######################

		--FORWARDING UNIT
		--######################
		FORW_INST:	FORWARD_UNIT	generic map (	OPCODE_SIZE => OP_CODE_SIZE,
								N_ADDR => N_ADDR)
						port map (	CLK => CLK,
								RST => RST,
								OPCODE_IF => INSTRUCTION_FETCH_OUT(N-1 downto N-OP_CODE_SIZE),
								REG_A_IF => INSTRUCTION_FETCH_OUT(N-OP_CODE_SIZE-1 downto N-OP_CODE_SIZE-N_ADDR),
								OPCODE_ID => INSTRUCTION_DECODE_IN(N-1 downto N-OP_CODE_SIZE),
								REG_DEST_ID => DEST_REG_DECODE_OUT,
								REG_DEST_EXE => DEST_REG_EXECUTE_IN,
								REG_DEST_MEM => DEST_REG_MEM_IN,
								REG_A => INSTRUCTION_DECODE_IN(N-OP_CODE_SIZE-1 downto N-OP_CODE_SIZE-N_ADDR),
								REG_B => INSTRUCTION_DECODE_IN(N-OP_CODE_SIZE-N_ADDR-1 downto N-OP_CODE_SIZE-2*N_ADDR),
								MUX_A => FORW_SEL_A,
								MUX_B => FORW_SEL_B,
								MUX_C => FORW_SEL_C,
								MUX_D => FORW_SEL_D,
								RST_DIV => RST_DIV_SIG,
								STALL_BRANCH => STALL_BRANCH_SIG,
								STALL => STALL_SIG);
		--######################

end RTL;

configuration CFG_DATAPTH_RTL of DATAPATH is
	for RTL
		for all: FETCH
			use configuration WORK.CFG_FETCH_STRUCTURAL;
		end for;
		for all: DECODE
			use configuration WORK.CFG_DECODE_STRUCTURAL;
		end for; 
		for all: EXECUTE
			use configuration WORK.CFG_EXECUTE_STRUCTURAL;
		end for;	
		for all: MEMORY
			use configuration WORK.CFG_MEMORY_STRUCTURAL;
		end for;
		for all: WB
			use configuration WORK.CFG_WB_STRUCTURAL;
		end for;
		for all: REG
			use configuration WORK.CFG_REG_SYN_STRUCTURAL;
		end for;
		for all: FORWARD_UNIT
			use configuration WORK.CFG_FORWARD_UNI_STRUCTURAL;
		end for;
		for all: BPU
			use configuration WORK.CFG_BPU_STRUCTURAL;
		end for;
	end for;
end CFG_DATAPTH_RTL;