library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball is
port (
    clock                   : in  std_logic;
    reset                   : in  std_logic;
    iniciar                 : in  std_logic;

    -- flipper buttons
    botao1                  : in  std_logic;
    botao2                  : in  std_logic;

    -- servos
    pwm_flipper1            : out std_logic;
    pwm_flipper2            : out std_logic;

    -- hcsr04 sensor
    echo                    : in  std_logic;
    trigger                 : out std_logic;

    -- debug
    db_estado               : out std_logic_vector(6 downto 0);
    db_detector_bola_estado : out std_logic_vector(6 downto 0);
    db_bola_caiu            : out std_logic;

    -- pontuacao
    alvos                     : in  std_logic_vector(3 downto 0);
    pontos0, pontos1, pontos2 : out std_logic_vector(6 downto 0);
    
    -- envio serial
    saida_serial            : out std_logic;
    db_saida_serial         : out std_logic
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
        echo                    : in  std_logic;
        iniciar_detec           : in  std_logic;
        trigger                 : out std_logic;
        bola_caiu               : out std_logic;
        db_detector_bola_estado : out std_logic_vector(3 downto 0);

        -- scoring
        alvos              : in  std_logic_vector(7 downto 0);
        ponto_feito        : out std_logic;
        conta_cont_pontos  : in  std_logic;
        zera_cont_pontos   : in  std_logic;
        conta_cont_alvo    : in  std_logic;
        zera_cont_alvo     : in  std_logic;
        fim_cont_alvo      : out std_logic;
        registra_cont_alvo : in  std_logic;
        pontos0, pontos1, pontos2 : out std_logic_vector(3 downto 0);

        -- rodada
        zera_cont_rodada  : in  std_logic;
        conta_cont_rodada : in  std_logic;
        fim_cont_rodada   : out std_logic;

        -- envio serial
        envia_dados       : in  std_logic;
        saida_serial      : out std_logic
    );
    end component flip_flop_pinball_fd;

    component flip_flop_pinball_uc is
    port (
        clock              : in  std_logic;
        reset              : in  std_logic;
        iniciar            : in  std_logic;
        bola_caiu          : in  std_logic;
        ponto_feito        : in  std_logic;
        fim_cont_alvo      : in  std_logic;
        fim_cont_rodada    : in  std_logic;

        flipper_enable     : out std_logic;
        iniciar_detec      : out std_logic;
        conta_cont_pontos  : out std_logic;
        zera_cont_pontos   : out std_logic;
        conta_cont_alvo    : out std_logic;
        zera_cont_alvo     : out std_logic;
        registra_cont_alvo : out std_logic;
        db_estado          : out std_logic_vector(3 downto 0);
        zera_cont_rodada   : out std_logic;
        conta_cont_rodada  : out std_logic;
        envia_dados        : out std_logic
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
    signal s_not_reset : std_logic;
    signal s_db_detector_bola_estado : std_logic_vector(3 downto 0);
    signal s_bola_caiu          : std_logic;
    signal s_ponto_feito        : std_logic;
    signal s_fim_cont_alvo      : std_logic;
    signal s_fim_cont_rodada    : std_logic;
    signal s_flipper_enable     : std_logic;
    signal s_iniciar_detec      : std_logic;
    signal s_conta_cont_pontos  : std_logic;
    signal s_zera_cont_pontos   : std_logic;
    signal s_conta_cont_alvo    : std_logic;
    signal s_zera_cont_alvo     : std_logic;
    signal s_registra_cont_alvo : std_logic;
    signal s_db_estado          : std_logic_vector(3 downto 0);
    signal s_zera_cont_rodada   : std_logic;
    signal s_conta_cont_rodada  : std_logic;
    signal s_alvos              : std_logic_vector(7 downto 0);
    signal s_pontos0_bcd, s_pontos1_bcd, s_pontos2_bcd : std_logic_vector(3 downto 0);
    signal s_envia_dados        : std_logic;
    signal s_saida_serial       : std_logic;

begin
    s_not_botao1  <= not botao1;
    s_not_botao2  <= not botao2;
    s_not_iniciar <= not iniciar;
    s_not_reset   <= not reset;

    -- FILL UNUSED TARGETS WITH '0':
    s_alvos <= "0000" & alvos;

    EDGE_INIC: edge_detector
    port map (
        clock => clock,
        reset => s_not_reset,
        sinal => s_not_iniciar,
        pulso => s_iniciar_edge
    );

    FD: flip_flop_pinball_fd
    port map (
        clock              => clock,
        reset              => s_not_reset,
        posicao_servo1     => s_not_botao1,
        posicao_servo2     => s_not_botao2,
        pwm_flipper1       => pwm_flipper1,
        pwm_flipper2       => pwm_flipper2,
        flipper_enable     => s_flipper_enable,
        echo               => echo,
        iniciar_detec      => s_iniciar_detec,
        trigger            => trigger,
        bola_caiu          => s_bola_caiu,
        alvos              => s_alvos,
        ponto_feito        => s_ponto_feito,
        conta_cont_pontos  => s_conta_cont_pontos,
        zera_cont_pontos   => s_zera_cont_pontos,
        conta_cont_alvo    => s_conta_cont_alvo,
        zera_cont_alvo     => s_zera_cont_alvo,
        fim_cont_alvo      => s_fim_cont_alvo,
        registra_cont_alvo => s_registra_cont_alvo,
        pontos0            => s_pontos0_bcd,
        pontos1            => s_pontos1_bcd,
        pontos2            => s_pontos2_bcd,
        zera_cont_rodada   => s_zera_cont_rodada,
        conta_cont_rodada  => s_conta_cont_rodada,
        fim_cont_rodada    => s_fim_cont_rodada,
	envia_dados        => s_envia_dados,
	saida_serial       => s_saida_serial,
        db_detector_bola_estado => s_db_detector_bola_estado
    );

    UC: flip_flop_pinball_uc
    port map (
        clock              => clock,
        reset              => s_not_reset,
        iniciar            => s_iniciar_edge,
        bola_caiu          => s_bola_caiu,
        ponto_feito        => s_ponto_feito,
        fim_cont_alvo      => s_fim_cont_alvo,
        fim_cont_rodada    => s_fim_cont_rodada,
        flipper_enable     => s_flipper_enable,
        iniciar_detec      => s_iniciar_detec,
        conta_cont_pontos  => s_conta_cont_pontos,
        zera_cont_pontos   => s_zera_cont_pontos,
        conta_cont_alvo    => s_conta_cont_alvo,
        zera_cont_alvo     => s_zera_cont_alvo,
        registra_cont_alvo => s_registra_cont_alvo,
        db_estado          => s_db_estado,
        zera_cont_rodada   => s_zera_cont_rodada,
        conta_cont_rodada  => s_conta_cont_rodada,
	envia_dados        => s_envia_dados
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

    HEX_PONTO0: hexa7seg
    port map (
        hexa => s_pontos0_bcd,
        sseg => pontos0
    );

    HEX_PONTO1: hexa7seg
    port map (
        hexa => s_pontos1_bcd,
        sseg => pontos1
    );

    HEX_PONTO2: hexa7seg
    port map (
        hexa => s_pontos2_bcd,
        sseg => pontos2
    );

 

    db_bola_caiu <= s_bola_caiu;
    saida_serial    <= s_saida_serial;
    db_saida_serial <= s_saida_serial;

end architecture;
