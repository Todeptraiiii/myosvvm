library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library OSVVM;
context OSVVM.OSVVMContext;
use osvvm.ScoreboardPkg_slv.all;

library osvvm_common;
context osvvm_common.OsvvmCommonContext;

entity Test8 is 

end entity Test8;

architecture tb of Test8 is

signal burstcov: DelayCoverageIDType;
signal ModelID: AlertLogIDType;


begin

TestProc: process
    variable delaycycles: integer;
    variable fuk1 : std_logic:= '1';
    variable fuk2 : std_logic_vector(7 downto 0):= (others => '1');
begin

    burstcov <= NewID("burstcov");
    ModelID <= NewID("Model");
    wait for 0 ns;
    wait for 0 ns;
    SetTestName("Test8");
    SetLogEnable(ModelID,INFO, TRUE);
    SetLogEnable(ModelID,PASSED, TRUE);
    wait for 100 ns;

    AddBins (burstcov.BurstLengthCov,  80, GenBin(3,11,1));
    AddBins (burstcov.BurstLengthCov,  20, GenBin(109,131,1)) ;

    AddBins (BurstCov.BurstDelayCov,   80, GenBin(12,20,1)) ;  
    AddBins (BurstCov.BurstDelayCov,   20, GenBin(132,156,1)) ;

    AddBins (BurstCov.BeatDelayCov,    85, GenBin(0)) ;    
    AddBins (BurstCov.BeatDelayCov,    10, GenBin(1)) ;     
    AddBins (BurstCov.BeatDelayCov,     5, GenBin(2)) ;  

    for i in 1 to 100 loop
        delaycycles := GetRandPoint(burstcov.BurstLengthCov);
        -- delaycycles := GetRandDelay(burstcov);
        Log( ModelID,
        "delaycycles: " & to_string(delaycycles),
        INFO
        ) ;
        wait for 0 ns;
        -- ICover(burstcov.BurstLengthCov, delaycycles);
    end loop;

    WriteBin(burstcov.BurstLengthCov);
    -- WriteBin(burstcov.BurstDelayCov);
    -- WriteBin(burstcov.BeatDelayCov);
    wait;

end process;

end architecture;

