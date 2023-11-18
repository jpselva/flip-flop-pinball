library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_q is
    generic (
        constant M : integer := 50;  
        constant N : integer := 6 
    );
    port (
        clock    : in  std_logic;
        zera     : in  std_logic;
        conta    : in  std_logic;
        registra : in std_logic;
        D     : in  std_logic_vector (N-1 downto 0);
        Q     : out std_logic_vector (N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
end entity contador_q;

architecture contador_q_arch of contador_q is
    signal IQ: integer range 0 to M-1;
begin
    process (clock,zera)
    begin
        if zera='1' then 
            IQ <= 0; 
        elsif clock'event and clock='1' then
            if registra='1' then
                IQ <= to_integer(unsigned(D));
            elsif conta='1' then 
                if IQ=0 then 
                    IQ <= M-1; 
                else 
                    IQ <= IQ-1; 
                end if;
            end if;
        end if;
        
        -- fim de contagem    
        if IQ=0 then 
            fim <= '1'; 
        else 
            fim <= '0'; 
        end if;
	    
        -- meio da contagem
        if IQ=M/2-1 then 
            meio <= '1'; 
        else 
            meio <= '0'; 
        end if;
    end process;

    Q <= std_logic_vector(to_unsigned(IQ, Q'length));
end architecture;
