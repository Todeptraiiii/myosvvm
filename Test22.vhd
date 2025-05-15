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

--Bài 6 – Tags (song song nhiều frame)
--Việc cần làm	Gợi ý
--1. Khai báo Tag kiểu integer	constant F1 : integer := 1;
--2. Push xen kẽ	Push(SB_ID, Data, Tag => F1); v.v.
--3. Check theo thứ tự frames	Scoreboard tự tách luồng; cuối test FIFO = 0

-----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_int.all;

entity Test22 is 
end entity;

architecture sim of Test22 is

    constant TB_ID : AlertLogIDType := NewID("TB");
    constant SB_ID : ScoreboardIDType := NewID("SB", TB_ID);
    constant F1 : string := "F1";
    constant F2 : string := "F2";

    -- function convert character to integer
    function char_to_int(c : character) return integer is
    begin
        case c is
            when '0' => return 0;
            when '1' => return 1;
            when '2' => return 2;
            when '3' => return 3;
            when '4' => return 4;
            when '5' => return 5;
            when '6' => return 6;
            when '7' => return 7;
            when '8' => return 8;
            when '9' => return 9;
            when 'A' => return 10;
            when 'B' => return 11;
            when 'C' => return 12;
            when 'D' => return 13;
            when 'E' => return 14;
            when 'F' => return 15;
            when 'G' => return 16;
            when 'H' => return 17;
            when 'I' => return 18;
            when 'J' => return 19;
            when 'K' => return 20;
            when 'L' => return 21;
            when 'M' => return 22;
            when 'N' => return 23;
            when 'O' => return 24;
            when 'P' => return 25;
            when 'Q' => return 26;
            when 'R' => return 27;
            when 'S' => return 28;
            when 'T' => return 29;
            when 'U' => return 30;
            when 'V' => return 31;
            when 'W' => return 32;
            when 'X' => return 33;
            when 'Y' => return 34;
            when 'Z' => return 35;
            when others => return -1;
        end case;
    end function;

    
begin

    TestProc: process
    begin

        SetTestName("Test22");
        SetReportMode(SB_ID,REPORT_ALL);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);
        wait for 0 ns; wait for 0 ns;

        Log(TB_ID, "Push xen ke 2 tag");

        Push(SB_ID,F1, char_to_int('A'));
        Log(TB_ID, "Push :" & 'A' & " Tag: " & F1);
        Push(SB_ID,F2, char_to_int('D'));
        Log(TB_ID, "Push :" & 'D' & " Tag: " & F2);
        Push(SB_ID,F1, char_to_int('B'));
        Log(TB_ID, "Push :" & 'B' & " Tag: " & F1);
        Push(SB_ID,F2, char_to_int('E'));
        Log(TB_ID, "Push :" & 'E' & " Tag: " & F2);
        Push(SB_ID,F1, char_to_int('C'));
        Log(TB_ID, "Push :" & 'C' & " Tag: " & F1);

        wait for 10 ns; -- gia lap xu ly
        -- Check theo thứ tự frames ( F1 -> F2)
        Check(SB_ID, F1, char_to_int('A'));
        Check(SB_ID, F1, char_to_int('B'));
        Check(SB_ID, F2, char_to_int('D'));
        Check(SB_ID, F2, char_to_int('E'));
        Check(SB_ID, F1, char_to_int('C'));

        Log(TB_ID, "So gia tri trong fifo: " & to_string(GetFifoCount(SB_ID)));

        AffirmIfEqual(GetFifoCount(SB_ID), 0, "Fifo is empty");

        wait for 100 ns;

        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;
        wait;
        
        
    end process;
    
end architecture;



