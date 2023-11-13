library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flip_flop_pinball_tb is
end entity;

architecture tb of flip_flop_pinball_tb is

  -- Componente a ser testado (Device Under Test -- DUT)
  component flip_flop_pinball is
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
      db_pontuacao1            : out std_logic_vector(6 downto 0);
      db_pontuacao2            : out std_logic_vector(6 downto 0);
      db_pontuacao3            : out std_logic_vector(6 downto 0);
      db_bola_caiu            : out std_logic
  );
  end component;

  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock                   : std_logic := '0';
  signal reset                   : std_logic := '0';
  signal botao1                  : std_logic := '0';
  signal botao2                  : std_logic := '0';
  signal iniciar                 : std_logic := '0';
  signal echo                    : std_logic := '0';
  signal ponto1                  : std_logic := '0';
  signal ponto2                  : std_logic := '0';
  signal ponto3                  : std_logic := '0';
  signal pwm_flipper1            : std_logic := '0';
  signal pwm_flipper2            : std_logic := '0';
  signal trigger                 : std_logic := '0';
  signal db_estado               : std_logic_vector(6 downto 0) := "0000000";
  signal db_detector_bola_estado : std_logic_vector(6 downto 0) := "0000000";
  signal db_pontuacao1           : std_logic_vector(6 downto 0) := "0000000";
  signal db_pontuacao2           : std_logic_vector(6 downto 0) := "0000000";
  signal db_pontuacao3           : std_logic_vector(6 downto 0) := "0000000";
  signal db_bola_caiu            : std_logic := '0';

  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
  
  -- lembrando que a relacao é: 1cm ~ 58.8us
  constant pulso_10cm: integer := 588;
  constant pulso_20cm: integer := 1176;
  signal pulso: integer := pulso_20cm;
  signal larguraPulso: time := 1 ns;
  

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock <= (not clock) and keep_simulating after clockPeriod/2;  

  -- Conecta DUT (Device Under Test)
  dut: flip_flop_pinball
    port map(
      clock                   => clock,
      reset                   => reset,
      botao1                  => botao1,
      botao2                  => botao2,
      iniciar                 => iniciar,
      echo                    => echo,
      ponto1                  => ponto1,
      ponto2                  => ponto2,
      ponto3                  => ponto3,
      pwm_flipper1            => pwm_flipper1,
      pwm_flipper2            => pwm_flipper2,
      trigger                 => trigger,
      db_estado               => db_estado,
      db_detector_bola_estado => db_detector_bola_estado,
      db_pontuacao1           => db_pontuacao1,
      db_pontuacao2           => db_pontuacao2,
      db_pontuacao3           => db_pontuacao3,
      db_bola_caiu            => db_bola_caiu
  );

  -- cria pulso de x us
  create_pulse: process
  begin
    assert false report "Pulso: " & integer'image(pulso) & "us" severity note;
    larguraPulso <= pulso * 1 us;

    -- 2) espera pelo pulso trigger
    wait until falling_edge(trigger);
    -- 3) espera por 400us (simula tempo entre trigger e echo)
    wait for 400 us;
     
    -- 4) gera pulso de echo (largura = larguraPulso)
    echo <= '1';
    wait for larguraPulso;
    echo <= '0';

    -- 5) espera sinal fim (indica final da medida de uma posicao do sonar)
    wait until rising_edge(trigger);
  end process;
  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    iniciar <= '1';
    botao1  <= '1';
    botao2  <= '1';
    pulso   <= pulso_20cm;
    ponto1  <= '0';
    ponto2  <= '0';
    ponto3  <= '0';
    ---- aciona reset ----------------
    wait for 100 us;
    reset <= '1';
    wait for 100 us;
    reset <= '0';
    ---- inicia jogo ----------------
    wait for 100 us;
    iniciar <= '0';
    wait for 100 us;
    iniciar <= '1';
    ---- ativa flipper 2, atinge ponto 1
    wait for 100 us;
    pulso <= pulso_20cm;
    botao2 <= '0';
    ponto1 <= '1';
    wait for 100 us;
    ponto1 <= '0';
    ---- atinge ponto 2
    wait for 100 us;
    ponto2 <= '1';
    wait for 100 us;
    ponto2 <= '0';
    ---- desativa flipper 2, atinge ponto 3
    wait for 100 us;
    botao2 <= '1';
    ponto3 <= '1';
    wait for 100 us;
    ponto3 <= '0';
    ---- bola cai
    wait for 100 us;
    wait until falling_edge(echo);
    pulso <= pulso_10cm;
    wait until falling_edge(echo);
    ---- atinge ponto com jogo desligado
    wait for 100 us;
    ponto2 <= '1';
    wait for 100 us;
    ponto2 <= '0'; 
    ---- reinicia jogo
    wait for 100 us;
    iniciar <= '0';
    wait for 100 us;
    iniciar <= '1';

    wait for 100 us;
    ---- espera pwm
    -- wait 20 ms;
    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';    

    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;




end architecture;
