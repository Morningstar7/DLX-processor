library IEEE;
use IEEE.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CACHE_DATA is
	generic (	N: integer;
			N_DATA: integer;
			SET_BIT: integer);
	port (		DATA_IN: in std_logic_vector(7 downto 0);
			DATA_OUT: out std_logic_vector(N-1 downto 0);
			ADDR: in std_logic_vector(SET_BIT-1 downto 0);
			OFFSET: in std_logic_vector(N_DATA-1 downto 0);
			CLK: in std_logic;
			WE: in std_logic);
end CACHE_DATA;

architecture BEHAVIORAL of CACHE_DATA is

	type MEM_MATRIX is array(2**SET_BIT-1 downto 0) of std_logic_vector(2**(N_DATA-2)*N-1 downto 0);

	signal CACHE_MEM: MEM_MATRIX;
	signal ADDR_INT:	integer;
	signal OFFSET_INT:	integer;
	
	begin

		ADDR_INT <= to_integer(unsigned(ADDR));
		OFFSET_INT <= to_integer(unsigned(OFFSET));
	
		process (WE, OFFSET, ADDR, CLK)
			begin
				if(WE = '1') then
					if(CLK'event and CLK = '0') then
						SAVE_LOOP: for i in 0 to 7 loop
							CACHE_MEM(ADDR_INT)(OFFSET_INT*8+i) <= DATA_IN(i);
						end loop SAVE_LOOP;
						--CACHE_MEM(to_integer(unsigned(ADDR)))((to_integer(unsigned(OFFSET))+1)*8-1 downto to_integer(unsigned(OFFSET))*8) <= DATA_IN;
						DATA_OUT <= (others => '0');
					end if;
				else
					OUT_LOOP: for i in 0 to N-1 loop
						DATA_OUT(i) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+i);
					end loop OUT_LOOP;
				end if;
		end process;
		
end BEHAVIORAL;

configuration CFG_CACHE_DATA_BEHAVIORAL of CACHE_DATA is
	for BEHAVIORAL
	end for;
end CFG_CACHE_DATA_BEHAVIORAL;