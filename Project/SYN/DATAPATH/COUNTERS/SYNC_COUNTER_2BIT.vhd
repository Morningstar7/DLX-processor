library IEEE;
use IEEE.std_logic_1164.all;

entity SYNC_COUNTER_2BIT is
	port (	EN:	in 	std_logic;
		RST:	in	std_logic;
		CLK:	in	std_logic;
		COUNT:	out	std_logic_vector(1 downto 0));
end SYNC_COUNTER_2BIT;

architecture STRUCTURAL of SYNC_COUNTER_2BIT is

	component FFT
		port (	T:	In	std_logic;
			CLK:	In	std_logic;
			EN:	In	std_logic;
			RST:	In	std_logic;
			Q:	Out	std_logic);
	end component;
	
	signal FFT_SIG:	std_logic_vector(1 downto 0);
	
	begin
	
	COUNT(0) <= FFT_SIG(0);
	COUNT(1) <= FFT_SIG(1);
	
		FFT_1: FFT port map (	T => '1',
					CLK => CLK,
					EN => EN,
					RST => RST,
					Q => FFT_SIG(0));
								
		FFT_2: FFT port map (	T => FFT_SIG(0),
					CLK => CLK,
					EN => EN,
					RST => RST,
					Q => FFT_SIG(1));

end STRUCTURAL;

configuration CFG_SYNC_COUNTER_2BIT_STRUCTURAL of SYNC_COUNTER_2BIT is
	for STRUCTURAL
		for all: FFT
			use configuration WORK.CFG_FFT_BEHAVIORAL;
		end for;
	end for;
end CFG_SYNC_COUNTER_2BIT_STRUCTURAL;