library IEEE;
use IEEE.std_logic_1164.all;

entity NOR_GATE is
	port (		A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
end NOR_GATE;

architecture BEHAVIORAL of NOR_GATE is

	begin

		Y <= not (A or B);
		
end BEHAVIORAL;

configuration CFG_NOR_GATE_BEHAVIORAL of NOR_GATE is
	for BEHAVIORAL
	end for;
end CFG_NOR_GATE_BEHAVIORAL;