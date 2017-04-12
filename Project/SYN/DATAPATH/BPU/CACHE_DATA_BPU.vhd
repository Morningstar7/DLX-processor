library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CACHE_DATA_BPU is
	generic (	N: integer;
			SET_BIT:	integer);
	port (		DATA_IN:	in	std_logic_vector(N-1 downto 0);
			DATA_OUT:	out	std_logic_vector(N-1 downto 0);
			ADDR:		in	std_logic_vector(SET_BIT-1 downto 0);
			CLK:		in	std_logic;
			WE:		in	std_logic);
end CACHE_DATA_BPU;

architecture BEHAVIORAL of CACHE_DATA_BPU is

	type MEM_MATRIX is array(2**SET_BIT-1 downto 0) of std_logic_vector(N-1 downto 0);

	signal CACHE_MEM: MEM_MATRIX;
	
	begin
	
		process (WE, ADDR, CLK)
			begin
				if(WE = '1') then
					if(CLK'event and CLK = '1') then
						CACHE_MEM(to_integer(unsigned(ADDR))) <= DATA_IN;
						DATA_OUT <= (others => '0');
					end if;
				else
					DATA_OUT <= CACHE_MEM(to_integer(unsigned(ADDR)));
				end if;
		end process;
		
end BEHAVIORAL;

configuration CFG_CACHE_DATA_BPU_BEHAVIORAL of CACHE_DATA_BPU is
	for BEHAVIORAL
	end for;
end CFG_CACHE_DATA_BPU_BEHAVIORAL;