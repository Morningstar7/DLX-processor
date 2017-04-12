library IEEE;
use IEEE.std_logic_1164.all;

entity RIGHT_SHIFTER is
	generic (	N: integer);
	port 	 (	DATA_IN:	in std_logic_vector(N-1 downto 0);
			ENABLE:		in std_logic_vector(4 downto 0);
			DATA_OUT:	out std_logic_vector(N-1 downto 0));
end RIGHT_SHIFTER;

architecture STRUCTURAL of RIGHT_SHIFTER is

	component MUX21
		port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	in	std_logic;
			Y:	out	std_logic);
	end component;

	type SignalVector is array(5 downto 0) of std_logic_vector(N+15 downto 0);

	signal SHIFT_SIG: SignalVector;
	signal MUX_SEL: std_logic_vector(4 downto 0);

	begin

		INIT_ARRAY: for i in 0 to 4 generate
			SHIFT_SIG(i)(N+15 downto N) <= (others => '0');
		end generate INIT_ARRAY;
	
		SHIFT_SIG(0)(N-1 downto 0) <= DATA_IN;
		MUX_SEL <= ENABLE;
		DATA_OUT <= SHIFT_SIG(5)(N-1 downto 0);

		MUX_MATRIX: for i in 0 to 4 generate
			MUX_ARRAYS: for j in 0 to N-1 generate
				MUX_INST: MUX21	port map (	A => SHIFT_SIG(i)(j+2**i),
								B => SHIFT_SIG(i)(j),
								S => MUX_SEL(i),
								Y => SHIFT_SIG(i+1)(j));
			end generate MUX_ARRAYS;
		end generate MUX_MATRIX;

end STRUCTURAL;

configuration CFG_RIGHT_SHIFTER_STRUCTURAL of RIGHT_SHIFTER is
	for STRUCTURAL
		for MUX_MATRIX
			for MUX_ARRAYS
				for all: MUX21
					use configuration WORK.CFG_MUX21_STRUCTURAL;
				end for;
			end for;
		end for;
	end for;
end CFG_RIGHT_SHIFTER_STRUCTURAL;