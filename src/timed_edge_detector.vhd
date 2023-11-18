library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity timed_edge_detector is
    generic (
        M : integer:= 5000000
    );
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
end entity timed_edge_detector;

architecture rtl of timed_edge_detector is
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

    component timed_edge_detector_uc is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            pulso        : in  std_logic;
            fim_timer    : in  std_logic;
            pulso_enable : out std_logic;
            conta_timer  : out std_logic;
    	    reset_timer  : out std_logic
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

    constant n_bits : natural := natural(ceil(log2(real(M))));
    signal s_fim_timer, s_conta_timer, s_reset_timer, s_pulso, s_pulso_enable : std_logic;
begin
    TIMER: contador_m
    generic map (
        M  => M,
        N  => n_bits
    )
    port map (
        clock  => clock,
        zera   => s_reset_timer,
        conta  => s_conta_timer,
        Q      => open,
        fim    => s_fim_timer,
        meio   => open
    );

    EDGE_DETEC:	edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => sinal,
        pulso => s_pulso
    );

    EDGE_UC: timed_edge_detector_uc
    port map (
        clock        => clock,
        reset        => reset,
        pulso        => s_pulso,
        fim_timer    => s_fim_timer,
        pulso_enable => s_pulso_enable,
        conta_timer  => s_conta_timer,
        reset_timer  => s_reset_timer
    );

    pulso <= s_pulso and s_pulso_enable;
end architecture rtl;
