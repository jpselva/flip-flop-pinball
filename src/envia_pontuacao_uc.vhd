library ieee;
use ieee.std_logic_1164.all;

entity envia_pontuacao_uc is
port (
    clock            : in  std_logic;
    reset            : in  std_logic;
    envia_dados      : in  std_logic;
    fim_conta_byte   : in  std_logic;
    tx_pronto        : in  std_logic;
    zera_conta_byte  : out std_logic;
    tx_partida       : out std_logic;
    conta_byte       : out std_logic;
    fim_envio        : out std_logic;
    write_sel        : out std_logic;
    db_estado        : out std_logic_vector(3 downto 0)
);
end entity;

architecture arch of envia_pontuacao_uc is
    type tipo_estado is (
        inicial,
        preparacao,
        transmite_byte, 
        proximo_byte,
        espera_transmissao,
        fim
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

    process (Eatual, envia_dados, fim_conta_byte, tx_pronto)
    begin
        zera_conta_byte <= '0';
        tx_partida      <= '0';
        conta_byte      <= '0';
        fim_envio       <= '0';
        write_sel       <= '0';
        case Eatual is
            when inicial =>
                write_sel <= '1';
                if envia_dados = '1' then
                    Eprox <= preparacao;
                else
                    Eprox <= inicial;
                end if;

            when preparacao =>
                zera_conta_byte <= '1';
                Eprox <= transmite_byte;

            when transmite_byte =>
                tx_partida <= '1';
                Eprox <= espera_transmissao;

            when espera_transmissao =>
                if tx_pronto = '0' then
                    Eprox <= espera_transmissao;
	        elsif fim_conta_byte = '0' then
                    Eprox <= proximo_byte;
                else 
                    Eprox <= fim;
                end if;
	
	    when proximo_byte =>
		conta_byte <= '1';
		Eprox <= transmite_byte;

            when fim =>
                fim_envio <= '1';
                Eprox <= inicial;

        end case;
    end process;

    with Eatual select db_estado <=
        "0001" when inicial,
        "0010" when preparacao, 
        "0011" when transmite_byte, 
        "0100" when proximo_byte, 
        "0101" when espera_transmissao, 
        "1111" when fim,
        "1110" when others;
end architecture;

