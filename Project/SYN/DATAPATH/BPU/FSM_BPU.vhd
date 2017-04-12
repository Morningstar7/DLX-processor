library IEEE;
use IEEE.std_logic_1164.all;

entity FSM_BPU is
	port (		RST:		in	std_logic;
			CLK:		in	std_logic;
			BRANCH_TAKEN:	in	std_logic;
			EN_FSM:		in	std_logic;
			FSM_SEL:	in	std_logic_vector(1 downto 0);
			MUX_SEL:	out	std_logic);
end FSM_BPU;

architecture FSM of FSM_BPU is

	component MUX41
		port (		A:	in	std_logic;
				B:	in	std_logic;
				C:	in	std_logic;
				D:	in	std_logic;
				SEL:	in	std_logic_vector(1 downto 0);
				Y:	out	std_logic);
	end component;

	type STATE is (S_TAKEN, TAKEN, NOT_TAKEN, S_NOT_TAKEN);

	signal CURRENT_STATE_A:	STATE;
	signal CURRENT_STATE_B:	STATE;
	signal CURRENT_STATE_C:	STATE;
	signal CURRENT_STATE_D:	STATE;
	signal MUX_SEL_A:	std_logic;
	signal MUX_SEL_B:	std_logic;
	signal MUX_SEL_C:	std_logic;
	signal MUX_SEL_D:	std_logic;

	begin

		--MUX_SEL <= MUX_SEL_SIG and EN_FSM;

		STATE_PROC: process(CLK)
			begin
				if RST='1' then
					--if(FSM_SEL = "00") then
						CURRENT_STATE_A <= NOT_TAKEN;
					--elsif(FSM_SEL = "01") then
						CURRENT_STATE_B <= NOT_TAKEN;
					--elsif(FSM_SEL = "10") then
						CURRENT_STATE_C <= NOT_TAKEN;
					--else
						CURRENT_STATE_D <= NOT_TAKEN;
					--end if;
				elsif CLK'event and CLK = '1' and EN_FSM = '1' then
					if(FSM_SEL = "00") then
						case CURRENT_STATE_A is
							when S_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_A <= S_TAKEN;
								else
									CURRENT_STATE_A <= TAKEN;
								end if;
							when TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_A <= S_TAKEN;
								else
									CURRENT_STATE_A <= NOT_TAKEN;
								end if;
							when NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_A <= TAKEN;
								else
									CURRENT_STATE_A <= S_NOT_TAKEN;
								end if;
							when S_NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_A <= NOT_TAKEN;
								else
									CURRENT_STATE_A <= S_NOT_TAKEN;
								end if;
							when others =>
								CURRENT_STATE_A <= TAKEN;
						end case;
					elsif(FSM_SEL = "01") then
						case CURRENT_STATE_B is
							when S_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_B <= S_TAKEN;
								else
									CURRENT_STATE_B <= TAKEN;
								end if;
							when TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_B <= S_TAKEN;
								else
									CURRENT_STATE_B <= NOT_TAKEN;
								end if;
							when NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_B <= TAKEN;
								else
									CURRENT_STATE_B <= S_NOT_TAKEN;
								end if;
							when S_NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_B <= NOT_TAKEN;
								else
									CURRENT_STATE_B <= S_NOT_TAKEN;
								end if;
							when others =>
								CURRENT_STATE_B <= TAKEN;
						end case;
					elsif(FSM_SEL = "10") then
						case CURRENT_STATE_C is
							when S_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_C <= S_TAKEN;
								else
									CURRENT_STATE_C <= TAKEN;
								end if;
							when TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_C <= S_TAKEN;
								else
									CURRENT_STATE_C <= NOT_TAKEN;
								end if;
							when NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_C <= TAKEN;
								else
									CURRENT_STATE_C <= S_NOT_TAKEN;
								end if;
							when S_NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_C <= NOT_TAKEN;
								else
									CURRENT_STATE_C <= S_NOT_TAKEN;
								end if;
							when others =>
								CURRENT_STATE_C <= TAKEN;
						end case;
					elsif(FSM_SEL = "11") then
						case CURRENT_STATE_D is
							when S_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_D <= S_TAKEN;
								else
									CURRENT_STATE_D <= TAKEN;
								end if;
							when TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_D <= S_TAKEN;
								else
									CURRENT_STATE_D <= NOT_TAKEN;
								end if;
							when NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_D <= TAKEN;
								else
									CURRENT_STATE_D <= S_NOT_TAKEN;
								end if;
							when S_NOT_TAKEN =>
								if(BRANCH_TAKEN = '1') then
									CURRENT_STATE_D <= NOT_TAKEN;
								else
									CURRENT_STATE_D <= S_NOT_TAKEN;
								end if;
							when others =>
								CURRENT_STATE_D <= TAKEN;
						end case;
					end if;
				end if;
		end process STATE_PROC;

		OUTPUT_STATE: process(CURRENT_STATE_A, CURRENT_STATE_B, CURRENT_STATE_C, CURRENT_STATE_D)
			begin
				case CURRENT_STATE_A is
					when S_TAKEN =>
						MUX_SEL_A <= '1';
					when TAKEN =>
						MUX_SEL_A <= '1';
					when NOT_TAKEN =>
						MUX_SEL_A <= '0';
					when S_NOT_TAKEN =>
						MUX_SEL_A <= '0';
				end case;
				case CURRENT_STATE_B is
					when S_TAKEN =>
						MUX_SEL_B <= '1';
					when TAKEN =>
						MUX_SEL_B <= '1';
					when NOT_TAKEN =>
						MUX_SEL_B <= '0';
					when S_NOT_TAKEN =>
						MUX_SEL_B <= '0';
				end case;
				case CURRENT_STATE_C is
					when S_TAKEN =>
						MUX_SEL_C <= '1';
					when TAKEN =>
						MUX_SEL_C <= '1';
					when NOT_TAKEN =>
						MUX_SEL_C <= '0';
					when S_NOT_TAKEN =>
						MUX_SEL_C <= '0';
				end case;
				case CURRENT_STATE_D is
					when S_TAKEN =>
						MUX_SEL_D <= '1';
					when TAKEN =>
						MUX_SEL_D <= '1';
					when NOT_TAKEN =>
						MUX_SEL_D <= '0';
					when S_NOT_TAKEN =>
						MUX_SEL_D <= '0';
				end case;
		end process OUTPUT_STATE;

		MUX_OUT: MUX41	port map (	A => MUX_SEL_D,
						B => MUX_SEL_C,
						C => MUX_SEL_B,
						D => MUX_SEL_A,
						SEL => FSM_SEL,
						Y => MUX_SEL);
end FSM;

configuration CFG_FSM_BPU_FSM of FSM_BPU is
	for FSM
		for all: MUX41
			use configuration WORK.CFG_MUX41_BEHAVIORAL;
		end for;
	end for;
end configuration CFG_FSM_BPU_FSM;