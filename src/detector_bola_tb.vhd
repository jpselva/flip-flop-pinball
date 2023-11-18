library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity tb_detector_bola is
end tb_detector_bola;

architecture tb of tb_detector_bola is

    component detector_bola
        generic (
            timeout_ciclos : natural := 25000000; -- quantos ciclos ate timeout
            dist_min_cm    : natural := 30  -- distancia minima para detectar bola
        );
        port (clock     : in std_logic;
              reset     : in std_logic;
              iniciar   : in std_logic;
              echo      : in std_logic;
              bola_caiu : out std_logic;
              trigger   : out std_logic;
              db_estado : out std_logic_vector (3 downto 0));
    end component;

    signal clock     : std_logic;
    signal reset     : std_logic;
    signal iniciar   : std_logic;
    signal echo      : std_logic;
    signal bola_caiu : std_logic;
    signal trigger   : std_logic;
    signal db_estado : std_logic_vector (3 downto 0);

    constant TbPeriod : time := 0.02 * ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    signal test_case : natural := 0;

    -- minimum distance considered for this testbench
    constant dist_min_cm : real := 30.0;
    constant timeout_ciclos : natural := 250000;
begin

    dut : detector_bola
    generic map (dist_min_cm => integer(floor(dist_min_cm)),
                 timeout_ciclos => timeout_ciclos)
    port map (clock     => clock,
              reset     => reset,
              iniciar   => iniciar,
              echo      => echo,
              bola_caiu => bola_caiu,
              trigger   => trigger,
              db_estado => db_estado);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        iniciar <= '0';
        echo <= '0';

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- start system
        iniciar <= '1';
        wait for 2*TbPeriod;
        iniciar <= '0';

        -- wait until after trigger pulse
        wait until trigger = '1';
        report "trigger went up";
        wait until trigger = '0';
        report "trigger went down";

        -- TEST 1: return distance that's greater than the minimum
        test_case <= 1;
        report "TEST 1" severity note;
        echo <= '1';
        wait for (58.82 * (dist_min_cm + 1.0)) * ns;
        echo <= '0';
        wait for 10*TbPeriod;
        assert bola_caiu = '0' report "TEST1 (min distance + 1) failed";

        -- it should raise trigger again and keep bola_caiu down
        wait until trigger = '0';

        -- TEST 2: return distance that's less than the minimum
        test_case <= 2;
        report "TEST 2" severity note;
        echo <= '1';
        wait for (58.82 * (dist_min_cm - 1.0)) * ns;
        echo <= '0';
        wait for 10*TbPeriod;
        assert bola_caiu = '1' report "TEST2 (min distance + 1) failed";

        -- TEST 3: assert bola_caiu stays active until iniciar is reactivated
        test_case <= 3;
        report "TEST 3" severity note;
        wait for 100*TbPeriod;
        assert bola_caiu = '1' report "TEST3 (bola_caiu keeps high) failed";

        -- TEST4: iniciar should restart measurement
        test_case <= 4;
        report "TEST 4" severity note;
        iniciar <= '1';
        wait until trigger = '1';
        wait until trigger = '0';

        -- TEST5 timeout
        test_case <= 5;
        report "TEST5";
        wait for timeout_ciclos * TbPeriod;
        wait until trigger = '1';
        wait until trigger = '0';

        TbSimEnded <= '1';
        wait;
    end process;

end tb;
