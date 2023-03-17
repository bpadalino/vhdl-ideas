use std.reflection.all ;

package mirror is

    type mirror_array is array(natural range <>) of value_mirror ;

    shared variable arr : mirror_array(0 to 10) ;

end package ;

use work.mirror.all ;
use std.reflection.all ;

entity test is
end entity ;

architecture arch of test is

    type a_t is record
        a : integer ;
        b : real ;
    end record ;

    type b_t is record
        x : real ;
        y : time ;
    end record ;

    signal a : a_t := ( a => 10, b => 1.01 ) ;
    signal b : b_t := ( x => 2.01, y => 2000 fs ) ;

    constant value : time := 1 hr ;

    impure function extract(variable rec : inout record_value_mirror ; x : string) return real is
        variable v : value_mirror := rec.get(x) ;
        variable fv : floating_value_mirror := v.to_floating ;
    begin
        return fv.value ;
    end function ;

    impure function extract(variable rec : inout record_value_mirror ; x : string) return integer is
        variable v : value_mirror := rec.get(x) ;
        variable iv : integer_value_mirror := v.to_integer ;
    begin
        return iv.value ;
    end function ;

    impure function extract(variable rec : inout record_value_mirror ; x : string) return time is
        variable v : value_mirror := rec.get(x) ;
        variable pv : physical_value_mirror := v.to_physical ;
        variable ps : physical_subtype_mirror := pv.get_subtype_mirror ;
        variable idx : index := pv.unit_index ;
        constant scale : natural := ps.scale(idx) ;
    begin
        for i in 0 to ps.units_length+10 loop
            report "name(" & to_string(i) & "): " & ps.unit_name(i) ;
        end loop ;
        report "scale : " & to_string(scale) ;
        report "value : " & to_string(pv.value) ;
        report "name  : " & ps.unit_name(idx) ;
        return pv.value * 1 ps ;
    end function ;

    impure function from(variable x : inout std.reflection.value_mirror) return a_t is
        variable sm : subtype_mirror := x.get_subtype_mirror ;
        constant simple_name : string := sm.simple_name ;
        variable rv : a_t ;
    begin
        assert x.get_value_class = CLASS_RECORD report "Invalid class for a_t: " & to_string(x.get_value_class) ;
        assert simple_name = "a_t" report "Invalid value mirror for a_t: " & simple_name ;
        make : block
            variable rec : record_value_mirror := x.to_record ;
        begin
            rv.a := extract(rec, "a") ;
            rv.b := extract(rec, "b") ;
        end block ;
        return rv ;
    end function ;

    impure function from(variable x : inout std.reflection.value_mirror) return b_t is
        variable sm : subtype_mirror := x.get_subtype_mirror ;
        constant simple_name : string := sm.simple_name ;
        variable rv : b_t ;
    begin
        assert x.get_value_class = CLASS_RECORD report "Invalis class for b_t: " & to_string(x.get_value_class) ;
        assert simple_name = "b_t" report "Invalid value mirror for b_t: " & simple_name ;
        make : block
            variable rec : record_value_mirror := x.to_record ;
        begin
            -- Populate rv with 'x' and 'y'
            rv.x := extract(rec, "x") ;
            rv.y := extract(rec, "y") ;
        end block ;
        return rv ;
    end function ;

    impure function "="(variable l, r : inout enumeration_value_mirror) return boolean is
    begin
        return l.pos = r.pos ;
    end function ;

    impure function "="(variable l, r : inout integer_value_mirror) return boolean is
    begin
        return l.value = r.value ;
    end function ;


    impure function "="(variable l, r : inout floating_value_mirror) return boolean is
    begin
        return l.value = r.value ;
    end function ;

    impure function "="(variable l, r : inout physical_value_mirror) return boolean is
    begin
        return l.value = r.value and l.unit_index = r.unit_index ;
    end function ;

    impure function "="(variable l, r : inout record_value_mirror) return boolean is
        variable rv : boolean := true ;
    begin
        return rv ;
    end function ;

    impure function "="(variable l, r : inout array_value_mirror) return boolean is
        variable rv : boolean := true ;
    begin
        return rv ;
    end function ;

    impure function "="(variable l, r : inout access_value_mirror) return boolean is
        variable rv : boolean := true ;
    begin
        return rv ;
    end function ;

    impure function "="(variable l, r : inout file_value_mirror) return boolean is
    begin
        return l.get_file_logical_name = r.get_file_logical_name and l.get_file_open_kind = r.get_file_open_kind ;
    end function ;

    impure function "="(variable l, r : inout protected_value_mirror) return boolean is
        variable rv : boolean := true ;
    begin
        return rv ;
    end function ;

    impure function "="(variable l, r : inout value_mirror) return boolean is
        variable rv : boolean := false ;
    begin
        return rv ;
    end function ;

begin

    tb : process
        variable sm : std.reflection.subtype_mirror ;
        variable aprime : a_t ;
        variable bprime : b_t ;
    begin
        report to_string(value) ;
        report to_string(a) ;
        report to_string(b) ;
        arr(0) := a'reflect ;
        arr(1) := b'reflect ;
        sm := arr(0).get_subtype_mirror ;
        report sm.simple_name ;
        sm := arr(1).get_subtype_mirror ;
        report sm.simple_name ;
        aprime := from(arr(0)) ;
        bprime := from(arr(1)) ;
        report to_string(aprime) ;
        report to_string(bprime) ;
        std.env.stop ;
    end process ;

end architecture ;
