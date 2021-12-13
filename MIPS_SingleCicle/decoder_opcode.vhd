LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;

-- decodifica instrucoes do tipo I
ENTITY decoder_opcode IS
  PORT (
    opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    decoder_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE comportamento OF decoder_opcode IS
BEGIN

  decoder_out <=
    CTRL_ADD WHEN (opcode = OP_LW) OR (opcode = OP_SW) ELSE
    CTRL_OR WHEN (opcode = OP_ORI) ELSE
    CTRL_SUB WHEN (opcode = OP_BEQ) ELSE
    CTRL_AND;

END ARCHITECTURE;