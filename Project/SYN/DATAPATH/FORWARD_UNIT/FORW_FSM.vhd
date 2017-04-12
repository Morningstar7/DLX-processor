library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity FORW_FSM is
	generic ( 	OPCODE_SIZE: integer;
			N_ADDR: integer);
	port 	(	CLK:		in	std_logic; 
			RST:		in	std_logic; 
			CMP_A_EXE:	in	std_logic;
			CMP_A_MEM:	in	std_logic;
			CMP_B_EXE:	in	std_logic;
			CMP_B_MEM:	in	std_logic;
			CMP_C_EXE:	in	std_logic;  -- CMP_B_MEM PIPED;	
			CMP_C_MEM:	in	std_logic;
			CMP_BRANCH_ID:	in	std_logic;
			CMP_BRANCH_EXE:	in	std_logic;
			CMP_BRANCH_MEM:	in	std_logic;
			OPCODE_IF:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			OPCODE_ID:	in	std_logic_vector(OPCODE_SIZE-1 downto 0); 
			OPCODE_EXE:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			OPCODE_MEM:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			OPCODE_WB:	in	std_logic_vector(OPCODE_SIZE-1 downto 0);
			MUX_A:		out	std_logic_vector(1 downto 0);
			MUX_B:		out	std_logic_vector(1 downto 0);
			MUX_C:		out	std_logic_vector(1 downto 0);
			MUX_D:		out	std_logic_vector(1 downto 0);
			RST_DIV:	out	std_logic;
			STALL_BRANCH:	out	std_logic;
			STALL:		out	std_logic);
end FORW_FSM;
	
architecture BEHAVIORAL of FORW_FSM is

		type A_STATES is (
			NO_FORW_A,
			FORW_ALU_MEM_A,	
			FORW_ALU_WB_A,
			FORW_MEM_WB_A,
			STALL_A
			);
		type B_STATES is (
			NO_FORW_B,
			FORW_ALU_MEM_B,	
			FORW_ALU_WB_B,
			FORW_MEM_WB_B,
			STALL_B
			);
		type C_STATES is (
			NO_FORW_C,
			FORW_ALU_WB_C,
			FORW_MEM_WB_C,
			FORW_REG_C
			);
		type D_STATES is (
			NO_FORW_D,
			FORW_ALU_MEM_D,
			FORW_ALU_WB_D,
			FORW_MEM_WB_D,
			STALL_D_ID,
			STALL_D_EXE);

		signal CURRENT_STATE_A:	A_STATES;
		
		signal CURRENT_STATE_B:	B_STATES;
		
		signal CURRENT_STATE_C:	C_STATES;

		signal CURRENT_STATE_D:	D_STATES;

		signal	STALL_A_SIG:	std_logic;
		signal	STALL_B_SIG:	std_logic;
		signal	STALL_INSTR:	std_logic;

		signal  CNT_MUL:	integer;
		signal  CNT_DIV:	integer;

		signal INSTR_IF:	std_logic;
		signal INSTR_ID:	std_logic_vector(1 downto 0);
		signal INSTR_EXE:	std_logic_vector(1 downto 0);
		signal INSTR_MEM:	std_logic_vector(1 downto 0);
		signal INSTR_WB:	std_logic;

	begin

		INSTR_IF <=	'1' when OPCODE_IF = BTYPE_BEQZ else
				'1' when OPCODE_IF = BTYPE_BNEZ else
				'0';

		INSTR_ID <=	"11" when OPCODE_ID = RTYPE else		--11 for R-TYPE and F-TYPE
				"11" when OPCODE_ID = FTYPE_MULT else
				"11" when OPCODE_ID = FTYPE_DIV else
				"10" when OPCODE_ID = ITYPE_ADDI else		--10 for I-TYPE and L-TYPE
				"10" when OPCODE_ID = ITYPE_ADDUI else
				"10" when OPCODE_ID = ITYPE_ANDI else
				"10" when OPCODE_ID = ITYPE_LHI else
				"10" when OPCODE_ID = ITYPE_ORI else
				"10" when OPCODE_ID = ITYPE_SEQI else
				"10" when OPCODE_ID = ITYPE_SGEI else
				"10" when OPCODE_ID = ITYPE_SGEUI else
				"10" when OPCODE_ID = ITYPE_SGTI else
				"10" when OPCODE_ID = ITYPE_SGTUI else
				"10" when OPCODE_ID = ITYPE_SLEI else
				"10" when OPCODE_ID = ITYPE_SLEUI else
				"10" when OPCODE_ID = ITYPE_SLLI else
				"10" when OPCODE_ID = ITYPE_SLTI else
				"10" when OPCODE_ID = ITYPE_SLTUI else
				"10" when OPCODE_ID = ITYPE_SNEI else
				"10" when OPCODE_ID = ITYPE_SRAI else
				"10" when OPCODE_ID = ITYPE_SRLI else
				"10" when OPCODE_ID = ITYPE_SUBI else
				"10" when OPCODE_ID = ITYPE_SUBUI else
				"10" when OPCODE_ID = ITYPE_XORI else
				"10" when OPCODE_ID = LTYPE_LB else
				"10" when OPCODE_ID = LTYPE_LBU else
				"10" when OPCODE_ID = LTYPE_LH else
				"10" when OPCODE_ID = LTYPE_LHU else
				"10" when OPCODE_ID = LTYPE_LW else
				"01" when OPCODE_ID = STYPE_SB else		--01 for S-TYPE
				"01" when OPCODE_ID = STYPE_SH else
				"01" when OPCODE_ID = STYPE_SW else
				"00";

		INSTR_EXE <=	"00" when OPCODE_EXE = STYPE_SB else
				"00" when OPCODE_EXE = STYPE_SH else
				"00" when OPCODE_EXE = STYPE_SW else
				"00" when OPCODE_EXE = NTYPE_NOP else
				"00" when OPCODE_EXE = BTYPE_BEQZ else
				"00" when OPCODE_EXE = BTYPE_BNEZ else
				"00" when OPCODE_EXE = JTYPE_J else
				"00" when OPCODE_EXE = JTYPE_JR else
