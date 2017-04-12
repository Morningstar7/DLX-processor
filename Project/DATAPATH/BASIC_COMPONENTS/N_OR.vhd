library IEEE;
use IEEE.std_logic_1164.all;

entity N_OR is
	generic (	N: integer);
	port (		A: in std_logic_vector(N-1 downto 0);
			Y: out std_logic);
end N_OR;

architecture BEHAVIORAL of N_OR is

	signal B: std_logic_vector(N-1 downto 0);

	begin

		B <= (others => '0');
		Y <= '0' when A = B else '1';
		
end BEHAVIORAL;

configuration CFG_N_OR_BEHAVIORAL of N_OR is
	for BEHAVIORAL
	end for;
end CFG_N_OR_BEHAVIORAL;