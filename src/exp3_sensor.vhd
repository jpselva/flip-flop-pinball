library ieee;
use ieee.std_logic_1164.all;

entity exp3_sensor is
    port (
        clock      : in std_logic;
        reset      : in std_logic;
        medir      : in std_logic;
        echo       : in std_logic;
        trigger    : out std_logic;
        hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
        hex1       : out std_logic_vector(6 downto 0);
        hex2       : out std_logic_vector(6 downto 0);
        pronto     : out std_logic;
        db_medir   : out std_logic;
        db_echo    : out std_logic;
        db_trigger : out std_logic;
        db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
    );
end entity exp3_sensor;

architecture arch of exp3_sensor is
    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0) -- estado da UC
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

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;

    signal db_estado_hexa : std_logic_vector(3 downto 0);
    signal medir_edge     : std_logic;
    signal medida         : std_logic_vector(11 downto 0);
    signal trigger_i      : std_logic;
begin
    HCSR04: interface_hcsr04
    port map (
        clock => clock,
        reset => reset,
        medir => medir_edge,
        echo => echo,
        trigger => trigger_i,
        medida => medida,
        pronto => pronto,
        db_estado => db_estado_hexa
    );

    EDGE: edge_detector
    port map (
        clock => clock,
        reset => reset,
        sinal => medir,
        pulso => medir_edge
    );

    HEX_DIG0: hexa7seg
    port map (
        hexa => medida(3 downto 0),
        sseg => hex0
    );

    HEX_DIG1: hexa7seg
    port map (
        hexa => medida(7 downto 4),
        sseg => hex1
    );

    HEX_DIG2: hexa7seg
    port map (
        hexa => medida(11 downto 8),
        sseg => hex2
    );

    HEX_ESTADO: hexa7seg
    port map (
        hexa => db_estado_hexa,
        sseg => db_estado
    );

    db_medir <= medir;
    db_echo <= echo;
    db_trigger <= trigger_i;
    trigger <= trigger_i;
end architecture;
