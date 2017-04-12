library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity P4_ADDER is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Ci:	in	std_logic;
			Co:	out	std_logic;
			S:	out	std_logic_vector(N-1 downto 0));
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is

	component CARRY_GENERATOR
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Ci:	in	std_logic;
				Co:	out	std_logic_vector(N/4-1 downto 0));
	end component;

	component SUM_GENERATOR
		generic (N:	integer);
		port (	A:	in	std_logic_vector(N-1 downto 0);		--first operand
			B:	in	std_logic_vector(N-1 downto 0);		--second operand
			Ci:	in	std_logic_vector(N/4-1 downto 0);		--carry in coming from the CLA Sparse Tree
			S:	out	std_logic_vector(N-1 downto 0));	--sum
	end component;

	signal CARRY_VECTOR: std_logic_vector(N/4 downto 0);

	begin

		CARRY_GENERATION: CARRY_GENERATOR	generic map (	N => N)
							port map (	A => A,
									B => B,
									Ci => Ci,
									Co => CARRY_VECTOR(N/4 downto 1));

		CARRY_VECTOR(0) <= Ci;
		Co <= CARRY_VECTOR(N/4);

		SUM_GENERATION: SUM_GENERATOR	generic map (	N => N)
						port map (	A => A,
								B => B,
								Ci => CARRY_VECTOR(N/4-1 downto 0),
								S => S);

end STRUCTURAL;

configuration CFG_P4_ADDER_STRUCTURAL of P4_ADDER is
	for STRUCTURAL
		for all: CARRY_GENERATOR
			use configuration WORK.CFG_CARRY_GENERATOR_STRUCTURAL;
		end for;
		for all: SUM_GENERATOR
			use configuration WORK.CFG_SUM_GENERATOR_STRUCTURAL;
		end for;
	end for;
end CFG_P4_ADDER_STRUCTURAL;