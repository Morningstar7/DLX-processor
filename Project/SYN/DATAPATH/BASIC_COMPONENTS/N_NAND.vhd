library IEEE;
use IEEE.std_logic_1164.all;

entity N_NAND is
	generic (	N: integer);
	port (		A: in	std_logic_vector(N-1 downto 0);
			Y: out	std_logic);
end N_NAND;

architecture BEHAVIORAL of N_NAND is

	signal B: std_logic_vector(N-1 downto 0);

	begin

		B <= (others => '1');
		Y <= '0' when A = B else '1';
		
end BEHAVIORAL;

configuration CFG_N_NAND_BEHAVIORAL of N_NAND is
	for BEHAVIORAL
	end for;
end CFG_N_NAND_BEHAVIORAL;