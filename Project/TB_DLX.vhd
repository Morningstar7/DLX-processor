library IEEE;
use IEEE.std_logic_1164.all;
use work.myTypes.all;

entity TB_DLX is
end TB_DLX;

architecture ALUPUSHTESTA  of TB_DLX is

	component DLX
		port	(	CLK:		in	std_logic;
				RST:		in	std_logic;
				DATA_IN_INSTR:	in	std_logic_vector(7 downto 0);
				DATA_IN_MEM:	in	std_logic_vector(31 downto 0);
				RM:		out	std_logic;
				WM:		out	std_logic;
				ADDR_MEM:	out	std_logic_vector(31 downto 0);
				DATA_OUT_MEM:	out	std_logic_vector;
				ADDR_INSTR:	out	std_logic_vector(31 downto 0));
	end component;

	component IRAM
		generic (	RAM_DEPTH:	integer;
				I_SIZE:		integer);
		port (		RST:	in	std_logic;
				ADDR:	in	std_logic_vector(I_SIZE-1 downto 0);
				D_OUT:	out	std_logic_vector(7 downto 0));
	end component;

	component DATA_MEMORY
		generic (	M: integer;
				N: integer);
		port (		RESET:		in	std_logic;
				CLK:		in	std_logic;
				RM:		in	std_logic;
				WM:		in	std_logic;
				LOAD:		in	std_logic;
				ADDR:		in	std_logic_vector(N-1 downto 0);
				DATA_IN:	in	std_logic_vector(N-1 downto 0);
				DATA_OUT:	out	std_logic_vector(N-1 downto 0));
	end component;

	constant PERIOD:	time := 10 ns; 
	signal CLK_TB:		std_logic := '0';
	signal RST_TB:		std_logic := '1';
	signal DATA_IRAM:	std_logic_vector(7 downto 0);
	signal ADDR_IRAM:	std_logic_vector(31 downto 0);
	signal ADDR_MEM:	std_logic_vector(31 downto 0);
	signal DATA_IN_MEM:	std_logic_vector(31 downto 0);
	signal DATA_OUT_MEM:	std_logic_vector(31 downto 0);
	signal RM:		std_logic;
	signal WM:		std_logic;
	signal LOAD:		std_logic;

	begin

		RST_TB <= '1', '0' after PERIOD;
		LOAD <= '1', '0' after PERIOD/2;

		PROC: process
			begin
				wait for PERIOD/2;
				CLK_TB<= not CLK_TB;
		end process;

		ALUPUSH: DLX port map (	CLK => CLK_TB,
					RST => RST_TB,
					DATA_IN_INSTR => DATA_IRAM,
					DATA_IN_MEM => DATA_OUT_MEM,
					RM => RM,
					WM => WM,
					ADDR_MEM => ADDR_MEM,
					DATA_OUT_MEM => DATA_IN_MEM,
					ADDR_INSTR => ADDR_IRAM);

		IRAM_INST: IRAM	generic map (	RAM_DEPTH => 2048,
						I_SIZE => 32)
				port map (	RST => RST_TB,
						ADDR => ADDR_IRAM,
						D_OUT => DATA_IRAM);

		DATA_MEM_INST: DATA_MEMORY	generic map (	M => 6,
								N => 32)
						port map (	RESET => RST_TB,
								CLK => CLK_TB,
								RM => RM,
								WM => WM,
								LOAD => LOAD,
								ADDR => ADDR_MEM,
								DATA_IN => DATA_IN_MEM,
								DATA_OUT => DATA_OUT_MEM);

end ALUPUSHTESTA; 

