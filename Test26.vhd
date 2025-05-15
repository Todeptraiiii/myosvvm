--| Nhóm                | Thủ tục / Hàm                                                                                         | Nhiệm vụ                                                                      | Khi dùng                                        |
--| ------------------- | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------- |
--| **Khởi tạo**        | `NewID`                                                                                               | Tạo **CoverageID**, gieo seed ngẫu nhiên                                      | Trước khi AddBins/ICover                        |
--| **Mô hình (Item)**  | `GenBin`, `IllegalBin`, `IgnoreBin` → `AddBins`                                                       | Khai báo các **bin** giá trị / phạm vi                                        | Theo test‑plan item coverage                    |
--| **Mô hình (Cross)** | `AddCross` + nhiều `GenBin`                                                                           | Tạo ma trận quan hệ (đến 20 item)                                             | Kiểm tra tổ hợp thanh ghi, cổng…                |
--| **Tích lũy**        | `ICover`                                                                                              | Ghi giá trị (int / int\_vector) vào mô hình                                   | Clock‑sampling, transaction‑sampling            |
--| **Kết thúc?**       | `IsCovered`                                                                                           | TRUE khi mọi bin đạt goal                                                     | Dừng test nhanh                                 |
--| **Thống kê**        | `GetCov`, `GetItemCount`, `GetTotalCovGoal`                                                           | % cover, số mục đã lấy                                                        | Báo cáo CI                                      |
--| **Random hóc cao**  | `GetRandPoint`, `GetRandBinVal`                                                                       | “Intelligent Coverage” bốc **lỗ hổng**                                        | Giảm mô phỏng từ N·logN xuống ≈ N turn1file17 |
--| **Báo cáo**         | `WriteBin`, `WriteCovHoles`, `FileOpenWriteBin`                                                       | Xuất bảng bin hoặc chỉ “hole”                                                 | Thân thiện requirements tools                   |
--| **Điều khiển**      | `SetIllegalMode`, `SetBinSize`, `SetWeightMode`, `SetCovTarget`, `SetCovThreshold`, `SetCountMode`, … | Tắt ALERT cho bin illegal, tối ưu RAM, chỉnh trọng số random, đặt ngưỡng %... | Nâng cao / tối ưu turn1file9                  |
--| **Transition**      | `TCover`                                                                                              | Bao phủ **chuỗi** giá trị                                                     | FSM, giao thức handshake                        |
--| **Tiện ích**        | `IsInitialized`, `GetSeed`, `SetSeed`, `GetRandIndex`, …                                              | Kiểm tra mô hình, tái lập bug                                                 | Debug, regression                               |

------------------------------------------------------------------------------------------------

--| Bài                                    | Mục tiêu chính                          | Thao tác bắt buộc                                                | Kết quả/Pass khi                                    |
--| -------------------------------------- | --------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
--| **0. Warm‑up**                         | Cài & compile CoveragePkg               | `vcom/ghdl` + context `OsvvmContext`                             | thư viện biên dịch OK                               |
--| **1. Item coverage cơ bản**            | Push bin 1 → 255 (theo ví dụ)           | `GenBin + AddBins`, `ICover` trong vòng lặp                      | `WriteBin` hiển thị 8 bin, % = 100                  |
--| **2. Cross coverage 8 × 8**            | ALU Src1×Src2                           | `AddCross`, `ICover`                                             | `IsCovered` kết thúc sim; `WriteBin` matrix 64 dòng |
--| **3. Detect Done + AlertLog**          | Tích hợp AlertLog                       | Dùng `IsCovered` + `Log`                                         | Khi %<100 ghi DEBUG, khi đủ 100 ghi FINAL           |
--| **4. Illegal & Ignore bin**            | Phân biệt, bật/tắt ALERT                | `IllegalBin`, `IgnoreBin`, `SetIllegalMode`                      | Illegal gây ERROR khi ON, im lặng khi OFF           |
--| **5. Coverage Goals & Weights**        | Mỗi bin goal khác nhau                  | Tham số `AtLeast` trong `AddBins`, xem **random weights**        | Bin goal cao xuất hiện nhiều hơn                    |
--| **6. Intelligent Coverage vs RandInt** | So tốc độ đạt 100 %                     | Thay `RandInt` bằng `GetRandPoint`                               | Số iteration giảm ≥ 4×                              |
--| **7. Coverage Target & Threshold**     | Tạm dừng ở 80 %                         | `SetCovTarget(80)`, `SetThresholding(…)`                         | ICover dừng khi đạt 80 %                            |
--| **8. Transition Coverage**             | FSM idle→run→idle                       | `AddCross` (state\_prev × state\_curr) + `TCover`                | Bao phủ đủ mọi chuyển tiếp                          |
--| **9. Reporting nâng cao**              | Gộp nhiều mô hình                       | `FileOpenWriteBin`, `PrintToCovFile`, `SetReportOptions`         | File txt/HTML duy nhất, chứa PASS/FAIL từng bin     |
--| **10. Merging & Overlap**              | Bins chồng lắp                          | `SetCountMode`, `Bin Merging`                                    | Độ phủ không double‑count                           |
--| **11. Seed control & replay**          | Reproduce bug                           | `GetSeed` log, `SetSeed` run lại                                 | Kết quả deterministic                               |
--| **12. Mini‑project**                   | Packet bus 4 length class × CRC ok/fail | Viết item + cross + intelligent coverage + AlertLog + Scoreboard | CI lấy YAML/Text, 0 ERROR, 100 % cov                |


