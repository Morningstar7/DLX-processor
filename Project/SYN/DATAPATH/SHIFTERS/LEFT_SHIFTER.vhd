library IEEE;
use IEEE.std_logic_1164.all;

entity LEFT_SHIFTER is
	generic (	N: integer);
	port (		DATA_IN:	in std_logic_vector(N-1 downto 0);
			ENABLE:		in std_logic_vector(4 downto 0);
			DATA_OUT:	out std_logic_vector(N-1 downto 0));
end LEFT_SHIFTER;

architecture STRUCTURAL of LEFT_SHIFTER is

	component IV
		port (	A:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component MUX21
		port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	in	std_logic;
			Y:	out	std_logic);
	end component;

	type SignalVector is array(4 downto 0) of std_logic_vector(N+15 downto 0);

	signal SHIFT_SIG: SignalVector;
	signal MUX_SEL: std_logic_vector(4 downto 0);

	begin

	SHIFT_SIG(0) <= DATA_IN & "0000000000000000";
	SHIFT_SIG(1)(15 downto 0) <= "0000000000000000";
	SHIFT_SIG(2)(15 downto 0) <= "0000000000000000";
	SHIFT_SIG(3)(15 downto 0) <= "0000000000000000";
	SHIFT_SIG(4)(15 downto 0) <= "0000000000000000";

		INV_ARRAY: for i in 0 to 4 generate
			IV_INST: INV	port map (	A => ENABLE(i),
							Y => MUX_SEL(i));
		end generate INV_ARRAY;

		MUX_ARRAY1: for i in 0 to N-1 generate
			MUX_INST1: MUX21	port map (	A => SHIFT_SIG(0)(N+15-i),
								B => SHIFT_SIG(0)(N+14-i),
								S => MUX_SEL(0),
								Y => SHIFT_SIG(1)(N+15-i));
		end generate MUX_ARRAY1;

		MUX_ARRAY2: for i in 0 to N-1 generate
			MUX_INST2: MUX21	port map (	A => SHIFT_SIG(1)(N+15-i),
								B => SHIFT_SIG(1)(N+13-i),
								S => MUX_SEL(1),
								Y => SHIFT_SIG(2)(N+15-i));
		end generate MUX_ARRAY2;

		MUX_ARRAY3: for i in 0 to N-1 generate
			MUX_INST3: MUX21	port map (	A => SHIFT_SIG(2)(N+15-i),
								B => SHIFT_SIG(2)(N+11-i),
								S => MUX_SEL(2),
								Y => SHIFT_SIG(3)(N+15-i));
		end generate MUX_ARRAY3;

		MUX_ARRAY4: for i in 0 to N-1 generate
			MUX_INST4: MUX21	port map (	A => SHIFT_SIG(3)(N+15-i),
								B => SHIFT_SIG(3)(N+7-i),
								S => MUX_SEL(3),
								Y => SHIFT_SIG(4)(N+15-i));
		end generate MUX_ARRAY4;

		MUX_ARRAY5: for i in 0 to N-1 generate
			MUX_INST5: MUX21	port map (	A => SHIFT_SIG(4)(N+15-i),
								B => SHIFT_SIG(4)(N-1-i),
								S => MUX_SEL(4),
								Y => DATA_OUT(N-1-i));
		end generate MUX_ARRAY5;

end STRUCTURAL;

configuration CFG_LEFT_SHIFTER_STRUCTURAL of LEFT_SHIFTER is
	for STRUCTURAL
		for INV_ARRAY
			for all: INV
				use configuration WORK.CFG_INV_BEHAVIORAL;
			end for;
		end for;
		for MUX_ARRAY1
			for all: MUX21
				use configuration WORK.CFG_MUX21_STRUCTURAL;
			end for;
		end for;
		for MUX_ARRAY2
			for all: MUX21
				use configuration WORK.CFG_MUX21_STRUCTURAL;
			end for;
		end for;
		for MUX_ARRAY3
			for all: MUX21
				use configuration WORK.CFG_MUX21_STRUCTURAL;
			end for;
		end for;
		for MUX_ARRAY4
			for all: MUX21
				use configuration WORK.CFG_MUX21_STRUCTURAL;
			end for;
		end for;
		for MUX_ARRAY5
			for all: MUX21
				use configuration WORK.CFG_MUX21_STRUCTURAL;
			end for;
		end for;
	end for;
end CFG_LEFT_SHIFTER_STRUCTURAL;