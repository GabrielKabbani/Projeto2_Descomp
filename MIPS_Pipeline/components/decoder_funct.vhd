LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;
-- decodifica instrucoes do tipo R
ENTITY decoder_funct IS
  PORT (
    funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    decoder_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE comportamento OF decoder_funct IS
BEGIN

  decoder_out <= CTRL_AND WHEN funct = OP_AND OR funct = OP_ANDI ELSE
    CTRL_OR WHEN funct = OP_OR OR funct = OP_ORI ELSE
    CTRL_ADD WHEN funct = OP_ADD OR funct = OP_ADDI ELSE
    CTRL_SUB WHEN funct = OP_SUB ELSE
    CTRL_SLT;

END ARCHITECTURE;