LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY ULA_MIPS IS
	GENERIC (larguraDados : NATURAL := 4);
	PORT (
		entradaA, entradaB : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
		operacao : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		saida : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
		flag_zero : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE comportamento OF ULA_MIPS IS
	SIGNAL C_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL overflow_slt : STD_LOGIC;

	SIGNAL inv_B : STD_LOGIC;
	SIGNAL seletor : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

	inv_B <= operacao(2);
	seletor <= operacao(1 DOWNTO 0);
	flag_zero <=
		NOT(saida(0)) AND NOT(saida(1)) AND NOT(saida(2)) AND NOT(saida(3)) AND
		NOT(saida(4)) AND NOT(saida(5)) AND NOT(saida(6)) AND NOT(saida(7)) AND
		NOT(saida(8)) AND NOT(saida(9)) AND NOT(saida(10)) AND NOT(saida(11)) AND
		NOT(saida(12)) AND NOT(saida(13)) AND NOT(saida(14)) AND NOT(saida(15)) AND
		NOT(saida(16)) AND NOT(saida(17)) AND NOT(saida(18)) AND NOT(saida(19)) AND
		NOT(saida(20)) AND NOT(saida(21)) AND NOT(saida(22)) AND NOT(saida(23)) AND
		NOT(saida(24)) AND NOT(saida(25)) AND NOT(saida(26)) AND NOT(saida(27)) AND
		NOT(saida(28)) AND NOT(saida(29)) AND NOT(saida(30)) AND NOT(saida(31));

	BIT00 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(0),
			B => entradaB(0),
			SLT => overflow_slt,
			inv_B => inv_B,
			sel => seletor,
			C_in => inv_B,
			C_out => C_OUT(0),
			S => saida(0)
		);

	BIT01 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(1), B => entradaB(1),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(0), C_out => C_OUT(1),
			S => saida(1)
		);

	BIT02 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(2), B => entradaB(2),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(1), C_out => C_OUT(2),
			S => saida(2)
		);

	BIT03 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(3), B => entradaB(3),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(2), C_out => C_OUT(3),
			S => saida(3)
		);

	BIT04 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(4), B => entradaB(4),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(3), C_out => C_OUT(4),
			S => saida(4)
		);

	BIT05 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(5), B => entradaB(5),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(4), C_out => C_OUT(5),
			S => saida(5)
		);

	BIT06 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(6), B => entradaB(6),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(5), C_out => C_OUT(6),
			S => saida(6)
		);

	BIT07 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(7), B => entradaB(7),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(6), C_out => C_OUT(7),
			S => saida(7)
		);

	BIT08 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(8), B => entradaB(8),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(7), C_out => C_OUT(8),
			S => saida(8)
		);

	BIT09 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(9), B => entradaB(9),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(8), C_out => C_OUT(9),
			S => saida(9)
		);

	BIT10 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(10), B => entradaB(10),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(9), C_out => C_OUT(10),
			S => saida(10)
		);

	BIT11 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(11), B => entradaB(11),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(10), C_out => C_OUT(11),
			S => saida(11)
		);

	BIT12 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(12), B => entradaB(12),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(11), C_out => C_OUT(12),
			S => saida(12)
		);

	BIT13 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(13), B => entradaB(13),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(12), C_out => C_OUT(13),
			S => saida(13)
		);

	BIT14 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(14), B => entradaB(14),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(13), C_out => C_OUT(14),
			S => saida(14)
		);

	BIT15 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(15), B => entradaB(15),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(14), C_out => C_OUT(15),
			S => saida(15)
		);

	BIT16 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(16), B => entradaB(16),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(15), C_out => C_OUT(16),
			S => saida(16)
		);

	BIT17 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(17), B => entradaB(17),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(16), C_out => C_OUT(17),
			S => saida(17)
		);

	BIT18 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(18), B => entradaB(18),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(17), C_out => C_OUT(18),
			S => saida(18)
		);

	BIT19 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(19), B => entradaB(19),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(18), C_out => C_OUT(19),
			S => saida(19)
		);

	BIT20 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(20), B => entradaB(20),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(19), C_out => C_OUT(20),
			S => saida(20)
		);

	BIT21 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(21), B => entradaB(21),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(20), C_out => C_OUT(21),
			S => saida(21)
		);

	BIT22 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(22), B => entradaB(22),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(21), C_out => C_OUT(22),
			S => saida(22)
		);

	BIT23 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(23), B => entradaB(23),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(22), C_out => C_OUT(23),
			S => saida(23)
		);

	BIT24 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(24), B => entradaB(24),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(23), C_out => C_OUT(24),
			S => saida(24)
		);

	BIT25 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(25), B => entradaB(25),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(24), C_out => C_OUT(25),
			S => saida(25)
		);

	BIT26 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(26), B => entradaB(26),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(25), C_out => C_OUT(26),
			S => saida(26)
		);

	BIT27 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(27), B => entradaB(27),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(26), C_out => C_OUT(27),
			S => saida(27)
		);

	BIT28 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(28), B => entradaB(28),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(27), C_out => C_OUT(28),
			S => saida(28)
		);

	BIT29 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(29), B => entradaB(29),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(28), C_out => C_OUT(29),
			S => saida(29)
		);

	BIT30 : ENTITY work.ULA_bit
		PORT MAP(
			A => entradaA(30), B => entradaB(30),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(29), C_out => C_OUT(30),
			S => saida(30)
		);

	BIT31 : ENTITY work.ULA_bit_overflow
		PORT MAP(
			A => entradaA(31), B => entradaB(31),
			SLT => '0', inv_B => inv_B, sel => seletor,
			C_in => C_OUT(30), overflow => overflow_slt,
			S => saida(31)
		);

END ARCHITECTURE;