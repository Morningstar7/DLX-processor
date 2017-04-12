library IEEE;
use IEEE.std_logic_1164.all;

entity BPU_ENCODER is
	port (	A:	in	std_logic_vector(3 downto 0);
		Y:	out	std_logic_vector(1 downto 0));
end BPU_ENCODER;

architecture STRUCTURAL of BPU_ENCODER is

	component OR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	begin

		OR_1: OR_GATE	port map (	A => A(1),
						B => A(3),
						Y => Y(0));

		OR_2: OR_GATE	port map (	A => A(2),
						B => A(3),
						Y => Y(1));
		
end STRUCTURAL;

configuration CFG_BPU_ENCODER_STRUCTURAL of BPU_ENCODER is
	for STRUCTURAL
		for all: OR_GATE
			use configuration WORK.CFG_OR_GATE_BEHAVIORAL;
		end for;
	end for;
end CFG_BPU_ENCODER_STRUCTURAL;