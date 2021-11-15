LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Aula15 IS
	GENERIC (
		larguraDados : NATURAL := 32;
		larguraLeftPC 	: natural := 26;
		larguraUm : NATURAL := 1;
		larguraCinco : NATURAL := 5;
		larguraSinais : NATURAL := 10;
		simulacao : BOOLEAN := TRUE -- para gravar na placa, altere de TRUE para FALSE
	);
	PORT (
		CLOCK_50 : IN STD_LOGIC;
		WR_Banco : IN STD_LOGIC;
		INSTR : OUT STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0)
	);
END ENTITY;
ARCHITECTURE arquitetura OF Aula15 IS

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
	SIGNAL proxPC	: STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);
	signal leftShift_PC	: std_logic_vector(larguraLeftPC-1 downto 0);

	SIGNAL branchEqual : STD_LOGIC;
	SIGNAL ULA_flipflop : STD_LOGIC;

	SIGNAL Saida_Mux_R3 : STD_LOGIC_VECTOR(larguraDados - 1 DOWNTO 0);

	SIGNAL enable_branchEqual : STD_LOGIC;
	-- sinais de controle (unidade de controle)

	SIGNAL sinaisControle : STD_LOGIC_VECTOR(larguraSinais - 1 DOWNTO 0);

	SIGNAL UC_WRITE_ENABLE : STD_LOGIC;
	SIGNAL UC_READ_ENABLE : STD_LOGIC;
	SIGNAL UC_BEQ : STD_LOGIC;
	SIGNAL UC_MUX_ULAMEM : STD_LOGIC;
	SIGNAL UC_MUX_INSTR : STD_LOGIC;
	SIGNAL UC_OP_ULA : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL UC_MUX_RT_IMED : STD_LOGIC;
	SIGNAL UC_WE_REG : STD_LOGIC;
	SIGNAL UC_MUX_RT_RD : STD_LOGIC;
	SIGNAL UC_MUX_BEQ : STD_LOGIC;

	SIGNAL UC_ULA_CTRL : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

	-- Instanciando os componentes:

	-- clock configurando como borda de subida
	CLK <= CLOCK_50;
	INSTR <= ROM_instru;

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
			seletor_MUX => UC_MUX_INSTR, -- seletor de instrucao R/I (unidade de controle)
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
			estendeSinal_OUT => saidaEstendeSinal
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

	UC_ULA : ENTITY work.ULA_UC
		PORT MAP(
			ULA_OP => UC_OP_ULA,
			funct => ROM_instru(5 DOWNTO 0),
			ULA_CTRL => UC_ULA_CTRL
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

	FLAG_EQ : ENTITY work.flipflopGenerico
		PORT MAP(
			ENABLE => UC_BEQ, -- sinal de controle
			RST => '0',
			CLK => CLK,
			DIN => ULA_flipflop, -- flag_zero ULA
			DOUT => branchEqual-- seletor MUX_BRANCH
		);

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

	--mux que seleciona a entrada de R3
	MUX_R3 : ENTITY work.muxGenerico2x1
		GENERIC MAP(larguraDados => 32)
		PORT MAP(
			entradaA_MUX => Saida_ULA, -- saida ULA
			entradaB_MUX => saidaMemDados, -- saida memoria de dados
			seletor_MUX => UC_MUX_ULAMEM, -- seletor ULA/MEMORIA (unidade de controle)
			saida_MUX => Saida_Mux_R3 -- Dado Lido R3
		);
	-- unidade de controle
	UC : ENTITY work.FD_UC
		PORT MAP(
			op_code => ROM_instru(31 DOWNTO 26),
			sinais_CTRL => sinaisControle
		);

	UC_WRITE_ENABLE <= sinaisControle(0);
	UC_READ_ENABLE <= sinaisControle(1);
	UC_BEQ <= sinaisControle(2);
	UC_MUX_ULAMEM <= sinaisControle(3);
	UC_OP_ULA <= sinaisControle(5 DOWNTO 4);
	UC_MUX_RT_IMED <= sinaisControle(6);
	UC_WE_REG <= sinaisControle(7);
	UC_MUX_RT_RD <= sinaisControle(8);
	UC_MUX_BEQ <= sinaisControle(9);

END ARCHITECTURE;