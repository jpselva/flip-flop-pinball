
library ieee;
use ieee.std_logic_1164.all;

entity codificador_digito_ascii is
    port(
        digito          : in  std_logic_vector(3 downto 0);
        codigo_ascii    : out std_logic_vector(6 downto 0)
    );
end entity;

architecture codificador_ascii_somador of codificador_digito_ascii is
    component somador_rc is
        generic (
            size : natural := 8
        );
        port (
            A, B    : in  std_logic_vector(size -1 downto 0);
            Ci      : in  std_logic;
            C       : out std_logic_vector(size-1 downto 0);
            Co      : out std_logic
        );
    end component;
    -- signal s_digito : std_logic_vector(3 downto 0);
    signal s_digito_ext, soma : std_logic_vector(6 downto 0);
begin

    -- s_digito <= digito;
    -- s_digito_ext <= "0000" & s_digito;
    s_digito_ext <= "000" & digito;

    RC : somador_rc
        generic map(
            size => 7
        )
        port map(
            a  => s_digito_ext,
            b  => "0110000",        -- soma com 30H
            ci => '0',
            c  => soma,
            co => open
        );

    codigo_ascii <= soma;
end architecture;
