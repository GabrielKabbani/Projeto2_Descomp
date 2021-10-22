library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULASomaSub is
    generic ( larguraDados : natural := 4 );
	 port (
		entradaA, entradaB	: in STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      seletor					: in STD_LOGIC_vector(1 downto 0);
      saida						: out STD_LOGIC_VECTOR((larguraDados-1) downto 0);
		flag_zero 				: out STD_LOGIC
    );
end entity;

architecture comportamento of ULASomaSub is

   signal soma 	  : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
   signal subtracao : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal resultado : STD_LOGIC_VECTOR((larguraDados-1) downto 0);

	constant valor_zero : STD_LOGIC_VECTOR((larguraDados-1) downto 0) := (others => '0');

	begin
   
		soma      <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
      subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
		
		
		
      resultado <= soma 		when (seletor = "00") else
						 subtracao  when (seletor = "01") else
					    entradaB;
		
					
		flag_zero <= '1' when resultado = valor_zero else '0';
		saida <= resultado;
		
		
end architecture;