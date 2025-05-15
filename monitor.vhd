library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

use work.Pkt_Types_Pkg.all;
use work.pkg_ids.all;

entity monitor is
    generic
    (
        SB_ID : ScoreboardIdType
    );
    port
    (
        data_in     : in data_t
    );
end entity;

architecture rtl of monitor is

    signal data_in_v : data_t;
    signal data_in_v_int : integer;

begin
    data_in_v       <= data_in;
    data_in_v_int   <= to_integer(unsigned(data_in_v));

    check_proc: process
    begin

        WaitForToggle(data_in_v_int);
        if data_in_v /= (data_in_v'range => '0') then
            Check(SB_ID, data_in_v);
        end if;
    end process;
end architecture;
