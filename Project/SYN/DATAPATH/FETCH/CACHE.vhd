library IEEE;
use IEEE.std_logic_1164.all;

entity CACHE is
	generic (	N:		integer;
			TAG_BIT:	integer;
			SET_BIT:	integer;
			N_DATA:		integer);
	port (		ADDR:		in	std_logic_vector(N-1 downto 0);
			ADDR_OUT:	out	std_logic_vector(N-1 downto 0);
			DATA_IN:	in	std_logic_vector(7 downto 0);
			DATA_OUT:	out	std_logic_vector(N-1 downto 0);
			RST:		in	std_logic;
			LOAD:		in	std_logic;
			CLK:		in	std_logic;
			HIT_MISS:	out	std_logic);
end CACHE;

architecture STRUCTURAL of CACHE is

	component CAM
		generic (	TAG_BIT: integer;
				SET_BIT: integer);
		port (		TAG_IN: in std_logic_vector(TAG_BIT-1 downto 0);
				TAG_OUT: out std_logic_vector(TAG_BIT-1 downto 0);
				SET_INDEX: in std_logic_vector(SET_BIT-1 downto 0);
				COUNT:	in	std_logic_vector(4 downto 0);
				VALID: out std_logic;
				CLK:	in	std_logic;
				RST: in std_logic;
				WE: in std_logic);
	end component;
	
	component CACHE_DATA
		generic (	N:		integer;
				N_DATA:		integer;
				SET_BIT:	integer);
		port (		DATA_IN:	in	std_logic_vector(7 downto 0);
				DATA_OUT:	out	std_logic_vector(N-1 downto 0);
				ADDR:		in	std_logic_vector(SET_BIT-1 downto 0);
				OFFSET:		in	std_logic_vector(N_DATA-1 downto 0);
				CLK:		in	std_logic;
				WE:		in	std_logic);
	end component;
	
	component SYNC_COUNTER_5BIT
		port (	EN: 	In 	std_logic;
				RST:	in std_logic;
				CLK: 	in	std_logic;
				COUNT: out std_logic_vector(4 downto 0));
	end component;
	
	component EQU_COMPARATOR
		generic (	N: integer);
		port (		A: in std_logic_vector(N-1 downto 0);
				B: in std_logic_vector(N-1 downto 0);
				Y: out std_logic);
	end component;
	
	component MUX21_GEN
		generic (	N: 	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;
	
	component AND_GATE
		port (	A: in std_logic;
			B: in std_logic;
			Y: out std_logic);
	end component;
	
	signal VALID_BIT: std_logic;
	signal CNT_RST: std_logic;
	signal COUNT_OUT: std_logic_vector(N-TAG_BIT-SET_BIT-1 downto 0);
	signal OFF_DATA: std_logic_vector(N-TAG_BIT-SET_BIT-1 downto 0);
	signal IN_COMP: std_logic_vector(TAG_BIT-1 downto 0);
	signal COMP_OUT: std_logic;
	--signal TEST:	std_logic;
	
	begin
	
		MUX_1: MUX21_GEN	generic map (	N => N-TAG_BIT-SET_BIT)
					port map (	A => COUNT_OUT,
							B => ADDR(N-TAG_BIT-SET_BIT-1 downto 0),
							SEL => LOAD,
							Y => OFF_DATA);
	
		CAM_INST: CAM	generic map (	TAG_BIT => TAG_BIT,
						SET_BIT => SET_BIT)
				port map (	TAG_IN => ADDR(N-1 downto N-TAG_BIT),
						TAG_OUT => IN_COMP,
						SET_INDEX => ADDR(N-TAG_BIT-1 downto N-TAG_BIT-SET_BIT),
						CLK => CLK,
						COUNT => COUNT_OUT,
						VALID => VALID_BIT,
						RST => RST,
						WE => LOAD);
										
		DATA_INST: CACHE_DATA	generic map (	N => N,
							N_DATA => N_DATA,
							SET_BIT => SET_BIT)
					port map (	DATA_IN => DATA_IN,
							DATA_OUT => DATA_OUT,
							ADDR => ADDR(N-TAG_BIT-1 downto N-TAG_BIT-SET_BIT),
							OFFSET => OFF_DATA,
							CLK => CLK,
							WE => LOAD);
												
		COMP_INST: EQU_COMPARATOR	generic map (	N => TAG_BIT)
						port map (	A => IN_COMP,
								B => ADDR(N-1 downto N-TAG_BIT),
								Y => COMP_OUT);

		CNT_INST: SYNC_COUNTER_5BIT	port map (	EN => LOAD,
								RST => CNT_RST,
								CLK => CLK,
								COUNT => COUNT_OUT);
												
		HIT_MISS_OUT: AND_GATE port map (	A => COMP_OUT,
							B => VALID_BIT,
							Y => HIT_MISS);

-- 		process(TEST, CLK, RST)
-- 			begin
-- 				if(RST = '1') then
-- 					HIT_MISS <= '0';
-- 				elsif(TEST = '0') then
-- 					if(LOAD = '1') and (COUNT_OUT /= "11111") then
-- 						HIT_MISS <= '0';
-- 					else
-- 						HIT_MISS <= '1';
-- 					end if;
-- 				else
-- 					if CLK'event and CLK = '1' then
-- 						HIT_MISS <= '1';
-- 					end if;
-- 				end if;
-- 		end process;

		--HIT_MISS <= TEST;
		CNT_RST <= not LOAD or RST;
		ADDR_OUT <= ADDR(N-1 downto N-TAG_BIT-SET_BIT) & COUNT_OUT;
		
end STRUCTURAL;
		
configuration CFG_CACHE_STRUCTURAL of CACHE is
	for STRUCTURAL
		for all: MUX21_GEN
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
		for all: CAM
			use configuration WORK.CFG_CAM_BEHAVIORAL;
		end for;
		for all: CACHE_DATA
			use configuration WORK.CFG_CACHE_DATA_BEHAVIORAL;
		end for;
		for all: EQU_COMPARATOR
			use configuration WORK.CFG_EQU_COMPARATOR_STRUCTURAL;
		end for;
		for all: SYNC_COUNTER_5BIT
			use configuration WORK.CFG_SYNC_COUNTER_5BIT_STRUCTURAL;
		end for;
	end for;
end CFG_CACHE_STRUCTURAL;