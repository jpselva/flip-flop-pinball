library ieee;
use ieee.std_logic_1164.all;

entity controle_led_buzzer_fd is
port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    zera_cont_lb   : in  std_logic;
    conta_lb       : in  std_logic;
    zera_timer_lb  : in  std_logic;
    conta_timer_lb : in  std_logic;
    controle_lb    : in  std_logic;
    write_sel      : in  std_logic;
    sel_nota       : in  std_logic_vector(2 downto 0);
    fim_timer_lb   : out std_logic;
    fim_cont_lb    : out std_logic;
    sinal_buzzer   : out std_logic;
    sinal_led      : out std_logic
);
end entity;

architecture arch of controle_led_buzzer_fd is
    component contador_m is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
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

    component gerador_freq is
        port (
            clock     : in  std_logic;
            toca_nota : in  std_logic;
            nota      : in  std_logic_vector(11 downto 0);
            saida     : out std_logic
        );
    end component;

    signal zera, registra : std_logic; 
    signal s_sel_cont    : std_logic_vector(1 downto 0); 
    signal s_sel_reg : std_logic_vector(2 downto 0);
    signal s_sel_nota : std_logic_vector(4 downto 0);
    signal s_nota : std_logic_vector(11 downto 0);

begin
    CONT_TIMER: contador_m
    generic map (
        --M => 25000000,
	--N => 25
        -- tb
	M => 2500,
	N => 12
    )
    port map (
        clock => clock,
        zera  => zera_timer_lb, 
        conta => conta_timer_lb,
        Q     => open, -- TB
        fim   => fim_timer_lb,
        meio  => open
    );

    CONT_NOTA: contador_m
    generic map (
        M => 4,
	N => 2
    )
    port map (
        clock => clock,
        zera  => zera_cont_lb, 
        conta => conta_lb,
        Q     => s_sel_cont,
        fim   => fim_cont_lb,
        meio  => open
    );

    zera     <= reset;
    registra <= write_sel;
    REG_SEL: process (clock, zera) 
    begin
        if zera = '1' then
            s_sel_reg <= "000";
        elsif clock'event and clock =  '1' and registra = '1' then
            s_sel_reg <= sel_nota;
        end if;
    end process;

    s_sel_nota <= s_sel_reg & s_sel_cont;
    with s_sel_nota select -- entrada do gerador de frequencia 
        s_nota <= "100000000000" when "00001", -- inicio rodada
                  "100000000000" when "01001",
                  "000000001000" when "10001",
                  "000000000100" when "11001",
                  "000000001000" when "00010", -- fim rodada
                  "100000000000" when "01010",
                  "100000000000" when "10010",
                  "100000000000" when "11010",
                  "000000001000" when "00011", -- fim jogo
                  "000000001000" when "01011",
                  "100000000000" when "10011",
                  "000000000100" when "11011",
                  "000000000100" when "00100", -- pontuacao feita
                  "000000000010" when "01100",
                  "000000000010" when "10100",
                  "000000000000" when "11100",
                  "000000000000" when others;

    GER_FREQ: gerador_freq
    port map (
            clock     => clock,
            toca_nota => controle_lb,
            nota      => s_nota,
            saida     => sinal_buzzer
        );
    sinal_led <= controle_lb;
end architecture;
