library ieee;
use ieee.std_logic_1164.all;

entity comunicacao_serial_uc is
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    enviar_dados    : in  std_logic;
    fim_conta_byte  : in  std_logic;
    tx_pronto       : in  std_logic;
    zera_conta_byte : out std_logic;
    tx_partida      : out std_logic;
    conta_byte      : out std_logic;
    db_estado       : out std_logic_vector(3 downto 0);
);
end entity;

architecture arch of comunicacao_serial_uc is
    type tipo_estado is (
        inicial,
        preparacao,
        transmite_byte, 
        proximo_byte,
        espera_transmissao
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
        zera_conta_byte <= '0';
        tx_partida      <= '0';
        conta_byte      <= '0';
 
        case Eatual is
            when inicial =>
                if enviar_dados = '1' then
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
	        elsif fim_conta_byte = '0'
		    Eprox <= proximo_byte;
		else 
		    Eprox <= inicial;
		end if;
        end case;
    end process;

    with Eatual select db_estado <=
        "0001" when inicial,
        "0010" when preparacao, 
        "0011" when transmite_byte, 
        "0100" when proximo_byte, 
        "0101" when espera_transmissao, 
        "1110" when others;
end architecture;

