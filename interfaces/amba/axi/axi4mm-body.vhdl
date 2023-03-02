package body axi4mm is

    use ieee.numeric_std.to_unsigned;

    function burst_lengths return burst_lengths_t is
        variable rv : burst_lengths_t ;
    begin
        for idx in rv'range loop
            rv(idx) := std_ulogic_vector(to_unsigned(idx-1, rv(idx)'length)) ;
        end loop ;
        return rv ;
    end function ;

    procedure assign(signal l : view address_manager of address_t ; signal r : view address_subordinate of address_t) is
    begin
        l.addr   <= r.addr ;
        l.prot   <= r.prot ;
        l.size   <= r.size ;
        l.burst  <= r.burst ;
        l.cache  <= r.cache ;
        l.id     <= r.id ;
        l.len    <= r.len ;
        l.lock   <= r.lock ;
        l.qos    <= r.qos ;
        l.region <= r.region ;
        l.user   <= r.user ;
        l.valid  <= r.valid ;
        r.ready  <= l.ready ;
    end procedure ;

    procedure assign(signal l : view bresp_manager of bresp_t ; signal r : view bresp_subordinate of bresp_t) is
    begin
        r.resp  <= l.resp ;
        r.valid <= l.valid ;
        r.id    <= l.id ;
        r.user  <= l.user ;
        l.ready <= r.ready ;
    end procedure ;

    procedure assign(signal l : view wdata_manager of wdata_t ; signal r : view wdata_subordinate of wdata_t) is
    begin
        l.data  <= r.data ;
        l.stb   <= r.stb ;
        l.valid <= r.valid ;
        l.last  <= r.last ;
        l.user  <= r.user ;
        r.ready <= l.ready ;
    end procedure ;

    procedure assign(signal l : view rdata_manager of rdata_t ; signal r : view rdata_subordinate of rdata_t) is
    begin
        r.data  <= l.data ;
        r.valid <= l.valid ;
        r.last  <= l.last ;
        r.id    <= l.id ;
        r.user  <= l.user ;
        l.ready <= r.ready ;
    end procedure ;

    procedure assign(signal l : view manager of aximm_t ; signal r : view subordinate of aximm_t) is
    begin
        -- Incompatible mode views
        assign(l.aw, r.aw) ;
        assign(l.b,  r.b) ;
        assign(l.w,  r.w) ;
        assign(l.ar, r.ar) ;
        assign(l.r,  r.r) ;
    end procedure ;

end package body ;

