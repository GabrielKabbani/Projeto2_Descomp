LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY estendeSinalGenerico IS
    GENERIC (
        larguraDadoEntrada : NATURAL := 8;
        larguraDadoSaida : NATURAL := 8
    );
    PORT (
        -- Input ports
        estendeSinal_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        controle : IN STD_LOGIC;
        -- Output ports
        estendeSinal_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF estendeSinalGenerico IS
BEGIN
    --    PROCESS (estendeSinal_IN) IS
    --    BEGIN
    --        IF (estendeSinal_IN(larguraDadoEntrada - 1) = '1') THEN
    --            estendeSinal_OUT <= (larguraDadoSaida - 1 DOWNTO larguraDadoEntrada => '1') & estendeSinal_IN;
    --        ELSE
    --            estendeSinal_OUT <= (larguraDadoSaida - 1 DOWNTO larguraDadoEntrada => '0') & estendeSinal_IN;
    --        END IF;
    --    END PROCESS;
    estendeSinal_OUT <=
        (31 DOWNTO 16 => estendeSinal_IN(15)) & estendeSinal_IN WHEN controle = '0' ELSE
        (31 DOWNTO 16 => '0') & estendeSinal_IN;

END ARCHITECTURE;