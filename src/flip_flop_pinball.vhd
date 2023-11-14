library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball is
port (
    clock                   : in  std_logic;
    reset                   : in  std_logic;
    botao1                  : in  std_logic;
    botao2                  : in  std_logic;
    iniciar                 : in  std_logic;
    echo                    : in  std_logic;
    pwm_flipper1            : out std_logic;
    pwm_flipper2            : out std_logic;
    trigger                 : out std_logic;
    db_estado               : out std_logic_vector(6 downto 0);
    db_detector_bola_estado : out std_logic_vector(6 downto 0);
    db_bola_caiu            : out std_logic
);
end entity flip_flop_pinball;

architecture arch of flip_flop_pinball is
    component flip_flop_pinball_fd is
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
        bola_caiu      : out std_logic;
        db_detector_bola_estado : out std_logic_vector(3 downto 0)
    );
    end component;

    component flip_flop_pinball_uc is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        iniciar        : in  std_logic;
        bola_caiu      : in  std_logic;
        flipper_enable : out std_logic;
        iniciar_detec  : out std_logic;
        db_estado      : out std_logic_vector(3 downto 0)
    );
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;

    component edge_detector is
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            sinal  : in  std_logic;
            pulso  : out std_logic
        );
    end component edge_detector;

    signal s_not_botao1, s_not_botao2, s_not_iniciar, s_iniciar_edge : std_logic;
    signal s_flipper_enable, s_iniciar_detec, s_bola_caiu : std_logic;
    signal s_db_estado : std_logic_vector(3 downto 0);
    signal s_db_detector_bola_estado : std_logic_vector(3 downto 0);
begin
    s_not_botao1 <= not botao1;
    s_not_botao2 <= not botao2;
    s_not_iniciar <= not iniciar;

    EDGE_INIC: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => s_not_iniciar,
        pulso => s_iniciar_edge
    );

    FD: flip_flop_pinball_fd
    port map (
        clock          => clock,
        reset          => reset,
        posicao_servo1 => s_not_botao1,
        posicao_servo2 => s_not_botao2,
        pwm_flipper1   => pwm_flipper1,
        pwm_flipper2   => pwm_flipper2,
        flipper_enable => s_flipper_enable,
        echo           => echo,
        iniciar_detec  => s_iniciar_detec,
        trigger        => trigger,
        bola_caiu      => s_bola_caiu,
        db_detector_bola_estado => s_db_detector_bola_estado
    );

    UC: flip_flop_pinball_uc
    port map (
        clock          => clock,
        reset          => reset,
        iniciar        => s_iniciar_edge,
        bola_caiu      => s_bola_caiu,
        flipper_enable => s_flipper_enable,
        iniciar_detec  => s_iniciar_detec,
        db_estado      => s_db_estado
    );

    HEX_ESTADO: hexa7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );

    HEX_ESTADO_DETEC_BOLA: hexa7seg
    port map (
        hexa => s_db_detector_bola_estado,
        sseg => db_detector_bola_estado
    );

    db_bola_caiu <= s_bola_caiu;
end architecture;
