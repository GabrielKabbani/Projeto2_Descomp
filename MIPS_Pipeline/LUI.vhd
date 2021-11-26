library ieee;
use ieee.std_logic_1164.all;

entity LUI is
    port(
        input : in  std_logic_vector(15 downto 0);
        output: out std_logic_vector(31 downto 0)
    );
end entity;

architecture comportamento of LUI is
begin

	output <= input & b"0000_0000_0000_0000";

	
end architecture;