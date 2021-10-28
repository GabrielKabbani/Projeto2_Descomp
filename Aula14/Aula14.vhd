library ieee;
use ieee.std_logic_1164.all;

entity Aula14 is
	generic (
		larguraDados 	: natural := 32;
		larguraUm 		: natural := 1;
      simulacao 		: boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
	);
	port (
		CLOCK_50 	: in std_logic;
		OP_ULA 		: in std_logic_vector(1 downto 0);
		WR_Banco 	: in std_logic;
		INSTR 		: out std_logic_vector(larguraDados-1 downto 0)
	);
end entity;


architecture arquitetura of Aula14 is

	signal CLK 				: std_logic;
	signal saidaSOM 		: std_logic_vector(larguraDados-1 downto 0);
	signal PC_out 			: std_logic_vector(larguraDados-1 downto 0);
	signal ROM_instru 	: std_logic_vector(larguraDados-1 downto 0);
	signal Saida_ULA 		: std_logic_vector(larguraDados-1 downto 0);
	signal entradaAULA 	: std_logic_vector(larguraDados-1 downto 0);
	signal entradaBULA 	: std_logic_vector(larguraDados-1 downto 0); 
	signal dadoLidoR2 	: std_logic_vector(larguraDados-1 downto 0);
	signal saidaMemDados : std_logic_vector(larguraDados-1 downto 0);
	signal saidaEstendeSinal : std_logic_vector(larguraDados-1 downto 0);
	
	signal habEscritaR3 : std_logic_vector(larguraDados-1 downto 0);
	signal habEscritaMEM: std_logic_vector(largudaDados-1 downto 0);
	signal habLeituraMEM: std_logic_vector(largudaDados-1 downto 0);
	signal leftShift_Somador: std_logic_vector(largudaDados-1 downto 0);
	
	signal somador_muxBranch	: std_logic_vector(largudaDados-1 downto 0);
	signal branchEqual			: std_logic_vector(largudaDados-1 downto 0);
	signal mux_PC					: std_logic_vector(largudaDados-1 downto 0);
	signal ULA_flipflop			: std_logic_vector(largudaDados-1 downto 0);
	
	signal sinaisControle		: std_logic_vector(larguraSinais-1 downto 0);
	
	signal enable_branchEqual 	: std_logic;
	
	constant larguraSinais : natural := 5 + 4;
	


begin

-- Instanciando os componentes:

-- clock configurando como borda de subida
CLK <= CLOCK_50;
INSTR <= ROM_instru;


PC: entity work.registradorGenerico
	generic map (larguraDados => 32)
   port map (
		DIN 		=> mux_PC, -- saida MUX_BRANCH 
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
			 
Banco_Registradores: entity work.bancoReg
	generic map (larguraDados => 32, larguraEndBancoRegs => 5)
	port map (
		clk				=> CLK,
		enderecoA 		=> ROM_instru(25 downto 21),
		enderecoB 		=> ROM_instru(20 downto 16),
		enderecoC 		=> ROM_instru(20 downto 16),
		escreveC 		=> WR_Banco,
		dadoEscritaC 	=> saidaMemDados,
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

LEFT_SHIFT: entity work.left_shift
	generic map(larguraDados => 32)
	port map(
		input 		=> saidaEstendeSinal,
		output 		=> leftShift_Somador-- somador
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


ULA : entity work.ULASomaSub
	generic map(larguraDados => larguraDados)
	port map (
		entradaA 	=> entradaAULA,
		entradaB 	=> saidaEstendeSinal,
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
		we			 	=> habEscritaMEM,
		re				=> habLeituraMEM
	);


-- unidade de controle
UC: entity work.unidadeDeControle
	generic map(largura_opcode => 6, largura_control => larguraSinais)
	port map(
		op_code	 		=> ROM_instru(31 downto 26),
		sinaisControle => sinaisControle
	);


habEscritaMEM			<= sinaisControle(0);
habLeituraMEM			<= sinaisControle(1);
enable_branchEqual 	<= sinaisControle(2);
OP_ULA					<=	sinaisControle(6 downto 3);
habEscritaR3			<= sinaisControle(7);

end architecture;