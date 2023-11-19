library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7O1 is
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        dado_serial       : in  std_logic;
        dado_recebido0    : out std_logic_vector(6 downto 0);
        dado_recebido1    : out std_logic_vector(6 downto 0);
        paridade_recebida : out std_logic;
        pronto_rx         : out std_logic;
        db_estado         : out std_logic_vector(6 downto 0)
  );
end entity;

architecture estrutural of rx_serial_7O1 is

    component rx_serial_7O1_fd
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
            paridade_recebida   : out std_logic
        );
    end component;

    component rx_serial_uc
        port ( 
            clock       : in  std_logic;
            reset       : in  std_logic;
            dado_serial : in  std_logic;
            tick        : in  std_logic;
            fim         : in  std_logic;
            zera        : out std_logic;
            conta       : out std_logic;
            carrega     : out std_logic;
            desloca     : out std_logic;
            pronto      : out std_logic;
            db_estado   : out std_logic_vector(3 downto 0)
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

    component hexa7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
    end component;
  
    signal s_reset, s_partida : std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim : std_logic;
    signal s_dados_ascii : std_logic_vector(6 downto 0);
    signal s_dados_recebido_1 : std_logic_vector(3 downto 0);
    signal s_estado : std_logic_vector(3 downto 0);

begin

    U1_UC: rx_serial_uc 
    port map (
        clock       => clock, 
        reset       => s_reset, 
--               partida   => s_partida, 
        dado_serial => dado_serial, 
        tick        => s_tick, 
        fim         => s_fim,
        zera        => s_zera, 
        conta       => s_conta, 
        carrega     => s_carrega, 
        desloca     => s_desloca, 
        pronto      => pronto_rx,
        db_estado   => s_estado
    );

    U2_FD: rx_serial_7O1_fd 
    port map (
        clock        => clock, 
        reset        => s_reset, 
        zera         => s_zera, 
        conta        => s_conta, 
        carrega      => s_carrega, 
        desloca      => s_desloca, 
        dados_ascii  => s_dados_ascii, 
        entrada_serial => dado_serial, 
        fim          => s_fim,
        paridade_recebida => paridade_recebida
    );

    U3_TICK: contador_m 
    generic map (
        M => 434, -- 115200 bauds
        N => 13
    ) 
    port map (
        clock => clock, 
        zera  => s_zera, 
        conta => '1', 
        Q     => open, 
        fim   => open, 
        meio  => s_tick
    );

    HEX0: hexa7seg
    port map (
        hexa => s_estado,
        sseg => db_estado
    );
    
    HEX_DADO0: hexa7seg
    port map (
        hexa => s_dados_ascii(3 downto 0),
        sseg => dado_recebido0
    );
    
    s_dados_recebido_1 <= '0' & s_dados_ascii(6 downto 4);

    HEX_DADO1: hexa7seg
    port map (
        hexa => s_dados_recebido_1,
        sseg => dado_recebido1
    );

end architecture;
