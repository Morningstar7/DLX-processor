library IEEE;
use IEEE.std_logic_1164.all;

entity T2_SHIFTER is
	generic (	N:	integer);
	port (		A:		in	std_logic_vector(N-1 downto 0);
			B:		in	std_logic_vector(4 downto 0);
			ARITH_LOG:	in	std_logic;
			RIGHT_LEFT:	in	std_logic;
			Y:		out	std_logic_vector(N-1 downto 0));
end T2_SHIFTER;

architecture STRUCTURAL of T2_SHIFTER is

	component MUX21_GEN
		generic (	N: 	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MUX21
		port (	A:	in	std_logic;
			B:	in	std_logic;
			S:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component MUX41_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(1 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MUX81_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				E:	in	std_logic_vector(N-1 downto 0);
				F:	in	std_logic_vector(N-1 downto 0);
				G:	in	std_logic_vector(N-1 downto 0);
				H:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(2 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	signal CONC:		std_logic;
	signal MASK_00:		std_logic_vector(N+6 downto 0);		--
	signal MASK_08:		std_logic_vector(N+6 downto 0);		--
	signal MASK_16:		std_logic_vector(N+6 downto 0);		--
	signal MASK_24:		std_logic_vector(N+6 downto 0);		--
	signal SEL_MASK:	std_logic_vector(N+6 downto 0);
	signal SEL:		std_logic_vector(2 downto 0);
	signal SIGN:		std_logic_vector(6 downto 0);
	signal SIGN_EXT:	std_logic_vector(7 downto 0);
	signal LEFT_TMP:	std_logic_vector(7 downto 0);

	begin

		SIGN <= (others => CONC);
		SIGN_EXT <= CONC & SIGN;
		LEFT_TMP <= (7 => A(0), others => '0');
	
		ARITH_MUX: MUX21	port map (	A => A(N-1),
							B => '0',
							S => ARITH_LOG,
							Y => CONC);
	
		GEN_MASK_00: for i in 0 to 4 generate
			FIRST_00: if i = 0 generate
				MUXS_00_1: MUX21_GEN	generic map (	N => 8)
							port map (	A => A(7 downto 0),
									B => LEFT_TMP,
									SEL => RIGHT_LEFT,
									Y => MASK_00(7 downto 0));
			end generate FIRST_00;
			MIDDLE_00: if i > 0 and i < 4 generate
				MUXS_00_2: MUX21_GEN	generic map (	N => 8)
							port map (	A => A(8*(i+1)-1 downto 8*i),
									B => A(8*i downto 8*(i-1)+1),
									SEL => RIGHT_LEFT,
									Y => MASK_00(8*(i+1)-1 downto 8*i));
			end generate MIDDLE_00;
			LAST_00: if i = 4 generate
				MUXS_00_3: MUX21_GEN	generic map (	N => 7)
							port map (	A => SIGN,
									B => A(N-1 downto N-7),
									SEL => RIGHT_LEFT,
									Y => MASK_00(8*(i+1)-2 downto 8*i));
			end generate LAST_00;
		end generate GEN_MASK_00;
	
		GEN_MASK_08: for i in 0 to 4 generate
			FIRST_08: if i = 0 generate
				MUXS_08_1: MUX21_GEN	generic map (	N => 8)
							port map (	A => A(15 downto 8),
									B => (others => '0'),
									SEL => RIGHT_LEFT,
									Y => MASK_08(7 downto 0));
			end generate FIRST_08;
			MIDDLE_08: if i > 0 and i < 4 generate
				MIDDLE_08_1: if i = 1 generate
					MUXS_08_2_1: MUX21_GEN	generic map (	N => 8)
								port map (	A => A(23 downto 16),
										B => LEFT_TMP,
										SEL => RIGHT_LEFT,
										Y => MASK_08(15 downto 8));
				end generate MIDDLE_08_1;
				MIDDLE_08_2: if i > 1 and i < 3 generate
					MUXS_08_2_2: MUX21_GEN	generic map (	N => 8)
								port map (	A => A(8*(i+2)-1 downto 8*(i+1)),
										B => A(8*(i-1) downto 8*(i-2)+1),
										SEL => RIGHT_LEFT,
										Y => MASK_08(8*(i+1)-1 downto 8*i));
				end generate MIDDLE_08_2;
				MIDDLE_08_3: if i = 3 generate
					MUXS_08_2_3: MUX21_GEN	generic map (	N => 8)
								port map (	A => SIGN_EXT,
										B => A(8*(i-1) downto 8*(i-2)+1),
										SEL => RIGHT_LEFT,
										Y => MASK_08(8*(i+1)-1 downto 8*i));
				end generate MIDDLE_08_3;
			end generate MIDDLE_08;
			LAST_08: if i = 4 generate
				MUXS_08_3: MUX21_GEN	generic map (	N => 7)
							port map (	A => SIGN,
									B => A(N-1 downto N-7),
									SEL => RIGHT_LEFT,
									Y => MASK_08(8*(i+1)-2 downto 8*i));
			end generate LAST_08;
		end generate GEN_MASK_08;
	
		GEN_MASK_16: for i in 0 to 4 generate
			FIRST_16: if i < 2 generate
				MUXS_16_1: MUX21_GEN	generic map (	N => 8)
							port map (	A => A(8*(i+3)-1 downto 8*(i+2)),
									B => (others => '0'),
									SEL => RIGHT_LEFT,
									Y => MASK_16(8*(i+1)-1 downto 8*i));
			end generate FIRST_16;
			MIDDLE_16: if i = 2 generate
				MUXS_16_2: MUX21_GEN	generic map (	N => 8)
							port map (	A => SIGN_EXT,
									B => LEFT_TMP,
									SEL => RIGHT_LEFT,
									Y => MASK_16(8*(i+1)-1 downto 8*i));
			end generate MIDDLE_16;
			LAST_16: if i > 2 generate
				LAST_16_1: if i = 3 generate
					MUXS_16_3: MUX21_GEN	generic map (	N => 8)
								port map (	A => SIGN_EXT,
										B => A(8 downto 1),
										SEL => RIGHT_LEFT,
										Y => MASK_16(8*(i+1)-1 downto 8*i));
				end generate LAST_16_1;
				LAST_16_2: if i = 4 generate
					MUXS_16_3: MUX21_GEN	generic map (	N => 7)
								port map (	A => SIGN,
										B => A(15 downto 9),
										SEL => RIGHT_LEFT,
										Y => MASK_16(8*(i+1)-2 downto 8*i));
				end generate LAST_16_2;
			end generate LAST_16;
		end generate GEN_MASK_16;
	
		GEN_MASK_24: for i in 0 to 4 generate
			FIRST_24: if i = 0 generate
				MUXS_24_1: MUX21_GEN	generic map (	N => 8)
							port map (	A => A(N-1 downto N-8),
									B => (others => '0'),
									SEL => RIGHT_LEFT,
									Y => MASK_24(7 downto 0));
			end generate FIRST_24;
			MIDDLE_24_1: if i > 0 and i < 3 generate
				MUXS_24_2: MUX21_GEN	generic map (	N => 8)
							port map (	A => SIGN_EXT,
									B => (others => '0'),
									SEL => RIGHT_LEFT,
									Y => MASK_24(8*(i+1)-1 downto 8*i));
			end generate MIDDLE_24_1;
			MIDDLE_24_2: if i = 3 generate
				MUXS_24_3: MUX21_GEN	generic map (	N => 8)
							port map (	A => SIGN_EXT,
									B => LEFT_TMP,
									SEL => RIGHT_LEFT,
									Y => MASK_24(8*(i+1)-1 downto 8*i));
			end generate MIDDLE_24_2;
			LAST_24: if i = 4 generate
				MUXS_24_4: MUX21_GEN	generic map (	N => 7)
							port map (	A => SIGN,
									B => A(7 downto 1),
									SEL => RIGHT_LEFT,
									Y => MASK_24(8*(i+1)-2 downto 8*i));
			end generate LAST_24;
		end generate GEN_MASK_24;

		COARSE_GRAIN: MUX41_GEN	generic map (	N => N+7)
					port map (	A => MASK_24,
							B => MASK_16,
							C => MASK_08,
							D => MASK_00,
							SEL => B(4 downto 3),
							Y => SEL_MASK);

		SEL(0) <= B(0) xor RIGHT_LEFT;
		SEL(1) <= B(1) xor RIGHT_LEFT;
		SEL(2) <= B(2) xor RIGHT_LEFT;

		FINE_GRAIN: MUX81_GEN	generic map (	N => N)
					port map (	A => SEL_MASK(N-1 downto 0),
							B => SEL_MASK(N downto 1),
							C => SEL_MASK(N+1 downto 2),
							D => SEL_MASK(N+2 downto 3),
							E => SEL_MASK(N+3 downto 4),
							F => SEL_MASK(N+4 downto 5),
							G => SEL_MASK(N+5 downto 6),
							H => SEL_MASK(N+6 downto 7),
							SEL => SEL,
							Y => Y);

end STRUCTURAL;

configuration CFG_T2_SHIFTER_STRUCTURAL of T2_SHIFTER is
	for STRUCTURAL
		for all : MUX21
			use configuration WORK.CFG_MUX21_STRUCTURAL;
		end for;
		for GEN_MASK_00
			for FIRST_00
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for MIDDLE_00
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for LAST_00
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
		end for;
		for GEN_MASK_08
			for FIRST_08
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for MIDDLE_08
				for MIDDLE_08_1
					for all : MUX21_GEN
						use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
					end for;
				end for;
				for MIDDLE_08_2
					for all : MUX21_GEN
						use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
					end for;
				end for;
				for MIDDLE_08_3
					for all : MUX21_GEN
						use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
					end for;
				end for;

			end for;
			for LAST_08
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
		end for;
		for GEN_MASK_16
			for FIRST_16
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for MIDDLE_16
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for LAST_16
				for LAST_16_1
					for all : MUX21_GEN
						use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
					end for;
				end for;
				for LAST_16_2
					for all : MUX21_GEN
						use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
					end for;
				end for;
			end for;
		end for;
		for GEN_MASK_24
			for FIRST_24
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for MIDDLE_24_1
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for MIDDLE_24_2
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
			for LAST_24
				for all : MUX21_GEN
					use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
				end for;
			end for;
		end for;
		for all: MUX41_GEN
			use configuration WORK.CFG_MUX41_GEN_BEHAVIORAL;
		end for;
		for all: MUX81_GEN
			use configuration WORK.CFG_MUX81_GEN_BEHAVIORAL;
		end for;
	end for;
end CFG_T2_SHIFTER_STRUCTURAL;
