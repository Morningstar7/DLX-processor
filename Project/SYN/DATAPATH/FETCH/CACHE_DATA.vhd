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
				if(WE = '1')then
					if(CLK'event and CLK = '0') then
						SAVE_LOOP: for i in 0 to 7 loop
							CACHE_MEM(ADDR_INT)(OFFSET_INT*8+i) <= DATA_IN(i);
						end loop SAVE_LOOP;
						--CACHE_MEM(to_integer(unsigned(ADDR)))((to_integer(unsigned(OFFSET))+1)*8-1 downto to_integer(unsigned(OFFSET))*8) <= DATA_IN;
						DATA_OUT <= (others => '0');
					end if;
				elsif(WE = '0') then
					OUT_LOOP: for i in 0 to N-1 loop
						DATA_OUT(i) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+i);
					end loop OUT_LOOP;
-- 					DATA_OUT(0) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N);
-- 					DATA_OUT(1) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+1);
-- 					DATA_OUT(2) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+2);
-- 					DATA_OUT(3) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+3);
-- 					DATA_OUT(4) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+4);
-- 					DATA_OUT(5) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+5);
-- 					DATA_OUT(6) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+6);
-- 					DATA_OUT(7) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+7);
-- 					DATA_OUT(8) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+8);
-- 					DATA_OUT(9) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+9);
-- 					DATA_OUT(10) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+10);
-- 					DATA_OUT(11) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+11);
-- 					DATA_OUT(12) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+12);
-- 					DATA_OUT(13) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+13);
-- 					DATA_OUT(14) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+14);
-- 					DATA_OUT(15) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+15);
-- 					DATA_OUT(16) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+16);
-- 					DATA_OUT(17) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+17);
-- 					DATA_OUT(18) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+18);
-- 					DATA_OUT(19) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+19);
-- 					DATA_OUT(20) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+20);
-- 					DATA_OUT(21) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+21);
-- 					DATA_OUT(22) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+22);
-- 					DATA_OUT(23) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+23);
-- 					DATA_OUT(24) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+24);
-- 					DATA_OUT(25) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+25);
-- 					DATA_OUT(26) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+26);
-- 					DATA_OUT(27) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+27);
-- 					DATA_OUT(28) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+28);
-- 					DATA_OUT(29) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+29);
-- 					DATA_OUT(30) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+30);
-- 					DATA_OUT(31) <= CACHE_MEM(ADDR_INT)(OFFSET_INT/4*N+31);
					--DATA_OUT <= CACHE_MEM(to_integer(unsigned(ADDR)))((to_integer(unsigned(OFFSET))/4+1)*N-1 downto to_integer(unsigned(OFFSET))/4*N);
				end if;
		end process;
		
end BEHAVIORAL;

configuration CFG_CACHE_DATA_BEHAVIORAL of CACHE_DATA is
	for BEHAVIORAL
	end for;
end CFG_CACHE_DATA_BEHAVIORAL;