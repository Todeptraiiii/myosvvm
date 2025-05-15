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
--Bài 2 – Alert & StopCount
--Mục tiêu:

--Gọi AlertIf(TRUE, "Lỗi giả định", ERROR).

--Đặt SetAlertStopCount(ERROR, 1) để mô phỏng tự dừng ngay khi Alert.

--Quan sát mã thoát (GHDL trả FAILURE exit code 1).

-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
use osvvm.AlertLogPkg.all;


entity Test11 is

end entity Test11;

architecture tb of Test11 is   

constant TB_ID: AlertLogIDType := NewID("Test11");

begin

TestProc: process
begin
    -- Bat INFO va DEBUG cho TB_ID
    SetLogEnable(TB_ID, INFO, TRUE);
    SetLogEnable(TB_ID, DEBUG, TRUE);
    SetAlertStopCount(ERROR, 1); -- Yeu cau mo phong tu dung ngay sau khi gap 1 Error

    wait for 0 ns; wait for 0 ns;

    -- Goi Log 3 lan voi ALWAYS, INFO, DEBUG
    Log(TB_ID, "Xin chao - Always", ALWAYS);
    Log(TB_ID, "Thong tin - Info", INFO);

    AlertIf(TRUE, "Error test", ERROR); -- Goi AlertIf voi 1 Error

    Log(TB_ID, "Day la trace - Debug", DEBUG);

    wait for 100 ns;

    -- ket thuc som de console ngan gon

    ReportAlerts; -- in bang dem
    std.env.stop; -- thoat mo phong



end process;

end tb;



