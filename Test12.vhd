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
--Bài 3 – Affirm & PASSED counter
--Mục tiêu:

--Viết vòng lặp khẳng định AffirmIf(i < 5, ...) cho 10 chu kỳ.

--Báo cáo cuối phải hiện PASSED = 10.

--Thử đổi một điều kiện sai để thấy PASSED giảm, ERROR tăng.

-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
context osvvm.OsvvmContext;
-- use osvvm.AlertLogPkg.all;


entity Test12 is

end entity Test12;

architecture tb of Test12 is   

constant TB_ID: AlertLogIDType := NewID("Test12");

begin

TestProc: process
begin

    SetTestName("Test12");
    SetLogEnable(TB_ID,PASSED, TRUE);

    TranscriptOpen;
    SetTranscriptMirror(TRUE);
    wait for 0 ns; wait for 0 ns;


    for i in 0 to 9 loop
        AffirmIf(TB_ID, i < 10, "Test " & to_string(i)); -- error moi hien log
        wait for 10 ns;
    end loop;


    wait for 100 ns;

    -- ket thuc som de console ngan gon

    TranscriptClose;
    EndOfTestSummary(ReportAll => TRUE);
    std.env.stop; -- thoat mo phong
    wait;



end process;

end tb;



