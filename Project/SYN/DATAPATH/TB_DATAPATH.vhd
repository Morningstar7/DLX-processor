library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity TB_DATAPATH is
end TB_DATAPATH;

architecture TEST of TB_DATAPATH is

component DATAPATH is
generic (	N:		integer;
			N_ADDR:		integer;
			IMM_SIZE:	integer;
			OP_CODE_SIZE:	integer;
			M:		integer;
			ALUSIZE:	integer);
	port	(	CLK:		in	std_logic;
			RST:		in	std_logic;
			--FETCH SIGNALS
			EN_PC:		in	std_logic;
			EN_1:		in	std_logic;
			--DECODE SIGNALS
			EN_2:		in	std_logic;
			CONFIRM_JMP:	in	std_logic;
			CONFIRM_BRANCH:	in	std_logic;
			BRANCH_TYPE:	in	std_logic;
			RD1:		in	std_logic;
			RD2:		in	std_logic;
			WR:		in	std_logic;
			SEL_DEST:	in	std_logic;
			--EXECUTE SIGNALS
			EN_3:		in	std_logic;
			ALU_CODE:	in 	std_logic_vector(ALUSIZE-1 downto 0); 
			OP_SEL:		in	std_logic; 
			--MEMORY SIGNALS
			EN_4:		in	std_logic;
			RM:		in	std_logic;
			WM:		in	std_logic;
			--WB SIGNALS
			EN_5:		in	std_logic;
			SEL:		in	std_logic);
end component;

	constant		PERIOD:		time := 4 ns; 
	constant		N:		integer := 32;
	constant		N_ADDR:		integer := 5;
	constant		IMM_SIZE:	integer := 16;
	constant		OP_CODE_SIZE:	integer := 6;
	constant		M:		integer := 5;
	constant		ALUSIZE:	integer := 4;
	signal			CLK_TB:			std_logic := '0';
	signal			RST_TB:			std_logic;
				--FETCH SIGNALS
	signal			EN_PC_TB:		std_logic;
	signal			EN_1_TB:		std_logic;
				--DECODE SIGNALS
	signal			EN_2_TB:		std_logic;
	signal			CONFIRM_JMP_TB:		std_logic;
	signal			CONFIRM_BRANCH_TB:	std_logic;
	signal			BRANCH_TYPE_TB:		std_logic;
	signal			RD1_TB:			std_logic;
	signal			RD2_TB:			std_logic;
	signal			WR_TB:			std_logic;
	signal			SEL_DEST_TB:		std_logic;
				--EXECUTE SIGNALS
	signal			EN_3_TB:		std_logic;
	signal			ALU_CODE_TB:		std_logic_vector(ALUSIZE-1 downto 0); 
	signal			OP_SEL_TB:		std_logic; 
				--MEMORY SIGNALS
	signal			EN_4_TB:		std_logic;
	signal			RM_TB:			std_logic;
	signal			WM_TB:			std_logic;
				--WB SIGNALS
	signal			EN_5_TB:		std_logic;
	signal			SEL_TB:			std_logic;

	begin
	
		CLK_process : process
			begin
				wait for PERIOD/2;
					CLK_TB <= not CLK_TB; 
		end process CLK_process; 
		
		RST_TB <= '1', '0' after 3*PERIOD; 

		EN_PC_TB <= '0', '1' after 3*PERIOD, '0' after 4*PERIOD, '1' after 6*PERIOD, '0' after 7*PERIOD, '1' after 10*PERIOD, '0' after 11*PERIOD;
		EN_1_TB <= '0','1' after 3*PERIOD, '0' after 4*PERIOD, '1' after 6*PERIOD, '0' after 7*PERIOD,  '1' after 10*PERIOD, '0' after 11*PERIOD;
		
		EN_2_TB <= '0', '1' after 4*PERIOD, '0' after 5*PERIOD, '1' after 7*PERIOD, '0' after 8*PERIOD, '1' after 10*PERIOD, '0' after 12*PERIOD,  '1' after 14*PERIOD, '0' after 15*PERIOD;
		CONFIRM_JMP_TB <= '0';
		CONFIRM_BRANCH_TB <= '0';
		BRANCH_TYPE_TB <= '0';
		RD1_TB <= '0', '1' after 4*PERIOD, '0' after 5*PERIOD, '1' after 7*PERIOD, '0' after 8*PERIOD, '1' after 11*PERIOD, '0' after 12*PERIOD;
		RD2_TB <= '0', '1' after 11*PERIOD, '0' after 12*PERIOD;
		WR_TB <= '0', '1' after 7*PERIOD, '0' after 8*PERIOD, '1' after 10*PERIOD, '0' after 11*PERIOD, '1' after 14*PERIOD, '0' after 15*PERIOD;
		SEL_DEST_TB <= '1', '0' after 11*PERIOD;
		
		EN_3_TB <= '0', '1' after 5*PERIOD, '0' after 6*PERIOD, '1' after 8*PERIOD, '0' after 9*PERIOD, '1' after 12*PERIOD, '0' after 13*PERIOD;
		ALU_CODE_TB <= "0000";
		OP_SEL_TB <= '0', '1' after 12*PERIOD;
		
		EN_4_TB <= '0', '1' after 6*PERIOD, '0' after 7*PERIOD, '1' after 9*PERIOD, '0' after 10*PERIOD, '1' after 13*PERIOD, '0' after 14*PERIOD;
		RM_TB <= '0';
		WM_TB <= '0';

		EN_5_TB <= '0', '1' after 7*PERIOD, '0' after 8*PERIOD, '1' after 10*PERIOD, '0' after 11*PERIOD, '1' after 14*PERIOD, '0' after 15*PERIOD;
		SEL_TB <= '0'; 
 
		
		DUT: DATAPATH generic map (	N		=> N,
						N_ADDR		=> N_ADDR,
						IMM_SIZE	=> IMM_SIZE,
						OP_CODE_SIZE	=> OP_CODE_SIZE,
						M		=> M,
						ALUSIZE		=> ALUSIZE)
				port map (	CLK		=> CLK_TB,
						RST		=> RST_TB,
						EN_PC		=> EN_PC_TB,
						EN_1		=> EN_1_TB,
						EN_2		=> EN_2_TB,
						CONFIRM_JMP	=> CONFIRM_JMP_TB,
						CONFIRM_BRANCH	=> CONFIRM_BRANCH_TB,
						BRANCH_TYPE	=> BRANCH_TYPE_TB,
						RD1		=> RD1_TB,
						RD2		=> RD2_TB,
						WR		=> WR_TB,
						SEL_DEST	=> SEL_DEST_TB,
						EN_3		=> EN_3_TB,
						ALU_CODE	=> ALU_CODE_TB,
						OP_SEL		=> OP_SEL_TB,
						EN_4		=> EN_4_TB,
						RM		=> RM_TB,
						WM		=> WM_TB,
						EN_5		=> EN_5_TB,
						SEL		=> SEL_TB);

end TEST; 