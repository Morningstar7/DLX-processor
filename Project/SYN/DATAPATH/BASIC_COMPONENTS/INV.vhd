library IEEE;
use IEEE.std_logic_1164.all;

entity INV is
	port (	A:	in	std_logic;
		Y:	out	std_logic);
end INV;


architecture BEHAVIORAL of INV is

	begin

		Y <= not(A);

end BEHAVIORAL;

configuration CFG_INV_BEHAVIORAL of INV is
	for BEHAVIORAL
	end for;
end CFG_INV_BEHAVIORAL;
