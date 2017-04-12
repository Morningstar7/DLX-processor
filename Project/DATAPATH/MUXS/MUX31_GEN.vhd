library IEEE;
use IEEE.std_logic_1164.all;

entity MUX31_GEN is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			C:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic_vector(1 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end MUX31_GEN;

architecture BEHAVIORAL of MUX31_GEN is

	begin

		Y <=	A when SEL = "11" else
			B when SEL = "10" else
			C ;

end BEHAVIORAL;

configuration CFG_MUX31_GEN_BEHAVIORAL of MUX31_GEN is
	for BEHAVIORAL
	end for;
end CFG_MUX31_GEN_BEHAVIORAL;