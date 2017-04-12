library IEEE;
use IEEE.std_logic_1164.all;

entity BRANCH is
	generic (	N:		integer);
	port (		REG_A:		in	std_logic_vector(N-1 downto 0);
			BNEZ_SEL:	in	std_logic;
			CONFIRM_BRANCH:	in	std_logic;
			CONFIRM_JMP:	in	std_logic;
			BRANCH_SEL:	out	std_logic);
end BRANCH;

architecture STRUCTURAL of BRANCH is

	component EQU_COMPARATOR
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Y:	out	std_logic);
	end component;
	
	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component MUX21
		port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component OR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	--COMPARATOR SIGNALS:
	--####################
	signal IN_A_COMP:	std_logic_vector(N-1 downto 0);
	signal IN_B_COMP:	std_logic_vector(N-1 downto 0);
	signal OUT_COMP:	std_logic;
	--####################
	
	--INVERTER SIGNALS:
	--####################
	signal IN_INV:	std_logic;
	signal OUT_INV:	std_logic;
	--####################
	
	--MUX SIGNALS:
	--####################
	signal IN_A_MUX:	std_logic;
	signal IN_B_MUX:	std_logic;
	signal SEL_MUX:		std_logic;
	signal OUT_MUX:		std_logic;
	--####################
	
	--AND GATE SIGNALS:
	--####################
	signal IN_A_AND:	std_logic;
	signal IN_B_AND:	std_logic;
	signal OUT_AND:		std_logic;
	--####################
	
	--OR GATE SIGNALS:
	--####################
	signal IN_A_OR:	std_logic;
	signal IN_B_OR:	std_logic;
	signal OUT_OR:	std_logic;
	--####################
	
	begin
	
		COMPARATOR_INST: EQU_COMPARATOR	generic map (	N => N)
						port map (	A => IN_A_COMP,
								B => IN_B_COMP,
								Y => OUT_COMP);
		
		--COMPARATOR SIGNAL ASSOCIATION:
		--####################
		IN_A_COMP <= REG_A;
		IN_B_COMP <= (others => '0');
		--####################
		
		INV_INST: INV	port map (	A => IN_INV,
						Y => OUT_INV);
		
		--INVERTER SIGNAL ASSOCIATION:
		--####################
		IN_INV <= OUT_COMP;
		--####################
		
		MUX_INST: MUX21	port map (	A => IN_A_MUX,
						B => IN_B_MUX,
						S => SEL_MUX,
						Y => OUT_MUX);
		
		--MUX21 SIGNAL ASSOCIATION:
		--####################
		IN_A_MUX <= OUT_INV;
		IN_B_MUX <= OUT_COMP;
		SEL_MUX <= BNEZ_SEL;
		--####################
		
		AND_INST: AND_GATE	port map (	A => IN_A_AND,
							B => IN_B_AND,
							Y => OUT_AND);
		
		--AND GATE SIGNAL ASSOCIATION:
		--####################
		IN_A_AND <= OUT_MUX;
		IN_B_AND <= CONFIRM_BRANCH;
		--####################
		
		OR_INST: OR_GATE	port map (	A => IN_A_OR,
							B => IN_B_OR,
							Y => OUT_OR);
		
		--OR GATE SIGNAL ASSOCIATION:
		--####################
		IN_A_OR <= OUT_AND;
		IN_B_OR <= CONFIRM_JMP;
		--####################
		
		--BRANCH SIGNAL ASSOCIATION:
		--####################
		BRANCH_SEL <= OUT_OR;
		--####################
		
end STRUCTURAL;

configuration CFG_BRANCH_STRUCTURAL of BRANCH is
	for STRUCTURAL
		for all: EQU_COMPARATOR
			use configuration WORK.CFG_EQU_COMPARATOR_STRUCTURAL;
		end for;
		for all: INV
			use configuration WORK.CFG_INV_BEHAVIORAL;
		end for;
		for all: MUX21
			use configuration WORK.CFG_MUX21_STRUCTURAL;
		end for;
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: OR_GATE
			use configuration WORK.CFG_OR_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_BRANCH_STRUCTURAL;