--				"00" when OPCODE_EXE = "000000" else
				"01" when OPCODE_EXE = FTYPE_MULT else
				"01" when OPCODE_EXE = FTYPE_DIV else
				"10" when OPCODE_EXE = LTYPE_LB else
				"10" when OPCODE_EXE = LTYPE_LBU else
				"10" when OPCODE_EXE = LTYPE_LH else
				"10" when OPCODE_EXE = LTYPE_LHU else
				"10" when OPCODE_EXE = LTYPE_LW else
				"11";

		INSTR_MEM <=	"00" when OPCODE_MEM = STYPE_SB else
				"00" when OPCODE_MEM = STYPE_SH else
				"00" when OPCODE_MEM = STYPE_SW else
				"00" when OPCODE_MEM = NTYPE_NOP else
				"00" when OPCODE_MEM = BTYPE_BEQZ else
				"00" when OPCODE_MEM = BTYPE_BNEZ else
				"00" when OPCODE_MEM = JTYPE_J else
				"00" when OPCODE_MEM = JTYPE_JR else
--				"00" when OPCODE_MEM = "000000" else
				"01" when OPCODE_MEM = LTYPE_LB else
				"01" when OPCODE_MEM = LTYPE_LBU else
				"01" when OPCODE_MEM = LTYPE_LH else
				"01" when OPCODE_MEM = LTYPE_LHU else
				"01" when OPCODE_MEM = LTYPE_LW else
				"10";

		INSTR_WB <=	'0' when OPCODE_WB = STYPE_SB else
				'0' when OPCODE_WB = STYPE_SH else
				'0' when OPCODE_WB = STYPE_SW else
				'0' when OPCODE_WB = NTYPE_NOP else
				'0' when OPCODE_WB = BTYPE_BEQZ else
				'0' when OPCODE_WB = BTYPE_BNEZ else
				'0' when OPCODE_WB = JTYPE_J else
				'0' when OPCODE_WB = JTYPE_JR else
