library ieee;
use ieee.std_logic_1164.all;

entity Aula15 is
	generic (
		larguraDados 	: natural := 32;
		larguraLeftPC 	: natural := 26;
		larguraUm 		: natural := 1;
		larguraCinco 	: natural := 5;
		larguraSinais  : natural := 5 + 4;
      simulacao 		: boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
	);
	port (
		CLOCK_50 	: in std_logic;
		WR_Banco 	: in std_logic;
		INSTR 		: out std_logic_vector(larguraDados-1 downto 0)
	);
end entity;


architecture arquitetura of Aula15 is

	signal CLK 				: std_logic;
	signal saidaSOM 		: std_logic_vector(larguraDados-1 downto 0);
	signal PC_out 			: std_logic_vector(larguraDados-1 downto 0);
	signal ROM_instru 	: std_logic_vector(larguraDados-1 downto 0);
	signal Saida_ULA 		: std_logic_vector(larguraDados-1 downto 0);
	signal entradaAULA 	: std_logic_vector(larguraDados-1 downto 0);
	signal entradaBULA 	: std_logic_vector(larguraDados-1 downto 0); 
	signal dadoLidoR2 	: std_logic_vector(larguraDados-1 downto 0);
	signal saidaMemDados : std_logic_vector(larguraDados-1 downto 0);
	signal ULA_B : std_logic_vector(larguraDados-1 downto 0);
	signal saidaEstendeSinal 	: std_logic_vector(larguraDados-1 downto 0);
	signal leftShift_Somador	: std_logic_vector(larguraDados-1 downto 0);
	signal leftShift_PC	: std_logic_vector(larguraLeftPC-1 downto 0);
	signal somador_muxBranch	: std_logic_vector(larguraDados-1 downto 0);
	signal mux_PC					: std_logic_vector(larguraDados-1 downto 0);
	signal proxPC					: std_logic_vector(larguraDados-1 downto 0);
	signal OP_ULA		 	: std_logic_vector(3 downto 0);
	signal habEscritaR3 	: std_logic;
	signal MUX_REG			: std_logic_vector(larguraCinco-1 downto 0);
	
	signal zeros : std_logic_vector(larguraUm downto 0);
	
	signal branchEqual			: std_logic;
	signal ULA_flipflop			: std_logic;
	
	signal Saida_Mux_R3					: std_logic_vector(larguraDados-1 downto 0);
	
	signal enable_branchEqual 	: std_logic;
	
	
	-- sinais de controle (unidade de controle)

	signal sinaisControle		: std_logic_vector(larguraSinais-1 downto 0);
	
	signal UC_MUX_INSTR		: std_logic; -- sinal de controle do mux que seleciona as instrucoes
	signal UC_WRITE_ENABLE	: std_logic;
	signal UC_READ_ENABLE	: std_logic;
	signal UC_ULA_CTRL		: std_logic_vector(3 downto 0);
	signal UC_MUX_ULA			: std_logic;
	signal UC_MUX_ULAMEM		: std_logic;
	signal UC_selMuxPC		: std_logic;
	

begin

-- Instanciando os componentes:

-- clock configurando como borda de subida
CLK <= CLOCK_50;
INSTR <= ROM_instru;


PC: entity work.registradorGenerico
	generic map (larguraDados => 32)
   port map (
		DIN 		=> proxPC, -- saida MUX_PC 
		DOUT 		=> PC_out, 
		ENABLE 	=> '1', 
		CLK 		=> CLK, 
		RST 		=> '0'
	);
			 
somador: entity work.somaConstante
	generic map (larguraDados => 32, constante => 4)
   port map (
		entrada	=> PC_out, 
		saida 	=> saidaSOM
	);
		  
-- ROM com instrucoes atualizadas
ROM: entity work.ROMMIPS
	generic map(dataWidth => 32, addrWidth => 32, memoryAddrWidth => 8) -- 256 posicoes de 32 bits cada
   port map (
		clk 		=> CLK,
		Endereco => PC_out, 
		Dado 		=> ROM_instru
	);
	
-- mux que seleciona a intrucao tipo R ou tipo I
MUX_INSTRUCOES: entity work.muxGenerico2x1
	generic map(larguraDados => 5)
	port map(
		entradaA_MUX => ROM_instru(20 downto 16), 	-- Rt
		entradaB_MUX => ROM_instru(15 downto 11), 	-- Rd
		seletor_MUX  => UC_MUX_INSTR, 					-- seletor de instrucao R/I (unidade de controle)
		saida_MUX	 => MUX_REG								-- enderecoC banco de registradores
	);

Banco_Registradores: entity work.bancoReg
	generic map (larguraDados => 32, larguraEndBancoRegs => 5)
	port map (
		clk				=> CLK,
		enderecoA 		=> ROM_instru(25 downto 21),
		enderecoB 		=> ROM_instru(20 downto 16),
		enderecoC 		=> MUX_REG, 
		escreveC 		=> WR_Banco,
		dadoEscritaC 	=> Saida_Mux_R3,
		saidaA 			=> entradaAULA,
		saidaB 			=> dadoLidoR2
	);

