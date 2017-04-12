library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;

entity NR_DIVISOR_DATAPATH is
port (
	CLK : 			in std_logic; 				-- CLOCK
	RST: 			in std_logic; 				-- RESET 
	Z   : 			in std_logic_vector(15 downto 0); 	-- DIVIDEND 
	D   : 			in std_logic_vector(15 downto 0); 	-- DIVISOR
	Q   : 			out std_logic_vector(15 downto 0);	-- QUOTIENT
	R   : 			out std_logic_vector(15 downto 0);	-- REMAINDER
	MSB_REM:		out std_logic;
	ADD_IN_D: 		out std_logic_vector(15 downto 0);
	ADD_IN_R:		out std_logic_vector(15 downto 0); 
	SIGN:			out std_logic;
	ADD_OUT:		in std_logic_vector(15 downto 0);
	SEL_R_MUX_IN:		in std_logic;
	SEL_Q_MUX_IN:		in std_logic;
	SEL_D_MUX:		in std_logic;
	SEL_ADD_IN_D_MUX:	in std_logic_vector(1 downto 0);
	SEL_ADD_IN_R_MUX:	in std_logic_vector(1 downto 0);
	SEL_SIGN_MUX:		in std_logic_vector(1 downto 0);
	EN_D:			in std_logic;
	EN_Z:			in std_logic;
	EN_Q:			in std_logic;
	EN_R:			in std_logic;
	EN_SIGN:		in std_logic
	);

end NR_DIVISOR_DATAPATH;

architecture STRUCTURAL of NR_DIVISOR_DATAPATH is

constant N : integer := 16;

component MUX21_GEN is
	generic (	N: 		integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic;
			Y:	out	std_logic_vector(N-1 downto 0));
end component;

component MUX41_GEN is
	generic (	N:		integer);
	port (		A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			C:	in	std_logic_vector(N-1 downto 0);
			D:	in	std_logic_vector(N-1 downto 0);
			SEL:	in	std_logic_vector(1 downto 0);
			Y:	out	std_logic_vector(N-1 downto 0));
end component;

component MUX41 is
	port (		A:	in	std_logic;
			B:	in	std_logic;
			C:	in	std_logic;
			D:	in	std_logic;
			SEL:	in	std_logic_vector(1 downto 0);
			Y:	out	std_logic);
end component;

component REG is
	generic (	N:		integer);
	port (		D: 	in 	std_logic_vector(N-1 downto 0);
			Q: 	out	std_logic_vector(N-1 downto 0);
			EN:	in	std_logic;
			RST:	in 	std_logic;
			CLK: 	in	std_logic);
end component;

component XOR_GATE is
	port (	A:	in	std_logic;
		B:	in	std_logic;
		Y:	out	std_logic);
end component;

component FD is
	port(	D:	in	std_logic;
		CLK:	in	std_logic;
		EN:	in	std_logic;
		RST:	in	std_logic;
		Q:	out	std_logic);
end component;

 	signal ZERO:		std_logic_vector(N-1 downto 0);
	signal R_MUX_OUT:	std_logic_vector(N-1 downto 0);
 	signal Q_MUX_OUT:	std_logic_vector(N-1 downto 0);
 	signal RQ:		std_logic_vector(2*N-1 downto 0);
	signal RQ_SHFT:		std_logic_vector(2*N-1 downto 0);
 	signal D_MUX_OUT:	std_logic_vector(N-1 downto 0);
	signal D_REG_OUT:	std_logic_vector(N-1 downto 0);
	signal Z_REG_OUT:	std_logic_vector(N-1 downto 0);
	signal R_REG_OUT: std_logic_vector(N-1 downto 0);  
	signal Q_REG_OUT: std_logic_vector(N-1 downto 0); 
	signal Q_MUX_IN:  std_logic_vector(N-1 downto 0);
	signal XOR_SIGN:  std_logic;
	signal SIGN_REG_OUT: std_logic;
	signal SIGN_SIG: std_logic;
	
	

