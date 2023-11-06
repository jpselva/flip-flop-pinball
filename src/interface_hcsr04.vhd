library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04 is
    port (
        clock     : in std_logic;
        reset     : in std_logic;
        medir     : in std_logic;
        echo      : in std_logic;
        trigger   : out std_logic;
        medida    : out std_logic_vector(11 downto 0); -- valor em cm
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end interface_hcsr04;

architecture arch of interface_hcsr04 is
    component interface_hcsr04_uc is 
        port ( 
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            fim_medida : in  std_logic;
            zera       : out std_logic;
            gera       : out std_logic;
            registra   : out std_logic;
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) 
        );
    end component;

    component interface_hcsr04_fd is
        port (
            clock      : in std_logic;
            echo       : in std_logic;
            gera       : in std_logic;
            registra   : in std_logic;
            zera       : in std_logic;
            reset      : in std_logic;
            trigger    : out std_logic;
            fim_medida : out std_logic;
            medida     : out std_logic_vector(11 downto 0)
        );
    end component;

    signal zera, gera, fim_medida, registra : std_logic;
begin
    UC: interface_hcsr04_uc
    port map (
        clock => clock,
        reset => reset,
        medir => medir,
        echo => echo,
        fim_medida => fim_medida,
        zera => zera,
        gera => gera,
        registra => registra,
        pronto => pronto,
        db_estado => db_estado
    );

    FD: interface_hcsr04_fd
    port map (
        clock => clock,
        echo => echo,
        gera => gera,
        registra => registra,
        zera => zera,
        reset => reset,
        trigger => trigger,
        fim_medida => fim_medida,
        medida => medida
    );
end architecture;
