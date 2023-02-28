library interfaces ;

package aximm_256 is new interfaces.axi4mm.make ;

library interfaces ;
library ieee ;
use     ieee.std_logic_1164.all ;

entity axi4mm_test is
  port (
   clock :  in std_ulogic ;
   reset :  in std_ulogic ;

   m     :  view interfaces.axi4mm.master of interfaces.axi4mm.aximm_t ;
   s     :  view interfaces.axi4mm.slave of work.aximm_256.aximm_t
  ) ;
end entity ;

architecture arch of axi4mm_test is

begin

end architecture ;
