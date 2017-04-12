library IEEE;
use IEEE.std_logic_1164.all;

entity OR_GATE is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		Y:	out	std_logic);
end OR_GATE;

architecture BEHAVIORAL of OR_GATE is

	begin

		Y <= A or B;
		
end BEHAVIORAL;

configuration CFG_OR_GATE_BEHAVIORAL of OR_GATE is
	for BEHAVIORAL
	end for;
end CFG_OR_GATE_BEHAVIORAL;