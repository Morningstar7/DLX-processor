library IEEE;
use IEEE.std_logic_1164.all;

entity N_NOR is
	generic (	N: integer);
	port (		A: in	std_logic_vector(N-1 downto 0);
			Y: out	std_logic);
end N_NOR;

architecture BEHAVIORAL of N_NOR is

	signal B: std_logic_vector(N-1 downto 0);

	begin

		B <= (others => '0');
		Y <= '1' when A = B else
		'0';
		
end BEHAVIORAL;

configuration CFG_N_NOR_BEHAVIORAL of N_NOR is
	for BEHAVIORAL
	end for;
end CFG_N_NOR_BEHAVIORAL;