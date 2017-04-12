library IEEE;
use IEEE.std_logic_1164.all;

entity BOOTH_ENCODER is
	port (		TO_ENC:	in	std_logic_vector(2 downto 0);
			ENC:	out	std_logic_vector(2 downto 0));
end BOOTH_ENCODER;

architecture BEHAVIORAL of BOOTH_ENCODER is

	begin

		--ENC(0) <= TO_ENC(2) and (not TO_ENC(1)) and (not TO_ENC(0)) or (not TO_ENC(2)) and ((not TO_ENC(1)) and TO_ENC(0) or TO_ENC(1) and (not TO_ENC(0)));

		process(TO_ENC)
			begin
				case TO_ENC is
					when "000" => ENC <= "111";
					when "111" => ENC <= "111";
					when "001" => ENC <= "110";
					when "010" => ENC <= "110";
					when "011" => ENC <= "100";
					when "100" => ENC <= "001";
					when "101" => ENC <= "101";
					when "110" => ENC <= "101";
					when others => ENC <= "111";
				end case;
		end process;

end BEHAVIORAL;

-- architecture STRUCTURAL of BOOTH_ENCODER is
-- 
-- 	component NAND_GATE
-- 		port (	A:	In	std_logic;
-- 			B:	In	std_logic;
-- 			Y:	Out	std_logic);
-- 	end component;
-- 
-- 	component INV
-- 		port (	A:	In	std_logic;
-- 			Y:	Out	std_logic);
-- 	end component;
-- 	
-- 	signal ENC_0_TMP:	std_logic_vector(4 downto 0);
-- 	signal ENC_1_TMP:	std_logic_vector(9 downto 0);
-- 	signal ENC_2_TMP:	std_logic_vector(4 downto 0);
-- 	
-- 	begin
-- 
-- 		--STARTING THE CREATION OF ENC(2):
-- 
-- 		ENC_O_IV_1: INV	port map (	A => TO_ENC(0),
-- 						Y => ENC_0_TMP(0));
-- 
-- 		ENC_O_IV_2: INV	port map (	A => TO_ENC(1),
-- 						Y => ENC_0_TMP(1));
-- 
-- 		ENC_O_ND_1: NAND_GATE	port map (	A => ENC_0_TMP(0),
-- 							B => ENC_0_TMP(1),
-- 							Y => ENC_0_TMP(2));
-- 
-- 		ENC_O_IV_3: INV	port map (	A => ENC_0_TMP(2),
-- 						Y => ENC_0_TMP(3));
-- 										
-- 		ENC_O_ND_2: NAND_GATE	port map (	A => TO_ENC(2),
-- 							B => ENC_0_TMP(3),
-- 							Y => ENC_0_TMP(4));
-- 
-- 		ENC_O_IV_4: INV	port map (	A => ENC_0_TMP(4),
-- 						Y => ENC(2));
-- 									
-- 		--STARTING THE CREATION OF ENC(1):
-- 
-- 		ENC_1_IV_1: INV	port map (	A => TO_ENC(0),
-- 						Y => ENC_1_TMP(0));
-- 
-- 		ENC_1_IV_2: INV	port map (	A => TO_ENC(1),
-- 						Y => ENC_1_TMP(1));
-- 
-- 		ENC_1_IV_3: INV	port map (	A => TO_ENC(2),
-- 						Y => ENC_1_TMP(2));
-- 
-- 		ENC_1_ND_1: NAND_GATE	port map (	A => TO_ENC(0),
-- 							B => TO_ENC(1),
-- 							Y => ENC_1_TMP(3));
-- 
-- 		ENC_1_ND_2: NAND_GATE	port map (	A => ENC_1_TMP(1),
-- 							B => TO_ENC(0),
-- 							Y => ENC_1_TMP(4));
-- 
-- 		ENC_1_ND_3: NAND_GATE	port map (	A => ENC_1_TMP(0),
-- 							B => TO_ENC(1),
-- 							Y => ENC_1_TMP(5));
-- 
-- 		ENC_1_IV_4: INV	port map (	A => ENC_1_TMP(3),
-- 						Y => ENC_1_TMP(6));
-- 
-- 		ENC_1_ND_4: NAND_GATE	port map (	A => ENC_1_TMP(4),
-- 							B => ENC_1_TMP(5),
-- 							Y => ENC_1_TMP(7));
-- 
-- 		ENC_1_ND_5: NAND_GATE	port map (	A => ENC_1_TMP(7),
-- 							B => TO_ENC(2),
-- 							Y => ENC_1_TMP(8));
-- 
-- 		ENC_1_ND_6: NAND_GATE	port map (	A => ENC_1_TMP(2),
-- 							B => ENC_1_TMP(6),
-- 							Y => ENC_1_TMP(9));
-- 
-- 		ENC_1_ND_7: NAND_GATE	port map (	A => ENC_1_TMP(8),
-- 							B => ENC_1_TMP(9),
-- 							Y => ENC(1));
-- 										
-- 		--STARTING THE CREATION OF ENC(2):
-- 		
-- 		ENC_2_IV_1: INV	port map (	A => TO_ENC(0),
-- 						Y => ENC_2_TMP(0));
-- 
-- 		ENC_2_IV_2: INV	port map (	A => TO_ENC(1),
-- 						Y => ENC_2_TMP(1));
-- 
-- 		ENC_2_IV_3: INV	port map (	A => TO_ENC(2),
-- 						Y => ENC_2_TMP(2));
-- 
-- 		ENC_2_ND_1: NAND_GATE	port map (	A => ENC_2_TMP(0),
-- 							B => ENC_2_TMP(1),
-- 							Y => ENC_2_TMP(3));
-- 
-- 		ENC_2_ND_2: NAND_GATE	port map (	A => ENC_2_TMP(2),
-- 							B => ENC_2_TMP(3),
-- 							Y => ENC_2_TMP(4));
-- 
-- 		ENC_2_IV_4: INV	port map (	A => ENC_2_TMP(4),
-- 						Y => ENC(0));
-- 
-- end STRUCTURAL;
-- 
configuration CFG_BOOTH_ENCODER_BEHAVIORAL OF BOOTH_ENCODER is
	for BEHAVIORAL
	end for;
end CFG_BOOTH_ENCODER_BEHAVIORAL;
-- 
-- configuration CFG_BOOTH_ENCODER_STRUCTURAL OF BOOTH_ENCODER is
-- 	for STRUCTURAL
-- 		for all: NAND_GATE
-- 			use configuration WORK.CFG_NAND_GATE_BEHAVIORAL;
-- 		end for;
-- 		for all: INV
-- 			use configuration WORK.CFG_INV_BEHAVIORAL;
-- 		end for;
-- 	end for;
-- end CFG_BOOTH_ENCODER_STRUCTURAL;