library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity flip_flop_pinball_fd is
generic (
    constant max_points_value : integer := 1000;
    constant max_points_N     : integer :=   10
);
port (
    clock          : in  std_logic;
    reset          : in  std_logic;

    -- flippers
    posicao_servo1 : in  std_logic;
    posicao_servo2 : in  std_logic;
    pwm_flipper1   : out std_logic;
    pwm_flipper2   : out std_logic;
    game_enable    : in  std_logic;

    -- ball detection
    echo           : in  std_logic;
    iniciar_detec  : in  std_logic;
    trigger        : out std_logic;
    bola_caiu      : out std_logic;
    db_detector_bola_estado : out std_logic_vector(3 downto 0);

    -- points scoring
    reset_pontuacao : in  std_logic;
    ponto1          : in  std_logic;
    ponto2          : in  std_logic;
    ponto3          : in  std_logic;
    pontuacao       : out std_logic_vector(max_points_N-1 downto 0)
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
    end component;

    component contador_multiplo is
    generic (
        constant M   : integer := 1000;  
        constant N   : integer :=   10;
        constant c1_v: integer :=    1;
        constant c2_v: integer :=   10;
        constant c3_v: integer :=  100
    );
    port (
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta_1 : in  std_logic;
        conta_2 : in  std_logic;
        conta_3 : in  std_logic;
        Q       : out std_logic_vector (N-1 downto 0)
    );
    end component;
    
    signal s_pwm_flipper1, s_pwm_flipper2 : std_logic;
    signal posicao_servo1_full, posicao_servo2_full : std_logic_vector(1 downto 0);
    signal s_ponto1, s_ponto2, s_ponto3: std_logic;
begin
    posicao_servo1_full <= '0' & (posicao_servo1 and game_enable);
    pwm_flipper1 <= s_pwm_flipper1;
    SERVO1: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo1_full,
        controle => s_pwm_flipper1
    );

    posicao_servo2_full <= '0' & (posicao_servo2 and game_enable);
    pwm_flipper2 <= s_pwm_flipper2;
    SERVO2: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo2_full,
        controle => s_pwm_flipper2
    );

    DETECT: detector_bola
    generic map (
        timeout_ciclos => 25000000, -- quantos ciclos ate timeout
        dist_min_cm    => 15     -- distancia minima para detectar bola
    )
    port map (
        clock     => clock,
        reset     => reset,
        iniciar   => iniciar_detec,
        echo      => echo,
        bola_caiu => bola_caiu,
        trigger   => trigger,
        db_estado => db_detector_bola_estado
    );

    s_ponto1 <= ponto1 and game_enable;
    s_ponto2 <= ponto2 and game_enable;
    s_ponto3 <= ponto3 and game_enable;
    POINTS: contador_multiplo
    generic map(
        M    => max_points_value,
        N    => max_points_N,
        c1_v =>   1,
        c2_v =>  10,
        c3_v => 100
    )
    port map(
        clock    => clock, 
        zera     => reset_pontuacao,
        conta_1  => s_ponto1,
        conta_2  => s_ponto2, 
        conta_3  => s_ponto3,
        Q        => pontuacao 
    );

end architecture;
