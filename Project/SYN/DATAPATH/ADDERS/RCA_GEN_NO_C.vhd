library ieee; 
use ieee.std_logic_1164.all; 

entity RCA_GEN_NO_C is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			S:	out	std_logic_vector(N-1 downto 0);
			Co:	out	std_logic);
end RCA_GEN_NO_C;

architecture STRUCTURAL of RCA_GEN_NO_C is

	component HA
		Port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	out	std_logic;
			Co:	out	std_logic);
	end component;

	component FA
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Ci:	in	std_logic;
			S:	out	std_logic;
			Co:	out	std_logic);
	end component;

	signal STMP : std_logic_vector(N-1 downto 0);
	signal CTMP : std_logic_vector(N-1 downto 0);

	begin
	
		S <= STMP;
		Co <= CTMP(N-1);
		
		HA_INST: HA	port map (	A => A(0),
						B => B(0),
						S => STMP(0),
						Co => CTMP(0));

		ADDER: for i in 0 to N-2 generate
			FAI: FA	port map (	A => A(i+1),
						B => B(i+1),
						Ci => CTMP(i),
						S => STMP(i+1),
						Co => CTMP(i+1));
		end generate;

end STRUCTURAL;

configuration CFG_RCA_GEN_NO_C_STRUCTURAL of RCA_GEN_NO_C is
	for STRUCTURAL 
		for all: HA
			use configuration WORK.CFG_HA_STRUCTURAL;
		end for;
		for ADDER
			for all: FA
				use configuration WORK.CFG_FA_STRUCTURAL;
			end for;
		end for;
	end for;
end CFG_RCA_GEN_NO_C_STRUCTURAL;