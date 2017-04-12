library IEEE;
use IEEE.std_logic_1164.all;

entity DECODE is
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
end DECODE;

architecture STRUCTURAL of DECODE is

	component REG_FILE
		generic (	N:		integer;
				N_ADDR:		integer);
		port	(	CLK:		in	std_logic;
				RST:		in	std_logic;
				EN:		in	std_logic;
				RD1:		in	std_logic;
				RD2:		in	std_logic;
				WR:		in	std_logic;
				ADDR_WR:	in	std_logic_vector(N_ADDR-1 downto 0);
				ADDR_RD1:	in	std_logic_vector(N_ADDR-1 downto 0);
				ADDR_RD2:	in	std_logic_vector(N_ADDR-1 downto 0);
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				DATA_OUT_1:	out	std_logic_vector(N-1 downto 0);
				DATA_OUT_2:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component MUX21_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MUX31_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(1 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MUX41_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(1 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component BRANCH
		generic (	N:		integer);
		port (		REG_A:		in	std_logic_vector(N-1 downto 0);
				BNEZ_SEL:	in	std_logic;
				CONFIRM_BRANCH:	in	std_logic;
				CONFIRM_JMP:	in	std_logic;
				BRANCH_SEL:	out	std_logic);
	end component;
	
	component RCA_GEN_NO_C
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				S:	out	std_logic_vector(N-1 downto 0);
				Co:	out	std_logic);
	end component;

	--BRANCH SIGNALS:
	--####################
	signal IN_A_BRANCH:		std_logic_vector(N-1 downto 0);
	signal BRANCH_SEL_OUT:		std_logic;
	--####################

	--REGISTER FILE SIGNALS:
	--####################
	signal RST_REG_FILE:		std_logic;
	signal EN_REG_FILE:		std_logic;
	signal RD1_REG_FILE:		std_logic;
	signal RD2_REG_FILE:		std_logic;
	signal WR_REG_FILE:		std_logic;
	signal ADDR_WR_REG_FILE:	std_logic_vector(N_ADDR-1 downto 0);
	signal ADDR_RD1_REG_FILE:	std_logic_vector(N_ADDR-1 downto 0);
	signal ADDR_RD2_REG_FILE:	std_logic_vector(N_ADDR-1 downto 0);
	signal DATA_IN_REG_FILE:	std_logic_vector(N-1 downto 0);
	signal DATA_OUT_1_REG_FILE:	std_logic_vector(N-1 downto 0);
	signal DATA_OUT_2_REG_FILE:	std_logic_vector(N-1 downto 0);
	--####################

	--ADDER SIGNALS:
	--####################
	signal IN_A_ADDER:	std_logic_vector(N-1 downto 0);
	signal IN_B_ADDER:	std_logic_vector(N-1 downto 0);
	signal OUT_ADDER:	std_logic_vector(N-1 downto 0);
	signal Co_ADDER:	std_logic;
	--####################
	
	--MUX21_GEN SIGNALS:
	--####################
	signal IN_A_MUX:	std_logic_vector(N_ADDR-1 downto 0);
	signal IN_B_MUX:	std_logic_vector(N_ADDR-1 downto 0);
	signal OUT_MUX:		std_logic_vector(N_ADDR-1 downto 0);
	
	--INTERNAL SIGNALS:
	--####################
	signal REG_A_ADDR:	std_logic_vector(N_ADDR-1 downto 0);
	signal REG_B_ADDR:	std_logic_vector(N_ADDR-1 downto 0);
	signal IMMEDIATE_INT:	std_logic_vector(IMM_SIZE-1 downto 0);
	signal IMMEDIATE_EXT:	std_logic_vector(N-1 downto 0);
	signal IMMEDIATE_EXT_LHI:	std_logic_vector(N-1 downto 0);
	signal DEST_REG_1:	std_logic_vector(N_ADDR-1 downto 0);
	signal DEST_REG_2:	std_logic_vector(N_ADDR-1 downto 0);
	--####################
	
	begin
	
		REG_FILE_INST: REG_FILE	generic map (	N => N,
							N_ADDR => N_ADDR)
					port map (	CLK => CLK,
							RST => RST_REG_FILE,
							EN => EN_REG_FILE,
							RD1 => RD1_REG_FILE,
							RD2 => RD2_REG_FILE,
							WR => WR_REG_FILE,
							ADDR_WR => ADDR_WR_REG_FILE,
							ADDR_RD1 => ADDR_RD1_REG_FILE,
							ADDR_RD2 => ADDR_RD2_REG_FILE,
							DATA_IN => DATA_IN_REG_FILE,
							DATA_OUT_1 => DATA_OUT_1_REG_FILE,
							DATA_OUT_2 => DATA_OUT_2_REG_FILE);
		
		DEST_MUX: MUX31_GEN	generic map (	N => N_ADDR)
					port map (	A => IN_A_MUX,
							B => IN_B_MUX,
							C => "11111",
							SEL => SEL_DEST,
							Y => OUT_MUX);

		IMMEDIATE_MUX: MUX21_GEN	generic map (	N => N)
						port map (	A => IMMEDIATE_EXT_LHI,
								B => IMMEDIATE_EXT,
								SEL => LHI_SEL,
								Y => IMMEDIATE);

		NPC_MUX: MUX21_GEN	generic map (	N => N)
					port map (	A => DATA_OUT_1_REG_FILE,
							B => OUT_ADDER,
							SEL => JMP_SEL,
							Y => NPC_ADDED);
		
		BRANCH_JMP_ADDER: RCA_GEN_NO_C	generic map (	N => N)
						port map (	A => IN_A_ADDER,
								B => IN_B_ADDER,
								S => OUT_ADDER,
								Co => Co_ADDER);

		FORW_BRANCH_MUX: MUX41_GEN	generic map (	N => N)
						port map (	A => FORW_MEM_WB,
								B => FORW_ALU_WB,
								C => FORW_ALU_MEM,
								D => DATA_OUT_1_REG_FILE,
								SEL => SEL_MUX_BRANCH,
								Y => IN_A_BRANCH);

		INST_BRANCH: BRANCH	generic map (	N => N)
					port map (	REG_A => IN_A_BRANCH,
							BNEZ_SEL => BRANCH_TYPE,
							CONFIRM_BRANCH => CONFIRM_BRANCH,
							CONFIRM_JMP => CONFIRM_JMP,
							BRANCH_SEL => BRANCH_SEL_OUT);

		--REG_FILE SIGNAL ASSOCIATION:
		--####################
		RST_REG_FILE <= RST;
		EN_REG_FILE <= EN;
		RD1_REG_FILE <= RD1;
		RD2_REG_FILE <= RD2;
		WR_REG_FILE <= WR;
		ADDR_WR_REG_FILE <= ADDR_WR;
		ADDR_RD1_REG_FILE <= REG_A_ADDR;
		ADDR_RD2_REG_FILE <= REG_B_ADDR;
		DATA_IN_REG_FILE <= DATA_IN;
		--####################
		
		--MUX21_GEN SIGNAL ASSOCIATION:
		--####################
		IN_A_MUX <= DEST_REG_1;
		IN_B_MUX <= DEST_REG_2;
		--####################
		
		--RCA_GEN_NO_C SIGNAL ASSOCIATION:
		--####################
		IN_A_ADDER <= NPC;
		IN_B_ADDER <= IMMEDIATE_EXT;
		--####################
		
		--DECODE SIGNAL ASSOCIATION:
		--####################
		DEST_REG <= OUT_MUX;
		REG_A <= DATA_OUT_1_REG_FILE;
		REG_B <= DATA_OUT_2_REG_FILE;
		PC_SEL_MUX <= BRANCH_SEL_OUT;
		NPC_OUT <= NPC;
		--####################
		
		--INTERNAL SIGNAL ASSOCIATION:
		--####################
		REG_A_ADDR <= INSTRUCTION(N-OP_CODE_SIZE-1 downto N-OP_CODE_SIZE-N_ADDR);
		REG_B_ADDR <= INSTRUCTION(N-OP_CODE_SIZE-N_ADDR-1 downto N-OP_CODE_SIZE-2*N_ADDR);
		IMMEDIATE_INT <= INSTRUCTION(IMM_SIZE-1 downto 0);
		IMMEDIATE_EXT(IMM_SIZE-1 downto 0) <= IMMEDIATE_INT;
		IMMEDIATE_EXT(N-1 downto N-OP_CODE_SIZE-2*N_ADDR) <= (others => IMMEDIATE_INT(IMM_SIZE-1));
		IMMEDIATE_EXT_LHI(N-1 downto N/2) <= IMMEDIATE_INT;
		IMMEDIATE_EXT_LHI(N/2-1 downto 0) <= (others => '0');
		DEST_REG_1 <= INSTRUCTION(IMM_SIZE+N_ADDR-1 downto IMM_SIZE);
		DEST_REG_2 <= INSTRUCTION(IMM_SIZE-1 downto IMM_SIZE-N_ADDR);
		--####################
		
end STRUCTURAL;

configuration CFG_DECODE_STRUCTURAL of DECODE is
	for STRUCTURAL
		for all: REG_FILE
			use configuration WORK.CFG_REG_FILE_BEHAVIORAL;
		end for;
		for all: BRANCH
			use configuration WORK.CFG_BRANCH_STRUCTURAL;
		end for;
		for all: RCA_GEN_NO_C
			use configuration WORK.CFG_RCA_GEN_NO_C_STRUCTURAL;
		end for;
		for all: MUX21_GEN
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
		for all: MUX31_GEN
			use configuration WORK.CFG_MUX31_GEN_BEHAVIORAL;
		end for;
		for all: MUX41_GEN
			use configuration WORK.CFG_MUX41_GEN_BEHAVIORAL;
		end for;
	end for;
end CFG_DECODE_STRUCTURAL;