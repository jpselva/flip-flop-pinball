library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball_uc is
port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    iniciar        : in  std_logic;
    bola_caiu      : in  std_logic;
    flipper_enable : out std_logic;
    iniciar_detec  : out std_logic
);
end entity;

architecture arch of flip_flop_pinball_uc is
    type tipo_estado is (
        inicial,
        preparacao,
        joga
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

    process (Eatual, iniciar,  bola_caiu)
    begin
        flipper_enable <= '0';
        iniciar_detec  <= '0';

        case Eatual is
            when inicial =>
                if iniciar = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
                iniciar_detec <= '1';
                Eprox <= joga;

            when joga =>
                flipper_enable <= '1';
                if bola_caiu = '1' then
                    Eprox <= inicial;
                else
                    Eprox <= joga;
                end if;

        end case;
    end process;
end architecture;
