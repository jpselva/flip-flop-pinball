library ieee;
use ieee.std_logic_1164.all;

entity envia_pontuacao_fd is
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    zera_conta_byte : in  std_logic;
    tx_partida      : in  std_logic;
    conta_byte      : in  std_logic;
    pontuacao       : in  std_logic_vector(11 downto 0); -- nao param
    sel_dado        : in  std_logic_vector( 2 downto 0);
    write_sel       : in  std_logic;
    saida_serial    : out std_logic;
    fim_conta_byte  : out std_logic;
    tx_pronto       : out std_logic 
);
end entity envia_pontuacao_fd;

architecture arch of envia_pontuacao_fd is
    component tx_serial_7O1 is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        partida         : in  std_logic;
        dados_ascii     : in  std_logic_vector(6 downto 0);
        saida_serial    : out std_logic;
        pronto          : out std_logic;
        db_clock        : out std_logic;
        db_tick         : out std_logic;
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(6 downto 0)
    );
    end component;

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
    
    component codificador_digito_ascii is
    port(
        digito          : in  std_logic_vector(3 downto 0);
        codigo_ascii    : out std_logic_vector(6 downto 0)
    );
    end component;

    signal s_sel_cont   : std_logic_vector(1 downto 0);
    signal s_ponto0, s_ponto1, s_ponto2 : std_logic_vector(3 downto 0);
    signal s_ponto_ascii0, s_ponto_ascii1, s_ponto_ascii2 : std_logic_vector(6 downto 0);
    signal s_dado_ascii, s_pontuacao_ascii : std_logic_vector(6 downto 0);
    signal zera, registra : std_logic;
    signal s_sel_dado_reg : std_logic_vector(2 downto 0);
begin

    CONT_DADO: contador_m
    generic map (
        M => 4, -- nao parametrizado --> 3 dados + # 
        N => 2 
    )
    port map (
        clock => clock,
        zera  => zera_conta_byte, 
        conta => conta_byte,
        Q     => s_sel_cont,
        fim   => fim_conta_byte,
        meio  => open
    );

    zera     <= reset;
    registra <= write_sel;
    REG_SEL: process (clock, zera) 
    begin
        if zera = '1' then
            s_sel_dado_reg <= "000";
        elsif clock'event and clock =  '1' and registra = '1' then
            s_sel_dado_reg <= sel_dado;
        end if;
    end process;

    s_ponto0 <= pontuacao( 3 downto  0);
    s_ponto1 <= pontuacao( 7 downto  4);
    s_ponto2 <= pontuacao(11 downto  8);

    COD_ASCII0: codificador_digito_ascii
    port map(
        digito => s_ponto0,
        codigo_ascii => s_ponto_ascii0
    );

    COD_ASCII1: codificador_digito_ascii
    port map(
        digito => s_ponto1,
        codigo_ascii => s_ponto_ascii1
    );

    COD_ASCII2: codificador_digito_ascii
    port map(
        digito => s_ponto2,
        codigo_ascii => s_ponto_ascii2
    );

    with s_sel_cont select  -- "P" + pontuacao_ascii  
        s_pontuacao_ascii <= "1010000"       when "00",  -- "P"
                             s_ponto_ascii2  when "01",
                             s_ponto_ascii1  when "10",
                             s_ponto_ascii0  when "11",
                             "1000101"       when others; -- "E"

    with s_sel_dado_reg select -- entrada do tx
        s_dado_ascii <= "1001001" when "000", -- I: reset 
                        "1010010" when "001", -- R: inicio rodada
                        "1000010" when "010", -- B: fim rodada
                        "1000110" when "011", -- F: fim jogo
                        s_pontuacao_ascii when "100",  -- "P" + pontuacao_ascii
                        "1000101"         when others; -- "E"

    TX: tx_serial_7O1
    port map(
        clock            => clock,
        reset            => reset,
        partida          => tx_partida,
        dados_ascii      => s_dado_ascii,
        saida_serial     => saida_serial,
        pronto           => tx_pronto,
        db_clock         => open,
        db_tick          => open,
        db_partida       => open,
        db_saida_serial  => open,
        db_estado        => open
    );

end architecture;
