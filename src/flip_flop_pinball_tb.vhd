library ieee;
use ieee.std_logic_1164.all;

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
      pwm_flipper1            : out std_logic;
      pwm_flipper2            : out std_logic;
      trigger                 : out std_logic;
      db_estado               : out std_logic_vector(6 downto 0);
      db_detector_bola_estado : out std_logic_vector(6 downto 0);
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
  signal pwm_flipper1            : std_logic := '0';
  signal pwm_flipper2            : std_logic := '0';
  signal trigger                 : std_logic := '0';
  signal db_estado               : std_logic_vector(6 downto 0) := "0000000";
  signal db_detector_bola_estado : std_logic_vector(6 downto 0) := "0000000";
  signal db_bola_caiu            : std_logic := '0';

  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
  
  -- lembrando que a relacao é: 1cm ~ 58.8us
  constant pulso_10cm: integer := 588;
  constant pulso_20cm: integer := 1176;
  signal pulso: integer := pulso_10cm;
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
      pwm_flipper1            => pwm_flipper1,
      pwm_flipper2            => pwm_flipper2,
      trigger                 => trigger,
      db_estado               => db_estado,
      db_detector_bola_estado => db_detector_bola_estado,
      db_bola_caiu            => db_bola_caiu
  );

  -- cria pulso de x us
  create_pulse: process
  begin
    assert false report "Posicao caida" & ": " & integer'image(pulso) & "us" severity note;
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
    iniciar <= '0';
    botao1  <= '1';
    botao2  <= '1';
    pulso   <= pulso_10cm;
    ---- aciona reset ----------------
    wait for 2*clockPeriod;
    reset <= '1'; 
    wait for 2 us;
    reset <= '0';
    wait until falling_edge(clock);

    ---- inicia jogo ----------------
    wait for 20 us;
    iniciar <= '1';

    ---- espera de 20us
    wait for 20 us; 

    pulso <= pulso_10cm;

    wait for 200 us;

    botao2 <= '0';
    wait for 400 us;
	
    wait for 20 ms;
    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';    

    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;




end architecture;
