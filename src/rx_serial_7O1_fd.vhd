------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1_fd.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
-- > implementa configuracao 7O1
-- > 
-- > bit de paridade calculada usando portas XOR (veja linha 76)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao

------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    port (
        clock               : in  std_logic;
        reset               : in  std_logic;
        zera                : in  std_logic;
        conta               : in  std_logic;
        carrega             : in  std_logic;
        desloca             : in  std_logic;
        entrada_serial      : in  std_logic;
        dados_ascii         : out std_logic_vector(6 downto 0);
        fim                 : out std_logic;
        paridade_recebida  : out std_logic
    );
end entity;

architecture rx_serial_7O1_fd_arch of rx_serial_7O1_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector(N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component;
    
    signal s_saida: std_logic_vector(9 downto 0);

begin
    U1: deslocador_n 
        generic map (
            N => 10
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => entrada_serial, 
            dados          => "0000000000", 
            saida          => s_saida
        );

    U2: contador_m 
        generic map (
            M => 12, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim, 
            meio  => open
        );

    dados_ascii <= s_saida(6 downto 0);
    paridade_recebida <= s_saida(7);
    
end architecture;

