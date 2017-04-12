library IEEE;
use IEEE.std_logic_1164.all;

entity REG is
	generic (	N:	integer);
	port (		D: 	in 	std_logic_vector(N-1 downto 0);
			Q: 	out	std_logic_vector(N-1 downto 0);
			EN:	in	std_logic;
			RST:	in 	std_logic;
			CLK: 	in	std_logic);
end REG;
	
architecture STRUCTURAL of REG is 

	component FD is
	Port (	D:	in	std_logic;
		CLK:	in	std_logic;
		EN:	in	std_logic;
		RST:	in	std_logic;
		Q:	out	std_logic);
	end component; 

	begin

		RegGen : for i in 0 to N-1 generate

			FF : FD port map (	D => D(i),
						CLK => CLK,
						EN => EN,
						RST => RST,
						Q => Q(i));
		end generate;

end STRUCTURAL;

configuration CFG_REG_SYN_STRUCTURAL of REG is 
	for  STRUCTURAL
		for RegGen
			for all : FD
				use configuration WORK.CFG_FD_PIPPO;
			end  for;
		end for;
	end for;
end CFG_REG_SYN_STRUCTURAL;

-- configuration CFG_REG_ASYN_STRUCTURAL of REG is 
-- 	for  STRUCTURAL
-- 		for RegGen
-- 			for all : FD
-- 				use configuration WORK.CFG_FD_PLUTO;
-- 			end  for;
-- 		end for;
-- 	end for;
-- end CFG_REG_ASYN_STRUCTURAL;