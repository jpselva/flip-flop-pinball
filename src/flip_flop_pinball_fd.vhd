library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    sel_dado          : in  std_logic_vector(2 downto 0);
    saida_serial      : out std_logic
);
end entity flip_flop_pinball_fd;

architecture arch of flip_flop_pinball_fd is
    component controle_servo is
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        posicao  : in  std_logic_vector(1 downto 0);
        controle : out std_logic
    );
    end component;

    component detector_bola is
    generic (
        timeout_ciclos : natural;
        dist_min_cm    : natural
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

    component detector_pontos is
    generic (
        cooldown_ciclos : natural
    );
    port (
        clock : in std_logic;
        reset : in std_logic;
        alvos : in std_logic_vector(7 downto 0);
        ponto_feito   : out std_logic; 
        alvo_acertado : out std_logic_vector(2 downto 0)
    );
    end component detector_pontos;

    component contador_q is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock    : in  std_logic;
        zera     : in  std_logic;
        conta    : in  std_logic;
        registra : in std_logic;
        D     : in  std_logic_vector (N-1 downto 0);
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component contador_q;

    component contador_bcd_3digitos is 
        port ( 
            clock   : in  std_logic;
            zera    : in  std_logic;
            conta   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic
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

    component envia_pontuacao is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        envia_dados     : in  std_logic;
        pontuacao       : in  std_logic_vector(11 downto 0);
        sel_dado        : in  std_logic_vector( 2 downto 0);
        saida_serial    : out std_logic;
        fim_envio       : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
    end component;

    signal s_pwm_flipper1, s_pwm_flipper2 : std_logic;
    signal posicao_servo1_full, posicao_servo2_full : std_logic_vector(1 downto 0);
    -- numero de bits necessarios para identificar 1 alvo
    constant n_bits_alvo       : integer := 3;
    -- numero de bits necessarios para quantificar valor de um alvo
    constant n_bits_valor_alvo : integer := 8;

    signal s_alvo_acertado : std_logic_vector(n_bits_alvo - 1 downto 0);
    signal s_valor_alvo    : std_logic_vector(n_bits_valor_alvo-1 downto 0);
    signal s_pontos0, s_pontos1, s_pontos2    : std_logic_vector(3 downto 0);
    signal s_pontuacao    : std_logic_vector(11 downto 0);

begin
    posicao_servo1_full <= '0' & (posicao_servo1 and flipper_enable);
    pwm_flipper1 <= s_pwm_flipper1;
    SERVO1: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo1_full,
        controle => s_pwm_flipper1
    );

    posicao_servo2_full <= '0' & (posicao_servo2 and flipper_enable);
    pwm_flipper2 <= s_pwm_flipper2;
    SERVO2: controle_servo
    port map (
        clock    => clock,
        reset    => reset,
        posicao  => posicao_servo2_full,
        controle => s_pwm_flipper2
    );

    DET_BOLA: detector_bola
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

    DET_PONTOS: detector_pontos
    generic map (
        cooldown_ciclos => 5000000
    )
    port map (
        clock         => clock,
        reset         => reset,
        alvos         => alvos,
        ponto_feito   => ponto_feito,
        alvo_acertado => s_alvo_acertado
    );

    CONT_ALVO: contador_q
    generic map (
        M  => 200,
        N  => n_bits_valor_alvo
    )
    port map (
        clock    => clock,
        conta    => conta_cont_alvo,
        zera     => zera_cont_alvo,
        registra => registra_cont_alvo,
        D        => s_valor_alvo,
        Q        => open,
        fim      => fim_cont_alvo,
        meio     => open
    );

    CONT_PONTOS: contador_bcd_3digitos
    port map (
        clock    => clock,
        zera     => zera_cont_pontos,
        conta    => conta_cont_pontos,
        digito0  => s_pontos0,
        digito1  => s_pontos1,
        digito2  => s_pontos2
    );

    pontos0 <= s_pontos0;
    pontos1 <= s_pontos1;
    pontos2 <= s_pontos2;

    -- SET SCORES BELOW
    -- ALWAYS SUBTRACT 1 FROM SCORE WHEN WRITING IT HERE
    -- (the counter counts down to 0, including 0, so it adds 1 extra cycle)
    with s_alvo_acertado select s_valor_alvo <=
        "00000100" when "000",
        "00001000" when "001",
        "00010000" when "010",
        "00100000" when "011",
        "01000000" when "100",
        "10000000" when "101",
        "10000000" when "110",
        "10000000" when "111",
        "00000000" when others;
    
    CONT_RODADA: contador_m
    generic map  (
        M => 3,
        N => 2
    )
    port map (
        clock => clock,
        zera  => zera_cont_rodada,
        conta => conta_cont_rodada,
        Q     => open,
        fim   => fim_cont_rodada,
        meio  => open
    );

    s_pontuacao <= s_pontos2&s_pontos1&s_pontos0;
    SERIAL: envia_pontuacao
    port map (
        clock           => clock,
        reset           => reset,
        envia_dados     => envia_dados,
        pontuacao       => s_pontuacao,
        sel_dado        => sel_dado,
        saida_serial    => saida_serial,
        fim_envio       => open,
        db_estado       => open
    );

end architecture;
