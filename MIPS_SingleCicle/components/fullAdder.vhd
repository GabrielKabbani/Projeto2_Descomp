LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY fullAdder IS
	PORT (
		A : in STD_LOGIC;
		B : in STD_LOGIC;
		C_in : in STD_LOGIC;
		C_out : out STD_LOGIC;
		S : out STD_LOGIC
	);
END ENTITY;

ARCHITECTURE comportamento OF fullAdder IS
BEGIN

	S <= (A XOR B) XOR C_in;
	C_out <= ((A XOR B) AND C_in) OR (A AND B);

END ARCHITECTURE;