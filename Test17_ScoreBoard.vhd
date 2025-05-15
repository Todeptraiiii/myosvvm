--| Nhóm                | Thủ tục / Hàm                                                                                  | Chức năng (nhiệm vụ)                                                                                 | Khi nào dùng?                                                                                  |
--| ------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
--| **ID & khởi tạo**   | `NewID` (5 overloads)                                                                          | Tạo **ScoreboardID** đơn, vector, ma trận; liên kết AlertLogID cha.                                  | Mỗi VC, cổng, hay instance DUT cần scoreboard riêng (in‑order/out‑of‑order). ([GitHub][1])     |
--| **Push**            | `Push` (proc & func, có/không Tag)                                                             | Ghi **ExpectedData** vào FIFO của scoreboard (return cho pipeline nếu dùng hàm).                     | Khi mô hình tham chiếu biết trước giá trị cần so sánh với DUT. ([GitHub][1])                   |
--| **Check**           | `Check` (proc & func, có/không Tag)                                                            | So khớp **ActualData** (từ DUT) với mục đầu FIFO; tăng PASSED/ERROR; hàm trả bool nếu overload func. | Data “đến đúng thứ tự”. Dùng trong `monitor → scoreboard`. ([GitHub][1])                       |
--| **CheckExpected**   | `CheckExpected` (proc & func)                                                                  | Kiểm tra *một giá trị cụ thể* đã được **Push** trước đó (không Pop).                                 | Khi muốn xác minh DUT chưa gửi nhưng reference đã lưu (độ bao phủ). ([GitHub][1])              |
--| **Pop / Peek**      | `Pop`, `Peek` (proc & func)                                                                    | Lấy (và tùy chọn loại bỏ) mục ở đầu FIFO – hỗ trợ kiểm tra tuyến tính, debug.                        | Cần xử lý ngoài scoreboard (ví dụ tính CRC tiếp). ([GitHub][1])                                |
--| **IsEmpty / Empty** | `IsEmpty`, alias `ScoreboardEmpty`                                                             | Trả `TRUE` nếu FIFO rỗng (hết Expected chưa so sánh).                                                | Chờ kết thúc luồng, timeout, hoặc assert “không còn gói treo”. ([GitHub][1])                   |
--| **Find / Flush**    | `Find`, `Flush`                                                                                | Tìm vị trí giá trị (có thể theo Tag) → xoá tới đó.                                                   | In‑order stream nhưng DUT drop/miss gói – cần “đuổi kịp” mô phỏng. ([GitHub][1])               |
--| **FindAndDelete**   | `FindAndDelete`                                                                                | Cho out‑of‑order: xóa *chính* item tìm thấy, giữ các item trước.                                     | Switches / re‑order buffers khi gói tới sai thứ tự. ([GitHub][1])                              |
--| **FindAndFlush**    | `FindAndFlush`                                                                                 | Cho in‑order: flush toàn bộ *đến* item tìm được (kể cả nó).                                          | DUT bỏ qua vài gói đầu, ta muốn bỏ Expected tương ứng. ([GitHub][1])                           |
--| **Thống kê**        | `GetItemCount`, `GetPushCount`, `GetPopCount`, `GetFifoCount`, `GetCheckCount`, `GetDropCount` | Trả số liệu runtime giúp assert coverage/tối ưu test.                                                | Regression kết thúc → `AffirmIf(GetFifoCount(ID)=0, …)` đảm bảo không lệch hàng. ([GitHub][1]) |
--| **Yaml Report**     | `WriteScoreboardYaml`, `GotScoreboards`                                                        | Xuất báo cáo YAML (push/pop/check/drop) cho CI.                                                      | Post‑sim Jenkins/GitLab, thống kê pass/fail từng scoreboard. ([GitHub][1])                     |
--| **Tiện ích khác**   | `IsInitialized`, `GetAlertLogID`, `AllScoreboardsEmpty`                                        | Kiểm tra ID hợp lệ, truy vấn AlertLogID gắn, xác nhận hết sạch FIFO toàn TB.                         | Đầu sim assert setup; cuối sim kết thúc sạch. ([GitHub][1])                                    |

-----------------------------------------------------------------------

--Bài 1 – Push/Check căn bản (pass khi PASSED = 5, ERROR = 0)

--Việc cần làm	Gợi ý
--1. Khởi tạo ScoreboardID	constant SB_ID : ScoreboardIDType := NewID("SB");
--2. Đẩy 5 giá trị	for i in 0 to 4 loop Push(SB_ID, i); end loop;
--3. Sau 10 ns, Check 5 giá trị	Check(SB_ID, i);
--4. Báo cáo	ReportAlerts;

--Khi console báo PASSED = 5, ERROR = 0 ⇒ Bài 1 hoàn thành.

-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_int.all;

entity Test17_ScoreBoard is 
end entity;

architecture sim of Test17_ScoreBoard is
    constant SB_ID : ScoreboardIDType := NewID("SB");

begin


    TestProc: process
    begin

        SetTestName("Test17_ScoreBoard");
        SetReportMode(SB_ID,REPORT_ALL);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);
        wait for 0 ns; wait for 0 ns;

        for i in 0 to 4 loop
            Push(SB_ID, i);
        end loop;

        wait for 10 ns;

        for i in 0 to 5 loop
            Check(SB_ID, i);
        end loop;

        wait for 10 ns;

        AffirmIf(GetFifoCount(SB_ID) = 0, "Fifo is empty");

        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;
        wait;
        
        
    end process;
    
end architecture;



