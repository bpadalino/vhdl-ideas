--library interfaces ;
--package aximm256 is new interfaces.axi4mm.make ;

library ieee ;
    use ieee.std_logic_1164.all ;

library interfaces ;
use interfaces.io.all ;
use interfaces.axi4mm.all ;
use interfaces.axi4l.all ;
use interfaces.pcie.all ;

entity aximm_pcie is
  port (
    clock       :   in  std_ulogic ;
    resetn      :   in  std_ulogic ;
    config      :   view interfaces.axi4l.slave of interfaces.axi4l.axil32_t ;
    dma         :   view interfaces.axi4mm.master of interfaces.axi4mm.aximm256.aximm_t ;
    interrupt   :   out std_ulogic ;

    pcie        :   view interfaces.pcie.endpoint of interfaces.pcie.pcie_t ;
  ) ;
end entity ;

architecture arch of aximm_pcie is

begin

end architecture ;
