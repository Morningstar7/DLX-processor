library IEEE;
use IEEE.std_logic_1164.all;

entity EQU_COMPARATOR is
	generic (	N: integer);
	port (		A: in std_logic_vector(N-1 downto 0);
			B: in std_logic_vector(N-1 downto 0);
			Y: out std_logic);
end EQU_COMPARATOR;

architecture STRUCTURAL of EQU_COMPARATOR is

	component XNOR_GATE
		port (		A: in std_logic;
				B: in std_logic;
				Y: out std_logic);
	end component;
	
	component N_AND
		generic (	N: integer);
		port (		A: in std_logic_vector(N-1 downto 0);
				Y: out std_logic);
	end component;

	signal L: std_logic_vector(N-1 downto 0);

	begin

		XNOR_GENERATE: for i in 0 to N-1 generate
			XNORING: XNOR_GATE port map (	A => A(i),
							B => B(i),
							Y => L(i));
		end generate;
		
		ANDING: N_AND	generic map (	N => N)
				port map (	A => L,
						Y => Y);
		
end STRUCTURAL;

configuration CFG_EQU_COMPARATOR_STRUCTURAL of EQU_COMPARATOR is
	for STRUCTURAL
		for all: N_AND
			use configuration WORK.CFG_N_AND_BEHAVIORAL;
		end for;
		for XNOR_GENERATE
			for all: XNOR_GATE
				use configuration WORK.CFG_XNOR_GATE_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_EQU_COMPARATOR_STRUCTURAL;