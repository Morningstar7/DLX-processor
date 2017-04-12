library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CAM is
	generic (	TAG_BIT: integer;
			SET_BIT: integer);
	port (		TAG_IN: in std_logic_vector(TAG_BIT-1 downto 0);
			TAG_OUT: out std_logic_vector(TAG_BIT-1 downto 0);
			SET_INDEX: in std_logic_vector(SET_BIT-1 downto 0);
			COUNT:	in	std_logic_vector(4 downto 0);
			VALID: out std_logic;
			CLK:	in	std_logic;
			RST: in std_logic;
			WE: in std_logic);
end CAM;

architecture BEHAVIORAL of CAM is

	type CAM_MATRIX is array(2**SET_BIT-1 downto 0) of std_logic_vector(TAG_BIT-1 downto 0);

	signal CAM_MEM: CAM_MATRIX;
	signal VALID_BIT: std_logic_vector(2**SET_BIT-1 downto 0);
	--signal SET_INDEX_INTEGER: integer;
	
	begin
	
		--SET_INDEX_INTEGER <= to_integer(unsigned(SET_INDEX));
	
		process (WE, RST, SET_INDEX, CAM_MEM, VALID_BIT, CLK, COUNT)
			begin
				if(RST = '1') then
					VALID_BIT <= (others => '0');
				else
					--if CLK'event and CLK = '0' then
						if(WE = '1') then
							CAM_MEM(to_integer(unsigned(SET_INDEX))) <= TAG_IN;
							VALID_BIT(to_integer(unsigned(SET_INDEX))) <= '1';
							TAG_OUT <= CAM_MEM(to_integer(unsigned(SET_INDEX)));
							if(COUNT = "11111") then
								if CLK'event and CLK = '1' then
									VALID <= VALID_BIT(to_integer(unsigned(SET_INDEX)));
								end if;
							else
								VALID <= '0';
							end if;
						else
							TAG_OUT <= CAM_MEM(to_integer(unsigned(SET_INDEX)));
							VALID <= VALID_BIT(to_integer(unsigned(SET_INDEX)));
						end if;
					--end if;
				end if;
		end process;
		
end BEHAVIORAL;

configuration CFG_CAM_BEHAVIORAL of CAM is
	for BEHAVIORAL
	end for;
end CFG_CAM_BEHAVIORAL;