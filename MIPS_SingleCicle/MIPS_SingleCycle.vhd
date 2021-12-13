LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY MIPS_SingleCycle IS
	GENERIC (
		larguraDados : NATURAL := 32;
		larguraLeftPC : NATURAL := 26;
		larguraUm : NATURAL := 1;
		larguraCinco : NATURAL := 5;
		larguraSinais : NATURAL := 11;
		simulacao : BOOLEAN := TRUE -- para gravar na placa, altere de TRUE para FALSE
	);
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		SW : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		HEX0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX2 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX3 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX4 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX5 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		KEY  : in  std_logic_vector	(3 downto 0);
		LEDR : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
--		debug_ula : OUT STD_LOGIC_VECTOR (larguraDados - 1 DOWNTO 0);
--		debug_pc : OUT STD_LOGIC_VECTOR (larguraDados - 1 DOWNTO 0);
--		debug_ula_A : OUT STD_LOGIC_VECTOR (larguraDados - 1 DOWNTO 0);
--		debug_ula_B : OUT STD_LOGIC_VECTOR (larguraDados - 1 DOWNTO 0);
--		debug_uc_beq : OUT STD_LOGIC;
--		debug_ula_ctrl : out std_logic_vector(2 downto 0);
--		debug_uc_mux : out std_logic_vector(1 downto 0);
--		debug_beq : OUT STD_LOGIC 
	);

END ENTITY;
ARCHITECTURE arquitetura OF MIPS_SingleCycle IS

	SIGNAL CLK : STD_LOGIC;
	SIGNAL saidaSOM : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL PC_out : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL ROM_instru : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL Saida_ULA : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL entradaAULA : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL entradaBULA : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL dadoLidoR2 : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL saidaMemDados : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL ULA_B : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL saidaEstendeSinal : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL leftShift_Somador : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL somador_muxBranch : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL mux_PC : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL OP_ULA : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL habEscritaR3 : STD_LOGIC;
	SIGNAL MUX_REG : STD_LOGIC_VECTOR(larguraCinco - 1 DOWNTO 0);
	SIGNAL proxPC : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	SIGNAL DATA_OUT : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);

	SIGNAL leftShift_PC : STD_LOGIC_VECTOR(larguraLeftPC - 1 DOWNTO 0);
	SIGNAL branchEqual : STD_LOGIC;
	SIGNAL ULA_flipflop : STD_LOGIC;
	SIGNAL saida_LUI : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL Saida_Mux_R3 : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);

	SIGNAL enable_branchEqual : STD_LOGIC;
	-- sinais de controle (unidade de controle)
	SIGNAL sinaisControle : STD_LOGIC_VECTOR(larguraSinais - 1 DOWNTO 0);
	SIGNAL UC_WRITE_ENABLE : STD_LOGIC;
	SIGNAL UC_READ_ENABLE : STD_LOGIC;
	SIGNAL UC_BEQ : STD_LOGIC;
	SIGNAL UC_MUX_ULAMEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL UC_MUX_INSTR : STD_LOGIC;
	SIGNAL UC_OP_ULA : STD_LOGIC;
	SIGNAL UC_MUX_RT_IMED : STD_LOGIC;
	SIGNAL UC_WE_REG : STD_LOGIC;
	SIGNAL UC_ORI : STD_LOGIC;
	SIGNAL UC_MUX_RT_RD : STD_LOGIC;
	SIGNAL UC_MUX_BEQ : STD_LOGIC;

	SIGNAL UC_ULA_CTRL : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

	-- Instanciando os componentes:

	-- clock configurando como borda de subida
	--	CLK <= CLOCK_50;
	
	detectorSub: work.edgeDetector(bordaSubida)
		port map (
			clk => CLOCK_50, 
			entrada => (not KEY(0)), 
			saida => CLK
		);
	-- INSTR <= ROM_instru;

	UC_WRITE_ENABLE <= sinaisControle(0);
	UC_READ_ENABLE <= sinaisControle(1);
	UC_BEQ <= sinaisControle(2);
	UC_MUX_ULAMEM <= sinaisControle(4 DOWNTO 3);
	UC_OP_ULA <= sinaisControle(5);
	UC_MUX_RT_IMED <= sinaisControle(6);
	UC_WE_REG <= sinaisControle(7);
	UC_ORI <= sinaisControle(8);
	UC_MUX_RT_RD <= sinaisControle(9);
	UC_MUX_BEQ <= sinaisControle(10);

