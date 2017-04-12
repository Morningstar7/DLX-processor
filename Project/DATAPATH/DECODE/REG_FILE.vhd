library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
--use IEEE.math_real.all;

entity REG_FILE is
	generic (	N:	integer;
			N_ADDR:	integer);
	port	(	CLK:		in 	std_logic; 
			RST:		in	std_logic; 				-- Active high reset
			EN:		in	std_logic;				-- Active high enable
			RD1:		in	std_logic;				-- Enable read port1
			RD2:		in	std_logic;				-- Enable read port2
			WR:		in	std_logic;				-- Enable write
			ADDR_WR:	in	std_logic_vector(N_ADDR-1 downto 0);	-- Write address
			ADDR_RD1:	in	std_logic_vector(N_ADDR-1 downto 0);	-- Read address
			ADDR_RD2:	in	std_logic_vector(N_ADDR-1 downto 0);	-- Read address
			DATA_IN:	in	std_logic_vector(N-1 downto 0);		-- Write port
			DATA_OUT_1:	out	std_logic_vector(N-1 downto 0);		-- Read port 1
			DATA_OUT_2:	out	std_logic_vector(N-1 downto 0));	-- Read port 2
end REG_FILE;

architecture BEHAVIORAL of REG_FILE is
	
	constant	N_REG: 		integer := 2**N_ADDR;
	type		REG_ARRAY is array(N_REG-1 downto 0) of std_logic_vector(N-1 downto 0);
	signal		REGISTERS:	REG_ARRAY; 

	begin 
	
		RESETTING: process(RST, EN, RD1, RD2, WR, DATA_IN, ADDR_RD1, ADDR_RD2, CLK)
			begin
				if (RST = '1') then
					RESET_LOOP: for i in 0 to N_REG-1 loop
						REGISTERS(i) <= (others => '0');
					end loop RESET_LOOP;
				else
					if (WR = '1') then
						REGISTERS(to_integer(unsigned(ADDR_WR))) <= DATA_IN;
					end if;
					if falling_edge(CLK) then
						if (EN = '1') then
							if (RD1 = '1') then
								DATA_OUT_1 <= REGISTERS(to_integer(unsigned(ADDR_RD1)));
							end if;
							if (RD2 = '1') then
								DATA_OUT_2 <= REGISTERS(to_integer(unsigned(ADDR_RD2)));
							end if;
						end if;
					end if;
				end if;
		end process RESETTING;
end BEHAVIORAL;

configuration CFG_REG_FILE_BEHAVIORAL of REG_FILE is
  for BEHAVIORAL
  end for;
end configuration;
