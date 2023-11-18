library ieee;
use ieee.std_logic_1164.all;

entity detector_pontos_tb is
end detector_pontos_tb;

architecture tb of detector_pontos_tb is

    component detector_pontos
        generic (cooldown_ciclos : natural);
        port (clock         : in std_logic;
              reset         : in std_logic;
              alvos         : in std_logic_vector (7 downto 0);
              ponto_feito   : out std_logic;
              alvo_acertado : out std_logic_vector (2 downto 0));
    end component;

    signal clock         : std_logic;
    signal reset         : std_logic;
    signal alvos         : std_logic_vector (7 downto 0);
    signal ponto_feito   : std_logic;
    signal alvo_acertado : std_logic_vector (2 downto 0);

    constant cooldown_ciclos : natural := 1000;

    constant TbPeriod : time := 20 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : detector_pontos
    generic map (cooldown_ciclos => cooldown_ciclos)
    port map (clock         => clock,
              reset         => reset,
              alvos         => alvos,
              ponto_feito   => ponto_feito,
              alvo_acertado => alvo_acertado);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        alvos <= (others => '0');

        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- TEST1: raise a single target
        assert ponto_feito = '0' report "TEST1: ponto_feito should start as 0";
        alvos(4) <= '1'; 
        wait until ponto_feito = '1';
        wait until ponto_feito = '0';
        wait for 0.75*TbPeriod; -- make sure alvo_acertado is correct during the following cycle
        assert alvo_acertado = "100" report "TEST1: wrong alvo_acertado";
        alvos(4) <= '0'; 
        wait for 10*TbPeriod;

        -- TEST2: bounce a single target
        assert ponto_feito = '0' report "TEST2: ponto_feito should start as 0";
        alvos(4) <= '1'; 
        wait for TbPeriod*1.25;
        assert ponto_feito = '0' report "TEST2: debounce not working";
        alvos(4) <= '0';
        wait for 10*TbPeriod;

        -- TEST3: raise another target
        assert ponto_feito = '0' report "TEST3: ponto_feito should start as 0";
        alvos(2) <= '1'; 
        wait until ponto_feito = '1';
        wait until ponto_feito = '0';
        wait for 0.75*TbPeriod; -- make sure alvo_acertado is correct during the following cycle
        assert alvo_acertado = "001" report "TEST3: wrong alvo_acertado";
        alvos(2) <= '0'; 
        wait for 10*TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;
