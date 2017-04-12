library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_GEN is
	generic (	N: 	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic;
			Y:	out	std_logic_vector(N-1 downto 0));
end MUX21_GEN;

architecture STRUCTURAL of MUX21_GEN is

	signal Y1: std_logic_vector(N-1 downto 0);
	signal Y2: std_logic_vector(N-1 downto 0);
	signal SB: std_logic;

	component NAND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	begin
 
		UIV: INV	port map (	A => SEL,
						Y => SB);

		COMPGEN: for i in 0 to N-1 generate 
			UND1: NAND_GATE	port map (	A => A(i),
							B => SEL,
							Y => Y1(i));

			UND2: NAND_GATE	port map (	A => B(i),
							B => SB,
							Y => Y2(i));

			UND3: NAND_GATE	port map (	A => Y1(i),
							B => Y2(i),
							Y => Y(i));
		end generate;

end STRUCTURAL;

configuration CFG_MUX21_GEN_STRUCTURAL of MUX21_GEN is
	for STRUCTURAL
		for all: INV
			use configuration WORK.CFG_INV_BEHAVIORAL;
		end for;
		for COMPGEN
			for all: NAND_GATE
				use configuration WORK.CFG_NAND_GATE_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_MUX21_GEN_STRUCTURAL;