--	debug_ula <= Saida_ULA;
--	debug_pc <= PC_out;
--	debug_beq <= branchEqual;
--	debug_uc_beq <= UC_BEQ;
--	debug_ula_ctrl <= UC_ULA_CTRL;
--	debug_uc_mux <= UC_MUX_ULAMEM;
--	debug_ula_A <= entradaAULA;
--	debug_ula_B <= ULA_B;
--	
	
	PC : ENTITY work.registradorGenerico
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			DIN => proxPC, -- saida MUX_PC 
			DOUT => PC_out,
			ENABLE => '1',
			CLK => CLK,
			RST => '0'
		);

	somador : ENTITY work.somaConstante
		GENERIC MAP(larguraDados => 32, constante => 4)
		PORT MAP(
			entrada => PC_out,
			saida => saidaSOM
		);

	-- ROM com instrucoes atualizadas
	ROM : ENTITY work.ROMMIPS
		GENERIC MAP(dataWidth => 32, addrWidth => 32, memoryAddrWidth => 8) -- 256 posicoes de 32 bits cada
		PORT MAP(
			clk => CLK,
			Endereco => PC_out,
			Dado => ROM_instru
		);

	-- mux que seleciona a intrucao tipo R ou tipo I
	MUX_INSTRUCOES : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 5)
		PORT MAP(
			entradaA_MUX => ROM_instru(20 DOWNTO 16), -- Rt
			entradaB_MUX => ROM_instru(15 DOWNTO 11), -- Rd
			seletor_MUX => UC_MUX_RT_RD, -- seletor de instrucao R/I (unidade de controle)
			saida_MUX => MUX_REG -- enderecoC banco de registradores
		);

	Banco_Registradores : ENTITY work.bancoReg
		GENERIC MAP(larguraDados => 32, larguraEndBancoRegs => 5)
		PORT MAP(
			clk => CLK,
			enderecoA => ROM_instru(25 DOWNTO 21),
			enderecoB => ROM_instru(20 DOWNTO 16),
			enderecoC => MUX_REG,
			escreveC => UC_WE_REG,
			dadoEscritaC => Saida_Mux_R3,
			saidaA => entradaAULA,
			saidaB => dadoLidoR2
		);

	-- extensor de sinal
	SIG_EXT : ENTITY work.estendeSinalGenerico
		GENERIC MAP(larguraDadoEntrada => 16, larguraDadoSaida => 32)
		PORT MAP(
			estendeSinal_IN => ROM_instru(15 DOWNTO 0),
			controle => UC_ORI,
			estendeSinal_OUT => saidaEstendeSinal
		);

	lui_comp : ENTITY work.LUI
		PORT MAP(
			input => ROM_instru(15 DOWNTO 0),
			output => saida_LUI -- 32 bits
		);

	LEFT_SHIFT : ENTITY work.shift_left
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			input => saidaEstendeSinal,
			output => leftShift_Somador-- somador
		);
	LEFT_SHIFT_PC : ENTITY work.shift_left
		GENERIC MAP(larguraDados => 26)
		PORT MAP(
			input => ROM_instru(25 DOWNTO 0),
			output => leftShift_PC
		);

	MUX_PROX_PC : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA_MUX => mux_PC,
			entradaB_MUX(31 DOWNTO 28) => saidaSOM(31 DOWNTO 28),
			entradaB_MUX(27 DOWNTO 2) => leftShift_PC(25 DOWNTO 0),
			entradaB_MUX(1 DOWNTO 0) => b"00",
			seletor_MUX => UC_MUX_BEQ,
			saida_MUX => proxPC
		);

	-- somador
	SOMA_DESVIO : ENTITY work.somadorGenerico
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA => saidaSOM, --
			entradaB => leftShift_Somador, --
			saida => somador_muxBranch
		);
	MUX_BRANCH : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA_MUX => saidaSOM, -- saida pc
			entradaB_MUX => somador_muxBranch, -- saida somaConstante
			seletor_MUX => branchEqual, -- saida flipflop		
			saida_MUX => mux_PC
		);

	-- mux que seleciona a entrada B da ULA
	MUX_ULA : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA_MUX => dadoLidoR2, -- Saida R2
			entradaB_MUX => saidaEstendeSinal, -- extensor de sinal
			seletor_MUX => UC_MUX_RT_IMED, -- seletedor Rt/Imediato (unidade de controle)
			saida_MUX => ULA_B -- entrada B da ULA
		);

	ULA : ENTITY work.ULA_MIPS
		GENERIC MAP(larguraDados => larguraDados)
		PORT MAP(
			entradaA => entradaAULA,
			entradaB => ULA_B,
			saida => Saida_ULA,
			operacao => UC_ULA_CTRL,
			flag_zero => ULA_flipflop
		);

	branchEqual <= ULA_flipflop AND UC_BEQ;

	-- memoria dados
	MEMORIA_DADOS : ENTITY work.RAMMIPS
		GENERIC MAP(dataWidth => 32, addrWidth => 32, memoryAddrWidth => 8) -- 256 posicoes de 32 bits cada
		PORT MAP(
			clk => CLK,
			Endereco => Saida_ULA,
			Dado_in => dadoLidoR2,
			Dado_out => saidaMemDados,
			we => UC_WRITE_ENABLE,
			re => UC_READ_ENABLE
		);

	MUX_R3 : ENTITY work.muxGenerico4x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			E0 => Saida_ULA,
			E1 => saidaMemDados,
			E2 => 32x"0",
			E3 => saida_LUI,
			SEL_MUX => UC_MUX_ULAMEM,
			MUX_OUT => Saida_Mux_R3
		);

	UC_ULA : ENTITY work.ULA_UC
		PORT MAP(
			tipoR => UC_OP_ULA,
			opcode => ROM_instru(31 DOWNTO 26),
			funct => ROM_instru(5 DOWNTO 0),
			ULA_CTRL => UC_ULA_CTRL
		);

	-- unidade de controle
	UC : ENTITY work.FD_UC
		PORT MAP(
			op_code => ROM_instru(31 DOWNTO 26),
			sinais_CTRL => sinaisControle
		);

	MUX_OUTPUT : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA_MUX => PC_out, -- 
			entradaB_MUX => Saida_ULA, --  
			seletor_MUX => SW(0), --  
			saida_MUX => DATA_OUT --  
		);

	HEX0_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(3 DOWNTO 0),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX0
		);

	HEX1_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(7 DOWNTO 4),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX1
		);

	HEX2_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(11 DOWNTO 8),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX2
		);

	HEX3_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(15 DOWNTO 12),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX3
		);

	HEX4_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(19 DOWNTO 16),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX4
		);

	HEX5_DECODER : ENTITY work.conversorHex7Seg
		PORT MAP(
			dadoHex => DATA_OUT(23 DOWNTO 20),
			apaga => '0',
			negativo => '0',
			overFlow => '0',
			saida7seg => HEX5
		);

	LEDR(3 DOWNTO 0) <= DATA_OUT(27 DOWNTO 24);
	LEDR(7 DOWNTO 4) <= DATA_OUT(31 DOWNTO 28);

END ARCHITECTURE;