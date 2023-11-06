library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball is
port (
    clock        : in  std_logic;
    reset        : in  std_logic;
    botao1       : in  std_logic;
    botao2       : in  std_logic;
    iniciar      : in  std_logic;
    echo         : in  std_logic;
    pwm_flipper1 : out std_logic;
    pwm_flipper2 : out std_logic;
    trigger      : out std_logic
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
        bola_caiu      : out std_logic
    );
    end component;

    component flip_flop_pinball_uc is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        iniciar        : in  std_logic;
        bola_caiu      : in  std_logic;
        flipper_enable : out std_logic;
        iniciar_detec  : out std_logic
    );
    end component;

    signal s_not_botao1, s_not_botao2 : std_logic;
    signal s_flipper_enable, s_iniciar_detec, s_bola_caiu : std_logic;
begin
    s_not_botao1 <= not botao1;
    s_not_botao2 <= not botao2;

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
        bola_caiu      => s_bola_caiu
    );

    UC: flip_flop_pinball_uc
    port map (
        clock          => clock,
        reset          => reset,
        iniciar        => iniciar,
        bola_caiu      => s_bola_caiu,
        flipper_enable => s_flipper_enable,
        iniciar_detec  => s_iniciar_detec
    );

end architecture;
