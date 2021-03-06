library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  --Soma (esta biblioteca =ieee)

entity unidadeDeControle is
    generic (
        largura_opcode : natural := 6;
		  largura_control: natural := 3
    );
    port (
        op_code			: in  STD_LOGIC_VECTOR((largura_opcode-1) downto 0);
        sinaisControle	: out STD_LOGIC_VECTOR((largura_control-1) downto 0)
    );
end entity;

architecture comportamento of unidadeDeControle is
	
	signal write_enable_reg3 : std_logic;
	signal write_enable_RAM  : std_logic;
	signal read_enable_RAM   : std_logic;
	signal operacao_ULA      : std_logic_vector(3 downto 0);
	signal branch_on_equal   : std_logic;


	constant lw   : std_logic_vector(5 downto 0) := "100011";
	constant sw   : std_logic_vector(5 downto 0) := "101011";
	constant beq  : std_logic_vector(5 downto 0) := "000100";
	
	begin
	
		write_enable_reg3 <= '1' 		when op_code = lw  else '0';
		write_enable_RAM  <= '1' 		when op_code = sw  else '0';
		read_enable_RAM   <= '1' 		when op_code = lw  else '0';
		operacao_ULA		<= "0001" 	when op_code = beq else "0010";
		branch_on_equal	<= '1' 		when op_code = beq else '0';
		
		
		sinaisControle(0) <= write_enable_RAM;
		sinaisControle(1) <= read_enable_RAM;
		sinaisControle(2) <= branch_on_equal;
		sinaisControle(6 downto 3) <= operacao_ULA;
		sinaisControle(7) <= write_enable_reg3;

	 
end architecture;