library ieee;
use ieee.std_logic_1164.all;

entity shift_left is
  generic   (
    larguraDados  : natural :=  32
  );

  port   (
    -- Input ports
    input  : in  std_logic_vector(larguraDados-1 downto 0);
    output : out std_logic_vector(larguraDados-1 downto 0)

  );
end entity;


architecture comportamento of shift_left is

begin

  dataOUT <= dataIN(29 DOWNTO 0) & "00";
  

end architecture;