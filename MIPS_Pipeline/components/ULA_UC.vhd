LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;

ENTITY ULA_UC IS
	PORT (
		tipoR : IN STD_LOGIC; -- tipo R ? '1' : '0'
		opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		ULA_CTRL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE comportamento OF ULA_UC IS

	SIGNAL case_R : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL case_I : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
	decoder_R : ENTITY work.decoder_funct
		PORT MAP(
			funct => funct,
			decoder_out => case_R
		);

	decoder_I : ENTITY work.decoder_opcode
		PORT MAP(
			opcode => opcode,
			decoder_out => case_I
		);

	MUX_OUTPUT : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 3)
		PORT MAP(
			entradaA_MUX => case_I,
			entradaB_MUX => case_R,
			seletor_MUX => tipoR,
			saida_MUX => mux_out
		);

	ULA_CTRL <= mux_out;

	END ARCHITECTURE;