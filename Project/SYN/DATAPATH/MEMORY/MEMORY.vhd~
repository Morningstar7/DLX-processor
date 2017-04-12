library IEEE;
use IEEE.std_logic_1164.all;

entity MEMORY is
	generic (	N:	integer;
			N_ADDR:	integer);
	port	(	IN_ALU:		in	std_logic_vector(N-1 downto 0);
			DEST_REG_IN:	in	std_logic_vector(N_ADDR-1 downto 0);
			REG_B_IN:	in	std_logic_vector(N-1 downto 0);
			FORW_ALU_WB:	in	std_logic_vector(N-1 downto 0);
			FORW_MEM_WB:	in	std_logic_vector(N-1 downto 0);
			FORW_REG:	in	std_logic_vector(N-1 downto 0);
			SEL_DATA:	in	std_logic_vector(1 downto 0);
			RESET:		in	std_logic;
			ENABLE:		in	std_logic;
			DATA_IN_MEM:	in	std_logic_vector(N-1 downto 0);
			LOAD_TYPE:	in	std_logic_vector(2 downto 0);
			STORE_MASK:	in	std_logic_vector(1 downto 0);
			ADDR_MEM:	out	std_logic_vector(N-1 downto 0);
			DATA_OUT_MEM:	out	std_logic_vector(N-1 downto 0);
			DEST_REG_OUT:	out	std_logic_vector(N_ADDR-1 downto 0);
			MEMORY_OUT:	out	std_logic_vector(N-1 downto 0);
			OUT_ALU:	out	std_logic_vector(N-1 downto 0));
end MEMORY;

architecture STRUCTURAL of MEMORY is

-- Component Declaration

	component DATA_MEMORY
		generic (	M: integer;
				N: integer);
		port (		RESET:		in	std_logic;
				ENABLE:		in	std_logic;
				RM:		in	std_logic;
				WM:		in	std_logic;
				ADDR:		in	std_logic_vector(M-1 downto 0);
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				DATA_OUT:	out	std_logic_vector(N-1 downto 0));
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

	component MUX51_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				E:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(2 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component AND_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

-- Signal declaration

	signal IN_A_MUX:		std_logic_vector(N-1 downto 0);
	signal IN_B_MUX:		std_logic_vector(N-1 downto 0);
	signal IN_C_MUX:		std_logic_vector(N-1 downto 0);
	signal IN_D_MUX:		std_logic_vector(N-1 downto 0);
	signal OUT_MUX:			std_logic_vector(N-1 downto 0);
	signal IN_A_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal IN_B_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal IN_C_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal IN_D_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal IN_E_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal IN_F_MUX_LOAD:		std_logic_vector(N-1 downto 0);
	signal OUT_MUX_LOAD:		std_logic_vector(N-1 downto 0);

	begin

		-- Signal mapping
		IN_A_MUX <= REG_B_IN;
		IN_B_MUX <= FORW_ALU_WB;
		IN_C_MUX <= FORW_MEM_WB;
		IN_D_MUX <= FORW_REG;
		ADDR_MEM <= IN_ALU;
		MEMORY_OUT <= OUT_MUX_LOAD;
		DEST_REG_OUT <= DEST_REG_IN;
		OUT_ALU <= IN_ALU;
		IN_A_MUX_LOAD <= (N-1 downto 8 => '0') & DATA_IN_MEM(7 downto 0);			--LBU
		IN_B_MUX_LOAD <= (N-1 downto 8 => DATA_IN_MEM(7)) & DATA_IN_MEM(7 downto 0);		--LB
		IN_C_MUX_LOAD <= (N-1 downto 16 => '0') & DATA_IN_MEM(15 downto 0);			--LHU
		IN_D_MUX_LOAD <= (N-1 downto 16 => DATA_IN_MEM(15)) & DATA_IN_MEM(15 downto 0);	--LH
		IN_E_MUX_LOAD <= DATA_IN_MEM;								--LW
		DATA_OUT_MEM(7 downto 0) <= OUT_MUX(7 downto 0);

		-- Port Mapping
		GEN_MASK: for i in 0 to 23 generate
			MASK_1: if i < 16 generate
				SH_MASK: AND_GATE	port map (	A => OUT_MUX(N-1-i),
									B => STORE_MASK(0),
									Y => DATA_OUT_MEM(N-1-i));
			end generate MASK_1;
			MASK_2: if i > 15 generate
				SB_MASK: AND_GATE	port map (	A => OUT_MUX(N-1-i),
									B => STORE_MASK(1),
									Y => DATA_OUT_MEM(N-1-i));
			end generate MASK_2;
		end generate GEN_MASK;

		REGB_MUX: MUX41_GEN 	generic map(	N => N)
					port map(	A => IN_A_MUX,
							B => IN_B_MUX,
							C => IN_C_MUX,
							D => IN_D_MUX,
							SEL => SEL_DATA,
							Y => OUT_MUX);

		LOAD_MUX: MUX51_GEN	generic map (	N => N)
					port map (	A => IN_A_MUX_LOAD,
							B => IN_B_MUX_LOAD,
							C => IN_C_MUX_LOAD,
							D => IN_D_MUX_LOAD,
							E => IN_E_MUX_LOAD,
							SEL => LOAD_TYPE,
							Y => OUT_MUX_LOAD);

end STRUCTURAL;
	
configuration CFG_MEMORY_STRUCTURAL of MEMORY is
	for STRUCTURAL
		for GEN_MASK
			for MASK_1
				for all: AND_GATE
					use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
				end for;
			end for;
			for MASK_2
				for all: AND_GATE
					use configuration WORK.CFG_AND_GATE_BEHAVIORAL;
				end for;
			end for;
		end for;
		for all: MUX41_GEN
			use configuration WORK.CFG_MUX41_GEN_BEHAVIORAL;
		end for;
		for all: MUX51_GEN
			use configuration WORK.CFG_MUX51_GEN_BEHAVIORAL;
		end for;
	end for;
end CFG_MEMORY_STRUCTURAL;
