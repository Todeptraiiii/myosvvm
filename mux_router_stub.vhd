library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.Pkt_Types_Pkg.all;

entity mux_router_stub is
    port 
    (
        dest_in     : in std_logic_vector(1 downto 0);
        data_in     : in data_t;

        out0_data   : out data_t;
        out1_data   : out data_t;
        out2_data   : out data_t;
        out3_data   : out data_t
    );
end entity;

architecture rtl of mux_router_stub is

begin

    out0_data <= data_in when dest_in = "00" else (others => '0');
    out1_data <= data_in when dest_in = "01" else (others => '0');
    out2_data <= data_in when dest_in = "10" else (others => '0');
    out3_data <= data_in when dest_in = "11" else (others => '0');

end architecture;
