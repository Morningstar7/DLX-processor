library ieee; 
use ieee.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_signed.all;
--use IEEE.numeric_std.all;
--use ieee.math_real.all;

entity BOOTHMUL_COMP_3 is 
	port (		PREVIOUS:	in	std_logic_vector(16 downto 0);
			A:	in	std_logic_vector(15 downto 0);
			NEG_A:	in	std_logic_vector(15 downto 0);
			B:	in	std_logic_vector(15 downto 0);
			P:	out	std_logic_vector(20 downto 0));
end BOOTHMUL_COMP_3; 

architecture STRUCTURAL of BOOTHMUL_COMP_3 is

	component MUX51_GEN
		generic (	N: 	integer);
		port (	A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			C:	In	std_logic_vector(N-1 downto 0);
			D:	In	std_logic_vector(N-1 downto 0);
			E:	In	std_logic_vector(N-1 downto 0);
			SEL:	In	std_logic_vector(2 downto 0);
			Y:	Out	std_logic_vector(N-1 downto 0));
	end component;

	component RCA_GEN_NO_C
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				S:	out	std_logic_vector(N-1 downto 0);
				Co:	out	std_logic);
	end component;

	component BOOTH_ENCODER
		port (		TO_ENC:	in	std_logic_vector(2 downto 0);
				ENC:	out	std_logic_vector(2 downto 0));
	end component;

	type ARRAY_1 is array (1 downto 0) of std_logic_vector(18 downto 0);
	type SEL_MUX is array (1 downto 0) of std_logic_vector(2 downto 0);

	signal OUT_MUX:		ARRAY_1;
	signal OUT_RCA:		ARRAY_1;
	signal IN_A_RCA:	ARRAY_1;
	signal IN_B_RCA:	ARRAY_1;
	signal SEL:		SEL_MUX;
	signal Co_SIG:		std_logic_vector(2 downto 0);
	signal ZERO:		std_logic_vector(18 downto 0);
	signal NEG_A_EXT:	std_logic_vector(18 downto 0);
	signal NEG_A_2:		std_logic_vector(18 downto 0);
	signal NEG_A_4:		std_logic_vector(18 downto 0);
	signal NEG_A_8:		std_logic_vector(18 downto 0);
	signal A_EXT:		std_logic_vector(18 downto 0);
	signal A_2:		std_logic_vector(18 downto 0);
	signal A_4:		std_logic_vector(18 downto 0);
	signal A_8:		std_logic_vector(18 downto 0);
	signal B_EXT:		std_logic_vector(16 downto 0);

	begin

		--GENERATING THE SIGNAL WITH ALL ZEROS
		ZERO <= (others => '0');
		--EXTENDING AND GENERATING THE POSITIVE SIGNALS FOR THE MUXS
		A_EXT <= A(15) & A(15) & A(15) & A;
		A_2 <= A_EXT(17 downto 0) & '0';
		A_4 <= A_2(17 downto 0) & '0';
		A_8 <= A_4(17 downto 0) & '0';
		--EXTENDING AND GENERATING THE NEGATIVE SIGNALS FOR THE MUXS
		NEG_A_EXT <= NEG_A(15) & NEG_A(15) & NEG_A(15) & NEG_A;
		NEG_A_2 <= NEG_A_EXT(17 downto 0) & '0';
		NEG_A_4 <= NEG_A_2(17 downto 0) & '0';
		NEG_A_8 <= NEG_A_4(17 downto 0) & '0';

		B_EXT <= B & '0';

		MUX_GEN: for i in 0 to 1 generate
			MUX_INST: MUX51_GEN	generic map (	N => 19)
						port map (	A => ZERO,
								B => A_4,
								C => NEG_A_4,
								D => A_8,
								E => NEG_A_8,
								SEL => SEL(i),
								Y => OUT_MUX(i));
		end generate MUX_GEN;

		RCA_GEN: for i in 0 to 1 generate
			RCA_INST_1: RCA_GEN_NO_C	generic map (	N => 19)
							port map (	A => IN_A_RCA(i),
									B => IN_B_RCA(i),
									S => OUT_RCA(i),
									Co => Co_SIG(i));
		end generate RCA_GEN;

		IN_A_RCA(0) <= PREVIOUS(16) & PREVIOUS(16) & PREVIOUS;
		IN_A_RCA(1) <= OUT_RCA(0)(18) & OUT_RCA(0)(18) & OUT_RCA(0)(18 downto 2);

		IN_B_RCA(0) <= OUT_MUX(0);
		IN_B_RCA(1) <= OUT_MUX(1);

		P(1 downto 0) <= OUT_RCA(0)(1 downto 0);
		P(20 downto 2) <= OUT_RCA(1);

		ENC_GEN: for i in 6 to 7 generate
			ENCODERS: BOOTH_ENCODER	port map (	TO_ENC => B_EXT(2*(i+1) downto 2*i),
								ENC => SEL(i-6));
		end generate ENC_GEN;

end STRUCTURAL;

configuration CFG_BOOTHMUL_COMP_3_STRUCTURAL of BOOTHMUL_COMP_3 is
	for STRUCTURAL
		for MUX_GEN
			for all: MUX51_GEN
				use configuration WORK.CFG_MUX51_GEN_BEHAVIORAL;
			end for;
		end for;
		for RCA_GEN
			for all: RCA_GEN_NO_C
				use configuration WORK.CFG_RCA_GEN_NO_C_STRUCTURAL;
			end for;
		end for;
		for ENC_GEN
			for all: BOOTH_ENCODER
				use configuration WORK.CFG_BOOTH_ENCODER_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_BOOTHMUL_COMP_3_STRUCTURAL;