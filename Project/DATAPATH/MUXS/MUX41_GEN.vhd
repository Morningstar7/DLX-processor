library IEEE;
use IEEE.std_logic_1164.all;

entity MUX41_GEN is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			C:	in	std_logic_vector(N-1 downto 0);
			D:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic_vector(1 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end MUX41_GEN;

architecture BEHAVIORAL of MUX41_GEN is

	begin

		Y <=	A when SEL = "11" else
			B when SEL = "10" else
			C when SEL = "01" else
			D;

end BEHAVIORAL;

configuration CFG_MUX41_GEN_BEHAVIORAL of MUX41_GEN is
	for BEHAVIORAL
	end for;
end CFG_MUX41_GEN_BEHAVIORAL;