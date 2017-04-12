library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;


-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity IRAM is
	generic (	RAM_DEPTH:	integer;
			I_SIZE:		integer);
	port (		RST:	in	std_logic;
			ADDR:	in	std_logic_vector(I_SIZE-1 downto 0);
			D_OUT:	out	std_logic_vector(7 downto 0));
end IRAM;

architecture BEHAVIORAL of IRAM is

  type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(7 downto 0);-- std_logic_vector(I_SIZE - 1 downto 0);

  signal IRAM_mem : RAMtype := (others => "00000000");
	--signal TMP:	integer;

begin  -- IRam_Bhe

  D_OUT <= IRAM_mem(conv_integer(unsigned(Addr)));

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem

  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '1') then
      file_open(mem_fp,"test.asm.mem",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);			--CONVERT TO STD_LOGIC_VECTOR
	--TMP <= conv_integer(unsigned(tmp_data_u));
        IRAM_mem(4*index) <= tmp_data_u(7 downto 0);
        IRAM_mem(4*index+1) <= tmp_data_u(15 downto 8);
        IRAM_mem(4*index+2) <= tmp_data_u(23 downto 16);
        IRAM_mem(4*index+3) <= tmp_data_u(31 downto 24);
        index := index + 1;
      end loop;
    end if;
  end process FILL_MEM_P;

end BEHAVIORAL;

configuration CFG_IRAM_BEHAVIORAL of IRAM is
	for BEHAVIORAL
	end for;
end CFG_IRAM_BEHAVIORAL;
