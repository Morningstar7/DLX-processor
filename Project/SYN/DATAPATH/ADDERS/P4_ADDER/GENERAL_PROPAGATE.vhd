library IEEE;
use IEEE.std_logic_1164.all;

entity GENERAL_PROPAGATE is
	port (		Pi:	in	std_logic_vector(1 downto 0);
			Po:	out	std_logic);
end GENERAL_PROPAGATE;

architecture STRUCTURAL of GENERAL_PROPAGATE is

	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	begin

		AND_INST: AND_GATE	port map (	A => Pi(1),
							B => Pi(0),
							Y => Po);

end STRUCTURAL;

configuration CFG_GENERAL_PROPAGATE_STRUCTURAL OF GENERAL_PROPAGATE is
	for STRUCTURAL
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_GENERAL_PROPAGATE_STRUCTURAL;