library ieee; 
use ieee.std_logic_1164.all; 

entity XOR_GATE is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		Y:	out	std_logic);
end XOR_GATE;

architecture BEHAVIORAL of XOR_GATE is

	begin
	
		Y <= A xor B;
		
end BEHAVIORAL;

configuration CFG_XOR_GATE_BEHAVIORAL of XOR_GATE is
	for BEHAVIORAL
	end for;
end CFG_XOR_GATE_BEHAVIORAL;