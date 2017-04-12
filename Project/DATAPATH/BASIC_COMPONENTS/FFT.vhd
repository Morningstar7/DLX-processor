library IEEE;
use IEEE.std_logic_1164.all;

entity FFT is
	port (	T:	in	std_logic;
		CLK:	In	std_logic;
		EN:	In	std_logic;
		RST:	In	std_logic;
		Q:	Out	std_logic);
end FFT;


architecture BEHAVIORAL of FFT is

	signal TMP: std_logic;

	begin
	
	Q <= TMP;
	
		PSYNCH: process(CLK, RST, EN)
		begin
			if CLK'event and CLK='1' then
				if RST = '1' then
					TMP <= '0';
				else
					if EN = '1' then
						TMP <= T xor TMP;
					end if;
				end if;
			end if;
		end process;

end BEHAVIORAL;

configuration CFG_FFT_BEHAVIORAL of FFT is
	for BEHAVIORAL
	end for;
end CFG_FFT_BEHAVIORAL;