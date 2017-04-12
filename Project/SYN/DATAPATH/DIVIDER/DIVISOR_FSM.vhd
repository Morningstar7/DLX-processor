library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FSM_DIVISOR is
port (
	CLK : 			in std_logic; 				-- CLOCK
	RST : 			in std_logic; 				-- RESET 
	EN  :    in std_logic;
	SEL_R_MUX_IN:		out std_logic;
	SEL_Q_MUX_IN:		out std_logic;
	SEL_D_MUX:		out std_logic;
	SEL_ADD_IN_D_MUX:	out std_logic_vector(1 downto 0);
	SEL_ADD_IN_R_MUX:	out std_logic_vector(1 downto 0);
	SEL_SIGN_MUX:		out std_logic_vector(1 downto 0);
	EN_D:			out std_logic;
	EN_Z:			out std_logic;
	EN_Q:			out std_logic;
	EN_R:			out std_logic;
	EN_SIGN:		out std_logic;
	MSB_REM:		in std_logic
	);
	
end FSM_DIVISOR;  

architecture FSM of FSM_DIVISOR is

type STATE is (
	LOAD_STATE,
	Z_SIGN_STATE,
	D_SIGN_STATE,
	LOOP_STATE,		
	LAST_LOOP,
	RESULT_STATE_1,
	RESULT_STATE_2,
	Q_SIGN_STATE,
	R_SIGN_STATE
	);

signal CURRENT_STATE : STATE;
signal CNT:	integer;

begin

STATE_PROC: process(CLK,RST)
	begin
		if RST='1' then
			CURRENT_STATE <= LOAD_STATE;
		elsif rising_edge(CLK) then
			if EN = '1' then
				case CURRENT_STATE is
					when LOAD_STATE =>
							CNT <= 0;
							CURRENT_STATE <= D_SIGN_STATE;
					when D_SIGN_STATE =>
							CURRENT_STATE <= Z_SIGN_STATE;
					when Z_SIGN_STATE =>
							CURRENT_STATE <= LOOP_STATE;
					when LOOP_STATE =>
							if CNT < 14 then
								CURRENT_STATE <= LOOP_STATE;
								CNT <= CNT + 1;
							else
								CURRENT_STATE <= LAST_LOOP;
							end if;   
					when LAST_LOOP =>
						if MSB_REM = '1' then
							CURRENT_STATE <= RESULT_STATE_2;
						else
							CURRENT_STATE <= RESULT_STATE_1;
						end if;
		           		when RESULT_STATE_1 =>
						   	CURRENT_STATE <= Q_SIGN_STATE;
					when RESULT_STATE_2 =>
							CURRENT_STATE <= Q_SIGN_STATE;
					when Q_SIGN_STATE =>
							CURRENT_STATE <= R_SIGN_STATE;
					when R_SIGN_STATE =>
							CURRENT_STATE <= R_SIGN_STATE; 
					when others =>
							CURRENT_STATE <= LOAD_STATE;
				end case;
			end if;
		end if;
end process STATE_PROC;

CW_PROC: process(CURRENT_STATE)
	begin
		case CURRENT_STATE is
