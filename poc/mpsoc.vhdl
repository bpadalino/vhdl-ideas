use work.axi4.resp_t ;
use work.axi4l.axil32_t ;
use work.axi4mm.aximm_t ;
use work.memory.memory_t ;
use work.axi4l.manager ;
use work.axi4mm.subordinate ;

package mpsoc is

    -- Generics to setup CPU?
    -- Public interface different than private interface?
    type mpsoc_api_t is protected
        -- Public API

        -- Reset
        -- TODO: Handle multiple clock domains
        procedure por(x : bit) ;
        procedure set_clock_frequency(x : real) ;

        -- AXI4-Lite Interface (blocking)
        impure function read(address : natural ; data : out bit_vector) return resp_t ;
        impure function write(address : natural ; data : bit_vector) return resp_t ;

        -- AXI4-MM transaction (blocking)
        impure function transact(x : aximm_transaction_t) return aximm_transaction_response_t ;

        -- Interrupts
        procedure clear_interrupt(x : natural) ;
        procedure wait_on_interrupt(x : natural) ;

        -- Private API - how to separate?
        procedure drive(signal x : view manager of axil32_t) ;
        procedure drive(signal x : view subordinate of aximm_t ; variable memory : inout memory_t) ;
        procedure drive_clock(signal clock : out  bit ; signal resetn : out bit) ;
        procedure drive_interrupts(signal ints : in bit_vector) ;
    end protected ;


end package ;

package body mpsoc is

    type mpsoc_api_t is protected body
        variable reset : bit := '1' ;
        variable half_period : time ;
        variable interrupts : bit_vector(15 downto 0) ;
        procedure por(x : bit) is
        begin
            reset := x ;
        end procedure ;

        function read(address : natural ; data : out bit_vector) return resp_t is
        begin

        end function ;
        function write(address : natural ; data : bit_vector) return resp_t is
        begin

        end function ;

        procedure drive(signal x : view work.axi4l.axil_manager of axil32_t) is
        begin

        end procedure ;

        procedure drive(signal x : view work.axi4mm.aximm_subordinate of aximm_t ; variable memory : inout memory_t) is
        begin

        end procedure ;

        procedure drive_interrupts(x : bit_vector) is
        begin
            interrupts := x ;
        end procedure ;

        procedure clear_interrupt(x : natural) is
        begin
            interrupts(x) := '0' ;
        end procedure ;

        procedure wait_on_interrupt(x : natural) is
        begin
            -- Edge or level config?
            wait until rising_edge(interrupts(x)) ;
        end procedure ;

        procedure set_clock_frequency(x : real) is
        begin
            half_period := (1.0/(2.0*x)) * 1 sec ;
        end procedure ;

        procedure drive_clock(signal clock : inout bit ; signal resetn : out bit) is
        begin
            if( reset = '1' ) then
                clock <= '1' ;
                reset <= '1' ;
            else
                reset <= '0' ;
                clock <= not clock after half_period ;
            end if ;
        end procedure ;
    end protected body ;

end package body ;

use work.mpsoc.mpsoc_api_t ;
use work.memory.memory_t ;

entity mpsoc_model is
  port (
    api         :   inout mpsoc_api_t ;
    memory      :   inout memory_t ;

    pl_clk0     :   out bit ;
    pl_resetn0  :   out bit ;

    m_axi_hpm_fpd_clock : in bit ;
    m_axi_hpm_fpd       : view manager of axil32_t ;

    s_axi_hpc0_fpd_clock : in bit ;
    s_axi_hpc0_fpd       : view subordinate of aximm_t ;

    interrupts : in bit_vector(15 downto 0)
  ) ;
end entity ;

architecture arch of mpsoc_model is

begin

    -- Drive this stuff
    api.drive(mpsoc_axil_m) ;
    api.drive(mpsoc_aximm_s, memory) ;
    api.drive_interrupts(interrupts) ;

end architecture ;
