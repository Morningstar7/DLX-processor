library IEEE;
use IEEE.std_logic_1164.all;

entity NAND_GATE is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		Y:	out	std_logic);
end NAND_GATE;


architecture BEHAVIORAL of NAND_GATE is

	begin
		Y <= not( A and B);

end BEHAVIORAL;

configuration CFG_NAND_GATE_BEHAVIORAL of NAND_GATE is
	for BEHAVIORAL
	end for;
end CFG_NAND_GATE_BEHAVIORAL;