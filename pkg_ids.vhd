library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

package pkg_ids is

    -- alert log id
    constant TB_ID : AlertLogIDType := NewID("Test30");

    -- scoreboard id
    constant SB0_ID : ScoreboardIdType := NewID("SB0", TB_ID);
    constant SB1_ID : ScoreboardIdType := NewID("SB1", TB_ID);
    constant SB2_ID : ScoreboardIdType := NewID("SB2", TB_ID);
    constant SB3_ID : ScoreboardIdType := NewID("SB3", TB_ID);

end package;

