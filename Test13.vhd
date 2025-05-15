--| Nhóm                     | Thủ tục / Hàm                                                                                                             | Mục đích chính                                    |
--| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
--| **Log**                  | `Log` (3 overloads)                                                                                                       | In thông điệp, lọc theo `LogType`                 |
--| **Alert**                | `Alert`, `AlertIf`, `AlertIfNot`, `AlertIfEqual/NotEqual`, `AlertIfFilesMatch/NotMatch`, `AlertDiff`                      | Báo lỗi và đếm **FAILURE / ERROR / WARNING**      |
--| **Affirm**               | `AffirmIf`, `AffirmIfEqual/NotEqual`, `AffirmIfFilesMatch/NotMatch`                                                       | “Assert‑pass” – tăng bộ đếm **PASSED**            |
--| **Cấu hình**             | `SetLogEnable`, `SetLogEnableHierarchy`, `SetLogEnableAll`<br>`SetAlertEnable`, `SetAlertStopCount`, `SetAlertLogOptions` | Bật/tắt mức log/alert, đặt ngưỡng dừng, định dạng |
--| **ID & tiện ích**        | `NewID`, `GetAlertCount`, `IsLogEnabled`, `GetTestName/SetTestName`                                                       | Phân cấp VC, truy vấn trạng thái                  |
--| **Báo cáo**              | `ReportAlerts/NonZeroAlerts`, `WriteAlertYaml`, `WriteAlertCsv`, `ReportRequirements`                                     | In/tạo file thống kê cuối test                    |
--| **Requirement tracking** | `ReadSpecification`, `GetReqID`, `SetPassedGoal`, `ReportRequirements`                                                    | Liên kết testcase ↔ tài liệu yêu cầu              |

-----------------------------------------------------------------------
--Bài 4 – Phân cấp ID & lọc theo hierarchy
--Mục tiêu:

--Tạo hai process riêng: TX_PROC, RX_PROC.

--Mỗi process NewID("TX"), NewID("RX").

--Bật DEBUG chỉ cho TX bằng SetLogEnable("TX", DEBUG, TRUE).

--Cho mỗi process in 5 dòng DEBUG và 3 dòng INFO.

--Kết quả: console chỉ thấy DEBUG của TX, INFO của cả hai.

-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
context osvvm.OsvvmContext;
-- use osvvm.AlertLogPkg.all;


entity Test13 is

end entity Test13;

architecture tb of Test13 is   

-- ID cha
constant TB_ID: AlertLogIDType := NewID("Test13");
-- ID con
constant TX_ID: AlertLogIDType := NewID("TX");
constant RX_ID: AlertLogIDType := NewID("RX");

begin



-- chi bat DEBUG cua TX


TX_PROC: process
begin

    SetLogEnable(TX_ID, DEBUG, TRUE);
    SetLogEnable(TX_ID, INFO, TRUE);
    wait for 0 ns;

    for i in 0 to 4 loop -- 5 debug
        Log(TX_ID, "TX DEBUG " & to_string(i),DEBUG);
        wait for 10 ns;
    end loop;

    for i in 0 to 2 loop -- 3 info
        Log(TX_ID, "TX INFO " & to_string(i),INFO);
        wait for 10 ns;
    end loop;

    wait;
    
end process;

RX_PROC: process
begin

    SetLogEnable(RX_ID, INFO, TRUE);
    wait for 0 ns;

    for i in 0 to 4 loop -- 5 debug ( se bi tat)
        Log(RX_ID, "RX DEBUG " & to_string(i),DEBUG);
        wait for 10 ns;
    end loop;

    for i in 0 to 2 loop -- 3 info
        Log(RX_ID, "RX INFO " & to_string(i),INFO);
        wait for 10 ns;
    end loop;

    wait;

end process;



TestProc: process
begin

    SetTestName("Test13");
    SetLogEnable(TB_ID,PASSED, TRUE);

    TranscriptOpen;
    SetTranscriptMirror(TRUE);
    wait for 0 ns; wait for 0 ns;


    -- for i in 0 to 9 loop
    --     AffirmIf(TB_ID, i < 10, "Test " & to_string(i)); -- error moi hien log
    --     wait for 10 ns;
    -- end loop;


    wait for 200 ns;

    -- ket thuc som de console ngan gon

    TranscriptClose;
    EndOfTestSummary(ReportAll => TRUE);
    std.env.stop; -- thoat mo phong
    wait;



end process;

end tb;



