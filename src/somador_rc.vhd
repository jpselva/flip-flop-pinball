
library ieee;
use ieee.std_logic_1164.all;

entity somador_rc is
    generic (
        size : natural := 8
    );
    port (
        A, B    : in  std_logic_vector(size -1 downto 0);
        Ci      : in  std_logic;
        C       : out std_logic_vector(size-1 downto 0);
        Co      : out std_logic
    );
end entity somador_rc;

architecture sd1 of somador_rc is

component full_adder is
    port (
        a , b , ci: in std_logic;
        r, co: out std_logic
    );
end component full_adder;

signal cots: std_logic_vector(size -1 downto 0);

begin 

    fas: for i in (size -1) downto 0 generate
        lsb: if i = 0 generate 
            fai : full_adder 
                port map (
                    A ( i ) , B ( i ) , Ci , C ( i ) , cots ( i )            
                );
        end generate;
        msb: if i > 0 generate
            fai : full_adder 
                port map (
                    A ( i ) , B ( i ) , cots (i - 1) , C ( i ) , cots ( i )
                );
        end generate;
    end generate fas;
    co <= cots(size-1);
end architecture;