library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity DATA_MEMORY is
	generic (	M: integer;
			N: integer);
	port (		RESET:		in	std_logic;
			ENABLE:		in	std_logic;
			RM:		in	std_logic;
			WM:		in	std_logic;
			ADDR:		in	std_logic_vector(M-1 downto 0);
			DATA_IN:	in	std_logic_vector(N-1 downto 0);
			DATA_OUT:	out	std_logic_vector(N-1 downto 0));
end DATA_MEMORY;

architecture BEHAVIORAL of DATA_MEMORY is

	type MEM_ARRAY is array(2**M-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal MEM: MEM_ARRAY;

	begin

		MEM_PROC: process(ENABLE, RESET, DATA_IN, ADDR, WM, RM)
			begin
				if(RESET = '1') then
					for i in 0 to 2**M-1 loop
						MEM(i) <= (others => '0');
					end loop;
				else
					if (ENABLE = '1') then
						if (WM = '1') then
							MEM(to_integer(unsigned(ADDR))) <= DATA_IN;
						elsif (RM = '1') then
							DATA_OUT <= MEM(to_integer(unsigned(ADDR)));
						else
							NULL;
						end if;
					else
						NULL;
					end if;
				end if;
		end process MEM_PROC;

end BEHAVIORAL;

configuration CFG_DATA_MEMORY_BEHAVIORAL of DATA_MEMORY is
	for BEHAVIORAL
	end for;
end CFG_DATA_MEMORY_BEHAVIORAL;