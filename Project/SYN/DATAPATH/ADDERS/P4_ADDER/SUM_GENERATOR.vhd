library IEEE;
use IEEE.std_logic_1164.all;

entity SUM_GENERATOR is
	generic (N:	integer);
	port (	A:	in	std_logic_vector(N-1 downto 0);		--first operand
		B:	in	std_logic_vector(N-1 downto 0);		--second operand
		Ci:	in	std_logic_vector(N/4-1 downto 0);	--carry in coming from the CLA Sparse Tree
		S:	out	std_logic_vector(N-1 downto 0));	--sum
end SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is

	--declaration of the CSA component
	component CSA
		generic (N:	integer);
		port (	A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Ci:	in	std_logic;
			S:	out	std_logic_vector(N-1 downto 0));
	end component;

	begin

		--generating the cascade of CSA
		COMPOSE: for i in 0 to N/4-1 generate
			DO: CSA	generic map (	N => 4)
				port map (	A => A(4*i+3 downto 4*i),
						B => B(4*i+3 downto 4*i),
						Ci => Ci(i),
						S => S(4*i+3 downto 4*i));
		end generate;

end STRUCTURAL;

configuration CFG_SUM_GENERATOR_STRUCTURAL of SUM_GENERATOR is
	for STRUCTURAL
		for COMPOSE
			for all : CSA
				use configuration WORK.CFG_CSA_STRUCTURAL;
			end for;
		end for;
	end for;
end CFG_SUM_GENERATOR_STRUCTURAL; 