LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY ULA_bit IS
	PORT (
		A : IN STD_LOGIC;
		B : IN STD_LOGIC;
		SLT : IN STD_LOGIC;
		inv_B : IN STD_LOGIC;
		sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		C_in : IN STD_LOGIC;
		C_out : OUT STD_LOGIC;
		S : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE comportamento OF ULA_bit IS

SIGNAL saida_inv_B : STD_LOGIC;
SIGNAL saida_full_adder : STD_LOGIC;
SIGNAL S0 : STD_LOGIC;
SIGNAL S1 : STD_LOGIC;
SIGNAL S2 : STD_LOGIC;
SIGNAL S3 : STD_LOGIC;

BEGIN
	MUX_INV_B : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 1)
		PORT MAP(
			entradaA_MUX(0) => B,
			entradaB_MUX(0) => NOT(B),
			seletor_MUX => inv_B,
			saida_MUX(0) => saida_inv_B
		);

	FULL_ADDER : ENTITY work.fullAdder
		PORT MAP(
			A => A,
			B => saida_inv_B,
			C_in => C_in,
			C_out => C_out,
			S => saida_full_adder
		);

	S0 <= A AND saida_inv_B;
	S1 <= A OR saida_inv_B;
	S2 <= saida_full_adder;
	S3 <= SLT;

	MUX_SAIDA : ENTITY work.muxGenerico4x1
		GENERIC MAP(larguraDados => 1)
		PORT MAP(
			E0(0) => S0, -- sel = 00
			E1(0) => S1, -- sel = 01
			E2(0) => S2, -- sel = 10
			E3(0) => S3, -- sel = 11
			SEL_MUX => sel,
			MUX_OUT(0) => S
		);

END ARCHITECTURE;