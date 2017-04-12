library IEEE;
use IEEE.std_logic_1164.all;

entity CMP is 
	generic (	N:	integer);
	port(		C:	in	std_logic;
			S:	in	std_logic_vector(N-1 downto 0);		-- SUM
			OP_SEL:	in	std_logic_vector(2 downto 0);		--111 LESS, 110 LESS OR EQUAL, 101 EQUAL, 100 NOT EQUAL, 011 GREATER OR EQUAL, 010 GREATER
			UNSIGN:	in	std_logic;
			MSB_A:	in	std_logic;
			MSB_B:	in	std_logic;
			Y:	out	std_logic_vector(N-1 downto 0));
end entity CMP;

architecture STRUCTURAL of CMP is 

	component INV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component OR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component N_NOR
		generic (	N: integer);
		port (		A: in	std_logic_vector(N-1 downto 0);
				Y: out	std_logic);
	end component;

	component XOR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component MUX21
		port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component MUX61
		port (		A:	in	std_logic;
				B:	in	std_logic;
				C:	in	std_logic;
				D:	in	std_logic;
				E:	in	std_logic;
				F:	in	std_logic;
				SEL:	in	std_logic_vector(2 downto 0);
				Y:	out	std_logic);
	end component;

	signal NC:		std_logic;
	signal Z:		std_logic;
	signal NZ:		std_logic;
	signal G_UNSIGNED:	std_logic;
	signal G_SIGNED:	std_logic;
	signal GE_UNSIGNED:	std_logic;
	signal GE_SIGNED:	std_logic;
	signal NE:		std_logic;
	signal E:		std_logic;
	signal LE_UNSIGNED:	std_logic;
	signal LE_SIGNED:	std_logic;
	signal L_UNSIGNED:	std_logic;
	signal L_SIGNED:	std_logic;
	signal Y_SIG:		std_logic;
	signal DIF:		std_logic;
	signal MUX_SEL:		std_logic;
	signal OUT_MUX_G:	std_logic;
	signal OUT_MUX_GE:	std_logic;
	signal OUT_MUX_LE:	std_logic;
	signal OUT_MUX_L:	std_logic;
	signal SIGN:		std_logic;

	begin 

		--CHECKING FOR DIFFERENT SIGNED OPERANDS
		CHECK_SIGN: XOR_GATE	port map (	A => MSB_A,
							B => MSB_B,
							Y => DIF);

		INV_UNSIGN: INV	port map (	A => UNSIGN,
						Y => SIGN);

		--GENERATING THE MUX SELECTOR
		GEN_SEL: AND_GATE	port map (	A => DIF,
							B => SIGN,
							Y => MUX_SEL);

		--INVERTING C
		INV_C: INV	port map (	A => C,
						Y => NC);

		--NORING THE SUM
		N_NOR_INST:	N_NOR	generic map (	N => N)
					port map (	A => S,
							Y => Z);

		--INVERTING Z
		INV_Z: INV	port map(	A => Z,
						Y => NZ);

		--A > B
		AND_INST: AND_GATE port map (	A => C,
						B => NZ,
						Y => G_UNSIGNED);

		--GREATER FOR UNSIGNED
		INV_G: INV 	port map (	A => G_UNSIGNED,
						Y => G_SIGNED);

		--SELECTING THE CORRECT GREATER
		G_MUX: MUX21	port map (	A => G_SIGNED,
						B => G_UNSIGNED,
						S => MUX_SEL,
						Y => OUT_MUX_G);

		--A >= B
		GE_UNSIGNED <= C;
		--GREATER OR EQUAL FOR UNSIGNED
		INV_GE: INV port map (	A => GE_UNSIGNED,
					Y => GE_SIGNED);

		--SELECTING THE CORRECT GREATER OR EQUAL
		GE_MUX: MUX21	port map (	A => GE_SIGNED,
						B => GE_UNSIGNED,
						S => MUX_SEL,
						Y => OUT_MUX_GE);

		--A != B
		NE <= NZ;

		--A = B
		E <= Z;

		--A <= B
		OR_INST: OR_GATE port map (	A => NC,
						B => Z,
						Y => LE_UNSIGNED);

		--LOWER OR EQUAL FOR UNSIGNED
		INV_LE: INV port map (	A => LE_UNSIGNED,
					Y => LE_SIGNED);

		--SELECTING THE CORRECT LOWER OR EQUAL
		LE_MUX: MUX21	port map (	A => LE_SIGNED,
						B => LE_UNSIGNED,
						S => MUX_SEL,
						Y => OUT_MUX_LE);

		--A < B
		L_UNSIGNED <= NC;

		--LOWER FOR UNSIGNED
		INV_L: INV port map (	A => L_UNSIGNED,
					Y => L_SIGNED);

		--SELECTING THE CORRECT GREATER
		L_MUX: MUX21	port map (	A => L_SIGNED,
						B => L_UNSIGNED,
						S => MUX_SEL,
						Y => OUT_MUX_L);

		--MUXING THE OUTPUT
		MUX_INST: MUX61	port map (	A => OUT_MUX_L,
						B => OUT_MUX_LE,
						C => E,
						D => NE,
						E => OUT_MUX_GE,
						F => OUT_MUX_G,
						SEL => OP_SEL,
						Y => Y_SIG);

		--EXTENDING THE VALUE TO N BITS
		Y(0) <= Y_SIG;
		Y(N-1 downto 1) <= (others => '0');
end STRUCTURAL;

configuration CFG_CMP_STRUCTURAL of CMP is
	for STRUCTURAL
		for all: INV
			use configuration WORK.CFG_INV_BEHAVIORAL;
		end for;
		for all: N_NOR
			use configuration WORK.CFG_N_NOR_BEHAVIORAL;
		end for;
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: OR_GATE
			use configuration WORK.CFG_OR_GATE_BEHAVIORAL;
		end for;
		for all: MUX61
			use configuration WORK.CFG_MUX61_BEHAVIORAL;
		end for;
	end for;
end CFG_CMP_STRUCTURAL;