-- 
		-- Output for each state. X represent a don't care. 

		when LOAD_STATE =>	-- Reset state, inputs have to be stable
				SEL_R_MUX_IN		<= 	'1';	-- x
				SEL_Q_MUX_IN		<=	'1';	-- x
				SEL_D_MUX		<=	'1';	-- x
				SEL_ADD_IN_R_MUX	<=	"11";	-- x
				SEL_SIGN_MUX		<=	"11";	-- x
				SEL_ADD_IN_D_MUX	<=	"11"; 	-- x
				EN_D			<=	'1';	-- x
				EN_Z			<=	'1';	-- x
				EN_Q			<=	'1';	-- x
				EN_R			<=	'1';	-- x
				EN_SIGN		<= 	'1';	-- x

	
		when D_SIGN_STATE =>	-- ZS, DS and  final SIGN are saved. If not, DS is made positive by 0-D op. 
				SEL_R_MUX_IN		<= 	'1';	-- Init R = 0
				SEL_Q_MUX_IN		<=	'1';	-- x
				SEL_D_MUX		<=	'0';	-- DS	
				SEL_ADD_IN_R_MUX	<=	"11";	--'0' 
				SEL_SIGN_MUX		<=	"01";	-- -/+
				SEL_ADD_IN_D_MUX	<=	"01"; 	-- DS
				EN_D			<=	'1';  	-- 
				EN_Z			<=	'0'; 	-- save ZS
				EN_Q			<=	'1';	-- x
				EN_R			<=	'1';	-- x
				EN_SIGN		<= 	'0'; 	-- Save sign difference
				
		when Z_SIGN_STATE =>	-- New D is saved. If not, Z is made positive by 0-D op. No need to resave Z
				SEL_R_MUX_IN		<= 	'1';	-- Init R = 0
				SEL_Q_MUX_IN		<=	'1';	-- 
				SEL_D_MUX		<=	'0';	-- D	
				SEL_ADD_IN_R_MUX	<=	"11";	--'0' 
				SEL_SIGN_MUX		<=	"10";	-- -/+
				SEL_ADD_IN_D_MUX	<=	"00"; 	-- ZS
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save ZS)
				EN_Q			<=	'1';	-- x
				EN_R			<=	'1';	-- x
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 

		when LOOP_STATE =>	-- 15 cycles. R is summed(subtracted) to D
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'0';	-- select Z positive
				SEL_D_MUX		<=	'0';	-- select D positive	
				SEL_ADD_IN_R_MUX	<=	"10";	-- R (Shifted)
				SEL_SIGN_MUX		<=	"11";	-- -/+
				SEL_ADD_IN_D_MUX	<=	"01"; 	-- D
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'1';	-- x
				EN_R			<=	'1';	-- x
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 	

		when LAST_LOOP =>	-- Last iteration. Here the final addition sign is evaluated
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'0';	-- select Z positive
				SEL_D_MUX		<=	'0';	-- select D positive	
				SEL_ADD_IN_R_MUX	<=	"10";	-- R (Shifted)
				SEL_SIGN_MUX		<=	"11";	-- -/+ (RQ31)
				SEL_ADD_IN_D_MUX	<=	"01"; 	-- D
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'1';	-- x
				EN_R			<=	'1';	-- x
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 
	
		when RESULT_STATE_1 =>	-- R is positive. No need of last restoring. Both R and Q are saved
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'0';	-- select Z positive
				SEL_D_MUX		<=	'0';	-- select D positive	
				SEL_ADD_IN_R_MUX	<=	"10";	-- x
				SEL_SIGN_MUX		<=	"11";	-- x
				SEL_ADD_IN_D_MUX	<=	"01"; 	-- x
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'0';	-- save Q unsigned
				EN_R			<=	'0';	-- save R unsigned
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 

		when RESULT_STATE_2 => -- R is negative. Need of last restoring. Only Q is saved
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'0';	-- select Z positive
				SEL_D_MUX		<=	'0';	-- select D positive	
				SEL_ADD_IN_R_MUX	<=	"01";	-- R 
				SEL_SIGN_MUX		<=	"11";	-- -/+ (RQ31)
				SEL_ADD_IN_D_MUX	<=	"01"; 	-- D
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'0';	-- save Q positive
				EN_R			<=	'1';	-- R has to be restored
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 
		
		when Q_SIGN_STATE =>  -- Save R. Correct sign of Q if needed 
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'1';	-- select Q with the correct sign 
				SEL_D_MUX		<=	'0';	-- select D positive	
				SEL_ADD_IN_R_MUX	<=	"11";	-- '0'
				SEL_SIGN_MUX		<=	"00";	-- Z XOR D
				SEL_ADD_IN_D_MUX	<=	"11"; 	-- Q
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'1';	-- update Q with the correct sign 
				EN_R			<=	'0';	-- save restored R
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 
		
		when R_SIGN_STATE => -- Save Q. Correct sign of R if needed.--------------------------------------- HAS R TO BE SAVED?
				SEL_R_MUX_IN		<= 	'0';	-- R = Adder out
				SEL_Q_MUX_IN		<=	'1';	-- select Q with the correct sign 
				SEL_D_MUX		<=	'0';	-- select D positive
				SEL_ADD_IN_R_MUX	<=	"11";	-- '0'
				SEL_SIGN_MUX		<=	"00";	-- Z XOR D
				SEL_ADD_IN_D_MUX	<=	"10"; 	-- R
				EN_D			<=	'0';  	-- to forever (save D)
				EN_Z			<=	'0'; 	-- to forever (save Z)
				EN_Q			<=	'0';	-- save Q with the correct sign 
				EN_R			<=	'1';	-- update R with the correct sign 
				EN_SIGN		<= 	'0'; 	-- to forever (save sign difference) 
		
	
		end case;

end process CW_PROC;

end FSM;

configuration CFG_FSM_DIVISOR_FSM of FSM_DIVISOR is
	for FSM
	end for;
end CFG_FSM_DIVISOR_FSM;