begin
	
	ZERO <= (others => '0');	-- Signal of 0s

	-- R TO RQ ------------------------------------------------
	R_MUX_IN: MUX21_GEN	generic map(	N	=> N)    
				port map(	A 	=> ZERO,		-- LOAD, 
						B 	=> ADD_OUT,
						SEL 	=> SEL_R_MUX_IN,
						Y 	=> R_MUX_OUT);

	REG_R: REG		generic map(	N 	=> N)
				port map(	D 	=> R_MUX_OUT,
						Q 	=> R_REG_OUT,	
						EN	=> EN_R,
						RST	=> RST,
						CLK 	=> CLK);
	-----------------------------------------------------------

	-- Q TO RQ ------------------------------------------------	
	Q_MUX_IN(N-1 downto 1) <= RQ_SHFT(N-1 downto 1);
	Q_MUX_IN(0) <= not ADD_OUT(15); 

	Q_MUX21_IN: MUX21_GEN	generic map(	N	=> N)
				port map(	A 	=> ADD_OUT,	
						B 	=> Q_MUX_IN,
						SEL 	=> SEL_Q_MUX_IN,
						Y 	=> Q_MUX_OUT);

	REG_Q: REG		generic map(	N 	=> N)
				port map(	D 	=> Q_MUX_OUT,
						Q 	=> Q_REG_OUT,	
						EN	=> EN_Q,
						RST	=> RST,
						CLK 	=> CLK);
	-----------------------------------------------------------

	RQ <= R_REG_OUT & Q_REG_OUT;
	RQ_SHFT(31 downto 0) <= RQ(30 downto 0) & '0';

	-- D TO ADDER ---------------------------------------------
	D_MUX: MUX21_GEN	generic map(	N	=> N)
				port map(	A 	=> D,
						B 	=> ADD_OUT,
						SEL 	=> SEL_D_MUX,
						Y 	=> D_MUX_OUT);
	
	REG_D: REG		generic map(	N 	=> N)
				port map(	D 	=> D_MUX_OUT,
						Q 	=> D_REG_OUT,	
						EN	=> EN_D,
						RST	=> '0',       -- <-- CHECK THIS
						CLK 	=> CLK);
	-----------------------------------------------------------

	-- Z TO ADD -----------------------------------------------
	REG_Z: REG		generic map(	N 	=> N)
				port map(	D 	=> Z,
						Q 	=> Z_REG_OUT,	
						EN	=> EN_Z,
						RST	=> RST,
						CLK 	=> CLK);
	-----------------------------------------------------------

	-- ADDER D AND R INPUTS -----------------------------------
	ADD_IN_D_MUX: MUX41_GEN generic map(	N	=> N)
				port map(	A 	=> Q_REG_OUT,
						B 	=> R_REG_OUT,
						C 	=> D_REG_OUT,
						D 	=> Z_REG_OUT,
						SEL 	=> SEL_ADD_IN_D_MUX,
						Y 	=> ADD_IN_D);
	
	ADD_IN_R_MUX: MUX41_GEN generic map(	N	=> N)
				port map(	A	=> ZERO,
						B 	=> RQ_SHFT(31 downto 16),
						C 	=> RQ(31 downto 16),
						D 	=> ZERO,
						SEL	=> SEL_ADD_IN_R_MUX,
						Y 	=> ADD_IN_R);
	-----------------------------------------------------------

	-- SIGN TO ADDER ------------------------------------------
	SIGN_XOR: XOR_GATE	port map(	A	=> Z(15),
						B 	=> D(15),
						Y	=> XOR_SIGN);

	SIGN_FD: FD 		port map(	D	=> XOR_SIGN,
						CLK	=> CLK,
						EN	=> EN_SIGN,
						RST	=> RST,
						Q	=> SIGN_REG_OUT);
	
	ADD_IN_SIGN_MUX: MUX41
				port map(	A	=> SIGN_SIG,
						B 	=> Z(15),
						C 	=> D(15),
						D 	=> SIGN_REG_OUT,
						SEL	=> SEL_SIGN_MUX,
						Y 	=> SIGN);
	
	SIGN_SIG <= not RQ(31);
	MSB_REM <= ADD_OUT(15);
	-----------------------------------------------------------
		
	R <= R_REG_OUT;
 	Q <= Q_REG_OUT;

end STRUCTURAL;

configuration CFG_NR_DIVISOR_DATAPATH_STRUCTURAL of NR_DIVISOR_DATAPATH is
	for STRUCTURAL
		for all: REG
			use configuration WORK.CFG_REG_SYN_STRUCTURAL;
		end for;
		for all: MUX21_GEN	
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
		for all: MUX41_GEN	
			use configuration WORK.CFG_MUX41_GEN_BEHAVIORAL;
		end for;
		for all: MUX41
			use configuration WORK.CFG_MUX41_BEHAVIORAL;
		end for;
		for all: XOR_GATE	
			use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
		end for;
		for all: FD
			use configuration WORK.CFG_FD_PIPPO;
		end for;
	end for;
end CFG_NR_DIVISOR_DATAPATH_STRUCTURAL;