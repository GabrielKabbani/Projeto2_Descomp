LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;

ENTITY FD_UC IS
  PORT (
    op_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    sinais_CTRL : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE comportamento OF FD_UC IS

  SIGNAL RE_MEM : STD_LOGIC;
  SIGNAL WE_MEM : STD_LOGIC;
  SIGNAL BEQ : STD_LOGIC;
  SIGNAL MUX_ULA_MEM : STD_LOGIC;
  SIGNAL OP_ULA : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL MUX_Rt_Imediato : STD_LOGIC;
  SIGNAL WE_Reg : STD_LOGIC;
  SIGNAL MUX_Rt_Rd : STD_LOGIC;
  SIGNAL MUX_BEq_JMP : STD_LOGIC;

BEGIN

  RE_MEM <= '1' WHEN op_code = OP_LW ELSE
    '0';
  WE_MEM <= '1' WHEN op_code = OP_SW ELSE
    '0';

  BEQ <= '1' WHEN op_code = OP_BEQ ELSE
    '0';

  MUX_ULA_MEM <= '0' WHEN op_code = OP_CODE_R ELSE
    '1'; -- possível bug

  OP_ULA <= "00" WHEN (op_code = OP_LW) OR (op_code = OP_SW) ELSE
    "01" WHEN (op_code = OP_BEQ) ELSE
    "10"; -- when (op_code =  OP_CODE_R); -- possível bug

  MUX_Rt_Imediato <= '1' WHEN (op_code = OP_LW) OR (op_code = OP_SW) ELSE
    '0';

  WE_Reg <= '1' WHEN (op_code = OP_LW) OR (op_code = OP_CODE_R) ELSE
    '0'; -- talvez nao inclua o caso de jump

  MUX_Rt_Rd <= '1' WHEN op_code = OP_CODE_R ELSE
    '0';

  MUX_BEq_JMP <= '1' WHEN op_code = OP_BEQ ELSE
    '0';
  --
  sinais_CTRL(0) <= RE_MEM;
  sinais_CTRL(1) <= WE_MEM;
  sinais_CTRL(2) <= BEQ;
  sinais_CTRL(3) <= MUX_ULA_MEM;
  sinais_CTRL(5 DOWNTO 4) <= OP_ULA;
  sinais_CTRL(6) <= MUX_Rt_Imediato;
  sinais_CTRL(7) <= WE_Reg;
  sinais_CTRL(8) <= MUX_Rt_Rd;
  sinais_CTRL(9) <= MUX_BEq_JMP;

END ARCHITECTURE;