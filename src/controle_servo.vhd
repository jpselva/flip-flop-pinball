library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
    port (
        clock    : in std_logic;
        reset    : in std_logic;
        posicao  : in std_logic_vector(1 downto 0);
        controle : out std_logic
    );
end entity controle_servo;

architecture structural of controle_servo is
    component circuito_pwm is
      generic (
          conf_periodo : integer := 1250;
          largura_00   : integer :=    0;
          largura_01   : integer :=   50;
          largura_10   : integer :=  500;
          largura_11   : integer := 1000 
      );
      port (
          clock   : in  std_logic;
          reset   : in  std_logic;
          largura : in  std_logic_vector(1 downto 0);
          pwm     : out std_logic 
      );
    end component circuito_pwm;
begin
    PWMGEN: circuito_pwm
    generic map (
        conf_periodo => 1000000,
        largura_00   => 0,
        largura_01   => 50000,
        largura_10   => 75000,
        largura_11   => 100000
    )
    port map (
        clock   => clock,
        reset   => reset,
        largura => posicao,
        pwm     => controle
    );
end architecture;
