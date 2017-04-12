library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity CARRY_GENERATOR is
	generic (	N:	integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			Ci:	in	std_logic;
			Co:	out	std_logic_vector(N/4-1 downto 0));
end CARRY_GENERATOR;

architecture STRUCTURAL of CARRY_GENERATOR is

	constant M: integer := 5;

	type SignalVector is array(M downto 0) of std_logic_vector(N-1 downto 0);

	signal gen_signal: SignalVector;
	signal pro_signal: SignalVector;

	component PG_NETWORK
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Ci:	in	std_logic;
				G:	out	std_logic_vector(N-1 downto 0);
				P:	out	std_logic_vector(N-1 downto 0));
	end component;

	component GENERAL_GENERATE
		port (	Gi_0:	in	std_logic;
			Gi_1:	in	std_logic;
			Pi:	in	std_logic;
			Go:	out	std_logic);
	end component;

	component PG_BLOCK
		port (	Gi_0:	in	std_logic;
			Gi_1:	in	std_logic;
			Pi_0:	in	std_logic;
			Pi_1:	in	std_logic;
			Po:	out	std_logic;
			Go:	out	std_logic);
	end component;

	begin

		PG_NETWORK_INST: PG_NETWORK	generic map (	N => N)
						port map (	A => A,
								B => B,
								Ci => Ci,
								G => gen_signal(0),
								P => pro_signal(0));

		CARRY_GENERATION: for i in 0 to M-1 generate
			FIRST_LINES: if i <= 1 generate
				LINE_GEN_1: for j in 0 to N/(2**(i+1))-1 generate
					FIRST_G_BLOCK_1: if j = 0 generate
						G_INST_1: GENERAL_GENERATE port map (	Gi_0 => gen_signal(i)(0),
											Gi_1 => gen_signal(i)(1),
											Pi => pro_signal(i)(1),
											Go => gen_signal(i+1)(0));
					end generate;
					OTHER_PG_BLOCKS_1: if j > 0 generate
						PG_INST_1: PG_BLOCK port map (	Gi_0 => gen_signal(i)(2*j),
										Gi_1 => gen_signal(i)(2*j+1),
										Pi_0 => pro_signal(i)(2*j),
										Pi_1 => pro_signal(i)(2*j+1),
										Po => pro_signal(i+1)(j),
										Go => gen_signal(i+1)(j));
					end generate;
				end generate;
			end generate;
			LAST_LINES: if i >= 2 generate
				LINE_GEN_2: for j in 0 to N/(2**(i+1))-1 generate
					FRST_COL: if j = 0 generate
						COL_SEL_1: for k in 0 to 2**(i-1)-1 generate
							SIGN_COL_1: if k < 2**(i-2) generate
								gen_signal(i+1)(k) <= gen_signal(i)(k);
							end generate;	--END SIGN_COL_1
							G_COL: if k >= 2**(i-2) generate
								G_INST_2: GENERAL_GENERATE port map (	Gi_0 => gen_signal(i)(2**(i-2)-1),
													Gi_1 => gen_signal(i)(k),
													Pi => pro_signal(i)(k),
													Go => gen_signal(i+1)(k));
							end generate;	--END G_COL
						end generate;		--END COL_SEL_1
					end generate;			--END FRST_COL
					OTHER_COL: if j > 0 generate
						COL_SEL_2: for k in 0 to 2**(i-1)-1 generate
							SIGN_COL_2: if k < 2**(i-2) generate
								gen_signal(i+1)(j*(2**(i-1))+k) <= gen_signal(i)(j*(2**(i-1))+k);
								pro_signal(i+1)(j*(2**(i-1))+k) <= pro_signal(i)(j*(2**(i-1))+k);
							end generate;	--SIGN_COL_2
							PG_COL: if k >= 2**(i-2) generate
								PG_INST_2: PG_BLOCK port map (	Gi_0 => gen_signal(i)(j*(2**(i-1))+2**(i-2)-1),
												Gi_1 => gen_signal(i)(j*(2**(i-1))+k),
												Pi_0 => pro_signal(i)(j*(2**(i-1))+2**(i-2)-1),
												Pi_1 => pro_signal(i)(j*(2**(i-1))+k),
												Po => pro_signal(i+1)(j*(2**(i-1))+k),
												Go => gen_signal(i+1)(j*(2**(i-1))+k));
							end generate;	--PG_COL
						end generate;		--END COL_SEL_2
					end generate;			--END OTHER_COL
				end generate;				--LINE_GEN_2
			end generate;					--LAST_LINES
		end generate;						--CARRY_GENERATION

		OUT_SIGNALS: for z in 0 to N/4-1 generate
			Co(z) <= gen_signal(M)(z);
		end generate;

end STRUCTURAL;

configuration CFG_CARRY_GENERATOR_STRUCTURAL OF CARRY_GENERATOR is
	for STRUCTURAL
		for all: PG_NETWORK
			use configuration WORK.CFG_PG_NETWORK_STRUCTURAL;
		end for;
		for CARRY_GENERATION
			for FIRST_LINES
				for LINE_GEN_1
					for FIRST_G_BLOCK_1
						for all: GENERAL_GENERATE
							use configuration WORK.CFG_GENERAL_GENERATE_STRUCTURAL;
						end for;
					end for;			--FIRST_G_BLOCK_1
					for OTHER_PG_BLOCKS_1
						for all: PG_BLOCK
							use configuration WORK.CFG_PG_BLOCK_STRUCTURAL;
						end for;
					end for;			--OTHER_PG_BLOCKS_1
				end for;				--LINE_GEN_1
			end for;					--FIRST_LINES
			for LAST_LINES
				for LINE_GEN_2
					for FRST_COL
						for COL_SEL_1
							for G_COL
								for all: GENERAL_GENERATE
									use configuration WORK.CFG_GENERAL_GENERATE_STRUCTURAL;
								end for;
							end for;	--G_COL
						end for;		--COL_SEL_1
					end for;			--FRST_COL
					for OTHER_COL
						for COL_SEL_2
							for PG_COL
								for all: PG_BLOCK
									use configuration WORK.CFG_PG_BLOCK_STRUCTURAL;
								end for;
							end for;	--PG_COL
						end for;		--END COL_SEL_2
					end for;			--END OTHER_COL
				end for;				--LINE_GEN_2
			end for;					--LAST_LINES
		end for;						--CARRY_GENERATION
	end for;							--STRUCTURAL
end CFG_CARRY_GENERATOR_STRUCTURAL;