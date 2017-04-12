library IEEE;
use IEEE.std_logic_1164.all;

entity N_AND is
	generic (	N: integer);
	port (		A: in std_logic_vector(N-1 downto 0);
			Y: out std_logic);
end N_AND;

architecture BEHAVIORAL of N_AND is

	signal B: std_logic_vector(N-1 downto 0);

	begin

		B <= (others => '1');
		Y <= '1' when A = B else '0';
		
end BEHAVIORAL;

configuration CFG_N_AND_BEHAVIORAL of N_AND is
	for BEHAVIORAL
	end for;
end CFG_N_AND_BEHAVIORAL;