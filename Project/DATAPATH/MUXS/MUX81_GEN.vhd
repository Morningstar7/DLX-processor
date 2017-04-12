library IEEE;
use IEEE.std_logic_1164.all;

entity MUX81_GEN is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			C:	in	std_logic_vector(N-1 downto 0);
			D:	in	std_logic_vector(N-1 downto 0);
			E:	in	std_logic_vector(N-1 downto 0);
			F:	in	std_logic_vector(N-1 downto 0);
			G:	in	std_logic_vector(N-1 downto 0);
			H:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic_vector(2 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end MUX81_GEN;

architecture BEHAVIORAL of MUX81_GEN is

	begin

		Y <=	A when SEL = "111" else
			B when SEL = "110" else
			C when SEL = "101" else
			D when SEL = "100" else
			E when SEL = "011" else
			F when SEL = "010" else
			G when SEL = "001" else
			H;

end BEHAVIORAL;

configuration CFG_MUX81_GEN_BEHAVIORAL of MUX81_GEN is
	for BEHAVIORAL
	end for;
end CFG_MUX81_GEN_BEHAVIORAL;