library ieee;
use ieee.std_logic_1164.all;

entity detector_bola_uc is
port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    iniciar        : in  std_logic;
    medida_pronta  : in  std_logic;
    fim_timeout    : in  std_logic;
    bola_proxima   : in  std_logic;
    conta_timeout  : out std_logic;
    zera_timeout   : out std_logic;
    reset_medidor  : out std_logic;
    medir          : out std_logic;
    bola_caiu      : out std_logic;
    db_estado      : out std_logic_vector(3 downto 0)
);
end entity;

architecture arch of detector_bola_uc is
    type tipo_estado is (
        inicial, 
        preparacao, 
        inicia_med, 
        espera_med, 
        comparacao, 
        trava
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

    process (Eatual, iniciar, medida_pronta, fim_timeout, bola_proxima)
    begin
        conta_timeout <= '0';
        zera_timeout  <= '0';
        reset_medidor <= '0';
        medir         <= '0';
        bola_caiu     <= '0';

        case Eatual is
            when inicial =>
                if iniciar = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
                zera_timeout <= '1';
                reset_medidor <= '1';
                Eprox <= inicia_med;

            when inicia_med =>
                medir <= '1';
                Eprox <= espera_med;

            when espera_med =>
                conta_timeout <= '1';

                if medida_pronta = '1' then
                    Eprox <= comparacao;
                elsif fim_timeout = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= espera_med;
                end if;

            when comparacao =>
                if bola_proxima = '1' then
                    Eprox <= trava;
                else
                    Eprox <= inicia_med;
                end if;

            when trava =>
                bola_caiu <= '1';
                if iniciar = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= trava;
                end if;
        end case;
    end process;

    with Eatual select db_estado <=
        "0001" when inicial,
        "0010" when preparacao, 
        "0011" when inicia_med, 
        "0100" when espera_med, 
        "0101" when comparacao, 
        "0110" when trava,
        "1111" when others;
end architecture;
