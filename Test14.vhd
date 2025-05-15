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
--Bài 5 – Báo cáo YAML/CSV
--Mục tiêu:

--Gọi WriteAlertYaml("alerts.yaml") và WriteAlertCsv("alerts.csv") ở cuối test.

--Mở file, xác minh có cột ERROR_COUNT, PASSED_COUNT.

--Thay đổi vài alert, chạy lại – file cập nhật đúng.

--(Dùng thử tiện ích YAML/CSV viewer tuỳ thích.)

-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
context osvvm.OsvvmContext;
-- use osvvm.AlertLogPkg.all;


entity Test14 is

end entity Test14;

architecture tb of Test14 is   

-- ID cha
constant TB_ID: AlertLogIDType := NewID("Test14");
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

    SetTestName("Test14");
    SetLogEnable(TB_ID,PASSED, TRUE);

    -- TranscriptOpen;
    -- SetTranscriptMirror(TRUE);
    wait for 0 ns; wait for 0 ns;


    -- for i in 0 to 9 loop
    --     AffirmIf(TB_ID, i < 10, "Test " & to_string(i)); -- error moi hien log
    --     wait for 10 ns;
    -- end loop;


    wait for 200 ns;
    AlertIf(TRUE, "Demo ERROR o cuoi test", ERROR);


    -- TranscriptClose;

    WriteAlertYaml("alerts",TimeOut => FALSE);
    -- WriteAlertCsv("alerts.csv");
    -- EndOfTestSummary(ReportAll => TRUE);



    std.env.stop; -- thoat mo phong
    wait;



end process;

end tb;



