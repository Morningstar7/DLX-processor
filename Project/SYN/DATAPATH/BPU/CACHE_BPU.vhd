library IEEE;
use IEEE.std_logic_1164.all;

entity CACHE_BPU is
	generic (	N:		integer;
			SET_BIT:	integer);
	port (		ADDR:		in	std_logic_vector(N-1 downto 0);
			DATA_IN:	in	std_logic_vector(N-1 downto 0);
			DATA_OUT:	out	std_logic_vector(N-1 downto 0);
			ENC:		out	std_logic_vector(1 downto 0);
			RST:		in	std_logic;
			LOAD:		in	std_logic;
			CLK:		in	std_logic;
			HIT_MISS:	out	std_logic);
end CACHE_BPU;

architecture STRUCTURAL of CACHE_BPU is

	component CAM_BPU
		generic (	N:		integer;
				SET_BIT:	integer);
		port (		ADDR:		in	std_logic_vector(SET_BIT-1 downto 0);
				RST:		in	std_logic;
				WE:		in	std_logic;
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				ADDR_OUT_1:	out	std_logic_vector(N-1 downto 0);
				ADDR_OUT_2:	out	std_logic_vector(N-1 downto 0);
				ADDR_OUT_3:	out	std_logic_vector(N-1 downto 0);
				ADDR_OUT_4:	out	std_logic_vector(N-1 downto 0);
				VALID_1:	out	std_logic;
				VALID_2:	out	std_logic;
				VALID_3:	out	std_logic;
				VALID_4:	out	std_logic);
	end component;
	
	component CACHE_DATA_BPU
		generic (	N:		integer;
				SET_BIT:	integer);
		port (		CLK:		in	std_logic;
				WE:		in	std_logic;
				ADDR:		in	std_logic_vector(1 downto 0);
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				DATA_OUT:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component EQU_COMPARATOR
		generic (	N: integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Y:	out	std_logic);
	end component;
	
	component MUX21_GEN
		generic (	N: 	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component SYNC_COUNTER_2BIT
		port (	EN:	in 	std_logic;
			RST:	in	std_logic;
			CLK:	in	std_logic;
			COUNT:	out	std_logic_vector(1 downto 0));
	end component;
	
	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component N_OR
		generic (	N: integer);
		port (		A: in std_logic_vector(N-1 downto 0);
				Y: out std_logic);
	end component;

	component BPU_ENCODER
		port (	A:	in	std_logic_vector(3 downto 0);
			Y:	out	std_logic_vector(1 downto 0));
	end component;

	component REG
		generic (	N:	integer);
		port (		D: 	in 	std_logic_vector(N-1 downto 0);
				Q: 	out	std_logic_vector(N-1 downto 0);
				EN:	in	std_logic;
				RST:	in 	std_logic;
				CLK: 	in	std_logic);
	end component;

	signal COMP_OUT_1:	std_logic;
	signal COMP_OUT_2:	std_logic;
	signal COMP_OUT_3:	std_logic;
	signal COMP_OUT_4:	std_logic;
	signal CAM_OUT_1:	std_logic_vector(N-1 downto 0);
	signal CAM_OUT_2:	std_logic_vector(N-1 downto 0);
	signal CAM_OUT_3:	std_logic_vector(N-1 downto 0);
	signal CAM_OUT_4:	std_logic_vector(N-1 downto 0);
	signal VALID_BIT_1:	std_logic;
	signal VALID_BIT_2:	std_logic;
	signal VALID_BIT_3:	std_logic;
	signal VALID_BIT_4:	std_logic;
	signal HIT_MISS_1:	std_logic;
	signal HIT_MISS_2:	std_logic;
	signal HIT_MISS_3:	std_logic;
	signal HIT_MISS_4:	std_logic;
	signal IN_OR:		std_logic_vector(3 downto 0);
	signal IN_B_MUX_2:	std_logic_vector(1 downto 0);
	signal COUNT_OUT:	std_logic_vector(1 downto 0);
	signal MEM_ADDR:	std_logic_vector(1 downto 0);
	signal IN_A_MUX:	std_logic_vector(N-1 downto 0);
	signal IN_B_MUX:	std_logic_vector(N-1 downto 0);
	signal OUT_MUX:		std_logic_vector(N-1 downto 0);
	
	begin

		ENC <= MEM_ADDR;

		PC_REG: REG	generic map (	N => N)
				port map (	D => ADDR,
						Q => IN_A_MUX,
						EN => '1',
						RST => RST,
						CLK => CLK);

		IN_B_MUX <= ADDR;

		MUX_1: MUX21_GEN	generic map (	N => N)
					port map (	A => IN_A_MUX,
							B => IN_B_MUX,
							SEL => LOAD,
							Y => OUT_MUX);
	
		CAM_INST: CAM_BPU	generic map (	N => N,
							SET_BIT => SET_BIT)
					port map (	ADDR => COUNT_OUT,
							RST => RST,
							WE => LOAD,
							DATA_IN => OUT_MUX,
							ADDR_OUT_1 => CAM_OUT_1,
							ADDR_OUT_2 => CAM_OUT_2,
							ADDR_OUT_3 => CAM_OUT_3,
							ADDR_OUT_4 => CAM_OUT_4,
							VALID_1 => VALID_BIT_1,
							VALID_2 => VALID_BIT_2,
							VALID_3 => VALID_BIT_3,
							VALID_4 => VALID_BIT_4);

		COMP_INST_1: EQU_COMPARATOR	generic map (	N => N)
						port map (	A => CAM_OUT_1,
								B => OUT_MUX,
								Y => COMP_OUT_1);

		COMP_INST_2: EQU_COMPARATOR	generic map (	N => N)
						port map (	A => CAM_OUT_2,
								B => OUT_MUX,
								Y => COMP_OUT_2);

		COMP_INST_3: EQU_COMPARATOR	generic map (	N => N)
						port map (	A => CAM_OUT_3,
								B => OUT_MUX,
								Y => COMP_OUT_3);

		COMP_INST_4: EQU_COMPARATOR	generic map (	N => N)
						port map (	A => CAM_OUT_4,
								B => OUT_MUX,
								Y => COMP_OUT_4);

		HIT_MISS_OUT_1: AND_GATE	port map (	A => COMP_OUT_1,
								B => VALID_BIT_1,
								Y => HIT_MISS_1);

		HIT_MISS_OUT_2: AND_GATE	port map (	A => COMP_OUT_2,
								B => VALID_BIT_2,
								Y => HIT_MISS_2);

		HIT_MISS_OUT_3: AND_GATE	port map (	A => COMP_OUT_3,
								B => VALID_BIT_3,
								Y => HIT_MISS_3);

		HIT_MISS_OUT_4: AND_GATE	port map (	A => COMP_OUT_4,
								B => VALID_BIT_4,
								Y => HIT_MISS_4);

		IN_OR <= HIT_MISS_4 & HIT_MISS_3 & HIT_MISS_2 & HIT_MISS_1;

		HIT_MISS_OUT: N_OR	generic map (	N => 4)
					port map (	A => IN_OR,
							Y => HIT_MISS);

		ENCODER: BPU_ENCODER	port map (	A => IN_OR,
							Y => IN_B_MUX_2);

		CNT_INST: SYNC_COUNTER_2BIT	port map (	EN => LOAD,
								RST => RST,
								CLK => CLK,
								COUNT => COUNT_OUT);
	
		MUX_2: MUX21_GEN	generic map (	N => SET_BIT)
					port map (	A => COUNT_OUT,
							B => IN_B_MUX_2,
							SEL => LOAD,
							Y => MEM_ADDR);

		DATA_INST: CACHE_DATA_BPU	generic map (	N => N,
								SET_BIT => SET_BIT)
						port map (	DATA_IN => DATA_IN,
								DATA_OUT => DATA_OUT,
								ADDR => MEM_ADDR,
								CLK => CLK,
								WE => LOAD);

end STRUCTURAL;
		
configuration CFG_CACHE_BPU_STRUCTURAL of CACHE_BPU is
	for STRUCTURAL
		for all: AND_GATE
			use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
		end for;
		for all: MUX21_GEN
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
		for all: BPU_ENCODER
			use configuration WORK.CFG_BPU_ENCODER_STRUCTURAL;
		end for;
		for all: CAM_BPU
			use configuration WORK.CFG_CAM_BPU_BEHAVIORAL;
		end for;
		for all: CACHE_DATA_BPU
			use configuration WORK.CFG_CACHE_DATA_BPU_BEHAVIORAL;
		end for;
		for all: EQU_COMPARATOR
			use configuration WORK.CFG_EQU_COMPARATOR_STRUCTURAL;
		end for;
		for all: SYNC_COUNTER_2BIT
			use configuration WORK.CFG_SYNC_COUNTER_2BIT_STRUCTURAL;
		end for;
		for all: N_OR
			use configuration WORK.CFG_N_OR_BEHAVIORAL;
		end for;
	end for;
end CFG_CACHE_BPU_STRUCTURAL;