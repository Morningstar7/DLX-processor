library IEEE;
use IEEE.std_logic_1164.all;

entity WB is
	generic (	N: 	integer;
			N_ADDR:	integer);
	port (		IN_MEM:		in	std_logic_vector(N-1 downto 0);
			IN_ALU:		in	std_logic_vector(N-1 downto 0);
			IN_NPC: 	in 	std_logic_vector(N-1 downto 0);
			SEL:		in	std_logic_vector(1 downto 0);
			DEST_REG_IN:	in	std_logic_vector(N_ADDR-1 downto 0);
			DEST_REG_OUT:	out	std_logic_vector(N_ADDR-1 downto 0);
			OUT_WB:		out	std_logic_vector(N-1 downto 0));
end WB;

architecture STRUCTURAL of WB is

	component MUX41_GEN 
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(1 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	signal IN_A_MUX:	std_logic_vector(N-1 downto 0);
	signal IN_B_MUX:	std_logic_vector(N-1 downto 0);
	signal IN_C_MUX:	std_logic_vector(N-1 downto 0);
	signal IN_D_MUX:	std_logic_vector(N-1 downto 0);
	signal OUT_MUX:		std_logic_vector(N-1 downto 0);

	begin

	IN_A_MUX <= IN_MEM;
	IN_B_MUX <= IN_ALU;
	IN_C_MUX <= IN_NPC;
	IN_D_MUX <= (others => '0'); -- TO BE CHANGED
	OUT_WB <= OUT_MUX;
	DEST_REG_OUT <= DEST_REG_IN;

	MUX_INST: MUX41_GEN	generic map (	N => N)
				port map (	A => IN_A_MUX,
						B => IN_B_MUX,
						C => IN_C_MUX,
						D => IN_D_MUX,
						SEL => SEL,
						Y => OUT_MUX);

end STRUCTURAL;

configuration CFG_WB_STRUCTURAL of WB is
	for STRUCTURAL
		for all: MUX41_GEN
			use configuration WORK.CFG_MUX41_GEN_BEHAVIORAL;
		end for;
	end for;
end CFG_WB_STRUCTURAL;