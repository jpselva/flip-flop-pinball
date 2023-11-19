------------------------------------------------------------------
-- Arquivo   : rx_serial_uc.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : unidade de controle do circuito da experiencia 2 
-- > implementa superamostragem (tick)
-- > independente da configuracao de recepcao (7O1, 8N2, etc)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao

------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        dado_serial : in  std_logic;
        tick        : in  std_logic;
        fim         : in  std_logic;
        zera        : out std_logic;
        conta       : out std_logic;
        carrega     : out std_logic;
        desloca     : out std_logic;
        pronto      : out std_logic;
        db_estado   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (dado_serial, tick, fim, Eatual) 
  begin
    zera     <= '0';
    conta    <= '0';
    carrega  <= '0';
    desloca  <= '0';
    pronto   <= '0';

    case Eatual is
        when inicial =>      
            if dado_serial='1' then 
                Eprox <= inicial;
            else 
                Eprox <= preparacao;
            end if;

        when preparacao =>
            Eprox <= espera;
            zera <= '1';

        when espera =>       
            if tick='1' then   
                Eprox <= recepcao;
            elsif fim='0' then 
                Eprox <= espera;
            else               
                Eprox <= final;
            end if;

        when recepcao =>  
            if fim='0' then
                Eprox <= espera;
            else
                Eprox <= final;
            end if;
            desloca <= '1';
            conta <= '1';

        when final =>        
            Eprox <= inicial;
            pronto <= '1';

        when others =>       
            Eprox <= inicial;

    end case;

  end process;

  with Eatual select
      db_estado <= "0000" when inicial,
                   "0001" when preparacao, 
                   "0010" when espera, 
                   "0100" when recepcao, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture rx_serial_uc_arch;
