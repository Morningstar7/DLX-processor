library ieee; 
use ieee.std_logic_1164.all; 

entity HA is
	Port (	A:	in	std_logic;
		B:	in	std_logic;
		S:	out	std_logic;
		Co:	out	std_logic);
end HA;

architecture STRUCTURAL of HA is

	component XOR_GATE
		Port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	begin

		XOR_GATE_INST: XOR_GATE	port map (	A => A,
							B => B,
							Y => S);
		
		AND_GATE_INST: AND_GATE	port map (	A => A,
							B => B,
							Y => Co);
		
end STRUCTURAL;

configuration CFG_HA_STRUCTURAL of HA is	
	for STRUCTURAL
		for all: XOR_GATE
			use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
		end for;
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_HA_STRUCTURAL;