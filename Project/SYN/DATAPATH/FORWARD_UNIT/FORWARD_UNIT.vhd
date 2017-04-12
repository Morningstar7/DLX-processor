library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;

entity FORWARD_UNIT is 
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
end FORWARD_UNIT;

architecture STRUCTURAL of FORWARD_UNIT is

	component EQU_COMPARATOR
		generic (	N: integer);
		port (		A: in std_logic_vector(N-1 downto 0);
				B: in std_logic_vector(N-1 downto 0);
				Y: out std_logic);
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
	
	component FORW_FSM
		generic ( 	OPCODE_SIZE: integer;
				N_ADDR: integer);
		port 	(	CLK:		in	std_logic; 
				RST:		in	std_logic; 
				CMP_A_EXE:	in	std_logic;
				CMP_A_MEM:	in	std_logic;
				CMP_B_EXE:	in	std_logic;
				CMP_B_MEM:	in	std_logic;
				CMP_C_EXE:	in	std_logic;  -- CMP_B_MEM PIPED;	
				CMP_C_MEM:	in	std_logic;
				CMP_BRANCH_ID:	in	std_logic;
				CMP_BRANCH_EXE:	in	std_logic;
				CMP_BRANCH_MEM:	in	std_logic;
				OPCODE_IF:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				OPCODE_ID:	in	std_logic_vector(OPCODE_SIZE-1 downto 0); 
				OPCODE_EXE:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				OPCODE_MEM:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				OPCODE_WB:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
				MUX_A:		out	std_logic_vector(1 downto 0);
				MUX_B:		out	std_logic_vector(1 downto 0);
				MUX_C:		out	std_logic_vector(1 downto 0);
				MUX_D:		out	std_logic_vector(1 downto 0);
				RST_DIV:	out	std_logic;
				STALL_BRANCH:	out	std_logic;
				STALL:		out	std_logic);
	end component;

	signal	CMP_A_EXE:	std_logic;
	signal	CMP_A_MEM:	std_logic;
	signal	CMP_B_EXE:	std_logic;
	signal	CMP_B_MEM:	std_logic;
	signal	CMP_C_EXE:	std_logic;
	signal	CMP_C_MEM:	std_logic;
	signal	STALL_SIG:	std_logic;
	signal	STALL_BRANCH_SIG:	std_logic;
	signal	EN_REG:		std_logic;
	signal CMP_BRANCH_ID: std_logic;
	signal CMP_BRANCH_EXE: std_logic;
	signal CMP_BRANCH_MEM: std_logic;

	
	signal OPCODE_EXE: std_logic_vector(OPCODE_SIZE-1 downto 0);
	signal OPCODE_MEM: std_logic_vector(OPCODE_SIZE-1 downto 0);
	signal OPCODE_WB: std_logic_vector(OPCODE_SIZE-1 downto 0);

	signal RST_DIV_SIG: std_logic;

	begin

		RST_DIV <= RST_DIV_SIG;

		STALL <= STALL_SIG;
		STALL_BRANCH <= STALL_BRANCH_SIG;
		EN_REG <= not STALL_SIG;

		CMP_EXE_A: EQU_COMPARATOR 	generic map(	N => N_ADDR)
						port map(	A => REG_A,
								B => REG_DEST_EXE,
								Y => CMP_A_EXE);

		CMP_MEM_A: EQU_COMPARATOR	generic map(	N => N_ADDR)
						port map(	A => REG_A,
								B => REG_DEST_MEM,
								Y => CMP_A_MEM);

		CMP_EXE_B: EQU_COMPARATOR	generic map(	N => N_ADDR)
						port map(	A => REG_B,
								B => REG_DEST_EXE,
								Y => CMP_B_EXE);

		CMP_MEM_B: EQU_COMPARATOR	generic map(	N => N_ADDR)
						port map(	A => REG_B,
								B => REG_DEST_MEM,
								Y => CMP_B_MEM);

		CMP_ID_IF: EQU_COMPARATOR	generic map (	N => N_ADDR)
						port map (	A => REG_A_IF,
								B => REG_DEST_ID,
								Y => CMP_BRANCH_ID);

		CMP_ID_EXE: EQU_COMPARATOR	generic map (	N => N_ADDR)
						port map (	A => REG_A_IF,
								B => REG_DEST_EXE,
								Y => CMP_BRANCH_EXE);

		CMP_ID_MEM: EQU_COMPARATOR	generic map (	N => N_ADDR)
						port map (	A => REG_A_IF,
								B => REG_DEST_MEM,
								Y => CMP_BRANCH_MEM);

		OP_PIPE_ID_EXE: REG	generic map (	N => OPCODE_SIZE)
					port map (	D => OPCODE_ID,
							Q => OPCODE_EXE,
							EN => EN_REG,
							RST => RST,
							CLK => CLK);
		
		OP_PIPE_EXE_MEM: REG	generic map (	N => OPCODE_SIZE)
					port map (	D => OPCODE_EXE,
							Q => OPCODE_MEM,
							EN => EN_REG,
							RST => RST,
							CLK => CLK);

		OP_PIPE_MEM_WB: REG	generic map (	N => OPCODE_SIZE)
					port map (	D => OPCODE_MEM,
							Q => OPCODE_WB,
							EN => '1',
							RST => RST,
							CLK => CLK);

		CMP_PIPE_C_EXE: FD	port map (	D => CMP_B_EXE,
							CLK => CLK,
							EN => EN_REG,
							RST => RST,
							Q => CMP_C_EXE);

		CMP_PIPE_C_MEM: FD	port map (	D => CMP_B_MEM,
							CLK => CLK,
							EN => EN_REG,
							RST => RST,
							Q => CMP_C_MEM);

		FSM_FORWARD: FORW_FSM	generic map (	OPCODE_SIZE => OPCODE_SIZE,
							N_ADDR => N_ADDR)
					port map ( 	CLK => CLK,
							RST => RST,
							OPCODE_IF => OPCODE_IF,
							OPCODE_ID => OPCODE_ID,
							OPCODE_EXE => OPCODE_EXE,
							OPCODE_MEM => OPCODE_MEM,
							OPCODE_WB => OPCODE_WB,
							CMP_A_EXE => CMP_A_EXE,
							CMP_A_MEM => CMP_A_MEM,
							CMP_B_EXE => CMP_B_EXE,
							CMP_B_MEM => CMP_B_MEM,
							CMP_C_EXE => CMP_C_EXE,
							CMP_C_MEM => CMP_C_MEM,
							CMP_BRANCH_ID => CMP_BRANCH_ID,
							CMP_BRANCH_EXE => CMP_BRANCH_EXE,
							CMP_BRANCH_MEM => CMP_BRANCH_MEM,
							MUX_A  => MUX_A,
							MUX_B  => MUX_B,
							MUX_C => MUX_C,
							MUX_D => MUX_D,
							RST_DIV => RST_DIV_SIG,
							STALL_BRANCH => STALL_BRANCH_SIG,
							STALL => STALL_SIG);

end STRUCTURAL; 

configuration CFG_FORWARD_UNI_STRUCTURAL of FORWARD_UNIT is
	for STRUCTURAL
		for all: FORW_FSM
			use configuration WORK.CFG_FORW_FSM_BEHAVIORAL;
		end for;
		for all: FD
			use configuration WORK.CFG_FD_PIPPO;
		end for;
		for all: REG
			use configuration WORK.CFG_REG_SYN_STRUCTURAL;
		end for;
		for all: EQU_COMPARATOR
			use configuration WORK.CFG_EQU_COMPARATOR_STRUCTURAL;
		end for;
	end for;
end CFG_FORWARD_UNI_STRUCTURAL;





