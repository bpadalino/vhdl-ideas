use std.textio.all ;

package log is

    procedure log(x : string) is
        variable l : line ;
    begin
        write(l, x) ;
        writeline(output, l) ;
    end procedure ;

end package ;
