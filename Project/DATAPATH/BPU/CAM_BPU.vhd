library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CAM_BPU is
	generic (	N:		integer;
			SET_BIT:	integer);
	port (		ADDR:		in	std_logic_vector(SET_BIT-1 downto 0);
			RST:		in	std_logic;
			WE:		in	std_logic;
			DATA_IN:	in	std_logic_vector(N-1 downto 0);
			ADDR_OUT_1:	out	std_logic_vector(N-1 downto 0);
			ADDR_OUT_2:	out	std_logic_vector(N-1 downto 0);
			ADDR_OUT_3:	out	std_logic_vector(N-1 downto 0);
			ADDR_OUT_4:	out	std_logic_vector(N-1 downto 0);
			VALID_1:	out	std_logic;
			VALID_2:	out	std_logic;
			VALID_3:	out	std_logic;
			VALID_4:	out	std_logic);
end CAM_BPU;

architecture BEHAVIORAL of CAM_BPU is

	type CAM_MATRIX is array(2**SET_BIT-1 downto 0) of std_logic_vector(N-1 downto 0);

	signal CAM_MEM: CAM_MATRIX;
	signal VALID_BIT: std_logic_vector(2**SET_BIT-1 downto 0);
	
	begin
	
		process (WE, RST, ADDR)
			begin
				if(RST = '1') then
					VALID_BIT <= (others => '0');
				else
						if(WE = '1') then
							CAM_MEM(to_integer(unsigned(ADDR))) <= DATA_IN;
							VALID_BIT(to_integer(unsigned(ADDR))) <= '1';
						else
							ADDR_OUT_1 <= CAM_MEM(0);
							ADDR_OUT_2 <= CAM_MEM(1);
							ADDR_OUT_3 <= CAM_MEM(2);
							ADDR_OUT_4 <= CAM_MEM(3);
							VALID_1 <= VALID_BIT(0);
							VALID_2 <= VALID_BIT(1);
							VALID_3 <= VALID_BIT(2);
							VALID_4 <= VALID_BIT(3);
						end if;
					--end if;
				end if;
		end process;
		
end BEHAVIORAL;

configuration CFG_CAM_BPU_BEHAVIORAL of CAM_BPU is
	for BEHAVIORAL
	end for;
end CFG_CAM_BPU_BEHAVIORAL;