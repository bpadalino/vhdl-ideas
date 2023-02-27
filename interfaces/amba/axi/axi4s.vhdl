library ieee ;
    use ieee.std_logic_1164.all ;

package axi4s is

    type axis_t is record
        data    :   std_ulogic_vector ;
        dest    :   std_ulogic_vector ;
        id      :   std_ulogic_vector ;
        strb    :   std_ulogic_vector ;
        keep    :   std_ulogic_vector ;
        user    :   std_ulogic_vector ;
        last    :   std_ulogic ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    type axis_array_t is array(natural range <>) of axis_t ;

    view master of axis_t is
        data    :   out ;
        dest    :   out ;
        id      :   out ;
        keep    :   out ;
        strb    :   out ;
        user    :   out ;
        last    :   out ;
        valid   :   out ;
        ready   :   in ;
    end view ;

    alias slave is master'converse ;

    package make is
      generic (
        DATA_BYTES  :   positive    := 4 ;
        DEST_WIDTH  :   natural     := 0 ;
        ID_WIDTH    :   natural     := 0 ;
        USER_WIDTH  :   natural     := 0 ;
      ) ;

        subtype DATA_RANGE is natural range DATA_BYTES*8-1 downto 0 ;
        subtype DEST_RANGE is natural range DEST_WIDTH-1 downto 0 ;
        subtype ID_RANGE   is natural range ID_WIDTH-1 downto 0 ;
        subtype KEEP_RANGE is natural range DATA_BYTES-1 downto 0 ;
        subtype USER_RANGE is natural range USER_WIDTH-1 downto 0 ;

        subtype axis_t is axis_t(
            data(DATA_RANGE),
            dest(DEST_RANGE),
            id(ID_RANGE),
            keep(KEEP_RANGE),
            strb(KEEP_RANGE),
            user(USER_RANGE)
        ) ;

    end package ;

    procedure assign(signal x : view slave of axis_t ; signal y : view master of axis_t) ;

end package ;

package body axi4s is

    procedure assign(signal x : view slave of axis_t ; signal y : view master of axis_t) is
    begin
        y.data  <= x.data ;
        y.dest  <= x.dest ;
        y.id    <= x.id ;
        y.keep  <= x.keep ;
        y.strb  <= x.strb ;
        y.user  <= x.user ;
        y.last  <= x.last ;
        y.valid <= x.valid ;
        x.ready <= y.ready ;
    end procedure ;

end package body ;
