library interfaces;

package axis32 is new interfaces.axi4s.make ;

library interfaces ;
library ieee ;
use     ieee.std_logic_1164.all ;

entity axi4s_test is
  port (
    clock   :   in  std_ulogic ;
    reset   :   in  std_ulogic ;

    s       :   view interfaces.axi4s.slave of interfaces.axi4s.axis_t ;
    m       :   view interfaces.axi4s.master of work.axis32.axis_t ;
  ) ;
end entity ;

architecture arch of axi4s_test is

begin

end architecture ;
