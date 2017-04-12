library IEEE;
use IEEE.std_logic_1164.all;

entity XNOR_GATE is
	port (		A: in std_logic;
			B: in std_logic;
			Y: out std_logic);
end XNOR_GATE;

architecture BEHAVIORAL of XNOR_GATE is

	begin

		Y <= A xnor B;
		
end BEHAVIORAL;

configuration CFG_XNOR_GATE_BEHAVIORAL of XNOR_GATE is
	for BEHAVIORAL
	end for;
end CFG_XNOR_GATE_BEHAVIORAL;