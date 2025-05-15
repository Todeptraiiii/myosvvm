library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

library osvvm_common;
context osvvm_common.OsvvmCommonContext;

entity Test9 is 

end entity Test9;

architecture tb of Test9 is

signal burstcov: DelayCoverageIDType;
signal ModelID: AlertLogIDType;


begin

TestProc: process
    variable ReadyBeforeValid, ReadyDelayCycles : integer ; 

begin

    burstcov <= NewID("burstcov");
    ModelID <= NewID("Model");
    wait for 0 ns;
    wait for 0 ns;
    SetTestName("Test9");
    SetLogEnable(ModelID,INFO, TRUE);
    SetLogEnable(ModelID,PASSED, TRUE);
    wait for 100 ns;

    AddBins (BurstCov.BurstLengthCov,  80, GenBin(3,11,1)) ;
    AddBins (BurstCov.BurstLengthCov,  20, GenBin(109,131,1)) ; 

    AddCross(BurstCov.BurstDelayCov,   65, GenBin(0), GenBin(2,8,1)) ;     -- 65% Ready Before Valid, small delay
    AddCross(BurstCov.BurstDelayCov,   10, GenBin(0), GenBin(108,156,1)) ; -- 10% Ready Before Valid, large delay
    AddCross(BurstCov.BurstDelayCov,   15, GenBin(1), GenBin(2,8,1)) ;     -- 15% Ready After Valid, small delay
    AddCross(BurstCov.BurstDelayCov,   10, GenBin(3,7,1), GenBin(108,156,1)) ; -- 10% Ready After Valid, large delay

    AddCross(BurstCov.BeatDelayCov,    85, GenBin(0), GenBin(0)) ;       -- 85% Ready Before Valid, no delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(0), GenBin(1)) ;       --  5% Ready Before Valid, 1 cycle delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(1), GenBin(0)) ;       --  5% Ready After Valid, no delay
    AddCross(BurstCov.BeatDelayCov,     5, GenBin(1), GenBin(1)) ;       --  5% Ready After Valid, 1 cycle delay 

    for i in 1 to 100 loop

        (ReadyBeforeValid, ReadyDelayCycles)  := GetRandPoint(BurstCov.BurstDelayCov);

        Log( ModelID,
        "ReadyBeforeValid: " & to_string(ReadyBeforeValid)
        & " ReadyDelayCycles: " & to_string(ReadyDelayCycles),
        INFO
        ) ;
        wait for 0 ns;
    end loop;

    WriteBin(burstcov.BurstLengthCov);
    -- WriteBin(burstcov.BurstDelayCov);
    -- WriteBin(burstcov.BeatDelayCov);
    wait;

end process;

end architecture;

