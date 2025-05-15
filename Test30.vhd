-- mini-project ( AlertLogPkg, ScoreboardPkg_slv, CoveragePkg)
-- ┌────────┐
-- │ StimUL │  -- Random pkt → MUX_IN
-- └────────┘
--        │  (AXI‑Str)
-- ┌──────▼──────┐
-- │   MUX DUT   │  -- chọn port dựa mã Destination (2 bit)
-- └─┬────┬───┬──┘
--   │    │   │
-- ┌─▼┐ ┌─▼┐ ┌─▼┐ ┌─▼┐
-- │P0│ │P1│ │P2│ │P3│  -- Monitor + Scoreboard Check
-- └──┘ └──┘ └──┘ └──┘
-- StimUL: tạo gói, log chiều dài + CRC, Push vào Scoreboard tương ứng.

-- Monitors: mỗi port lấy gói thực, Check đối chiếu Expected.

-- Coverage: ICover mỗi gói (LenClass, CRC_OK/FAIL) và cross.


-- | File           | Nội dung                                              |
-- | -------------- | ----------------------------------------------------- |
-- | `pkg_ids.vhd`  | Khai báo AlertLogID + ScoreboardID cho P0..P3, TB     |
-- | `stim_gen.vhd` | Process sinh gói; sử dụng RandomPkg, CoveragePkg      |
-- | `monitor.vhd`  | Component chung; param `g_PORT`                       |
-- | `tb_mux.vhd`   | Top‑level TB; inst Stim, DUT, 4 Monitor; báo cáo cuối |


-- Ket qua: Khong chay duoc


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

entity Test30 is end;

architecture tb of Test30 is

    constant TB_ID  : AlertLogIDType := NewID("Test30");
    constant COV_ID : CoverageIDType := NewID("Cov", TB_ID);
    constant COV_ID1: CoverageIDType := NewID("Cov1", TB_ID);
    constant COV_CROSS: CoverageIDType := NewID("CovCross", TB_ID);
    
begin


    test_proc: process
        variable i : integer;
        variable e : integer;
        variable c,d,f : integer;
    begin
        SetTestName("Test30");
        SetLogEnable(TB_ID, INFO, TRUE);
        SetLogEnable(TB_ID, PASSED, TRUE);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);

        wait for 0 ns; wait for 0 ns;

        AddBins(COV_ID, 10, GenBin(64, 127));
        AddBins(COV_ID, 10, GenBin(128, 511));
        AddBins(COV_ID, 10, GenBin(512, 1023));
        AddBins(COV_ID, 10, GenBin(1024, 1518));


        AddBins(COV_ID1, 40, GenBin(0));
        AddBins(COV_ID1, 10, GenBin(1));


        AddCross(COV_CROSS,  GenBin(64, 127,1), GenBin(12,31,1));
        AddCross(COV_CROSS,  GenBin(64, 127,1), GenBin(32,64,1));

        for m in 1 to 100 loop
            i := GetRandPoint(COV_ID);
            e := GetRandPoint(COV_ID1);

            (c,d) := GetRandPoint(COV_CROSS);

            Log(TB_ID, "c = " & to_string(c) & " d = " & to_string(d), INFO);
            

            -- ICover(COV_ID, i);
            -- ICover(COV_ID1, e);
            -- ICover(COV_CROSS, (c, (d, f)));
            wait for 10 ns;

        end loop;

        wait for 100 ns;

        -- WriteBin(COV_ID);
        -- WriteBin(COV_ID1);
        WriteBin(COV_CROSS);
        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;
        wait;
        
    end process;



end architecture;


