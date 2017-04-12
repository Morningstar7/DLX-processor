library ieee; 
use ieee.std_logic_1164.all; 

entity RCA_GEN is
	generic (	N:	integer);
	Port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Ci:	in	std_logic;
			S:	out	std_logic_vector(N-1 downto 0);
			Co:	out	std_logic);
end RCA_GEN;

architecture STRUCTURAL of RCA_GEN is

	component FA
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Ci:	in	std_logic;
			S:	out	std_logic;
			Co:	out	std_logic);
	end component;

	signal STMP : std_logic_vector(N-1 downto 0);
	signal CTMP : std_logic_vector(N downto 0);

	begin

		CTMP(0) <= Ci;
		S <= STMP;
		Co <= CTMP(N);

		ADDER: for i in 1 to N generate
			FAI: FA	port map (	A => A(i-1),
						B => B(i-1),
						Ci => CTMP(i-1),
						S => STMP(i-1),
						Co => CTMP(i));
		end generate;

end STRUCTURAL;

configuration CFG_RCA_GEN_STRUCTURAL of RCA_GEN is
	for STRUCTURAL 
		for ADDER
			for all: FA
				use configuration WORK.CFG_FA_STRUCTURAL;
			end for;
		end for;
	end for;
end CFG_RCA_GEN_STRUCTURAL;