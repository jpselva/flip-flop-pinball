library ieee;
use ieee.std_logic_1164.all;

entity flip_flop_pinball_uc is
port (
    clock              : in  std_logic;
    reset              : in  std_logic;
    iniciar            : in  std_logic;
    bola_caiu          : in  std_logic;
    ponto_feito        : in  std_logic;
    fim_cont_alvo      : in  std_logic;
    fim_cont_rodada    : in  std_logic;

    flipper_enable     : out std_logic;
    iniciar_detec      : out std_logic;
    conta_cont_pontos  : out std_logic;
    zera_cont_pontos   : out std_logic;
    conta_cont_alvo    : out std_logic;
    zera_cont_alvo     : out std_logic;
    registra_cont_alvo : out std_logic;
    db_estado          : out std_logic_vector(3 downto 0);
    zera_cont_rodada   : out std_logic;
    conta_cont_rodada  : out std_logic;
    envia_dados        : out std_logic;
    sel_dado           : out std_logic_vector(2 downto 0); 
    ativa_lb           : out std_logic
);
end entity;

architecture arch of flip_flop_pinball_uc is
    type tipo_estado is (
        envia_reset,
        inicial,
        preparacao,
        envia_inicio_rodada,
        inicia_deteccao,
        espera,
        carrega,
        incrementa,
        envia_pontuacao,
        compara_rodada,
        incrementa_rodada,
        envia_fim_rodada,
        envia_fim_jogo,
        espera_reinicio
    );

    signal Eatual, Eprox: tipo_estado;
begin
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= envia_reset;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    process (Eatual, iniciar, bola_caiu, ponto_feito, fim_cont_alvo, fim_cont_rodada)
    begin
        flipper_enable     <= '0';
        iniciar_detec      <= '0';
        conta_cont_pontos  <= '0';
        zera_cont_pontos   <= '0';
        conta_cont_alvo    <= '0';
        registra_cont_alvo <= '0';
        zera_cont_rodada   <= '0';
        conta_cont_rodada  <= '0';
        zera_cont_alvo     <= '0';
        envia_dados        <= '0';
        ativa_lb           <= '0';
        sel_dado           <= "111";

        case Eatual is
            when envia_reset =>
                envia_dados <= '1';
                sel_dado    <= "000";
                Eprox       <= inicial;

            when inicial =>
                if iniciar = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
                zera_cont_alvo <= '1';
                zera_cont_pontos <= '1';
                zera_cont_rodada <= '1';
                Eprox <= envia_inicio_rodada;

            when envia_inicio_rodada =>
                envia_dados <= '1';
                ativa_lb    <= '1';
                sel_dado    <= "001";
                Eprox       <= inicia_deteccao;

            when inicia_deteccao =>
                iniciar_detec <= '1';
                Eprox <= espera;

            when espera =>
                flipper_enable <= '1';
                if ponto_feito = '1' then
                    Eprox <= carrega;
                elsif bola_caiu = '1' then
                    Eprox <= compara_rodada;
                else
                    Eprox <= espera;
                end if;

            when carrega =>
                registra_cont_alvo <= '1';
                Eprox <= incrementa;

            when incrementa =>
                conta_cont_alvo <= '1';
                conta_cont_pontos <= '1';
                if fim_cont_alvo = '1' then
                    Eprox <= envia_pontuacao;
                else
                    Eprox <= incrementa;
                end if;

            when envia_pontuacao =>
                envia_dados <= '1';
                ativa_lb    <= '1';
                sel_dado    <= "100";
                Eprox <= espera;

            when compara_rodada =>
                if fim_cont_rodada = '1' then 
                    Eprox <= envia_fim_jogo;
                else
                    Eprox <= incrementa_rodada;
                end if;

            when incrementa_rodada =>
                conta_cont_rodada <= '1';
                Eprox <= envia_fim_rodada;

            when envia_fim_rodada =>
                envia_dados <= '1';
                ativa_lb    <= '1';
                sel_dado    <= "010";
                Eprox       <= espera_reinicio;

            when espera_reinicio =>
                if iniciar = '1' then
                    Eprox <= envia_inicio_rodada;
                else
                    Eprox <= espera_reinicio;
                end if;

           when envia_fim_jogo =>
                envia_dados <= '1';
                ativa_lb    <= '1';
                sel_dado    <= "011";
                Eprox       <= inicial;

        end case;
    end process;

    with Eatual select db_estado <=
        "0000" when inicial,
        "1110" when espera,
        "1100" when carrega,
        "0001" when incrementa,
        "0010" when preparacao,
        "0011" when envia_reset,	
        "0111" when envia_inicio_rodada,
        "1010" when envia_pontuacao,
        "1011" when envia_fim_rodada,
        "0110" when envia_fim_jogo,
        "0100" when compara_rodada,
        "1000" when incrementa_rodada,
        "1101" when espera_reinicio,
        "1111" when others;
end architecture;
