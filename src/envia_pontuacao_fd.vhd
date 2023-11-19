library ieee;
use ieee.std_logic_1164.all;

entity envia_pontuacao_fd is
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    zera_conta_byte : in  std_logic;
    tx_partida      : in  std_logic;
    conta_byte      : in  std_logic;
    pontuacao       : in  std_logic_vector(11 downto 0); -- nao param
    saida_serial    : out std_logic;
    fim_conta_byte  : out std_logic;
    tx_pronto       : out std_logic 
);
end entity envia_pontuacao_fd;

architecture arch of envia_pontuacao_fd is
    component tx_serial_7O1 is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        partida         : in  std_logic;
        dados_ascii     : in  std_logic_vector(6 downto 0);
        saida_serial    : out std_logic;
        pronto          : out std_logic;
        db_clock        : out std_logic;
        db_tick         : out std_logic;
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(6 downto 0)
    );
    end component;

    component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component;
    
    component codificador_digito_ascii is
    port(
        digito          : in  std_logic_vector(3 downto 0);
        codigo_ascii    : out std_logic_vector(6 downto 0)
    );
    end component;

    signal s_sel_dado   : std_logic_vector(1 downto 0);
    signal s_dado       : std_logic_vector(3 downto 0);
    signal s_dado_ascii : std_logic_vector(6 downto 0);
begin

    CONT_DADO: contador_m
    generic map (
        M => 4, -- nao parametrizado --> 3 dados + # 
        N => 2 
    )
    port map (
        clock => clock,
        zera  => zera_conta_byte, 
        conta => conta_byte,
        Q     => s_sel_dado,
        fim   => fim_conta_byte,
        meio  => open
    );
    with s_sel_dado select
        s_dado <= pontuacao( 3 downto  0) when "00",
                  pontuacao( 7 downto  4) when "01",
                  pontuacao(11 downto  8) when "10",
                  "1010" when others; 
    -- depois do codificador vira 3A -> ":"
    
    COD_ASCII: codificador_digito_ascii
    port map(
        digito => s_dado,
        codigo_ascii => s_dado_ascii
    );

    TX: tx_serial_7O1
    port map(
        clock            => clock,
        reset            => reset,
        partida          => tx_partida,
        dados_ascii      => s_dado_ascii,
        saida_serial     => saida_serial,
        pronto           => tx_pronto,
        db_clock         => open,
        db_tick          => open,
        db_partida       => open,
        db_saida_serial  => open,
        db_estado        => open
    );

end architecture;
