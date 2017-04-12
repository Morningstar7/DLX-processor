library IEEE;
use IEEE.std_logic_1164.all;

entity MUX51_GEN is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			C:	in	std_logic_vector(N-1 downto 0);
			D:	in	std_logic_vector(N-1 downto 0);
			E:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic_vector(2 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end MUX51_GEN;

architecture BEHAVIORAL of MUX51_GEN is

	begin

		Y <=	A when SEL = "111" else
			B when SEL = "110" else
			C when SEL = "101" else
			D when SEL = "100" else
			E;

end BEHAVIORAL;

configuration CFG_MUX51_GEN_BEHAVIORAL of MUX51_GEN is
	for BEHAVIORAL
	end for;
end CFG_MUX51_GEN_BEHAVIORAL;