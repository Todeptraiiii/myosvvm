library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package Pkt_Types_Pkg is

    subtype data_t is std_logic_vector(15 downto 0);
    constant N_PKTS : integer := 100;

end package;