--| API / Hằng                     | Tác dụng                                                                                                                                                                  | Ghi chú                                     |
--| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
--| `AtLeast => N` trong `AddBins` | Đặt **mục tiêu** (goal) cho từng bin                                                                                                                                      | Mặc định `1`                                |
--| `SetWeightMode(ID, mode)`      | Điều chỉnh **trọng số** khi dùng `GetRandPoint` <br>• `WEIGHT_EQUAL` (default) <br>• `WEIGHT_GOAL` (tỉ lệ theo goal) <br>• `WEIGHT_REMAINING` (tỉ lệ theo **goal‑count**) | Giúp tập trung random vào bin chưa đạt goal |
--| `SetCovTarget(ID, Percent)`    | Cho phép dừng sớm khi độ phủ ≥ % target                                                                                                                                   | Dùng trong regression dài                   |
--| `GetTotalCovGoal(ID)`          | Trả tổng **mục tiêu** (sum AtLeast) của mô hình                                                                                                                           | So sánh số mẫu đã thu thập                  |
--| `GetCov(ID)`                   | Trả % coverage (0…100)                                                                                                                                                    | Phù hợp khi không gọi `IsCovered`           |

------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

entity Test26 is   
end entity;

architecture tb of Test26 is

constant TB_ID : AlertLogIDType := NewID("Test26");
constant SB_ID : ScoreboardIdType := NewID("Scoreboard", TB_ID);
constant COV_ID: CoverageIdType := NewID("Coverage", TB_ID);


begin

    Test_proc: process
        variable R : RandomPType;
        variable i,e : integer;
        variable count: integer := 0;
    begin

        SetTestName("Test26");
        SetLogEnable(TB_ID,PASSED, TRUE);
        SetLogEnable(TB_ID,INFO, TRUE);
        -- SetWeightMode(COV_ID, WEIGHT);
        -- SetCovTarget(COV_ID, 90.0);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);

        wait for 0 ns; wait for 0 ns;
        AddBins(COV_ID,4,GenBin(0,1,1));
        AddBins(COV_ID,3,GenBin(2,4,1));
        AddBins(COV_ID,2,GenBin(5,7,1));
        AddBins(COV_ID,1,GenBin(8,9,1));
        wait for 10 ns;

        loop
            i := GetRandPoint(COV_ID);
            ICover(COV_ID, i);
            Log(TB_ID, "i = " & to_string(i), INFO);
            exit when IsCovered(COV_ID);
        end loop;
        AffirmIfCovered;
        Log(TB_ID, "CovTarget = " & to_string(GetCovTarget(COV_ID)), INFO);

        -- AffirmIfEqual(TB_ID, GetTotalCovGoal(COV_ID), 11, "Da dat goal");
        WriteBin(COV_ID);
        WriteCovHoles(COV_ID); -- in ra hole rong -> neu khong co hole thi khong in ra
        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);

        std.env.stop;

    end process;
    
end architecture;