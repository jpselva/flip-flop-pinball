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
    ponto1                  : in  std_logic;
    ponto2                  : in  std_logic;
    ponto3                  : in  std_logic;
    pwm_flipper1            : out std_logic;
    pwm_flipper2            : out std_logic;
    trigger                 : out std_logic;
    db_estado               : out std_logic_vector(6 downto 0);
    db_detector_bola_estado : out std_logic_vector(6 downto 0);
    db_pontuacao1           : out std_logic_vector(6 downto 0);
    db_pontuacao2           : out std_logic_vector(6 downto 0);
    db_pontuacao3           : out std_logic_vector(6 downto 0);
    db_bola_caiu            : out std_logic
);
end entity flip_flop_pinball;

architecture arch of flip_flop_pinball is
    component flip_flop_pinball_fd is
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
        reset_pontuacao : in std_logic;
        ponto1          : in  std_logic;
        ponto2          : in  std_logic;
        ponto3          : in  std_logic;
        pontuacao       : out std_logic_vector(max_points_N-1 downto 0)
    );
    end component;

    component flip_flop_pinball_uc is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        iniciar         : in  std_logic;
        bola_caiu       : in  std_logic;
        reset_pontuacao : out std_logic;
        game_enable     : out std_logic;
        iniciar_detec   : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
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
    signal s_game_enable, s_iniciar_detec, s_bola_caiu : std_logic;
    signal s_db_estado : std_logic_vector(3 downto 0);
    signal s_db_detector_bola_estado : std_logic_vector(3 downto 0);
    signal s_ponto1, s_ponto2, s_ponto3 : std_logic;
    signal s_not_ponto1, s_not_ponto2, s_not_ponto3 : std_logic;
    signal s_ponto1_edge, s_ponto2_edge, s_ponto3_edge : std_logic;
    signal s_reset_pontuacao : std_logic;
    signal s_pontuacao : std_logic_vector(9 downto 0);
    signal s_pontuacao1, s_pontuacao2, s_pontuacao3 : std_logic_vector(3 downto 0);
begin
    s_not_botao1  <= not botao1;
    s_not_botao2  <= not botao2;
    s_not_ponto1  <= not ponto1;
    s_not_ponto2  <= not ponto2;
    s_not_ponto3  <= not ponto3;
    s_not_iniciar <= not iniciar;

    EDGE_INIC: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => s_not_iniciar,
        pulso => s_iniciar_edge
    );
    EDGE_PONT1: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => ponto1,
        pulso => s_ponto1_edge
    );

    EDGE_PONT2: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => ponto2,
        pulso => s_ponto2_edge
    );

    EDGE_PONT3: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => ponto3,
        pulso => s_ponto3_edge
    );

    FD: flip_flop_pinball_fd
    generic map(
        max_points_value => 1000,
        max_points_N => 10
    )
    port map (
        clock          => clock,
        reset          => reset,
        posicao_servo1 => s_not_botao1,
        posicao_servo2 => s_not_botao2,
        pwm_flipper1   => pwm_flipper1,
        pwm_flipper2   => pwm_flipper2,
        game_enable    => s_game_enable,
        echo           => echo,
        iniciar_detec  => s_iniciar_detec,
        trigger        => trigger,
        bola_caiu      => s_bola_caiu,
        db_detector_bola_estado => s_db_detector_bola_estado,
        reset_pontuacao => s_reset_pontuacao,
	ponto1         => s_ponto1_edge,
        ponto2         => s_ponto2_edge,
        ponto3         => s_ponto3_edge,
        pontuacao      => s_pontuacao
    );

    UC: flip_flop_pinball_uc
    port map (
        clock           => clock,
        reset           => reset,
        iniciar         => s_iniciar_edge,
        bola_caiu       => s_bola_caiu,
        game_enable     => s_game_enable,
        iniciar_detec   => s_iniciar_detec,
	reset_pontuacao => s_reset_pontuacao,
        db_estado       => s_db_estado
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

    s_pontuacao1 <= s_pontuacao(3 downto 0);
    s_pontuacao2 <= s_pontuacao(7 downto 4);
    s_pontuacao3 <= "00"&s_pontuacao(9 downto 8);
    
    HEX_PONTUACAO1: hexa7seg
    port map (
        hexa => s_pontuacao1,
        sseg => db_pontuacao1
    );

    HEX_PONTUACAO2: hexa7seg
    port map (
        hexa => s_pontuacao2,
        sseg => db_pontuacao2
    );

    HEX_PONTUACAO3: hexa7seg
    port map (
        hexa => s_pontuacao3,
        sseg => db_pontuacao3
    );

end architecture;
