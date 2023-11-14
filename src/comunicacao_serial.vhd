library ieee;
use ieee.std_logic_1164.all;

entity comunicacao_serial is
generic (
    constant max_points_value : integer := 1000;
    constant max_points_N     : integer := 10
);
port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    enviar_dados    : in  std_logic;
    pontuacao       : in  std_logic_vector(max_points_N-1 downto 0);
    saida_serial    : out std_logic;
    db_estado       : out std_logic_vector(3 downto 0)
);


