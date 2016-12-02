--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package util is

function LOG2(C:INTEGER) return INTEGER;

end util;

package body util is

function LOG2(C:INTEGER) return INTEGER is -- C should be >0 
variable TEMP,COUNT:INTEGER; 
begin 
  TEMP:=0; 
  COUNT:=C;
  while COUNT>1 loop 
    TEMP:=TEMP+1; 
    COUNT:=COUNT/2; 
  end loop; 
  
  return TEMP; 
end; 


 
end util;
