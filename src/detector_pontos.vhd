library ieee;
use ieee.std_logic_1164.all;

entity detector_pontos is
generic (
    cooldown_ciclos : natural := 50000000
);
port (
    clock : in std_logic;
    reset : in std_logic;
    alvos : in std_logic_vector(7 downto 0);

    -- ponto_feito stays high during the cycle immediatly after a target is
    -- hit. During the clock cycle after ponto_feito falls, alvo_acertado 
    -- contains the target that was hit
    ponto_feito   : out std_logic; 
    alvo_acertado : out std_logic_vector(2 downto 0)
);
end entity detector_pontos;

architecture dec of detector_pontos is
    component timed_edge_detector is
        generic (
            M : integer
        );
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            sinal  : in  std_logic;
            pulso  : out std_logic
        );
    end component timed_edge_detector;

    signal pulsos_ponto        : std_logic_vector(7 downto 0);
    signal or_pulsos_ponto     : std_logic_vector(6 downto 0);
    signal s_ponto_feito       : std_logic;
    signal s_alvo_acertado_tmp : std_logic_vector(2 downto 0);
begin
    g_DETECTORS: for i in 0 to 7 generate
        g_DETECTOR: timed_edge_detector
        generic map (
            M => cooldown_ciclos
        )
        port map (
            clock => clock,
            reset => reset,
            sinal => alvos(i),
            pulso => pulsos_ponto(i)
        );

        g_OR_PULSOS1: if (i = 1) generate
            or_pulsos_ponto(i - 1) <= pulsos_ponto(i) or pulsos_ponto(i - 1);
        end generate;

        g_OR_PULSOS: if (i > 1) generate
            or_pulsos_ponto(i - 1) <= pulsos_ponto(i) or or_pulsos_ponto(i - 2);
        end generate;
    end generate g_DETECTORS;

    s_ponto_feito <= or_pulsos_ponto(6);
    ponto_feito <= s_ponto_feito;

    -- priority encoder
    s_alvo_acertado_tmp <= "111" when (pulsos_ponto(7) = '1') else
                           "110" when (pulsos_ponto(6) = '1') else
                           "101" when (pulsos_ponto(5) = '1') else
                           "100" when (pulsos_ponto(4) = '1') else
                           "011" when (pulsos_ponto(3) = '1') else
                           "010" when (pulsos_ponto(2) = '1') else
                           "001" when (pulsos_ponto(1) = '1') else
                           "000" when (pulsos_ponto(0) = '1') else
                           "000";

    REGALVO: process (clock, reset) is
    begin
        if (reset = '1') then
            alvo_acertado <= (others => '0');
        elsif (clock = '1' and clock'event and s_ponto_feito = '1') then
            alvo_acertado <= s_alvo_acertado_tmp;
        end if;
    end process;
end architecture;
