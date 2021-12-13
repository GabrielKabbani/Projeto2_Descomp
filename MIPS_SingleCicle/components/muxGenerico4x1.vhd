LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY muxGenerico4x1 IS
  GENERIC (larguraDados : NATURAL := 8);
  PORT (
    E0, E1, E2, E3 : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SEL_MUX : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    MUX_OUT : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE arch_name OF muxGenerico4x1 IS

BEGIN

  MUX_OUT <= E0 WHEN (SEL_MUX = "00") ELSE
    E1 WHEN (SEL_MUX = "01") ELSE
    E2 WHEN (SEL_MUX = "10") ELSE
    E3;

END ARCHITECTURE;