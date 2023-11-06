library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball_fd is
port (
    clock          : in  std_logic;
    reset          : in  std_logic;

    -- flippers
    posicao_servo1 : in  std_logic;
    posicao_servo2 : in  std_logic;
    pwm_flipper1   : out std_logic;
    pwm_flipper2   : out std_logic;
    flipper_enable : in  std_logic;

    -- ball detection
    echo           : in  std_logic;
    iniciar_detec  : in  std_logic;
    trigger        : out std_logic;
    bola_caiu      : out std_logic
);
end entity flip_flop_pinball_fd;

architecture arch of flip_flop_pinball_fd is
    component controle_servo is
        port (
            clock    : in std_logic;
            reset    : in std_logic;
            posicao  : in std_logic_vector(1 downto 0);
            controle : out std_logic
        );
    end component;

    component detector_bola is
    generic (
        timeout_ciclos : natural := 25000; -- quantos ciclos ate timeout
        dist_min_cm    : natural := 30  -- distancia minima para detectar bola
    );
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        iniciar   : in  std_logic;
        echo      : in  std_logic;
        bola_caiu : out std_logic;
        trigger   : out std_logic
    );
    end component;

    signal s_pwm_flipper1, s_pwm_flipper2 : std_logic;
    signal posicao_servo1_full, posicao_servo2_full : std_logic_vector(1 downto 0);
begin
    posicao_servo1_full <= '0' & posicao_servo1;
    pwm_flipper1 <= s_pwm_flipper1 and flipper_enable;
    SERVO1: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo1_full,
        controle => s_pwm_flipper1
    );

    posicao_servo2_full <= '0' & posicao_servo2;
    pwm_flipper2 <= s_pwm_flipper2 and flipper_enable;
    SERVO2: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo2_full,
        controle => s_pwm_flipper2
    );

    DETECT: detector_bola
    generic map (
        timeout_ciclos => 25000, -- quantos ciclos ate timeout
        dist_min_cm    => 30     -- distancia minima para detectar bola
    )
    port map (
        clock     => clock,
        reset     => reset,
        iniciar   => iniciar_detec,
        echo      => echo,
        bola_caiu => bola_caiu,
        trigger   => trigger
    );
end architecture;
