library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_multiplo is
    generic (
        constant M   : integer := 1000;  
        constant N   : integer :=   10;
        constant c1_v: integer :=    1;
        constant c2_v: integer :=   10;
        constant c3_v: integer :=  100
    );
    port (
        clock   : in  std_logic;
        zera    : in  std_logic;
        conta_1 : in  std_logic;
        conta_2 : in  std_logic;
        conta_3 : in  std_logic;
        Q       : out std_logic_vector (N-1 downto 0)
    );
end entity contador_multiplo;

architecture contador_multiplo_arch of contador_multiplo is
    signal IQ: integer range 0 to M-1;
begin
    process (clock,zera,conta_1,conta_2,conta_3,IQ)
    begin
        if zera='1' then IQ <= 0; 
        elsif clock'event and clock='1' then
            if conta_1='1' then 
                if IQ=M-c1_v then IQ <= 0; 
                else IQ <= IQ + c1_v; 
                end if;
            elsif conta_2='1' then 
                if IQ=M-c2_v then IQ <= 0; 
                else IQ <= IQ + c2_v; 
                end if;
            elsif conta_3='1' then 
                if IQ=M-c3_v then IQ <= 0; 
                else IQ <= IQ + c3_v; 
                end if;
            end if;
       end if;
        
        Q <= std_logic_vector(to_unsigned(IQ, Q'length));
    
    end process;
end architecture;
