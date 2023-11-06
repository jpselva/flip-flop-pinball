library ieee;
use ieee.std_logic_1164.all;

entity medidor_largura is
    port (
        clock  : in  std_logic;
        pulso  : in  std_logic;
        zera   : in  std_logic;
        reset  : in  std_logic;
        medida : out std_logic_vector(11 downto 0);
        pronto : out std_logic
    );
end entity;

architecture arch of medidor_largura is
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

    component edge_detector is
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            sinal  : in  std_logic;
            pulso  : out std_logic
        );
    end component edge_detector;

    signal tick : std_logic;
    signal not_pulso: std_logic;
begin
    CNT_MED: contador_m
    generic map (
        M => 4000,
        N => 12
    )
    port map (
        clock => clock,
        zera  => zera,
        conta => tick,
        Q     => medida,
        fim   => open,
        meio  => open
    );

    CNT: contador_m
    generic map (
        M => 2941,  -- 58.2 us / 20 ns
        N => 15
    )
    port map (
        clock => clock,
        zera  => zera,
        conta => pulso,
        Q     => open,
        fim   => open,
        meio  => tick
    );

    not_pulso <= not pulso;
    DETEC_FIM: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => not_pulso,
        pulso => pronto
    );
end architecture;
