package hdmi_switch_p is

    type diff_t is record
        p   :   bit ;
        n   :   bit ;
    end record ;

    view master of diff_t is
        p   :   out ;
        n   :   out ;
    end view ;

    type diffs_t is array(natural range <>) of diff_t ;

    alias diff_slave is master'converse ;

    type hdmi_t is record
        tmds  : diffs_t(0 to 2) ;
        clock : diff_t ;
    end record ;

    view diff_master of hdmi_t is
        tmds  : view (diff_master) ;
        clock : view diff_master ;
    end view ;

    alias slave is master'converse ;

    -- Some list of sources
    type input_source_t is (eARC0, eARC1, HDMI0, HDMI2, HDMI3) ;

    type hdmi_inputs_t is array(input_source_t) of hdmi_t ;

    procedure assign(signal x : view diff_slave of diff_t ; signal y : view diff_master of diff_t) ;

    alias diff_assign is assign [diff_slave, diff_master] ;

    procedure assign(signal x : view slave of hdmi_t; signal y : view master of hdmi_t) ;

    alias hdmi_assign is assign [slave, master] ;

end package ;

package body hdmi_switch_t is

    procedure assign(signal x : view slave of diff_t ; signal y : view master of diff_t) is
    begin
        y.p <= x.p ;
        y.n <= x.n ;
    end procedure ;


    procedure assign(signal x : view slave of hdmi_t ; signal y : view master of hdmi_t) is
    begin
        for idx in x.tmds loop
            assign(x.tmds(idx), y.tmdx(idx)) ;
        end loop ;
        assign(x.clock, y.clock) ;
    end procedure ;


end package body ;

use work.hdmi_switch_p.all ;
use work.generic_mux.all ;

entity hdmi_switch is
  port (
    hdmi_sel    : input_source_t ;
    hdmi_inputs : view (slave) of hdmi_inputs_t ;
    hdmi_output : view master of hdmi_t
  ) ;
end entity ;

architecture arch of hdmi_switch is

begin

    U_mux : generic_mux
      generic map (
        elements_t => hdmi_inputs_t,
        assign     => hdmi_assign
      ) port map (
        sel    => hdmi_sel,
        inputs => hdmi_inputs,
        output => hdmi_output
      ) ;

end architecture ;
