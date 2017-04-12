library IEEE;
use IEEE.std_logic_1164.all;

entity CSA is
	generic (N:	integer);
	port (	A:	in	std_logic_vector(N-1 downto 0);		--first operand
		B:	in	std_logic_vector(N-1 downto 0);		--second operand
		Ci:	in	std_logic;				--carry in
		S:	out	std_logic_vector(N-1 downto 0));	--sum
end CSA;

architecture STRUCTURAL of CSA is

	signal S_RCA_1:		std_logic_vector(N-1 downto 0); -- Sum signal for carry in 0
	signal S_RCA_2:		std_logic_vector(N-1 downto 0);	-- Sum signal for carry in 1
	signal Co_RCA_1:	std_logic; -- Carry out signal for carry in 0
	signal Co_RCA_2:	std_logic; -- Carry out signal for carry in 1

	-- declaration of the RCA component
	component RCA_GEN
		generic (	N:	integer);
		port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0);
			Co:	Out	std_logic);
	end component;

	--declaration of the generic MUX 2 to 1 component
	component MUX21_GEN
		generic (	N:	integer);
		port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			SEL:	In	std_logic;
			Y:	Out	std_logic_vector(N-1 downto 0));
	end component;

	begin

		--instatiating the RCA with carry in 0
		RCA_1 : RCA_GEN	generic map (	N => N)
				port map (	A => A,
						B => B,
						Ci => '0',
						S => S_RCA_1,
						Co => Co_RCA_1);
		
		--instatiating the RCA with carry in 1
		RCA_2 : RCA_GEN	generic map (	N => N)
				port map (	A => A,
						B => B,
						Ci => '1',
						S => S_RCA_2,
						Co => Co_RCA_2);

		--instatiating the generic MUX 2 to 1 for selecting the right output sum
		MUX_SUM : MUX21_GEN	generic map (	N => N)
					port map (	A => S_RCA_2,
							B => S_RCA_1,
							SEL => Ci,
							Y => S);

end STRUCTURAL;

configuration CFG_CSA_STRUCTURAL of CSA is
	for STRUCTURAL
		for all : RCA_GEN
			use configuration WORK.CFG_RCA_GEN_STRUCTURAL;
		end for;
		for all : MUX21_GEN
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
	end for;
end CFG_CSA_STRUCTURAL;