library ieee;
use ieee.std_logic_1164.all;

entity controle_led_buzzer is
port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    sel_nota       : in  std_logic_vector(2 downto 0);
    ativa_lb       : in  std_logic;
    sinal_buzzer   : out std_logic;
    sinal_led      : out std_logic;
    db_estado      : out std_logic_vector(3 downto 0)
);
end entity;

architecture arch of controle_led_buzzer is

    component controle_led_buzzer_fd is
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
    end component;

    component controle_led_buzzer_uc is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        ativa_lb       : in  std_logic;
        fim_cont_lb    : in  std_logic;
        fim_timer_lb   : in  std_logic;
        zera_cont_lb   : out std_logic;
        zera_timer_lb  : out std_logic;
        controle_lb    : out std_logic;
        conta_lb       : out std_logic;
        conta_timer_lb : out std_logic;
        write_sel      : out std_logic;
        db_estado      : out std_logic_vector(3 downto 0)
    );
    end component;

    signal s_fim_cont_lb, s_zera_cont_lb, s_conta_lb : std_logic;
    signal s_fim_timer_lb, s_zera_timer_lb, s_conta_timer_lb : std_logic;
    signal s_controle_lb, s_write_sel : std_logic;
begin
    FD: controle_led_buzzer_fd
    port map(
        clock          => clock,
        reset          => reset,
        zera_cont_lb   => s_zera_cont_lb,
        conta_lb       => s_conta_lb,
        zera_timer_lb  => s_zera_timer_lb,
        conta_timer_lb => s_conta_timer_lb,
        controle_lb    => s_controle_lb,
        write_sel      => s_write_sel,
        sel_nota       => sel_nota,
        fim_timer_lb   => s_fim_timer_lb,
        fim_cont_lb    => s_fim_cont_lb,
        sinal_buzzer   => sinal_buzzer,
        sinal_led      => sinal_led
    );

    UC: controle_led_buzzer_uc
    port map(
        clock          => clock,
        reset          => reset,
        ativa_lb       => ativa_lb,
        fim_cont_lb    => s_fim_cont_lb,
        fim_timer_lb   => s_fim_timer_lb,
        zera_cont_lb   => s_zera_cont_lb,
        zera_timer_lb  => s_zera_timer_lb,
        controle_lb    => s_controle_lb,
        conta_lb       => s_conta_lb,
        conta_timer_lb => s_conta_timer_lb,
        write_sel      => s_write_sel,
        db_estado      => db_estado
    );

end architecture;
