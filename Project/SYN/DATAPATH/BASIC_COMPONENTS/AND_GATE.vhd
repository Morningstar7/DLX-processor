library IEEE;
use IEEE.std_logic_1164.all;

entity AND_GATE is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		Y:	out	std_logic);
end AND_GATE;

architecture BEHAVIORAL of AND_GATE is

	begin

		Y <= A and B;
		
end BEHAVIORAL;

configuration CFG_AND_GATE_BEHAVIORAL of AND_GATE is
	for BEHAVIORAL
	end for;
end CFG_AND_GATE_BEHAVIORAL;