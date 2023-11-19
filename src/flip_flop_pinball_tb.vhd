library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball_tb is
end flip_flop_pinball_tb;

architecture tb of flip_flop_pinball_tb is

    component flip_flop_pinball
        port (clock                   : in std_logic;
              reset                   : in std_logic;
              iniciar                 : in std_logic;
              botao1                  : in std_logic;
              botao2                  : in std_logic;
              pwm_flipper1            : out std_logic;
              pwm_flipper2            : out std_logic;
              echo                    : in std_logic;
              trigger                 : out std_logic;
              db_estado               : out std_logic_vector (6 downto 0);
              db_detector_bola_estado : out std_logic_vector (6 downto 0);
              db_bola_caiu            : out std_logic;
              alvos                   : in std_logic_vector (3 downto 0);
              pontos0                 : out std_logic_vector (6 downto 0);
              pontos1                 : out std_logic_vector (6 downto 0);
              pontos2                 : out std_logic_vector (6 downto 0);
              saida_serial            : out std_logic;
              db_saida_serial         : out std_logic);
    end component;

    component rx_serial_7O1 is
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            dado_serial       : in  std_logic;
            dado_recebido0    : out std_logic_vector(6 downto 0);
            dado_recebido1    : out std_logic_vector(6 downto 0);
            paridade_recebida : out std_logic;
            pronto_rx         : out std_logic;
            db_estado         : out std_logic_vector(6 downto 0)
      );
    end component;

    signal clock                   : std_logic;
    signal reset                   : std_logic;
    signal iniciar                 : std_logic;
    signal botao1                  : std_logic;
    signal botao2                  : std_logic;
    signal pwm_flipper1            : std_logic;
    signal pwm_flipper2            : std_logic;
    signal echo                    : std_logic;
    signal trigger                 : std_logic;
    signal db_estado               : std_logic_vector (6 downto 0);
    signal db_detector_bola_estado : std_logic_vector (6 downto 0);
    signal db_bola_caiu            : std_logic;
    signal alvos                   : std_logic_vector (3 downto 0);
    signal pontos0                 : std_logic_vector (6 downto 0);
    signal pontos1                 : std_logic_vector (6 downto 0);
    signal pontos2                 : std_logic_vector (6 downto 0);
    signal saida_serial            : std_logic;
    signal db_saida_serial         : std_logic;

    constant TbPeriod : time      := 20 ns; -- EDIT Put right period here
    signal   TbClock : std_logic    := '0';
    signal   TbSimEnded : std_logic := '0';
    signal   caso_teste : integer    := 0;

    signal rx_reset : std_logic := '0';
begin

    dut: flip_flop_pinball
    port map (clock                   => clock,
              reset                   => reset,
              iniciar                 => iniciar,
              botao1                  => botao1,
              botao2                  => botao2,
              pwm_flipper1            => pwm_flipper1,
              pwm_flipper2            => pwm_flipper2,
              echo                    => echo,
              trigger                 => trigger,
              db_estado               => db_estado,
              db_detector_bola_estado => db_detector_bola_estado,
              db_bola_caiu            => db_bola_caiu,
              alvos                   => alvos,
              pontos0                 => pontos0,
              pontos1                 => pontos1,
              pontos2                 => pontos2,
              saida_serial            => saida_serial,
              db_saida_serial         => db_saida_serial);

    -- Only here to help seeing the serial output
    rx: rx_serial_7O1
    port map (
        clock => clock,
        reset => rx_reset,
        dado_serial => saida_serial,
        dado_recebido0 => open,
        dado_recebido1 => open,
        paridade_recebida => open,
        pronto_rx => open,
        db_estado => open
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed 
        caso_teste <= 0;
        iniciar <= '1';
        botao1 <= '0';
        botao2 <= '0';
        echo <= '0';
        alvos <= (others => '1');

        rx_reset <= '1'; 
        wait for 100 ns;
        rx_reset <= '0';
        wait for 100 ns;

        -- Reset generation
        caso_teste <= 1;
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 500 us;

        -- start game
        caso_teste <= 2;
        iniciar <= '0';
        wait for 10 * TbPeriod;
        iniciar <= '1';
        wait for 500 us;

        -- hit points
        caso_teste <= 3;
        alvos(0) <= '0';
        wait for 2*TbPeriod;
        alvos(0) <= '1';
        wait for 500 us;

        -- ball falls
        caso_teste <= 4;
        echo <= '1';
        wait for 100 us;
        echo <= '0';
        wait for 500 us;

        -- restart round
        caso_teste <= 5;
        iniciar <= '0';
        wait for 10 * TbPeriod;
        iniciar <= '1';
        wait for 500 us;

        -- hit more points
        caso_teste <= 6;
        alvos(1) <= '0';
        wait for 2*TbPeriod;
        alvos(1) <= '1';
        wait for 500 us;

        -- ball falls
        caso_teste <= 7;
        echo <= '1';
        wait for 100 us;
        echo <= '0';
        wait for 500 us;

        -- restart round
        caso_teste <= 8;
        iniciar <= '0';
        wait for 10 * TbPeriod;
        iniciar <= '1';
        wait for 500 us;

        -- ball falls
        caso_teste <= 9;
        echo <= '1';
        wait for 100 us;
        echo <= '0';
        wait for 500 us;

        -- restart round
        caso_teste <= 10;
        iniciar <= '0';
        wait for 10 * TbPeriod;
        iniciar <= '1';
        wait for 500 us;

        wait for 100 us;
        -- Stop the clock and hence terminate the simulation
        -- wait for 200*TbPeriod;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
