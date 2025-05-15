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
--Bài 6 – Requirement tracking
--Mục tiêu:

--Tạo file spec.txt với 3 dòng “REQ001;Frame ≤ 1500”, …

--Trong test, ReadSpecification("spec.txt").

--Mỗi lần check AffirmIf, gắn GetReqID("REQ001").

--Gọi ReportRequirements.

--Bảng cuối test phải liệt kê REQ001 đã PASSED ≥ 1.

-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library osvvm;
context osvvm.OsvvmContext;
-- use osvvm.AlertLogPkg.all;


entity Test15 is

end entity Test15;

architecture tb of Test15 is   

-- ID cha
constant TB_ID: AlertLogIDType := NewID("Test15");
-- ID con
constant TX_ID: AlertLogIDType := NewID("TX");
constant RX_ID: AlertLogIDType := NewID("RX");

-- Requirement ID declaration

constant REQ1 : integer := GetReqID("REQ001"); -- Frame length ≤ 1500
constant REQ2 : integer := GetReqID("REQ002"); -- CRC correct
constant REQ3 : integer := GetReqID("REQ003"); -- Payload not all zero



begin


    INNIT_PROC: process
        variable FrameLen : integer := 1400;
        variable CRC_OK   : boolean := FALSE;
        variable Payload  : integer := 0;
    begin

        ReadSpecification("spec.txt");
        SetPassedGoal(REQ1, 1);
        -- SetPassedGoal(REQ2, 1);
        SetLogEnable(INFO,TRUE);
        SetLogEnable(PASSED,TRUE);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);
        wait for 0 ns;

        AffirmIf(REQ1,FrameLen = 1500,"Frame length <= 1500",TRUE); -- messge display reply on level INFO
        AffirmIf(REQ2,not CRC_OK,"CRC OK",TRUE);

        AffirmIf(REQ3,Payload = 0,"Payload all zero",TRUE);

        EndOfTestSummary(ReportAll => TRUE);
        TranscriptClose;
        wait for 100 ns;
        std.env.stop;

        wait;
    end process;

end tb;



