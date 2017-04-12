library IEEE;
use IEEE.std_logic_1164.all;

entity PG_BLOCK is
	port (		Gi_0:	in	std_logic;
			Gi_1:	in	std_logic;
			Pi_0:	in	std_logic;
			Pi_1:	in std_logic;
			Po:	out	std_logic;
			Go:	out	std_logic);
end PG_BLOCK;

architecture STRUCTURAL of PG_BLOCK is

	signal pro_signal:	std_logic_vector(1 downto 0);

	component GENERAL_GENERATE
	port (		Gi_0:	in	std_logic;
			Gi_1:	in	std_logic;
			Pi:	in	std_logic;
			Go:	out	std_logic);
	end component;

	component GENERAL_PROPAGATE
		port (		Pi:	in	std_logic_vector(1 downto 0);
				Po:	out	std_logic);
	end component;

	begin

		GEN_BLOCK: GENERAL_GENERATE port map (	Gi_0 => Gi_0,
							Gi_1 => Gi_1,
							Pi => Pi_1,
							Go => Go);
							
		pro_signal <= Pi_1 & Pi_0;

		PRO_BLOCK: GENERAL_PROPAGATE port map (	Pi => pro_signal,
							Po => Po);

end STRUCTURAL;

configuration CFG_PG_BLOCK_STRUCTURAL OF PG_BLOCK is
	for STRUCTURAL
		for all: GENERAL_GENERATE
			use configuration WORK.CFG_GENERAL_GENERATE_STRUCTURAL;
		end for;
		for all: GENERAL_PROPAGATE
			use configuration WORK.CFG_GENERAL_PROPAGATE_STRUCTURAL;
		end for;
	end for;
end CFG_PG_BLOCK_STRUCTURAL;