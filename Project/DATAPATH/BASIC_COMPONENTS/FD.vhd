library IEEE;
use IEEE.std_logic_1164.all;

entity FD is
	port(	D:	in	std_logic;
		CLK:	in	std_logic;
		EN:	in	std_logic;
		RST:	in	std_logic;
		Q:	out	std_logic);
end FD;

architecture PIPPO of FD is --FFD with syncronous reset

	begin
		PSYNCH: process(CLK, RST, EN)
			begin
				if CLK'event and CLK = '1' then
					if RST = '1' then
						Q <= '0';
					else
						if EN = '1' then
							Q <= D; --input is written on output
						end if;
					end if;
				end if;
		end process;

end PIPPO;

-- architecture PLUTO of FD is --FFD with asyncronous reset
-- 
-- 	begin
-- 	
-- 		PASYNCH: process(CLK, RST, EN)
-- 			begin
-- 				if RST='1' then
-- 					Q <= '0';
-- 				elsif CLK'event and CLK='1' then --positive edge triggered:
-- 					if EN = '1' then
-- 						Q <= D; 
-- 					end if;
-- 				end if;
-- 		end process;
-- 
-- end PLUTO;

configuration CFG_FD_PIPPO of FD is
	for PIPPO
	end for;
end CFG_FD_PIPPO;

-- configuration CFG_FD_PLUTO of FD is
-- 	for PLUTO
-- 	end for;
-- end CFG_FD_PLUTO;