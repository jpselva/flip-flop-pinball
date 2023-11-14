library ieee;
use ieee.std_logic_1164.all;

entity comunicacao_serial_fd is
generic (
    constant max_points_value : integer := 1000;
    constant max_points_N     : integer := 10
);
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    zera_conta_byte : in  std_logic;
    tx_partida      : in  std_logic;
    conta_byte      : in  std_logic;
    pontuacao       : in  std_logic_vector(max_points_N-1 downto 0);
    saida_serial    : out std_logic;
    fim_conta_byte  : out std_logic;
    tx_pronto       : out std_logic 
);

architecture arch of comunicacao_serial is
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

    siganl s_sel_dado : std_logic;
    signal s_dado_enviado : std_logic_vector(6 downto 0);
begin
    TX: tx_serial_7O1
    port map(
        clock            => clock,
        reset            => reset
        partida          => enviar_dados,
        dados_ascii      => s_dado_ascii,
        saida_serial     => saida_serial,
        pronto           => tx_pronto,
        db_clock         => open,
        db_tick          => open,
        db_partida       => open,
        db_saida_serial  => open,
        db_estado        => open
    );
    CONT_DADO: contador_m
    generic map (
        M =>  
        N => 
    );
    port map (
        clock => clock,
        zera  => zera_conta_byte, 
        conta => conta_byte,
        Q     => s_sel_dado,
        fim   => open,
        meio  => open
    );

    COD_ASCII0: codificador_digito_ascii
    port map(
        digito => s_dado_enviado,
        codigo_ascii => s_dado_ascii
    );


end architecture;
