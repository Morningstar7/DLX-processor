library IEEE;
use IEEE.std_logic_1164.all;

entity MUX61 is
	port (		A:	in	std_logic;
			B:	in	std_logic;
			C:	in	std_logic;
			D:	in	std_logic;
			E:	in	std_logic;
			F:	in	std_logic;
			SEL:	in	std_logic_vector(2 downto 0);
			Y:	out	std_logic);
end MUX61;

architecture BEHAVIORAL of MUX61 is

	begin

		Y <=	A when SEL = "111" else
			B when SEL = "110" else
			C when SEL = "101" else
			D when SEL = "100" else
			E when SEL = "011" else
			F;

end BEHAVIORAL;

configuration CFG_MUX61_BEHAVIORAL of MUX61 is
	for BEHAVIORAL
	end for;
end CFG_MUX61_BEHAVIORAL;