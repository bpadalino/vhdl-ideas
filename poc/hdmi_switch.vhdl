package hdmi_switch_p is

    type diff_t is record
        p   :   bit ;
        n   :   bit ;
    end record ;

    type diffs_t is array(natural range <>) of diff_t ;

    view diff_master of diff_t is
        p   :   out ;
        n   :   out ;
    end view ;

    --view diff_slave of diff_t is
    --    p   :   in ;
    --    n   :   in ;
    --end view ;

    alias diff_slave is diff_master'converse ;

    type hdmi_t is record
        data  : diffs_t(0 to 2) ;
        clock : diff_t ;
    end record ;

    view hdmi_master of hdmi_t is
        data  : view (diff_master) ;
        clock : view diff_master ;
    end view ;

    --view hdmi_slave of hdmi_t is
    --    data  : view (diff_slave) ;
    --    clock : view diff_slave ;
    --end view ;

    alias hdmi_slave is hdmi_master'converse ;

    -- Some list of sources
    type input_source_t is (eARC0, eARC1, HDMI0, HDMI2, HDMI3) ;

    type hdmi_inputs_t is array(input_source_t) of hdmi_t ;

    procedure assign(signal x : view diff_slave of diff_t ; signal y : view diff_master of diff_t) ;

    --alias diff_assign is assign [diff_slave, diff_master] ;

    procedure hdmi_assign(signal x : view hdmi_slave of hdmi_t; signal y : view hdmi_master of hdmi_t) ;

end package ;

package body hdmi_switch_p is

    procedure assign(signal x : view diff_slave of diff_t ; signal y : view diff_master of diff_t) is
    begin
        y.p <= x.p ;
        y.n <= x.n ;
    end procedure ;

    procedure hdmi_assign(signal x : view hdmi_slave of hdmi_t ; signal y : view hdmi_master of hdmi_t) is
    begin
        for idx in x.data'range loop
            assign(x.data(idx), y.data(idx)) ;
        end loop ;
        assign(x.clock, y.clock) ;
    end procedure ;

end package body ;

use work.hdmi_switch_p.all ;

entity hdmi_switch is
  port (
    hdmi_sel    : input_source_t ;
    hdmi_inputs : view (hdmi_slave) of hdmi_inputs_t ;
    hdmi_output : view hdmi_master of hdmi_t ;
    hdmi_output2 : view hdmi_master of hdmi_t
  ) ;
end entity ;

architecture arch of hdmi_switch is

    signal sel : hdmi_inputs'element ;

begin

    -- Works
    sel <= hdmi_inputs(hdmi_sel) ;
    hdmi_assign(sel, hdmi_output2) ;

    -- Doesn't work
    U_mux : entity work.generic_mux
      generic map (
        elements_t => hdmi_inputs'subtype,
        output_t   => hdmi_output'subtype,
        assign     => hdmi_assign
      ) port map (
        sel    => hdmi_sel,
        inputs => hdmi_inputs,
        output => hdmi_output
      ) ;

end architecture ;
