library IEEE;
use IEEE.std_logic_1164.all;

entity GENERAL_GENERATE is
	port (	Gi_0:	in	std_logic;
		Gi_1:	in	std_logic;
		Pi:	in	std_logic;
		Go:	out	std_logic);
end GENERAL_GENERATE;

architecture STRUCTURAL of GENERAL_GENERATE is

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

	signal OUT_AND:	std_logic;

	begin

		AND_INST: AND_GATE	port map (	A => Pi,
							B => Gi_0,
							Y => OUT_AND);

		OR_INST: OR_GATE	port map (	A => Gi_1,
							B => OUT_AND,
							Y => Go);

end STRUCTURAL;

configuration CFG_GENERAL_GENERATE_STRUCTURAL of GENERAL_GENERATE is
	for STRUCTURAL
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: OR_GATE
			use configuration WORK.CFG_OR_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_GENERAL_GENERATE_STRUCTURAL;