library ieee ;
use ieee.std_logic_1164.all ;

use work.io.all ;

package pcie is

    type pcie_t is record
        clock   : std_ulogic ;
        resetn  : std_ulogic ;
        smbus   : i2c.i2c_t ;
        jtag    : jtag.jtag_t ;
        tx      : diffpair.diffpairs_t ;
        rx      : diffpair.diffpairs_t ;
    end record ;

    view rootport of pcie_t is
        clock  : out ;
        resetn : out ;
        smbus  : view i2c.driver ;
        jtag   : view jtag.controller ;
        tx     : out ;
        rx     : in ;
    end view ;

    view endpoint of pcie_t is
        clock  : in ;
        resetn : in ;
        smbus  : view i2c.driver ;
        jtag   : view jtag.device ;
        tx     : out ;
        rx     : in ;
    end view ;

    --procedure connect(signal rc : view rootport of pcie_t ; signal ep : view endpoint of pcie_t) ;
    procedure connect(signal rc : inout pcie_t ; signal ep : inout pcie_t) ;

    procedure collect_rootport(
        signal clock : in std_ulogic ;
        signal resetn : in std_ulogic ;
        signal smbus : inout i2c.i2c_pins_t ;
        signal jtag : inout jtag.jtag_t ;
        signal tx : in diffpair.diffpairs_t ;
        signal rx : out diffpair.diffpairs_t ;
        signal pcie : inout pcie_t
    ) ;

    procedure collect_endpoint(
        signal clock : out std_ulogic ;
        signal resetn : out std_ulogic ;
        signal smbus : inout i2c.i2c_pins_t ;
        signal jtag : inout jtag.jtag_t ;
        signal tx : in diffpair.diffpairs_t ;
        signal rx : out diffpair.diffpairs_t ;
        signal pcie : inout pcie_t
    ) ;

    subtype x1_t  is pcie_t( tx(0 to  0), rx(0 to  0) ) ;
    subtype x2_t  is pcie_t( tx(0 to  1), rx(0 to  1) ) ;
    subtype x4_t  is pcie_t( tx(0 to  3), rx(0 to  3) ) ;
    subtype x8_t  is pcie_t( tx(0 to  7), rx(0 to  7) ) ;
    subtype x16_t is pcie_t( tx(0 to 15), rx(0 to 15) ) ;

end package ;

package body pcie is

    --procedure connect(signal rc : view rootport of pcie_t ; signal ep : view endpoint of pcie_t) is
    procedure connect(signal rc : inout pcie_t; signal ep : inout pcie_t) is
    begin
        -- Why doesn't this work when the views are used for the assignments?
        ep.clock <= rc.clock ;
        ep.resetn <= rc.resetn ;
        -- would need to connect to some pins ...
        -- ... then to the interface
        --i2c.assign(rc.smbus, smbus) ;
        --i2c.assign(smbus, ep.smbus) ;
        jtag.assign(rc.jtag, ep.jtag) ;
        diffpair.connect(rc.tx, ep.rx) ;
        diffpair.connect(ep.tx, rc.rx) ;
    end procedure ;

    procedure collect_rootport(
        signal clock : in std_ulogic ;
        signal resetn : in std_ulogic ;
        signal smbus : inout i2c.i2c_pins_t ;
        signal jtag : inout jtag.jtag_t ;
        signal tx : in diffpair.diffpairs_t ;
        signal rx : out diffpair.diffpairs_t ;
        signal pcie : inout pcie_t
    ) is
    begin
        pcie.clock <= clock ;
        pcie.resetn <= resetn ;
        --pcie.smbus <= smbus ;
        pcie.jtag <= jtag ;
        pcie.tx <= tx ;
        rx <= pcie.rx ;
    end procedure ;

    procedure collect_endpoint(
        signal clock : out std_ulogic ;
        signal resetn : out std_ulogic ;
        signal smbus : inout i2c.i2c_pins_t ;
        signal jtag : inout jtag.jtag_t ;
        signal tx : in diffpair.diffpairs_t ;
        signal rx : out diffpair.diffpairs_t ;
        signal pcie : inout pcie_t
    ) is
    begin
        clock <= pcie.clock ;
        resetn <= pcie.resetn ;
        --pcie.smbus <= smbus ;
        pcie.jtag <= jtag ;
        pcie.tx <= tx ;
        rx <= pcie.rx ;
    end procedure ;

end package body ;
