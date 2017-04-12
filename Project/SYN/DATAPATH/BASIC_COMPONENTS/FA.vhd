library ieee; 
use ieee.std_logic_1164.all; 

entity FA is 
	Port (	A:	in	std_logic;
		B:	in	std_logic;
		Ci:	in	std_logic;
		S:	out	std_logic;
		Co:	out	std_logic);
end FA;

architecture STRUCTURAL of FA is

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
	
	component OR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	signal OUT_XOR:	std_logic;
	signal OUT_AND:	std_logic_vector(1 downto 0);
	signal OUT_OR:	std_logic;

	begin

		XOR_GATE_1: XOR_GATE	port map (	A => A,
							B => B,
							Y => OUT_XOR);
		
		XOR_GATE_2: XOR_GATE	port map (	A => OUT_XOR,
							B => Ci,
							Y => S);
		
		AND_GATE_1: AND_GATE	port map (	A => A,
							B => B,
							Y => OUT_AND(0));
		
		AND_GATE_2: AND_GATE	port map (	A => OUT_XOR,
							B => Ci,
							Y => OUT_AND(1));
		
		OR_GATE_1: OR_GATE	port map (	A => OUT_AND(0),
							B => OUT_AND(1),
							Y => Co);

end STRUCTURAL;

configuration CFG_FA_STRUCTURAL of FA is	
	for STRUCTURAL
		for all: XOR_GATE
			use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
		end for;
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: OR_GATE
			use configuration WORK.CFG_OR_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_FA_STRUCTURAL;
