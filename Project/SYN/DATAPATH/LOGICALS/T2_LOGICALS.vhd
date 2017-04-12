library IEEE;
use IEEE.std_logic_1164.all;

entity T2_LOGICALS is
	generic (	N: integer);
	port (		OP:	in	std_logic_vector(3 downto 0);	--0001 AND, 1110 NAND, 0111 OR, 1000 NOR, 0110 XOR, 1001 XNOR
			A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end T2_LOGICALS;

architecture STRUCTURAL of T2_LOGICALS is

	component N_NAND
		generic (	N: integer);
		port (		A: in	std_logic_vector(N-1 downto 0);
				Y: out	std_logic);
	end component;

	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	type SignalVector_1 is array(N-1 downto 0) of std_logic_vector(2 downto 0);
	type SignalVector_2 is array(N-1 downto 0) of std_logic_vector(3 downto 0);

	signal NAND_IN_1:	SignalVector_1;
	signal NAND_IN_2:	SignalVector_1;
	signal NAND_IN_3:	SignalVector_1;
	signal NAND_IN_4:	SignalVector_1;
	signal NAND_IN_5:	SignalVector_2;
	signal A_INV:		std_logic_vector(N-1 downto 0);
	signal B_INV:		std_logic_vector(N-1 downto 0);
	signal NAND_OUT_1:	std_logic_vector(N-1 downto 0);
	signal NAND_OUT_2:	std_logic_vector(N-1 downto 0);
	signal NAND_OUT_3:	std_logic_vector(N-1 downto 0);
	signal NAND_OUT_4:	std_logic_vector(N-1 downto 0);

	begin

		INV_INPUTS_1: for i in 0 to N-1 generate
			INVERTING_1: INV 	port map (	A => A(i),
								Y => A_INV(i));
		end generate INV_INPUTS_1;

		INV_INPUTS_2: for i in 0 to N-1 generate
			INVERTING_2: INV	port map (	A => B(i),
								Y => B_INV(i));
		end generate INV_INPUTS_2;

		SIG_1: for i in 0 to N-1 generate
			NAND_IN_1(i) <= OP(3) & A_INV(i) & B_INV(i);
		end generate SIG_1;

		SIG_2: for i in 0 to N-1 generate
			NAND_IN_2(i) <= OP(2) & A_INV(i) & B(i);
		end generate SIG_2;

		SIG_3: for i in 0 to N-1 generate
			NAND_IN_3(i) <= OP(1) & A(i) & B_INV(i);
		end generate SIG_3;

		SIG_4: for i in 0 to N-1 generate
			NAND_IN_4(i) <= OP(0) & A(i) & B(i);
		end generate SIG_4;

		NAND_1: for i in 0 to N-1 generate
			NANDS_1: N_NAND	generic map (	N => 3)
					port map (	A => NAND_IN_1(i),
							Y => NAND_OUT_1(i));
		end generate NAND_1;

		NAND_2: for i in 0 to N-1 generate
			NANDS_2: N_NAND	generic map (	N => 3)
					port map (	A => NAND_IN_2(i),
							Y => NAND_OUT_2(i));
		end generate NAND_2;

		NAND_3: for i in 0 to N-1 generate
			NANDS_3: N_NAND	generic map (	N => 3)
					port map (	A => NAND_IN_3(i),
							Y => NAND_OUT_3(i));
		end generate NAND_3;

		NAND_4: for i in 0 to N-1 generate
			NANDS_4: N_NAND	generic map (	N => 3)
					port map (	A => NAND_IN_4(i),
							Y => NAND_OUT_4(i));
		end generate NAND_4;

		SIG_5: for i in 0 to N-1 generate
			NAND_IN_5(i)(0) <= NAND_OUT_1(i);
			NAND_IN_5(i)(1) <= NAND_OUT_2(i);
			NAND_IN_5(i)(2) <= NAND_OUT_3(i);
			NAND_IN_5(i)(3) <= NAND_OUT_4(i);
		end generate SIG_5;

		NAND_5: for i in 0 to N-1 generate
			NANDS_5: N_NAND	generic map (	N => 4)
					port map (	A => NAND_IN_5(i),
							Y => Y(i));
		end generate NAND_5;
		
end STRUCTURAL;


configuration CFG_T2_LOGICALS_STRUCTURAL of T2_LOGICALS is
	for STRUCTURAL
		for INV_INPUTS_1
			for all: INV
				use configuration WORK.CFG_INV_BEHAVIORAL;
			end for;
		end for;
		for INV_INPUTS_2
			for all: INV
				use configuration WORK.CFG_INV_BEHAVIORAL;
			end for;
		end for;
		for NAND_1
			for all: N_NAND
				use configuration WORK.CFG_N_NAND_BEHAVIORAL;
			end for;
		end for;
		for NAND_2
			for all: N_NAND
				use configuration WORK.CFG_N_NAND_BEHAVIORAL;
			end for;
		end for;
		for NAND_3
			for all: N_NAND
				use configuration WORK.CFG_N_NAND_BEHAVIORAL;
			end for;
		end for;
		for NAND_4
			for all: N_NAND
				use configuration WORK.CFG_N_NAND_BEHAVIORAL;
			end for;
		end for;
		for NAND_5
			for all: N_NAND
				use configuration WORK.CFG_N_NAND_BEHAVIORAL;
			end for;
		end for;
	end for; 
end CFG_T2_LOGICALS_STRUCTURAL;