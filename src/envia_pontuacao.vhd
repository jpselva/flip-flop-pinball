library ieee;
use ieee.std_logic_1164.all;

entity envia_pontuacao is
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    envia_dados     : in  std_logic;
    pontuacao       : in  std_logic_vector(11 downto 0);
    saida_serial    : out std_logic;
    fim_envio       : out std_logic;
    db_estado       : out std_logic_vector(3 downto 0)
);
end entity;

architecture arch of envia_pontuacao is
    component envia_pontuacao_fd is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        zera_conta_byte : in  std_logic;
        tx_partida      : in  std_logic;
        conta_byte      : in  std_logic;
        pontuacao       : in  std_logic_vector(11 downto 0); -- nao param
        saida_serial    : out std_logic;
        fim_conta_byte  : out std_logic;
        tx_pronto       : out std_logic 
    );
    end component;
    
    component envia_pontuacao_uc is
    port (
        clock            : in  std_logic;
        reset            : in  std_logic;
        enviar_pontuacao : in  std_logic;
        fim_conta_byte   : in  std_logic;
        tx_pronto        : in  std_logic;
        zera_conta_byte  : out std_logic;
        tx_partida       : out std_logic;
        conta_byte       : out std_logic;
        fim_envio        : out std_logic;
        db_estado        : out std_logic_vector(3 downto 0)
    );
    end component;
    signal s_zera_conta_byte, s_conta_byte, s_fim_conta_byte, s_tx_partida, s_tx_pronto : std_logic;
begin
    FD: envia_pontuacao_fd
    port map(
        clock           => clock,
        reset           => reset,
        zera_conta_byte => s_zera_conta_byte,
        tx_partida      => s_tx_partida,
        conta_byte      => s_conta_byte,
        pontuacao       => pontuacao,
        saida_serial    => saida_serial,
        fim_conta_byte  => s_fim_conta_byte,
        tx_pronto       => s_tx_pronto
    );
    
    UC: envia_pontuacao_uc
    port map(
        clock            => clock,
        reset            => reset,
        enviar_pontuacao => envia_dados,
        fim_conta_byte   => s_fim_conta_byte,
        tx_pronto        => s_tx_pronto,
        zera_conta_byte  => s_zera_conta_byte,
        tx_partida       => s_tx_partida,
        conta_byte       => s_conta_byte,
        fim_envio        => fim_envio,
        db_estado        => db_estado
    );
end architecture;
