package hdmi_switch_p is

    type diff_t is record
        p   :   bit ;
        n   :   bit ;
    end record ;

    type diffs_t is array(natural range <>) of diff_t ;

    type hdmi_t is record
        data  : diffs_t(0 to 2) ;
        clock : diff_t ;
    end record ;

    -- Some list of sources
    type input_source_t is (eARC0, eARC1, HDMI0, HDMI2, HDMI3) ;

    type hdmi_inputs_t is array(input_source_t) of hdmi_t ;

    procedure assign(signal x : in hdmi_t ; signal y : out hdmi_t) ;

end package ;

package body hdmi_switch_p is

    procedure assign(signal x : in hdmi_t ; signal y : out hdmi_t) is
    begin
        for idx in x.data'range loop
            y.data(idx) <= x.data(idx) ;
        end loop ;
        y.clock <= x.clock ;
    end procedure ;

end package body ;

use work.hdmi_switch_p.all ;

entity hdmi_switch is
  port (
    hdmi_sel    : input_source_t ;
    hdmi_inputs : in hdmi_inputs_t ;
    hdmi_output : out hdmi_t ;
    hdmi_output2 : out hdmi_t
  ) ;
end entity ;

architecture arch of hdmi_switch is

    signal sel : hdmi_inputs'element ;

    signal hdmi_a : hdmi_t ;
    signal hdmi_b : hdmi_t ;

begin

    assign(hdmi_a, hdmi_b) ;

    -- Works
    sel <= hdmi_inputs(hdmi_sel) ;
    assign(sel, hdmi_output2) ;

    -- Doesn't work
    U_mux : entity work.generic_mux
      generic map (
        elements_t => hdmi_inputs'subtype,
        output_t   => hdmi_output'subtype,
        assign     => assign
      ) port map (
        sel    => hdmi_sel,
        inputs => hdmi_inputs,
        output => hdmi_output
      ) ;

end architecture ;
