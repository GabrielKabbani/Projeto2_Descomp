library ieee;
use ieee.std_logic_1164.all;

entity Aula13 is
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


architecture arquitetura of Aula13 is

	signal CLK 				: std_logic;
	signal saidaSOM 		: std_logic_vector(larguraDados-1 downto 0);
	signal PC_out 			: std_logic_vector(larguraDados-1 downto 0);
	signal ROM_instru 	: std_logic_vector(larguraDados-1 downto 0);
	signal Saida_ULA 		: std_logic_vector(larguraDados-1 downto 0);
	signal entradaAULA 	: std_logic_vector(larguraDados-1 downto 0);
	signal entradaBULA 	: std_logic_vector(larguraDados-1 downto 0);


begin

-- Instanciando os componentes:

-- clock configurando como borda de subida
CLK <= CLOCK_50;
INSTR <= ROM_instru;


PC: entity work.registradorGenerico
	generic map (larguraDados => 32)
   port map (
		DIN 		=> saidaSOM, 
		DOUT 		=> PC_out, 
		ENABLE 	=> '1', 
		CLK 		=> CLK, 
		RST 		=> '0'
	);
			 
somador: entity work.somaConstante
	generic map (larguraDados => 32, constante => 1)
   port map (
		entrada	=> PC_out, 
		saida 	=> saidaSOM
	);
		  
-- ROM com instrucoes atualizadas
ROM: entity work.ROMMIPS
	generic map (dataWidth => 32, addrWidth => 32, memoryAddrWidth => 8)
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
		enderecoC 		=> ROM_instru(15 downto 11),
		escreveC 		=> WR_Banco,
		dadoEscritaC 	=> Saida_ULA,
		saidaA 			=> entradaAULA,
		saidaB 			=> entradaBULA
	);
		  
		  
ULA : entity work.ULASomaSub
	generic map(larguraDados => larguraDados)
	port map (
		entradaA 	=> entradaAULA,
		entradaB 	=> entradaBULA,
		saida 		=> Saida_ULA,
		seletor 		=> OP_ULA
		-- flag_zero  	=>   -- desnecessaria ate que seja implementada a operacao de "EQ"
	);




end architecture;