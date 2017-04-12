library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21 is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		S:	in	std_logic;
		Y:	out	std_logic);
end MUX21;

architecture STRUCTURAL of MUX21 is

	signal Y1: std_logic;
	signal Y2: std_logic;
	signal SB: std_logic;

	component NAND_GATE
		Port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;
	
	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	begin

		UIV: INV	port map (	A => S,
						Y => SB);

		UND1: NAND_GATE	port map (	A => A,
						B => S,
						Y => Y1);

		UND2: NAND_GATE	port map (	A => B,
						B => SB,
						Y => Y2);

		UND3: NAND_GATE	port map (	A => Y1,
						B => Y2,
						Y => Y);

end STRUCTURAL;

configuration CFG_MUX21_STRUCTURAL of MUX21 is
	for STRUCTURAL
		for all : INV
			use configuration WORK.CFG_INV_BEHAVIORAL;
		end for;
		for all : NAND_GATE
			use configuration WORK.CFG_NAND_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_MUX21_STRUCTURAL;
