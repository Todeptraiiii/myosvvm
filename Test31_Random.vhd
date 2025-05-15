-- | Nhóm                                     | Thủ tục / Hàm                                                              | Chức năng chính                                          | Ghi chú dùng                     |
-- | ---------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------- | -------------------------------- |
-- | **Khởi tạo / Seed**                      | `InitSeed(seed : integer)`<br>`InitSeed(seed_str : string)`                | Nạp seed, reset PRNG                                     | Chuỗi được băm CRC‑32 thành seed |
-- |                                          | `GetSeed return integer`                                                   | Trả seed hiện thời                                       | Ghi log để replay                |
-- |                                          | `ResetRandomState` *(2025)*                                                | Quay về đầu luồng (replay trong run)                     | Không đổi seed                   |
-- | **Random nguyên**                        | `RandInt(lo,hi)`                                                           | Số nguyên bao gồm cả lo+hi                               | 32‑bit                           |
-- |                                          | `RandIntExcl(lo,hi,ExcludeVector)`                                         | Sinh trong phạm vi nhưng bỏ giá trị                      | Hỗ trợ “tránh lặp lại”           |
-- |                                          | `RandIntV(IntVector)`                                                      | Chọn một phần tử ngẫu nhiên từ vector giá trị            |                                  |
-- | **Random bit / bool**                    | `RandBit(prob)`                                                            | ‘1’ với xác suất *prob*                                  | `prob` : real 0…1                |
-- |                                          | `RandBool(prob)`                                                           | boolean tương đương                                      | TRUE = ‘1’                       |
-- | **Random std\_logic\_vector / unsigned** | `RandSlv(width)` / `RandUnsigned(width)`                                   | Chuỗi bit tùy chiều dài                                  |                                  |
-- |                                          | `RandSlv(lo,hi)` / `RandUnsigned(lo,hi)`                                   | Sinh giá trị 2^n‑bit trong phạm vi                       |                                  |
-- |                                          | `RandSlvExcl(lo,hi,ExcludeVector)`                                         | … nhưng bỏ những giá trị                                 |                                  |
-- | **Random kiểu thời gian / real**         | `RandReal(lo,hi)`                                                          | Real trong khoảng                                        |                                  |
-- |                                          | `RandTime(lo,hi,unit)`                                                     | Thời gian ngẫu nhiên                                     | unit = fs, ps, ns …              |
-- | **Random mảng (phân phối)**              | `RandIntArray(IntArray, ProbArray)`                                        | Chọn giá trị theo trọng số xác suất                      | ProbArray sum ≤ 1.0              |
-- | **Điều khiển phân phối**                 | `SetRandMode(Mode)`<br>   • `RAND_MODE_UNIFORM`<br>   • `RAND_MODE_BIASED` | Chế độ lấy số *Uniform* (mặc định) hay *Biased* (ít lặp) | Ảnh hưởng một stream             |
-- | **Truy vấn/Debug**                       | `GetRandIndex return integer`                                              | Số lần gọi Rand\* tới nay                                | Hữu ích khi log bug điểm #       |
-- |                                          | `GetRandMax return integer`                                                | Max giá trị PRNG nội (2³²‑1)                             |                                  |
-- | **Xác suất nâng cao**                    | `RandCovered(ID)`                                                          | Lấy giá trị từ Intelligent‑Coverage còn “hole”           | Wrapper: `GetRandBinVal`         |
-- | **Hàm tiện ích khác**                    | `Swap(RandPType, RandPType)`                                               | Hoán đổi trạng thái 2 luồng                              |                                  |
-- |                                          | `CopyState(src,dst)`                                                       | Sao chép PRNG state                                      | Phục vụ snapshot                 |

------------------------------------------------------------------------------------
-- | Việc cần làm                                            | Gợi ý                               |
-- | ------------------------------------------------------- | ----------------------------------- |
-- | 1. Khai báo `shared variable R : RandomPType;`          |                                     |
-- | 2. `R.InitSeed(1);` → sinh 5 số `RandInt(0,99)` --> log | dùng `Log(DEBUG, …)` hoặc `report`. |
-- | 3. Gọi `R.InitSeed(1)` **lần 2**, sinh lại 5 số         |                                     |
-- | 4. Dùng `AffirmIf` so sánh 2 vector kết quả             | nếu giống → **PASSED**              |


------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;


entity Test31_Random is
end entity;

architecture tb of Test31_Random is

begin

    test_proc: process
        variable R : RandomPType;
        variable a : integer_vector(1 to 4);
        variable b : integer_vector(1 to 4);
    begin

        SetTestName("Test31_Random");
        SetLogEnable(PASSED, TRUE);
        TranscriptOpen;
        SetTranscriptMirror(TRUE);

        wait for 0 ns; wait for 0 ns;

        R.InitSeed(1);
        for i in 1 to 4 loop
            a(i) := R.RandInt(0,99);
            Log("a(" & to_string(i) & ") = " & to_string(a(i)));
        end loop;

        R.InitSeed(1);
        for i in 1 to 4 loop
            b(i) := R.RandInt(0,99);
            Log("b(" & to_string(i) & ") = " & to_string(b(i)));
        end loop;
        -- wait for 100 ns;

        AffirmIfEqual(a, b, "a = b");
        TranscriptClose;
        EndOfTestSummary(ReportAll => TRUE);
        std.env.stop;
        wait;
    end process;




end architecture;
