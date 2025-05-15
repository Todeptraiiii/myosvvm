library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library osvvm;
    context osvvm.OsvvmContext;


entity Test1 is
    -- port
    -- (    
    -- );

end entity;

architecture rtl of Test1 is

signal cov1: CoverageIDType;

begin


TestProc: process
begin

    cov1 <= NewID("Cov1"); -- Contruct the Coverage Model
    wait for 0 ns; -- update Cov;
    AddBins(cov1,70, GenBin(1, 3));                                 
    AddBins(Cov1,20, GenBin(4,252,2)) ;
    AddBins(Cov1,10, GenBin(253,255)) ;
    SetWeightMode (Cov1, REMAIN); 

    for i in 0 to 31 loop
        ICover(Cov1, i);
        exit when IsCovered(Cov1); -- done? 
    end loop;
        WriteBin(Cov1); -- Print Results
        wait;
end process;    

end architecture;