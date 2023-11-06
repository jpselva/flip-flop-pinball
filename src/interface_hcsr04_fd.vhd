library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_fd is
    port (
        clock      : in std_logic;

        -- vem do sensor:
        echo       : in std_logic;
        -- vem da uc:
        gera       : in std_logic; -- inicia trigger
        registra   : in std_logic;
        zera       : in std_logic;
        reset      : in std_logic;

        -- vai para o sensor:
        trigger    : out std_logic;
        -- vai para a uc:
        fim_medida : out std_logic;

        medida     : out std_logic_vector(11 downto 0)
    );
end interface_hcsr04_fd;

architecture fd_arch of interface_hcsr04_fd is
    component gerador_pulso is
        generic (
            largura : integer
        );
        port(
            clock   : in  std_logic;
            reset   : in  std_logic;
            gera    : in  std_logic;
            para    : in  std_logic;
            pulso   : out std_logic;
            pronto  : out std_logic
        );
    end component;

    component medidor_largura is
        port (
            clock  : in  std_logic;
            pulso  : in  std_logic;
            zera   : in  std_logic;
            reset  : in  std_logic;
            medida : out std_logic_vector(11 downto 0);
            pronto : out std_logic
        );
    end component;

    signal medida_tmp: std_logic_vector(11 downto 0);
    signal medida_reg: std_logic_vector(11 downto 0);
begin
    GER_PULSO: gerador_pulso
    generic map (
        largura => 500 -- 10 us / 20 ns (clock 50Mhz -> periodo 20 ns)
    )
    port map (
        clock => clock,
        reset => zera,
        gera => gera,
        para => '0',
        pulso => trigger,
        pronto => open
    );

    LARG_MED: medidor_largura
    port map (
        clock  => clock,
        pulso  => echo,
        zera   => zera,
        reset  => reset,
        medida => medida_tmp,
        pronto => fim_medida
    );

    REG_MEDIDA: process (clock, zera) 
    begin
        if zera = '1' then
            medida_reg <= "000000000000";
        elsif clock'event and clock =  '1' and registra = '1' then
            medida_reg <= medida_tmp;
        end if;
    end process;

    medida <= medida_reg;
end architecture;
