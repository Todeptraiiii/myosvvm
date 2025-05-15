
-- | API                                                                                                                                                | Kiểu                     | Tác dụng ngắn gọn                                                                                                                                   | Ghi chú                                            | Tài liệu |
-- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- | -------- |
-- | `TranscriptOpen(Status, Path [,Kind]), TranscriptOpen(Path [,Kind]), impure function TranscriptOpen(Path [,Kind]) return FILE_OPEN_STATUS`         | procedure / function     | Mở (hoặc tạo) file transcript và gắn nó vào **TranscriptFile**. Khi mở, mọi `Print`, `WriteLine`, `alert`, `log`, … sẽ ghi vào file thay vì STDOUT. | `Kind` mặc định `WRITE_MODE` (append chưa hỗ trợ). |          |
-- | `TranscriptClose`                                                                                                                                  | procedure                | Đóng `TranscriptFile`; các lệnh in sau đó quay về STDOUT.                                                                                           |                                                    |          |
-- | `IsTranscriptOpen return boolean`                                                                                                                  | impure function          | TRUE khi file đang mở.                                                                                                                              | Dùng tránh ghi vào file đóng.                      |          |
-- | `WriteLine(buf)`                                                                                                                                   | procedure                | Ghi **line buffer** (std.textio) vào file nếu mở, ngược lại STDOUT.                                                                                 | Buffer do `swrite`, `hwrite`, … tạo.               |          |
-- | `Print(string)`                                                                                                                                    | procedure                | Ghi chuỗi + newline giống `WriteLine`, nhưng trực tiếp từ string.                                                                                   | Tiện log ngắn.                                     |          |
-- | `BlankLine(count := 1)`                                                                                                                            | procedure                | In *count* dòng trắng (gọi `Print("")`).                                                                                                            | Dọn log cho dễ đọc.                                |          |
-- | `SetTranscriptMirror(A := TRUE)`                                                                                                                   | procedure                | Bật/ tắt **mirror mode** – `Print`/`WriteLine` ghi **cả** file lẫn STDOUT.                                                                          | Gọi không tham số → bật.                           |          |
-- | `IsTranscriptMirrored return boolean`                                                                                                              | impure function          | TRUE khi mirror mode đang bật.                                                                                                                      | Kiểm tra trước khi in kép.                         |          |
-- | `TranscriptFile`                                                                                                                                   | **internal file object** | Dùng trực tiếp trong `writeline(TranscriptFile, buf)` khi muốn toàn quyền định dạng.                                                                | Chỉ hợp lệ sau `TranscriptOpen`.                   |          |


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;
use std.textio.all ;


entity Test34_Transcript is
end entity;

architecture tb of Test34_Transcript is

begin

    test_proc: process
        variable buf : line;
    begin

        TranscriptOpen("Transcript.txt", APPEND_MODE);
        Print("=== Test started ===");

        swrite(buf, "Vector = ");
        hwrite(buf, x"ABCDEFABCD123");
        writeline(buf);

        BlankLine(2); -- khoang trang 2 dong

        SetTranscriptMirror(TRUE);
        Print("Mirrored line");

        TranscriptClose;

        Print("This line printed to console");

        wait for 100 ns;

        std.env.stop;
    end process;


end architecture;
