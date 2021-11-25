LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY fullAdder IS
	PORT (
		A : IN STD_LOGIC;
		B : IN STD_LOGIC;
		C_in : IN STD_LOGIC;
		C_out : OUT STD_LOGIC;
		S : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE comportamento OF fullAdder IS
BEGIN

	S <= (A XOR B) XOR C_in;
	C_out <= ((A XOR B) AND C_in) OR (A AND B);

END ARCHITECTURE;