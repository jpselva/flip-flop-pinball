library ieee;
use ieee.std_logic_1164.all;

entity timed_edge_detector_uc is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        pulso        : in  std_logic;
        fim_timer    : in  std_logic;
        pulso_enable : out std_logic;
        conta_timer  : out std_logic;
	reset_timer  : out std_logic
    );
end entity timed_edge_detector_uc;


architecture arch of timed_edge_detector_uc is
    type tipo_estado is (
        inicial,
	preparacao,
        espera_timer 
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

    process (Eatual, pulso, fim_timer)
    begin
        conta_timer  <= '0';
        reset_timer  <= '0';
	pulso_enable <= '1';

        case Eatual is
            when inicial =>
                if pulso = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
		reset_timer <= '1';
	        Eprox <= espera_timer;

            when espera_timer =>
                conta_timer  <= '1';
		pulso_enable <= '0';

		if fim_timer='1' then
                    Eprox <= inicial;
                else
		    Eprox <= espera_timer;
                end if;

        end case;
    end process;
end architecture;
