
library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
    port (
        a , b , ci: in std_logic;
        r, co: out std_logic
    );
end entity full_adder;

architecture and_or_xor of full_adder is
begin
    co <= (a and b) or (a and ci) or (b and ci);
    r  <= a xor b xor ci;
end architecture and_or_xor;
