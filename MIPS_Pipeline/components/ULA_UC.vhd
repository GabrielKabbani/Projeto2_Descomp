LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

LIBRARY constants;
USE constants.controls.ALL;

ENTITY ULA_UC IS
	PORT (
		ULA_OP   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		opcode   : IN STD_LOGIC_VECTOR(5 downto 0);
		funct    : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		ULA_CTRL : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE comportamento OF ULA_UC IS

	SIGNAL tipoR : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ctrlBEQ : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ctrl_LW_SW : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

	tipoR <= CTRL_AND WHEN funct = OP_AND ELSE
		CTRL_OR WHEN funct = OP_OR ELSE
		CTRL_ADD WHEN funct = OP_ADD ELSE
		CTRL_SUB WHEN funct = OP_SUB ELSE
		CTRL_SLT; -- WHEN funct = OP_SLT;

	ctrl_LW_SW <= CTRL_ADD; -- ULA_OP = "00"
	
	ctrlBEQ <= CTRL_SUB; -- ULA_OP = "01";
	
	ULA_CTRL <= tipoR WHEN ULA_OP = "10" ELSE
		ctrl_LW_SW WHEN ULA_OP = "00" ELSE
		ctrlBEQ; -- possível bug

	--
END ARCHITECTURE;