-- extensor de sinal
SIG_EXT: entity work.estendeSinalGenerico
	generic map (larguraDadoEntrada => 16, larguraDadoSaida => 32)
	port map(
		estendeSinal_IN 	=> ROM_instru(15 downto 0),
		estendeSinal_OUT	=> saidaEstendeSinal
	);

LEFT_SHIFT: entity work.shift_left
	generic map(larguraDados => 32)
	port map(
		input 		=> saidaEstendeSinal,
		output 		=> leftShift_Somador-- somador
	);
	
	
LEFT_SHIFT_PC: entity work.shift_left
	generic map(larguraDados => 26)
	port map(
		input 		=> ROM_instru(25 downto 0),
		output 		=> leftShift_PC
	);
	
MUX_PROX_PC: entity work.muxGenerico2x1
	generic map(larguraDados => 32)
	port map(
		entradaA_MUX => mux_PC, 	
		entradaB_MUX(31 downto 28) => saidaSOM(31 downto 28),
		entradaB_MUX(27 downto 2) =>	leftShift_PC(25 downto 0),
		entradaB_MUX(1 downto 0) =>	b"00",
		seletor_MUX  => UC_selMuxPC, 					
		saida_MUX	 => proxPC								
	);
	
-- somador
SOMA_DESVIO: entity work.somadorGenerico
	generic map(larguraDados => 32)
	port map(
		entradaA		=> saidaSOM, --
		entradaB		=> leftShift_Somador, --
		saida			=>	somador_muxBranch
	);

	
MUX_BRANCH: entity work.muxGenerico2x1
	generic map(larguraDados => 32)
	port map(
		entradaA_MUX => saidaSOM, -- saida pc
		entradaB_MUX => somador_muxBranch, -- saida somaConstante
		seletor_MUX  => branchEqual, -- saida flipflop		
		saida_MUX	 => mux_PC
	);

-- mux que seleciona a entrada B da ULA
MUX_ULA: entity work.muxGenerico2x1
	generic map(larguraDados => 32)
	port map(
		entradaA_MUX => dadoLidoR2, 			-- Saida R2
		entradaB_MUX => saidaEstendeSinal, 	-- extensor de sinal
		seletor_MUX  => UC_MUX_ULA, 			-- seletedor Rt/Imediato (unidade de controle)
		saida_MUX	 => ULA_B	-- entrada B da ULA
	);

ULA : entity work.ULASomaSub
	generic map(larguraDados => larguraDados)
	port map (
		entradaA 	=> entradaAULA,
		entradaB 	=> ULA_B,
		saida 		=> Saida_ULA,
		seletor 		=> OP_ULA,
		flag_zero  	=> ULA_flipflop
	);

FLAG_EQ: entity work.flipflopGenerico
	port map(
		ENABLE	=> enable_branchEqual, -- sinal de controle
		RST		=> '0',
		CLK		=> CLK, 
		DIN		=> ULA_flipflop, -- flag_zero ULA
		DOUT		=> branchEqual-- seletor MUX_BRANCH
	);
	
-- memoria dados
MEMORIA_DADOS: entity work.RAMMIPS
	generic map(dataWidth => 32, addrWidth => 32, memoryAddrWidth => 8)   -- 256 posicoes de 32 bits cada
	port map (
		clk       	=> CLK,
		Endereco  	=> Saida_ULA,
		Dado_in   	=> dadoLidoR2,
		Dado_out  	=> saidaMemDados,
		we			 	=> UC_WRITE_ENABLE,
		re				=> UC_READ_ENABLE
	);
	
 --mux que seleciona a entrada de R3
MUX_R3: entity work.muxGenerico2x1
	generic map(larguraDados => 32)
	port map(
		entradaA_MUX => Saida_ULA, 	-- saida ULA
		entradaB_MUX => saidaMemDados, 	-- saida memoria de dados
		seletor_MUX  => UC_MUX_ULAMEM, 	-- seletor ULA/MEMORIA (unidade de controle)
		saida_MUX	 => Saida_Mux_R3		-- Dado Lido R3
	);


-- unidade de controle
--UC: entity work.unidadeDeControle
--	generic map(largura_opcode => 6, largura_control => larguraSinais)
--	port map(
--		op_code	 		=> ROM_instru(31 downto 26),
--		sinaisControle => sinaisControle
--	);


-- UC_MUX_ULA			<= sinaisControle(?);
UC_WRITE_ENABLE		<= sinaisControle(0);
UC_READ_ENABLE			<= sinaisControle(1);
enable_branchEqual 	<= sinaisControle(2);
UC_ULA_CTRL				<=	sinaisControle(6 downto 3);
habEscritaR3			<= sinaisControle(7);

end architecture;