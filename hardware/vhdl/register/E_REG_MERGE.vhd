library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_REG_MERGE is
    port (
        sel_i  : in Register23;
        data_i : in std_logic_vector((24*64)-1 downto 0);
        data_o : out Word23
    );
end;

architecture A_REG_MERGE of E_REG_MERGE is

begin

    process (sel_i, data_i)
    begin
        case sel_i is
            when "000000" => data_o <= data_i((24* 1)-1 downto (24* 0));
            when "000001" => data_o <= data_i((24* 2)-1 downto (24* 1));
            when "000010" => data_o <= data_i((24* 3)-1 downto (24* 2));
            when "000011" => data_o <= data_i((24* 4)-1 downto (24* 3));
            when "000100" => data_o <= data_i((24* 5)-1 downto (24* 4));
            when "000101" => data_o <= data_i((24* 6)-1 downto (24* 5));
            when "000110" => data_o <= data_i((24* 7)-1 downto (24* 6));
            when "000111" => data_o <= data_i((24* 8)-1 downto (24* 7));
            when "001000" => data_o <= data_i((24* 9)-1 downto (24* 8));
            when "001001" => data_o <= data_i((24*10)-1 downto (24* 9));
            when "001010" => data_o <= data_i((24*11)-1 downto (24*10));
            when "001011" => data_o <= data_i((24*12)-1 downto (24*11));
            when "001100" => data_o <= data_i((24*13)-1 downto (24*12));
            when "001101" => data_o <= data_i((24*14)-1 downto (24*13));
            when "001110" => data_o <= data_i((24*15)-1 downto (24*14));
            when "001111" => data_o <= data_i((24*16)-1 downto (24*15));
            when "010000" => data_o <= data_i((24*17)-1 downto (24*16));
            when "010001" => data_o <= data_i((24*18)-1 downto (24*17));
            when "010010" => data_o <= data_i((24*19)-1 downto (24*18));
            when "010011" => data_o <= data_i((24*20)-1 downto (24*19));
            when "010100" => data_o <= data_i((24*21)-1 downto (24*20));
            when "010101" => data_o <= data_i((24*22)-1 downto (24*21));
            when "010110" => data_o <= data_i((24*23)-1 downto (24*22));
            when "010111" => data_o <= data_i((24*24)-1 downto (24*23));
            when "011000" => data_o <= data_i((24*25)-1 downto (24*24));
            when "011001" => data_o <= data_i((24*26)-1 downto (24*25));
            when "011010" => data_o <= data_i((24*27)-1 downto (24*26));
            when "011011" => data_o <= data_i((24*28)-1 downto (24*27));
            when "011100" => data_o <= data_i((24*29)-1 downto (24*28));
            when "011101" => data_o <= data_i((24*30)-1 downto (24*29));
            when "011110" => data_o <= data_i((24*31)-1 downto (24*30));
            when "011111" => data_o <= data_i((24*32)-1 downto (24*31));
            when "100000" => data_o <= data_i((24*33)-1 downto (24*32));
            when "100001" => data_o <= data_i((24*34)-1 downto (24*33));
            when "100010" => data_o <= data_i((24*35)-1 downto (24*34));
            when "100011" => data_o <= data_i((24*36)-1 downto (24*35));
            when "100100" => data_o <= data_i((24*37)-1 downto (24*36));
            when "100101" => data_o <= data_i((24*38)-1 downto (24*37));
            when "100110" => data_o <= data_i((24*39)-1 downto (24*38));
            when "100111" => data_o <= data_i((24*40)-1 downto (24*39));
            when "101000" => data_o <= data_i((24*41)-1 downto (24*40));
            when "101001" => data_o <= data_i((24*42)-1 downto (24*41));
            when "101010" => data_o <= data_i((24*43)-1 downto (24*42));
            when "101011" => data_o <= data_i((24*44)-1 downto (24*43));
            when "101100" => data_o <= data_i((24*45)-1 downto (24*44));
            when "101101" => data_o <= data_i((24*46)-1 downto (24*45));
            when "101110" => data_o <= data_i((24*47)-1 downto (24*46));
            when "101111" => data_o <= data_i((24*48)-1 downto (24*47));
            when "110000" => data_o <= data_i((24*49)-1 downto (24*48));
            when "110001" => data_o <= data_i((24*50)-1 downto (24*49));
            when "110010" => data_o <= data_i((24*51)-1 downto (24*50));
            when "110011" => data_o <= data_i((24*52)-1 downto (24*51));
            when "110100" => data_o <= data_i((24*53)-1 downto (24*52));
            when "110101" => data_o <= data_i((24*54)-1 downto (24*53));
            when "110110" => data_o <= data_i((24*55)-1 downto (24*54));
            when "110111" => data_o <= data_i((24*56)-1 downto (24*55));
            when "111000" => data_o <= data_i((24*57)-1 downto (24*56));
            when "111001" => data_o <= data_i((24*58)-1 downto (24*57));
            when "111010" => data_o <= data_i((24*59)-1 downto (24*58));
            when "111011" => data_o <= data_i((24*60)-1 downto (24*59));
            when "111100" => data_o <= data_i((24*61)-1 downto (24*60));
            when "111101" => data_o <= data_i((24*62)-1 downto (24*61));
            when "111110" => data_o <= data_i((24*63)-1 downto (24*62));
            when "111111" => data_o <= data_i((24*64)-1 downto (24*63));
            when others => data_o <= (others => '0');
        end case;
    end process;

end;