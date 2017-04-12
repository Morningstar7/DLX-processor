library IEEE;
use IEEE.std_logic_1164.all;

entity CU_BPU is
	port (		HIT_MISS:	in	std_logic;
			BRANCH_FETCH:	in	std_logic;
			CLK:		in	std_logic;
			RST:		in	std_logic;
			BRANCH_TAKEN:	in	std_logic;
			STALL_BRANCH:	in	std_logic;
			NEW_BRANCH:	out	std_logic;
			EN_FSM:		out	std_logic);
end CU_BPU;

architecture FSM of CU_BPU is

	type STATE is (IDLE, UPDATE, FILL);

	signal CURRENT_STATE:	STATE;

	begin

		STATE_PROC: process(CLK)
			begin
				if RST='1' then
					CURRENT_STATE <= IDLE;
				elsif CLK'event and CLK = '1' then
					if (STALL_BRANCH = '1') then
						CURRENT_STATE <= CURRENT_STATE;
					else
						case CURRENT_STATE is
							when IDLE =>
								if(BRANCH_FETCH = '1') then
									if(HIT_MISS = '1') then
										CURRENT_STATE <= UPDATE;
									else
										CURRENT_STATE <= FILL;
									end if;
								else
									CURRENT_STATE <= IDLE;
								end if;
							when UPDATE =>
								if(BRANCH_FETCH = '1') then
									if(HIT_MISS = '1') then
										CURRENT_STATE <= UPDATE;
									else	
										CURRENT_STATE <= FILL;
									end if;
								else
									CURRENT_STATE <= IDLE;
								end if;
							when FILL =>
								if(BRANCH_FETCH = '1') then
									if(HIT_MISS = '1') then
										CURRENT_STATE <= UPDATE;
									else
										CURRENT_STATE <= FILL;
									end if;
								else
									CURRENT_STATE <= IDLE;
								end if;
						end case;
					end if;
				end if;
		end process STATE_PROC;

		OUTPUT_STATE: process(CURRENT_STATE)
			begin
				case CURRENT_STATE is
					when IDLE =>
						NEW_BRANCH <= '0';
						EN_FSM <= '0';
					when FILL =>
						NEW_BRANCH <= '1';
						EN_FSM <= '1';
					when UPDATE =>
						NEW_BRANCH <= '0';
						EN_FSM <= '1';
				end case;
		end process OUTPUT_STATE;

end FSM;

configuration CFG_CU_BPU_FSM of CU_BPU is
	for FSM
	end for;
end configuration CFG_CU_BPU_FSM;