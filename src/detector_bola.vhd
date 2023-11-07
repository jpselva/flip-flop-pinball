library ieee;
use ieee.std_logic_1164.all;

entity detector_bola is
generic (
    timeout_ciclos : natural := 25000000; -- quantos ciclos ate timeout
    dist_min_cm    : natural := 30  -- distancia minima para detectar bola
);
port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    iniciar   : in  std_logic;
    echo      : in  std_logic;
    bola_caiu : out std_logic;
    trigger   : out std_logic;
    db_estado : out std_logic_vector(3 downto 0)
);
end entity;

architecture arch of detector_bola is
    component detector_bola_uc is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        iniciar        : in  std_logic;
        medida_pronta  : in  std_logic;
        fim_timeout    : in  std_logic;
        bola_proxima   : in  std_logic;
        conta_timeout  : out std_logic;
        zera_timeout   : out std_logic;
        reset_medidor  : out std_logic;
        medir          : out std_logic;
        bola_caiu      : out std_logic;
        db_estado      : out std_logic_vector(3 downto 0)
    );
    end component;

    component detector_bola_fd is
    generic (
        timeout_ciclos : natural; -- quantos ciclos ate timeout
        dist_min_cm    : natural  -- distancia minima para detectar bola
    );
    port (
        clock         : in  std_logic;
        reset         : in  std_logic;
        conta_timeout : in  std_logic;
        zera_timeout  : in  std_logic;
        reset_medidor : in  std_logic;
        medir         : in  std_logic;
        echo          : in  std_logic;
        medida_pronta : out std_logic;
        fim_timeout   : out std_logic;
        bola_proxima  : out std_logic;
        trigger       : out std_logic
    );
    end component;

    signal s_conta_timeout, s_zera_timeout, s_reset_medidor, s_medir, 
           s_medida_pronta, s_fim_timeout, s_bola_proxima, 
           s_trigger : std_logic;
begin
    FD: detector_bola_fd
    generic map (
        timeout_ciclos => timeout_ciclos,
        dist_min_cm    => dist_min_cm
    )
    port map (
        clock         => clock,
        reset         => reset,
        conta_timeout => s_conta_timeout,
        zera_timeout  => s_zera_timeout,
        reset_medidor => s_reset_medidor,
        medir         => s_medir,
        echo          => echo,
        medida_pronta => s_medida_pronta,
        fim_timeout   => s_fim_timeout,
        bola_proxima  => s_bola_proxima,
        trigger       => trigger
    );

    UC: detector_bola_uc
    port map (
        clock         => clock,
        reset         => reset,
        iniciar       => iniciar,
        medida_pronta => s_medida_pronta,
        fim_timeout   => s_fim_timeout,
        bola_proxima  => s_bola_proxima,
        conta_timeout => s_conta_timeout,
        zera_timeout  => s_zera_timeout,
        reset_medidor => s_reset_medidor,
        medir         => s_medir,
        bola_caiu     => bola_caiu,
        db_estado     => db_estado
    );
end architecture;
