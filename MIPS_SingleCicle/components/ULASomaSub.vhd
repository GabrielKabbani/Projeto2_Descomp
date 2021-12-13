LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY ULASomaSub IS
	GENERIC (larguraDados : NATURAL := 4);
	PORT (
		entradaA, entradaB : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
		seletor : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		saida : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
		flag_zero : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE comportamento OF ULASomaSub IS

	SIGNAL soma : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
	SIGNAL subtracao : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
	SIGNAL resultado : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);

	CONSTANT valor_zero : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0) := (OTHERS => '0');

BEGIN

	soma <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
	subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));

	resultado <= soma WHEN (seletor = "0000") ELSE
		subtracao WHEN (seletor = "0001") ELSE
		entradaB;
	flag_zero <= '1' WHEN resultado = valor_zero ELSE
		'0';
	saida <= resultado;
END ARCHITECTURE;