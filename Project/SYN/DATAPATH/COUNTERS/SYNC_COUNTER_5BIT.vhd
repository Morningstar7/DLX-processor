library IEEE;
use IEEE.std_logic_1164.all;

entity SYNC_COUNTER_5BIT is
	port (	EN: 	in 	std_logic;
		RST:	in std_logic;
		CLK: 	In	std_logic;
		COUNT: out std_logic_vector(4 downto 0));
end SYNC_COUNTER_5BIT;

architecture STRUCTURAL of SYNC_COUNTER_5BIT is

	component AND_GATE
		port (		A: in std_logic;
					B: in std_logic;
					Y: out std_logic);
	end component;
	
	component FFT
		port (	T:	In	std_logic;
			CLK:	In	std_logic;
			EN:	In	std_logic;
			RST:	In	std_logic;
			Q:	Out	std_logic);
	end component;
	
	signal FFT_SIG:	std_logic_vector(4 downto 0);
	signal AND_SIG:	std_logic_vector(2 downto 0);
	
	begin
	
	COUNT(0) <= FFT_SIG(0);
	COUNT(1) <= FFT_SIG(1);
	COUNT(2) <= FFT_SIG(2);
	COUNT(3) <= FFT_SIG(3);
	COUNT(4) <= FFT_SIG(4);
	
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
								
		AND_1: AND_GATE port map (	A => FFT_SIG(0),
						B => FFT_SIG(1),
						Y => AND_SIG(0));

		FFT_3: FFT port map (	T => AND_SIG(0),
					CLK => CLK,
					EN => EN,
					RST => RST,
					Q => FFT_SIG(2));

		AND_2: AND_GATE port map (	A => AND_SIG(0),
						B => FFT_SIG(2),
						Y => AND_SIG(1));

		FFT_4: FFT port map (	T => AND_SIG(1),
					CLK => CLK,
					EN => EN,
					RST => RST,
					Q => FFT_SIG(3));

		AND_3: AND_GATE port map (	A => AND_SIG(1),
						B => FFT_SIG(3),
						Y => AND_SIG(2));

		FFT_5: FFT port map (	T => AND_SIG(2),
					CLK => CLK,
					EN => EN,
					RST => RST,
					Q => FFT_SIG(4));

end STRUCTURAL;

configuration CFG_SYNC_COUNTER_5BIT_STRUCTURAL of SYNC_COUNTER_5BIT is
	for STRUCTURAL
		for all: FFT
			use configuration WORK.CFG_FFT_BEHAVIORAL;
		end for;
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_SYNC_COUNTER_5BIT_STRUCTURAL;