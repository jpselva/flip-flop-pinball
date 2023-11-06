library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity detector_bola_fd is
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
end entity;

architecture arch of detector_bola_fd is
    component interface_hcsr04 is
        port (
            clock     : in std_logic;
            reset     : in std_logic;
            medir     : in std_logic;
            echo      : in std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- valor em cm
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component contador_m is
        generic (
            constant M : integer;
            constant N : integer
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

    signal s_reset_medidor : std_logic;
    signal s_medida        : std_logic_vector(11 downto 0);
begin
    CONT_TIMEOUT: contador_m
    generic map (
        M => timeout_ciclos,
        N => natural(ceil(log2(real(timeout_ciclos))))
    )
    port map (
        clock => clock,
        zera  => zera_timeout,
        conta => conta_timeout,
        Q     => open,
        fim   => fim_timeout,
        meio  => open
    );

    s_reset_medidor <= reset or reset_medidor;
    MEDIDOR: interface_hcsr04
    port map (
        clock     => clock,
        reset     => s_reset_medidor,
        medir     => medir,
        echo      => echo,
        trigger   => trigger,
        medida    => s_medida,
        pronto    => medida_pronta,
        db_estado => open
    );

    bola_proxima <= '1' when to_integer(unsigned(s_medida)) < dist_min_cm else 
                    '0';
end architecture;
