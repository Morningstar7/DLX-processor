library ieee; 
use ieee.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_signed.all;
--use IEEE.numeric_std.all;
--use ieee.math_real.all;

entity BOOTHMUL is 
	port (		A:	in	std_logic_vector(15 downto 0);
			B:	in	std_logic_vector(15 downto 0);
			CLK:	in	std_logic;
			EN:	in	std_logic;
			RST:	in	std_logic;
			P:	out	std_logic_vector(31 downto 0));
end BOOTHMUL; 

architecture STRUCTURAL of BOOTHMUL is

	component BOOTHMUL_COMP_1
		port (		A:	in	std_logic_vector(15 downto 0);
				NEG_A:	in	std_logic_vector(15 downto 0);
				B:	in	std_logic_vector(15 downto 0);
				P:	out	std_logic_vector(20 downto 0));
	end component;

	component BOOTHMUL_COMP_2
		port (		PREVIOUS:	in	std_logic_vector(16 downto 0);
				A:	in	std_logic_vector(15 downto 0);
				NEG_A:	in	std_logic_vector(15 downto 0);
				B:	in	std_logic_vector(15 downto 0);
				P:	out	std_logic_vector(22 downto 0));
	end component;

	component BOOTHMUL_COMP_3
		port (		PREVIOUS:	in	std_logic_vector(16 downto 0);
				A:	in	std_logic_vector(15 downto 0);
				NEG_A:	in	std_logic_vector(15 downto 0);
				B:	in	std_logic_vector(15 downto 0);
				P:	out	std_logic_vector(20 downto 0));
	end component;

	component RCA_GEN_NO_C
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				S:	out	std_logic_vector(N-1 downto 0);
				Co:	out	std_logic);
	end component;

	component REG
		generic (	N:	integer);
		port (		D: 	in 	std_logic_vector(N-1 downto 0);
				Q: 	out	std_logic_vector(N-1 downto 0);
				EN:	in	std_logic;
				RST:	in 	std_logic;
				CLK: 	in	std_logic);
	end component;

	signal NOT_A:		std_logic_vector(15 downto 0);
	signal NEG_A:		std_logic_vector(15 downto 0);
	signal OUT_1:		std_logic_vector(20 downto 0);
	signal OUT_2:		std_logic_vector(22 downto 0);
	signal OUT_3:		std_logic_vector(20 downto 0);
	signal IN_COMP_2:	std_logic_vector(16 downto 0);
	signal IN_COMP_3:	std_logic_vector(16 downto 0);
	signal ONE:		std_logic_vector(15 downto 0);
	signal A_1:		std_logic_vector(15 downto 0);
	signal B_1:		std_logic_vector(15 downto 0);
	signal NEG_A_1:		std_logic_vector(15 downto 0);
	signal A_2:		std_logic_vector(15 downto 0);
	signal B_2:		std_logic_vector(15 downto 0);
	signal NEG_A_2:		std_logic_vector(15 downto 0);
	signal P_1:		std_logic_vector(3 downto 0);
	signal IN_REG_P:	std_logic_vector(9 downto 0);
	signal P_2:		std_logic_vector(9 downto 0);
	signal Co_SIG:		std_logic;

	begin

		ONE <= (0 => '1', others => '0');

		ZERO_GEN: for i in 0 to 15 generate
			NOT_A(i) <= not A(i);
		end generate;

		NEG_A_GEN: RCA_GEN_NO_C	generic map (	N => 16)
					port map (	A => NOT_A,
							B => ONE,
							S => NEG_A,
							Co => Co_SIG);

		COMP_1: BOOTHMUL_COMP_1	port map (	A => A,
							NEG_A => NEG_A,
							B => B,
							P => OUT_1);

		--P(3 downto 0) <= OUT_1(3 downto 0);

		PIPE_1_0: REG	generic map (	N => 4)
				port map (	D => OUT_1(3 downto 0),
						Q => P_1,
						EN => EN,
						RST => RST,
						CLK => CLK);
						

		PIPE_1_1: REG	generic map (	N => 17)
				port map (	D => OUT_1(20 downto 4),
						Q => IN_COMP_2,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_1_2: REG	generic map (	N => 16)
				port map (	D => A,
						Q => A_1,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_1_3: REG	generic map (	N => 16)
				port map (	D => B,
						Q => B_1,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_1_4: REG	generic map (	N => 16)
				port map (	D => NEG_A,
						Q => NEG_A_1,
						EN => EN,
						RST => RST,
						CLK => CLK);

		COMP_2: BOOTHMUL_COMP_2	port map (	PREVIOUS => IN_COMP_2,
							A => A_1,
							NEG_A => NEG_A_1,
							B => B_1,
							P => OUT_2);

		--P(9 downto 4) <= OUT_2(5 downto 0);
		IN_REG_P <= OUT_2(5 downto 0) & P_1;

		PIPE_2_0: REG	generic map (	N => 10)
				port map (	D => IN_REG_P,
						Q => P_2,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_2_1: REG	generic map (	N => 17)
				port map (	D => OUT_2(22 downto 6),
						Q => IN_COMP_3,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_2_2: REG	generic map (	N => 16)
				port map (	D => A_1,
						Q => A_2,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_2_3: REG	generic map (	N => 16)
				port map (	D => B_1,
						Q => B_2,
						EN => EN,
						RST => RST,
						CLK => CLK);

		PIPE_2_4: REG	generic map (	N => 16)
				port map (	D => NEG_A_1,
						Q => NEG_A_2,
						EN => EN,
						RST => RST,
						CLK => CLK);
-- 		IN_COMP_3 <= OUT_2(22 downto 6);

		COMP_3: BOOTHMUL_COMP_3	port map (	PREVIOUS => IN_COMP_3,
							A => A_2,
							NEG_A => NEG_A_2,
							B => B_2,
							P => OUT_3);
		P(9 downto 0) <= P_2;
		P(31 downto 10) <= OUT_3(20) & OUT_3;

end STRUCTURAL;

configuration CFG_BOOTHMUL_STRUCTURAL of BOOTHMUL is
	for STRUCTURAL
		for all: RCA_GEN_NO_C
			use configuration WORK.CFG_RCA_GEN_NO_C_STRUCTURAL;
		end for;
		for all: BOOTHMUL_COMP_1
			use configuration WORK.CFG_BOOTHMUL_COMP_1_STRUCTURAL;
		end for;
		for all: BOOTHMUL_COMP_2
			use configuration WORK.CFG_BOOTHMUL_COMP_2_STRUCTURAL;
		end for;
		for all: BOOTHMUL_COMP_3
			use configuration WORK.CFG_BOOTHMUL_COMP_3_STRUCTURAL;
		end for;
		for all: REG
			use configuration WORK.CFG_REG_SYN_STRUCTURAL;
		end for;
	end for;
end CFG_BOOTHMUL_STRUCTURAL;