--				'0' when OPCODE_WB = "000000" else
				'1';

		STALL <= STALL_A_SIG or STALL_B_SIG or STALL_INSTR;
	
		A_STATE_PROC: process(CLK, RST, CURRENT_STATE_A, INSTR_ID, INSTR_EXE, INSTR_MEM)
			begin
				if RST='1' then
					CURRENT_STATE_A <= NO_FORW_A;
				elsif rising_edge(CLK) then
					case CURRENT_STATE_A is
						when STALL_A =>
							CURRENT_STATE_A <= FORW_MEM_WB_A;
						when NO_FORW_A to FORW_MEM_WB_A =>
							if INSTR_ID = "00" then
								CURRENT_STATE_A <= NO_FORW_A;
							elsif (STALL_INSTR = '1') then
								CURRENT_STATE_A <= CURRENT_STATE_A;
							elsif CMP_A_EXE = '1' then
								if INSTR_ID /= "00" then
									if INSTR_EXE = "11" then
										CURRENT_STATE_A <= FORW_ALU_MEM_A;
									elsif INSTR_EXE = "01" then
										if(CURRENT_STATE_A = STALL_A) or (CNT_MUL > 0) or (CNT_DIV > 0) or (CURRENT_STATE_B = STALL_B) then
											CURRENT_STATE_A <= NO_FORW_A;
										else
											CURRENT_STATE_A <= FORW_ALU_MEM_A;
										end if;
									elsif INSTR_EXE = "10" then
										CURRENT_STATE_A <= STALL_A; -- FORWARDING SUCCESSIVO = MEM_WB_A
									else
										if CMP_A_MEM = '1' then
											if INSTR_MEM = "10" then
												CURRENT_STATE_A <= FORW_ALU_WB_A;
											elsif INSTR_MEM = "01" then
												CURRENT_STATE_A <= FORW_MEM_WB_A;
											else
												CURRENT_STATE_A <= NO_FORW_A;
											end if;	
										else
											CURRENT_STATE_A <= NO_FORW_A;
										end if;
									end if;
								else
									CURRENT_STATE_A <= NO_FORW_A;
								end if;
							elsif CMP_A_MEM = '1' then
								if INSTR_ID /= "00" then
									if INSTR_MEM = "10" then
										CURRENT_STATE_A <= FORW_ALU_WB_A;
									elsif INSTR_MEM = "01" then
										CURRENT_STATE_A <= FORW_MEM_WB_A;
									else
										CURRENT_STATE_A <= NO_FORW_A;
									end if;
								else	
									CURRENT_STATE_A <= NO_FORW_A;
								end if;
							else 
								CURRENT_STATE_A <= NO_FORW_A;
							end if;
					when others => CURRENT_STATE_A <= NO_FORW_A;
					end case;
				end if;
			end process;
		
		B_STATE_PROC: process(CLK, RST, CURRENT_STATE_B, INSTR_ID, INSTR_EXE, INSTR_MEM)
			begin
				if RST='1' then
					CURRENT_STATE_B <= NO_FORW_B;
				elsif rising_edge(CLK) then
					case CURRENT_STATE_B is
						when STALL_B =>
							CURRENT_STATE_B <= FORW_MEM_WB_B;
						when NO_FORW_B to FORW_MEM_WB_B  =>
							if INSTR_ID = "00" then
								CURRENT_STATE_B <= NO_FORW_B;
							elsif (STALL_INSTR = '1') then
								CURRENT_STATE_B <= CURRENT_STATE_B;
							elsif CMP_B_EXE = '1' then
								if (INSTR_ID = "11") then
									if (INSTR_EXE = "11") then
										CURRENT_STATE_B <= FORW_ALU_MEM_B;
									elsif INSTR_EXE = "01" then
										if(CURRENT_STATE_B = STALL_B) or (CNT_MUL > 0) or (CNT_DIV > 0) or (CURRENT_STATE_B = STALL_B) then
											CURRENT_STATE_B <= NO_FORW_B;
										else
											CURRENT_STATE_B <= FORW_ALU_MEM_B;
										end if;
									elsif INSTR_EXE = "10"then 
										CURRENT_STATE_B <= STALL_B; -- AFTER: mem_wb_B
									else
										if CMP_B_MEM = '1' then
											if INSTR_MEM = "10" then
												CURRENT_STATE_B <= FORW_ALU_WB_B;
											elsif INSTR_MEM = "01" then
												CURRENT_STATE_B <= FORW_MEM_WB_B;
											else 
												CURRENT_STATE_B <= NO_FORW_B; -- NOP STATE C
											end if;
										else	
											CURRENT_STATE_B <= NO_FORW_B; 
										end if;
									end if;
								else
									CURRENT_STATE_B <= NO_FORW_B;
								end if;
							elsif CMP_B_MEM = '1' then
								if INSTR_ID = "11" then
									if INSTR_MEM = "10" then
										CURRENT_STATE_B <= FORW_ALU_WB_B;
									elsif INSTR_MEM = "01" then
										CURRENT_STATE_B <= FORW_MEM_WB_B;
									else 
										CURRENT_STATE_B <= NO_FORW_B; -- NOP STATE C
									end if;
								else
									CURRENT_STATE_B <= NO_FORW_B;
								end if;
							else 
								CURRENT_STATE_B <= NO_FORW_B;
							end if;
					when others => CURRENT_STATE_B <= NO_FORW_B;
					end case;
				end if;
			end process; 
	
		C_STATE_PROC: process(CLK, RST, CURRENT_STATE_C, INSTR_MEM, INSTR_WB)
			begin
				if RST='1' then
					CURRENT_STATE_C <= NO_FORW_C;
				elsif rising_edge(CLK) then
					case CURRENT_STATE_C is
						when NO_FORW_C to FORW_REG_C =>
							if CMP_C_EXE = '1' then			--IT'S THE PIPELINED CMP
								if OPCODE_EXE = STYPE_SW then
									if INSTR_MEM = "10" then
										CURRENT_STATE_C <= FORW_ALU_WB_C;
									elsif INSTR_MEM  = "01" then
										CURRENT_STATE_C <= FORW_MEM_WB_C;
									else
										CURRENT_STATE_C <= NO_FORW_C;
									end if;
								else
									CURRENT_STATE_C  <= NO_FORW_C;
								end if;
							elsif CMP_C_MEM = '1' then
								if OPCODE_EXE = STYPE_SW then
									if INSTR_WB = '1' then
										CURRENT_STATE_C <= FORW_REG_C;
									else
										CURRENT_STATE_C <= NO_FORW_C;
									end if;
								else
									CURRENT_STATE_C  <= NO_FORW_C;
								end if;
							else
								CURRENT_STATE_C  <= NO_FORW_C;
							end if;
						when others =>
							CURRENT_STATE_C <= NO_FORW_C;
					end case;
				end if;
		end process C_STATE_PROC;

		D_STATE_PROC: process(CLK, RST, CURRENT_STATE_D, INSTR_ID, INSTR_EXE, INSTR_MEM)
			begin
				if RST = '1' then
					CURRENT_STATE_D <= NO_FORW_D;
				elsif rising_edge(CLK) then
					case CURRENT_STATE_D is
						when STALL_D_ID =>
							if (INSTR_EXE = "10") or (INSTR_EXE = "01") then
								CURRENT_STATE_D <= STALL_D_EXE;
							else
								CURRENT_STATE_D <= FORW_ALU_MEM_D;
							end if;
						when STALL_D_EXE =>
							if INSTR_EXE = "01" then
								if CNT_MUL = 2 or CNT_DIV = 21 then
									CURRENT_STATE_D <= FORW_ALU_MEM_D;
								else
									CURRENT_STATE_D <= STALL_D_EXE;
								end if;
							else
								CURRENT_STATE_D <= FORW_MEM_WB_D;
							end if;
						when NO_FORW_D to FORW_MEM_WB_D =>
							if INSTR_IF = '1' then
								if CMP_BRANCH_ID = '1' then
									if (INSTR_ID = "11") or (INSTR_ID = "10") then
										CURRENT_STATE_D <= STALL_D_ID;
									else
										CURRENT_STATE_D <= NO_FORW_D;
									end if;
								elsif CMP_BRANCH_EXE = '1' then
									if (INSTR_EXE = "01") or (INSTR_EXE = "10") then
										CURRENT_STATE_D <= STALL_D_EXE;
									elsif INSTR_EXE = "11" then
										CURRENT_STATE_D <= FORW_ALU_MEM_D;
									else
										CURRENT_STATE_D <= NO_FORW_D;
									end if;
								elsif CMP_BRANCH_MEM = '1' then
									if INSTR_MEM = "01" then
										CURRENT_STATE_D <= FORW_MEM_WB_D;
									elsif INSTR_MEM = "10" then
										CURRENT_STATE_D <= FORW_ALU_WB_D;
									else
									CURRENT_STATE_D <= NO_FORW_D;
									end if;
								end if;
							else
								CURRENT_STATE_D <= NO_FORW_D;
							end if;
					end case;
				end if;
		end process D_STATE_PROC;
					
					
		STALL_INSTR_PROC: process(CLK, RST, OPCODE_ID)
			begin
				if RST = '1' then
					STALL_INSTR <= '0';
					CNT_MUL <= 0;
					CNT_DIV <= 0;
					RST_DIV <= '1';
				else
					if rising_edge(CLK) then
						if (CNT_MUL > 0) then
							if(CNT_MUL = 2) then
								CNT_MUL <= 0;
								STALL_INSTR <= '0';
							else
								CNT_MUL <= CNT_MUL + 1;
							end if;
						elsif (CNT_DIV > 0) then
							if (OPCODE_EXE = FTYPE_DIV) then
								STALL_INSTR <= '1';
							end if;
							RST_DIV <= '0';
							if(CNT_DIV = 22) then
								CNT_DIV <= 0;
								STALL_INSTR <= '0';
								RST_DIV <= '1';
							else
								CNT_DIV <= CNT_DIV + 1;
							end if;
						else  -- ##MODIFICATION
							if ((CMP_A_EXE = '1') or (CMP_B_EXE = '1')) and (OPCODE_EXE = LTYPE_LW) then
								STALL_INSTR <= '0';
								if (OPCODE_ID = FTYPE_MULT) then
									CNT_MUL <= 0;
								elsif (OPCODE_ID = FTYPE_DIV) then
									RST_DIV <= '1';
									CNT_DIV <= 0;
								else
									CNT_MUL <= 0;
									CNT_DIV <= 0;
								end if;
							else
								if (OPCODE_ID = FTYPE_MULT) then
									CNT_MUL <= CNT_MUL + 1;
									STALL_INSTR <= '1';
								elsif (OPCODE_ID = FTYPE_DIV) then
									CNT_DIV <= CNT_DIV + 1;
									RST_DIV <= '0';    -- 
									STALL_INSTR <= '1';
								else
									CNT_DIV <= 0;
									CNT_MUL <= 0;
									STALL_INSTR <= '0';
								end if;
							end if;
						end if;
					end if;
				end if;
		end process STALL_INSTR_PROC;

