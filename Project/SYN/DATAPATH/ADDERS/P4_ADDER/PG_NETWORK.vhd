library IEEE;
use IEEE.std_logic_1164.all;

entity PG_NETWORK is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Ci:	in	std_logic;
			G:	out	std_logic_vector(N-1 downto 0);
			P:	out	std_logic_vector(N-1 downto 0));
end PG_NETWORK;

architecture STRUCTURAL of PG_NETWORK is

	signal P_tmp: std_logic;
	signal G_tmp: std_logic;

	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component XOR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component GENERAL_GENERATE
		port (	Gi_0:	in	std_logic;
			Gi_1:	in	std_logic;
			Pi:	in	std_logic;
			Go:	out	std_logic);
	end component;

	begin

		FIRST_GEN_BLOCK: AND_GATE port map (	A => A(0),
							B => B(0),
							Y => G_tmp);

		FIRST_PRO_BLOCK: XOR_GATE port map (	A => A(0),
							B => B(0),
							Y => P_tmp);

		FIRST_GENERATE: GENERAL_GENERATE port map (	Gi_0 => Ci,
								Gi_1 => G_tmp,
								Pi => P_tmp,
								Go => G(0));

		P(0) <= '0';

		NETWORK_GEN: for i in 1 to N-1 generate
			GEN_BLOCK:	AND_GATE port map (	A => A(i),
								B => B(i),
								Y => G(i));

			PRO_BLOCK:	XOR_GATE port map (	A => A(i),
								B => B(i),
								Y => P(i));
		end generate;

end STRUCTURAL;

configuration CFG_PG_NETWORK_STRUCTURAL of PG_NETWORK is
	for STRUCTURAL
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: XOR_GATE
			use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
		end for;
		for all: GENERAL_GENERATE
			use configuration WORK.CFG_GENERAL_GENERATE_STRUCTURAL;
		end for;
		for NETWORK_GEN
			for all: AND_GATE
				use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
			end for;
			for all: XOR_GATE
				use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_PG_NETWORK_STRUCTURAL;