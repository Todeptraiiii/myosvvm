library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all ;

use work.Pkt_Types_Pkg.all;
use work.pkg_ids.all;

entity stim_gen is
    port 
    (
    
        dest_out    : out std_logic_vector(1 downto 0);
        data_out    : out data_t
    );
end entity;

architecture rtl of stim_gen is

signal pkt_cnt  : integer := 0;

begin

    gen_proc: process
        variable R        : RandomPType;  
        variable dest_int : integer;
        variable dword    : data_t;
    begin

        R.InitSeed(778);
        -- wait for 10 ns;
        
        for i in 0 to N_PKTS - 1 loop
            -- random destination
            dest_int := R.RandInt(0, 3);
            Log(TB_ID, "dest_int: " & to_string(dest_int), INFO);
            dest_out <= std_logic_vector(to_unsigned(dest_int, 2));

            -- random data
            dword    := std_logic_vector(to_unsigned(i, 16));
            data_out <= dword;

            case dest_int is
                when 0 => Push(SB0_ID, dword);
                when 1 => Push(SB1_ID, dword);
                when 2 => Push(SB2_ID, dword);
                when 3 => Push(SB3_ID, dword);
                when others => null;
            end case;
        wait for 20 ns;
        end loop;

        wait;

    end process;

end architecture;



