library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity DATA_MEMORY is
	generic (	M: integer;
			N: integer);
	port (		RESET:		in	std_logic;
			CLK:		in	std_logic;
			RM:		in	std_logic;
			WM:		in	std_logic;
			LOAD:		in	std_logic;
			ADDR:		in	std_logic_vector(N-1 downto 0);
			DATA_IN:	in	std_logic_vector(N-1 downto 0);
			DATA_OUT:	out	std_logic_vector(N-1 downto 0));
end DATA_MEMORY;

architecture BEHAVIORAL of DATA_MEMORY is

	type MEM_ARRAY is array(2**M-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal MEM: MEM_ARRAY := (others => (others => '0'));

	begin

		MEM_PROC: process(WM, RM, RESET, LOAD, CLK)
			file mem_fp: text;
			variable file_line : line;
			variable index : integer := 0;
			variable tmp_data_u : std_logic_vector(N-1 downto 0);
			begin
				if(LOAD = '1') then
					file_open(mem_fp,"memory.asm.mem",READ_MODE);
					while (not endfile(mem_fp)) loop
						readline(mem_fp,file_line);
						hread(file_line,tmp_data_u);			--CONVERT TO STD_LOGIC_VECTOR
						MEM(index) <= tmp_data_u;
						index := index + 1;
					end loop;
					file_close(mem_fp);
				else
					if(RESET = '0') then
						if falling_edge(CLK) then
							if (RM = '1') then
								DATA_OUT <= MEM(conv_integer(unsigned(ADDR)));
							elsif (WM = '1') then
								MEM(conv_integer(unsigned(ADDR))) <= DATA_IN;
							end if;
						end if;
					end if;
				end if;
		end process MEM_PROC;

end BEHAVIORAL;

configuration CFG_DATA_MEMORY_BEHAVIORAL of DATA_MEMORY is
	for BEHAVIORAL
	end for;
end CFG_DATA_MEMORY_BEHAVIORAL;