-- DIV_STALL_PROC: process (CLK, RST, OPCODE_ID)
-- 	begin	
-- 		if RST = '1' then
-- 			STALL_INSTR <= '0';
-- 			CNT_DIV <= 0;
-- 		elsif rising_edge(CLK) then
-- 				if (CNT_DIV > 0) then
-- 					RST_DIV <= '0';
-- 					if(CNT_DIV = 35) then
-- 						CNT_DIV <= 0;
-- 						STALL_INSTR <= '0';
-- 					else
-- 						CNT_DIV <= CNT_DIV + 1;
-- 					end if;
-- 				elsif(OPCODE_ID = FTYPE_DIV) then
-- 							RST_DIV <= '1';
-- 							CNT_DIV <= CNT_DIV + 1;
-- 							STALL_INSTR <= '1';
-- 				end if;
-- 		end if;
-- end process DIV_STALL_PROC;
			
		
				
OUT_PROC: process (CURRENT_STATE_A, CURRENT_STATE_B, CURRENT_STATE_C, CURRENT_STATE_D) 
	 begin
			case CURRENT_STATE_A is
				when NO_FORW_A 		=> MUX_A <= "11";
							STALL_A_SIG <= '0';
				when FORW_ALU_MEM_A 	=> MUX_A <= "10";
							STALL_A_SIG <= '0';
				when FORW_ALU_WB_A 	=> MUX_A <= "01";
							STALL_A_SIG <= '0';
				when FORW_MEM_WB_A	=> MUX_A <= "00";
							STALL_A_SIG <= '0';
				when STALL_A 		=> MUX_A <= "11";
							STALL_A_SIG <= '1';
			end case;
			
			case CURRENT_STATE_B is 
				when NO_FORW_B		=> MUX_B <= "11";
							STALL_B_SIG <= '0';
				when FORW_ALU_MEM_B	=> MUX_B <= "10";
							STALL_B_SIG <= '0';
				when FORW_ALU_WB_B	=> MUX_B <= "01";
							STALL_B_SIG <= '0';
				when FORW_MEM_WB_B	=> MUX_B <= "00";
							STALL_B_SIG <= '0';
				when STALL_B		=> MUX_B <= "11";
							STALL_B_SIG <= '1';
			end case;
	
			case CURRENT_STATE_C is 
				when NO_FORW_C		=> MUX_C <= "11";
				when FORW_ALU_WB_C	=> MUX_C <= "10";
				when FORW_MEM_WB_C	=> MUX_C <= "01";
				when FORW_REG_C		=> MUX_C <= "00";
			end case;

			case CURRENT_STATE_D is
				when NO_FORW_D		=> MUX_D <= "00";
							STALL_BRANCH <= '0';
				when FORW_ALU_MEM_D	=> MUX_D <= "01";
							STALL_BRANCH <= '0';
				when FORW_ALU_WB_D	=> MUX_D <= "10";
							STALL_BRANCH <= '0';
				when FORW_MEM_WB_D	=> MUX_D <= "11";
							STALL_BRANCH <= '0';
				when STALL_D_ID		=> MUX_D <= "00";
							STALL_BRANCH <= '1';
				when STALL_D_EXE	=> MUX_D <= "00";
							STALL_BRANCH <= '1';
			end case;
	end process OUT_PROC;

end BEHAVIORAL;
			
configuration CFG_FORW_FSM_BEHAVIORAL of FORW_FSM is
	for BEHAVIORAL
	end for;
end CFG_FORW_FSM_BEHAVIORAL;