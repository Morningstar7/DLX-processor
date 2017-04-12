library IEEE;
use IEEE.std_logic_1164.all;
--use work.myTypes.all;

entity ALU is
	generic (	N:		integer;
			ALU_SIZE:	integer);
	port	(	IN_A:		in	std_logic_vector(N-1 downto 0);
			IN_B:		in	std_logic_vector(N-1 downto 0);
			ALU_OP_CODE:	in 	std_logic_vector(ALU_SIZE-1 downto 0);
			CLK:		in	std_logic;
			RST:		in	std_logic;
			RST_DIV: 	in 	std_logic;
			OUT_ALU:	out	std_logic_vector(N-1 downto 0));
end ALU;

architecture STRUCTURAL of ALU is

	component P4_ADDER
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Ci:	in	std_logic;
				Co:	out	std_logic;
				S:	out	std_logic_vector(N-1 downto 0));
	end component;

	component CMP
		generic (	N:	integer);
		port(		C:	in	std_logic;
				S:	in	std_logic_vector(N-1 downto 0);		-- SUM
				OP_SEL:	in	std_logic_vector(2 downto 0);		--111 LESS, 110 LESS OR EQUAL, 101 EQUAL, 100 NOT EQUAL, 011 GREATER OR EQUAL, 010 GREATER
				UNSIGN:	in	std_logic;
				MSB_A:	in	std_logic;
				MSB_B:	in	std_logic;
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component T2_LOGICALS
		generic (	N: integer);
		port (		OP:	in	std_logic_vector(3 downto 0);		--0001 AND, 1110 NAND, 0111 OR, 1000 NOR, 0110 XOR, 1001 XNOR
				A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component T2_SHIFTER
		generic (	N:	integer);
		port (		A:		in	std_logic_vector(N-1 downto 0);
				B:		in	std_logic_vector(4 downto 0);
				ARITH_LOG:	in	std_logic;
				RIGHT_LEFT:	in	std_logic;
				Y:		out	std_logic_vector(N-1 downto 0));
	end component;

	component BOOTHMUL
		port (		A:	in	std_logic_vector(15 downto 0);
				B:	in	std_logic_vector(15 downto 0);
				CLK:	in	std_logic;
				EN:	in	std_logic;
				RST:	in	std_logic;
				P:	out	std_logic_vector(31 downto 0));
	end component;

	component MUX61_GEN
		generic (	N:	integer);
		port (		A:	in	std_logic_vector(N-1 downto 0);
				B:	in	std_logic_vector(N-1 downto 0);
				C:	in	std_logic_vector(N-1 downto 0);
				D:	in	std_logic_vector(N-1 downto 0);
				E:	in	std_logic_vector(N-1 downto 0);  
				F: 	in std_logic_vector(N-1 downto 0);
				SEL:	in	std_logic_vector(2 downto 0);
				Y:	out	std_logic_vector(N-1 downto 0));
	end component;

	component MUX21_GEN
		generic (	N:	integer);
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

	component XOR_GATE
		port (	A:	in	std_logic;
			B:	in	std_logic;
			Y:	out	std_logic);
	end component;

	component NR_DIVISOR is
		port (
			CLK : 		in std_logic; 				-- CLOCK
			RST: 		in std_logic; 				-- RESET
			EN:		in std_logic;
			Z   : 		in std_logic_vector(15 downto 0); 	-- DIVIDEND 
			D   : 		in std_logic_vector(15 downto 0); 	-- DIVISOR
			Q   : 		out std_logic_vector(15 downto 0);	-- QUOTIENT
			R   : 		out std_logic_vector(15 downto 0);		-- REMAINDER
			ADD_IN_D: 	out std_logic_vector(15 downto 0);
			ADD_IN_R:	out std_logic_vector(15 downto 0); 
			SIGN:		out std_logic;
			ADD_OUT:	in std_logic_vector(15 downto 0));
	end component;

	component D_LATCH
		port (		D:	in	std_logic;
				EN:	in	std_logic;
				Q:	out	std_logic);
	end component;

	signal SIGN_SIG:	std_logic;
	signal SUB_ADD:		std_logic;
	signal MUX_SEL:		std_logic_vector(2 downto 0);
	signal MUX_SEL_ADD_D:	std_logic;
	signal MUX_SEL_ADD_R:	std_logic;
	signal MUX_SEL_ADD_S:	std_logic;

	--P4 ADDER SIGNALS
	signal IN_A_P4:		std_logic_vector(N-1 downto 0);
	signal IN_B_P4:		std_logic_vector(N-1 downto 0);
	signal Ci_P4:		std_logic;
	signal OUT_P4:		std_logic_vector(N-1 downto 0);
	signal Co_ADDER:	std_logic;
	signal A_SIG:		std_logic_vector(N-1 downto 0);
	signal B_SIG:		std_logic_vector(N-1 downto 0);
	signal B_SIG2:		std_logic_vector(N-1 downto 0);

	--T2 LOGICALS SIGNALS
	signal LOG_OP:		std_logic_vector(3 downto 0);
	signal LOG_OP_SIG:	std_logic_vector(3 downto 0);
	signal A_LOG:		std_logic_vector(N-1 downto 0);
	signal B_LOG:		std_logic_vector(N-1 downto 0);
	signal OUT_LOG:		std_logic_vector(N-1 downto 0);

	--T2 SHIFTER SIGNALS
	signal RIGHT_LEFT:	std_logic;
	signal ARITH_LOG:	std_logic;
	signal OUT_SHIFT:	std_logic_vector(N-1 downto 0);

	--MULTIPLIER SIGNALS
	signal EN_MUL:		std_logic;
	signal OUT_MUL:		std_logic_vector(N-1 downto 0);

	--DIVISOR SIGNALS
	signal DIV_EN	:	std_logic;
	signal OUT_DIV:		std_logic_vector(N-1 downto 0);
	signal OUT_DIV_D:	std_logic_vector(N-1 downto 0);
	signal OUT_DIV_R:	std_logic_vector(N-1 downto 0);
	signal OUT_DIV_SIGN:	std_logic;
	signal RST_DIV_SIG:	std_logic;
	--signal FLAG_RST:	integer := 0;

	--SIGNAL FOR UNSIGNED OPERATIONS
	signal UNSIGN:		std_logic;

	--COMPARATOR SIGNALS
	signal S_CMP:		std_logic_vector(N-1 downto 0);
	signal Co_CMP:		std_logic;
	signal OUT_CMP:		std_logic_vector(N-1 downto 0);
	signal UNSIGN_CMP:	std_logic;
	signal MSB_A_CMP:	std_logic;
	signal MSB_B_CMP:	std_logic;
	signal CMP_OP:		std_logic_vector(2 downto 0);

	--GUARDED EVALUATION SIGNALS
	signal EN_GUARD_CMP:	std_logic;
	signal EN_GUARD_LOG:	std_logic;
	signal EN_GUARD_P4:	std_logic;

	begin

		RST_DIV_SIG <= RST_DIV;
		
		--ASSIGN THE LOG_OP SIGNAL
		LOG_OP <=	"0001" when ALU_OP_CODE = "00001" else
				"0111" when ALU_OP_CODE = "00010" else
				"0110";

		--ASSIGN THE CMP_OP SIGNAL
		CMP_OP <=	"111" when ALU_OP_CODE = "01011" else
				"111" when ALU_OP_CODE = "01100" else
				"110" when ALU_OP_CODE = "01000" else
				"110" when ALU_OP_CODE = "01001" else
				"101" when ALU_OP_CODE = "00011" else
				"100" when ALU_OP_CODE = "01101" else
				"011" when ALU_OP_CODE = "00100" else
				"011" when ALU_OP_CODE = "00101" else
				"010";

		--ASSIGN THE UNSIGNED BIT
		UNSIGN <=	'1' when ALU_OP_CODE = "00101" else
				'1' when ALU_OP_CODE = "00111" else
				'1' when ALU_OP_CODE = "01001" else
				'1' when ALU_OP_CODE = "01100" else
				'0';

		--ASSIGN THE SUB_ADD SIGNAL
		SUB_ADD <=	'1' when ALU_OP_CODE = "00011" else
				'1' when ALU_OP_CODE = "00100" else
				'1' when ALU_OP_CODE = "00101" else
				'1' when ALU_OP_CODE = "00110" else
				'1' when ALU_OP_CODE = "00111" else
				'1' when ALU_OP_CODE = "01000" else
				'1' when ALU_OP_CODE = "01001" else
				'1' when ALU_OP_CODE = "01011" else
				'1' when ALU_OP_CODE = "01100" else
				'1' when ALU_OP_CODE = "01101" else
				'1' when ALU_OP_CODE = "10000" else
				'0';

		--ASSIGN MUXES FOR P4 ADDER INPUT A
		MUX_SEL_ADD_D <=	'1' when ALU_OP_CODE = "10011" else
					'0';
	
		--ASSIGN MUX FOR P4 ADDER INPUT B
		MUX_SEL_ADD_R <=	'1' when ALU_OP_CODE = "10011" else
					'0';

		--ASSIGN MUX FOR P4 ADDER INPUT SIGN
		MUX_SEL_ADD_S <=	'1' when ALU_OP_CODE = "10011" else
					'0';

		--ENABLING THE MULTIPLIER
		EN_MUL <=		'1' when ALU_OP_CODE = "10010" else
					'0';

		--ASSIGN THE T2 SHIFTER SIGNALS
		--*****************************
		--ASSIGN LEFT/RIGHT SHIFT SIGNAL
		RIGHT_LEFT <=	'0' when ALU_OP_CODE = "01010" else
				'1';
		--ASSIGN THE ARITHMETICAL/LOGICAL SIGNALS
		ARITH_LOG <=	'1' when ALU_OP_CODE = "01110" else
				'0';
		--*****************************

		--ASSIGNING THE GUARDED EVALUATION SIGNALS
		--****************************************
		EN_GUARD_CMP <=	'1' when ALU_OP_CODE = "00011" else
				'1' when ALU_OP_CODE = "00100" else
				'1' when ALU_OP_CODE = "00101" else
				'1' when ALU_OP_CODE = "00110" else
				'1' when ALU_OP_CODE = "00111" else
				'1' when ALU_OP_CODE = "01000" else
				'1' when ALU_OP_CODE = "01001" else
				'1' when ALU_OP_CODE = "01011" else
				'1' when ALU_OP_CODE = "01100" else
				'1' when ALU_OP_CODE = "01101" else
				'0' or RST;

		EN_GUARD_LOG <=	'1' when ALU_OP_CODE = "00001" else
				'1' when ALU_OP_CODE = "00010" else
				'1' when ALU_OP_CODE = "10001" else
				'0' or RST;

		EN_GUARD_P4 <=	'1' when ALU_OP_CODE = "00000" else
				'1' when ALU_OP_CODE = "00011" else
				'1' when ALU_OP_CODE = "00100" else
				'1' when ALU_OP_CODE = "00101" else
				'1' when ALU_OP_CODE = "00110" else
				'1' when ALU_OP_CODE = "00111" else
				'1' when ALU_OP_CODE = "01000" else
				'1' when ALU_OP_CODE = "01001" else
				'1' when ALU_OP_CODE = "01011" else
				'1' when ALU_OP_CODE = "01100" else
				'1' when ALU_OP_CODE = "01101" else
				'1' when ALU_OP_CODE = "10000" else
				'1' when ALU_OP_CODE = "10011" else
				'0' or RST;
		--****************************************

		--ASSIGN THE FINAL MUX
		MUX_SEL <=	"111" when ALU_OP_CODE = "00000" else
				"101" when ALU_OP_CODE = "00001" else
				"101" when ALU_OP_CODE = "00010" else
				"110" when ALU_OP_CODE = "00011" else
				"110" when ALU_OP_CODE = "00100" else
				"110" when ALU_OP_CODE = "00101" else
				"110" when ALU_OP_CODE = "00110" else
				"110" when ALU_OP_CODE = "00111" else
				"110" when ALU_OP_CODE = "01000" else
				"110" when ALU_OP_CODE = "01001" else
				"100" when ALU_OP_CODE = "01010" else
				"110" when ALU_OP_CODE = "01011" else
				"110" when ALU_OP_CODE = "01100" else
				"110" when ALU_OP_CODE = "01101" else
				"100" when ALU_OP_CODE = "01110" else
				"100" when ALU_OP_CODE = "01111" else
				"111" when ALU_OP_CODE = "10000" else
				"101" when ALU_OP_CODE = "10001" else
				"011" when ALU_OP_CODE = "10010" else
				"010";

		OUT_DIV_D(N-1 downto 16) <= (others => '0');
		OUT_DIV_R(N-1 downto 16) <= (others => '0');

		--GUARDED EVALUATION OF THE P4 ADDER
		--**********************************
		EVAL_P4: for i in 0 to N-1 generate
			LATCH_P4_A: D_LATCH	port map (	D => A_SIG(i),
								EN => EN_GUARD_P4,
								Q => IN_A_P4(i));

			LATCH_P4_B: D_LATCH	port map (	D => B_SIG(i),
								EN => EN_GUARD_P4,
								Q => IN_B_P4(i));
		end generate EVAL_P4;

		EVAL_P4_Ci: D_LATCH	port map (	D => SIGN_SIG,
							EN => EN_GUARD_P4,
							Q => Ci_P4);
		--**********************************

		XORING_B: for i in 0 to N-1 generate
			XORS: XOR_GATE	port map (	A => IN_B_P4(i),
							B => SIGN_SIG,
							Y => B_SIG2(i));
		end generate XORING_B;

		ADDER_INST: P4_ADDER	generic map (	N => N)
					port map (	A => IN_A_P4,
							B => B_SIG2,
							Ci => Ci_P4,
							Co => Co_ADDER,
							S => OUT_P4);

		--GUARDED EVALUATION OF THE COMPARATOR
		--************************************
		EVAL_CMP_S: for i in 0 to N-1 generate
			LATCH_CMP: D_LATCH	port map (	D => OUT_P4(i),
								EN => EN_GUARD_CMP,
								Q => S_CMP(i));
		end generate EVAL_CMP_S;

		EVAL_CMP_Co: D_LATCH	port map (	D => Co_ADDER,
							EN => EN_GUARD_CMP,
							Q => Co_CMP);

		EVAL_CMP_UNSIGN: D_LATCH	port map (	D => UNSIGN,
								EN => EN_GUARD_CMP,
								Q => UNSIGN_CMP);

		EVAL_CMP_MSB_A: D_LATCH	port map (	D => IN_A(N-1),
							EN => EN_GUARD_CMP,
							Q => MSB_A_CMP);

		EVAL_CMP_MSB_B: D_LATCH	port map (	D => IN_B(N-1),
							EN => EN_GUARD_CMP,
							Q => MSB_B_CMP);
		--************************************

		--INSTANTIATE COMPARATOR
		CMP_INST: CMP	generic map (	N => N)
				port map (	C => Co_CMP,
						S => S_CMP,
						OP_SEL => CMP_OP,
						UNSIGN => UNSIGN_CMP,
						MSB_A => MSB_A_CMP,
						MSB_B => MSB_B_CMP,
						Y => OUT_CMP);

		--GURADED EVALUATION OF THE T2 LOGICALS
		--*************************************
		EVAL_LOG: for i in 0 to N-1 generate
			LATCH_LOG_1: D_LATCH	port map (	D => IN_A(i),
								EN => EN_GUARD_LOG,
								Q => A_LOG(i));

			LATCH_LOG_2: D_LATCH	port map (	D => IN_B(i),
								EN => EN_GUARD_LOG,
								Q => B_LOG(i));
		end generate EVAL_LOG;

		EVAL_LOG_OP: for i in 0 to 3 generate
			LATCH_LOG_3: D_LATCH	port map (	D => LOG_OP(i),
								EN => EN_GUARD_LOG,
								Q => LOG_OP_SIG(i));
		end generate EVAL_LOG_OP;
		--*************************************

		--INSTATIATE T2 LOGICALS
		LOG_INST:	T2_LOGICALS	generic map (	N => N)
						port map (	OP => LOG_OP_SIG,
								A => A_LOG,
								B => B_LOG,
								Y => OUT_LOG);

		--INSTATIATE SHIFTER
		SHIFT_INST:	T2_SHIFTER	generic map (	N => N)
						port map (	A => IN_A,
								B => IN_B(4 downto 0),
								ARITH_LOG => ARITH_LOG,
								RIGHT_LEFT => RIGHT_LEFT,
								Y => OUT_SHIFT);

		--INSTATIATE MULTIPLIERS
		MULT_INST:	BOOTHMUL	port map (	A => IN_A(15 downto 0),
								B => IN_B(15 downto 0),
								CLK => CLK,
								EN => '1',
								RST => RST,
								P => OUT_MUL);

		-- INSTANTIATE DIVISOR
		DIVISOR_INST: NR_DIVISOR	port map (	CLK		=> CLK,
								RST		=> RST_DIV_SIG,
								EN		=> '1',
								Z		=> IN_A(15 downto 0),
								D		=> IN_B(15 downto 0),
								Q		=> OUT_DIV(15 downto 0),
								R		=> OUT_DIV(31 downto 16),
								ADD_IN_D	=> OUT_DIV_D(15 downto 0),
								ADD_IN_R	=> OUT_DIV_R ( 15 downto 0),
								SIGN		=> OUT_DIV_SIGN,
								ADD_OUT		=> OUT_P4(15 downto 0));
-- MUXING P4 ADDER INPUTS
		MUX_IN_A:	MUX21_GEN	generic map (	N => N)
						port map (	A => OUT_DIV_R,
								B => IN_A,
								SEL => MUX_SEL_ADD_R,
								Y => A_SIG);

		MUXING_IN_B:	MUX21_GEN	generic map (	N => N)
						port map (	A => OUT_DIV_D,
								B => IN_B,
								SEL => MUX_SEL_ADD_D,
								Y => B_SIG);

		MUXING_IN_S:	MUX21
						port map (	A => OUT_DIV_SIGN,
								B => SUB_ADD,
								S => MUX_SEL_ADD_S,
								Y => SIGN_SIG);

--MUXING THE OUTPUT
		MUXING:	MUX61_GEN	generic map (	N => N)
					port map (	A => OUT_P4,		--111
							B => OUT_CMP,		--110
							C => OUT_LOG,		--101
							D => OUT_SHIFT,		--100
							E => OUT_MUL,		--011
							F => OUT_DIV,		--010
							SEL => MUX_SEL,
							Y => OUT_ALU);

		

end STRUCTURAL;

configuration CFG_ALU_STRUCTURAL of ALU is
	for STRUCTURAL
		for XORING_B
			for all: XOR_GATE
				use configuration WORK.CFG_XOR_GATE_BEHAVIORAL;
			end for;
		end for;
		for all: P4_ADDER
			use configuration WORK.CFG_P4_ADDER_STRUCTURAL;
		end for;
		for all: CMP
			use configuration WORK.CFG_CMP_STRUCTURAL;
		end for;
		for all: T2_LOGICALS
			use configuration WORK.CFG_T2_LOGICALS_STRUCTURAL;
		end for;
		for all: T2_SHIFTER
			use configuration WORK.CFG_T2_SHIFTER_STRUCTURAL;
		end for;
		for all: MUX61_GEN
			use configuration WORK.CFG_MUX61_GEN_BEHAVIORAL;
		end for;
		for all: MUX21_GEN
			use configuration WORK.CFG_MUX21_GEN_STRUCTURAL;
		end for;
		for all: MUX21
	      		use configuration WORK.CFG_MUX21_STRUCTURAL;
		end for;
		for all: NR_DIVISOR
			use configuration WORK.CFG_NR_DIVISOR_STRUCTURAL; 
		end for;
		for EVAL_CMP_S
			for all: D_LATCH
				use configuration WORK.CFG_D_LATCH_STRUCTURAL;
			end for;
		end for;
		for all: D_LATCH
			use configuration WORK.CFG_D_LATCH_STRUCTURAL;
		end for;
		for EVAL_LOG
			for all: D_LATCH
				use configuration WORK.CFG_D_LATCH_STRUCTURAL;
			end for;
		end for;
		for EVAL_LOG_OP
			for all: D_LATCH
				use configuration WORK.CFG_D_LATCH_STRUCTURAL;
			end for;
		end for;
		for EVAL_P4
			for all: D_LATCH
				use configuration WORK.CFG_D_LATCH_STRUCTURAL;
			end for;
		end for;
	end for;
end CFG_ALU_STRUCTURAL;