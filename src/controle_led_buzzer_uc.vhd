library ieee;
use ieee.std_logic_1164.all;

entity controle_led_buzzer_uc is
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
end entity;

architecture arch of controle_led_buzzer_uc is
    type tipo_estado is (
        inicial,
        preparacao,
        reproduz, 
        proximo
    );
    signal Eatual, Eprox: tipo_estado;
begin
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    process (Eatual, ativa_lb, fim_cont_lb, fim_timer_lb)
    begin
        write_sel      <= '0';
        zera_cont_lb   <= '0';
        zera_timer_lb  <= '0';
        controle_lb    <= '0';
        conta_lb       <= '0';
        conta_timer_lb <= '0';
        case Eatual is
            when inicial =>
                write_sel <= '1';
                if ativa_lb = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
                zera_cont_lb <= '1';
                Eprox <= reproduz;

            when reproduz =>
                controle_lb <= '1';
                conta_timer_lb <= '1';
                if fim_timer_lb = '1' then
                    Eprox <= proximo;
                else
                    Eprox <= reproduz;
                end if;

            when proximo =>
                conta_lb <= '1';
                zera_timer_lb <= '1';
                if fim_cont_lb = '1' then
                    Eprox <= inicial;
                else
                    Eprox <= reproduz;
                end if;
        end case;
    end process;

    with Eatual select db_estado <=
        "0001" when inicial,
        "0010" when preparacao, 
        "0011" when reproduz, 
        "0100" when proximo, 
        "1110" when others;
end architecture;

