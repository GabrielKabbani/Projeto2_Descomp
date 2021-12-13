LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY LUI IS
    PORT (
        input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF LUI IS
BEGIN

    output <= input & b"0000_0000_0000_0000";
END ARCHITECTURE;