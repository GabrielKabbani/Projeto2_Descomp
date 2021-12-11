LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;

ENTITY FD_UC IS
  PORT (
    op_code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    sinais_CTRL : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE comportamento OF FD_UC IS

  SIGNAL RE_MEM : STD_LOGIC;
  SIGNAL WE_MEM : STD_LOGIC;
  SIGNAL BNE : STD_LOGIC;
  SIGNAL BEQ : STD_LOGIC;
  SIGNAL MUX_ULA_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL TIPO_R : STD_LOGIC;
  SIGNAL MUX_Rt_Imediato : STD_LOGIC;
  SIGNAL WE_Reg : STD_LOGIC;
  SIGNAL ORI_ANDI : STD_LOGIC;
  SIGNAL MUX_Rt_Rd : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL MUX_BEq_JMP : STD_LOGIC;
  SIGNAL JR : STD_LOGIC;

BEGIN

  RE_MEM <= '1' WHEN op_code = OP_LW ELSE
    '0';

  WE_MEM <= '1' WHEN op_code = OP_SW ELSE
    '0';

  BEQ <= '1' WHEN op_code = OP_BEQ ELSE
    '0';

  BNE <= '1' WHEN op_code = OP_BNE ELSE
    '0';

  MUX_ULA_MEM <= "00" WHEN op_code = OP_CODE_R ELSE
    "01" WHEN op_code = OP_LW ELSE
    "10" WHEN op_code = OP_JAL ELSE
    "11" WHEN op_code = OP_LUI; -- possível bug

  TIPO_R <= '1' WHEN op_code = OP_CODE_R ELSE
    '0';

  MUX_Rt_Imediato <= NOT(TIPO_R);

  WE_Reg <= '1' WHEN (op_code = OP_LW) OR (op_code = OP_CODE_R)
    OR (op_code = OP_ORI)
    OR (op_code = OP_LUI)
    OR (op_code = OP_ADDI)
    OR (op_code = OP_SLTI)
    OR (op_code = OP_JAL) ELSE
    '0';

  ORI_ANDI <= '1' WHEN (op_code = OP_ORI) OR (op_code = OP_ANDI) ELSE
    '0';

  MUX_Rt_Rd <= "01" WHEN op_code = OP_CODE_R ELSE
    "10" WHEN op_code = OP_JAL ELSE
    "00";

  MUX_BEq_JMP <= '1' WHEN (op_code = OP_JMP) ELSE
    '0';

  JR <= '1' WHEN op_code = OP_JR ELSE
    '0';

  sinais_CTRL(0) <= RE_MEM;-- UC_WRITE_ENABLE;
  sinais_CTRL(1) <= WE_MEM;-- UC_READ_ENABLE;
  sinais_CTRL(2) <= BNE;-- UC_BNE;
  sinais_CTRL(3) <= BEQ;-- UC_BEQ;
  sinais_CTRL(5 DOWNTO 4) <= MUX_ULA_MEM;-- UC_MUX_ULAMEM;
  sinais_CTRL(6) <= TIPO_R; -- UC_TIPO_R;
  sinais_CTRL(7) <= MUX_Rt_Imediato;-- UC_MUX_RT_IMED;
  sinais_CTRL(8) <= WE_Reg; -- UC_WE_REG;
  sinais_CTRL(9) <= ORI_ANDI;-- UC_ORI_ANDI;
  sinais_CTRL(11 DOWNTO 10) <= MUX_Rt_Rd;-- UC_MUX_RT_RD;
  sinais_CTRL(12) <= MUX_BEq_JMP;-- UC_MUX_BEQ;
  sinais_CTRL(13) <= JR;-- UC_JR;

END ARCHITECTURE;