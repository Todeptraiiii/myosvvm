library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_int.all;

use work.pkg_ids.all;

entity tb_mux_skeleton is

end entity;

architecture tb of tb_mux_skeleton is

begin

    Test_proc: process
    begin
        SetTestName("tb_mux_skeleton");
        SetLogEnable(TB_ID, PASSED, TRUE);
        SetLogEnable(TB_ID, INFO, TRUE);

        TranscriptOpen;
        SetTranscriptMirror(TRUE);

        wait for 10 ns;

        AffirmIfEqual(TB_ID,
        AllScoreboardsEmpty,
        TRUE,
        "AllScoreboardsEmpty"
        ) ;

        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;
        wait;
    end process;

end tb;



