library ieee ;
use ieee.std_logic_1164.all ;

package io is

    -- Nested packages to create a clean hierarchy?
    -- Too many deep names?
    -- Utilize aliases in contexts for convenient names?

    -- Tri-State IO Interface
    package tri is

        type tri_t is record
            i   :   std_ulogic ;
            o   :   std_ulogic ;
            en  :   std_ulogic ;
        end record ;

        type tris_t is array(natural range <>) of tri_t ;

        view driver of tri_t is
            i   :   in ;
            o   :   out ;
            en  :   in ;
        end view ;

        -- Procedures to help with writing and reading interface
        procedure write(signal x : std_ulogic ; signal y : view driver of tri_t) ;
        procedure read(signal x : view driver of tri_t ; signal y : out std_ulogic) ;

        -- Assignment operator stand-in?
        procedure assign(signal x : view driver of tri_t ; signal pin : inout std_logic) ;
    end package ;

    -- Differential Pair IO Interface
    package diffpair is
        type diffpair_t is record
            p   :   std_ulogic ;
            n   :   std_ulogic ;
        end record ;

        type diffpairs_t is array(natural range<>) of diffpair_t ;

        procedure assign(signal value : in std_ulogic ; signal x : out diffpair_t) ;
        procedure assign(signal x : diffpair_t ; signal value : out std_ulogic) ;

        procedure assign(signal value : in std_ulogic_vector ; signal x : out diffpairs_t) ;
        procedure assign(signal x : in diffpairs_t ; signal value : out std_ulogic_vector) ;

        procedure connect(signal x : in diffpairs_t ; signal y : out diffpairs_t) ;

    end package ;

    package spi is

        type spi_t is record
            clock   :   std_ulogic ;
            mosi    :   std_ulogic ;
            miso    :   std_ulogic ;
            csn     :   std_ulogic ;
        end record ;

        view master of spi_t is
            clock   :   out ;
            mosi    :   out ;
            miso    :   in  ;
            csn     :   out ;
        end view ;

        alias slave is master'converse ;

    end package ;

    package qspi is

        type qspi_t is record
            clock   :   std_ulogic ;
            io      :   tri.tris_t(0 to 3) ;
            csn     :   std_ulogic ;
        end record ;

        view master of qspi_t is
            clock   :   out ;
            io      :   view (tri.driver) ;
            csn     :   out ;
        end view ;

        alias slave is master'converse ;

    end package ;

    package jtag is

        type jtag_t is record
            tck     :   std_ulogic ;
            tms     :   std_ulogic ;
            tdi     :   std_ulogic ;
            tdo     :   std_ulogic ;
            trst    :   std_ulogic ;
        end record ;

        view controller of jtag_t is
            tck     :   out ;
            tms     :   out ;
            tdi     :   out ;
            tdo     :   in ;
            trst    :   out ;
        end view ;

        alias device is controller'converse ;

        procedure assign(signal x : inout jtag_t ; signal y : inout jtag_t) ;

    end package ;

    package i2c is

        type i2c_t is record
            scl : tri.tri_t ;
            sda : tri.tri_t ;
        end record ;

        type i2c_pins_t is record
            scl : std_ulogic ;
            sda : std_ulogic ;
        end record ;

        -- Works
        view driver of i2c_t is
            scl : view tri.driver ;
            sda : view tri.driver ;
        end view ;

        ---- Doesn't work
        --view driver of i2c_t is
        --    scl : view driver ;
        --    sda : view driver ;
        --end view ;

        procedure assign(signal x : inout i2c_t ; signal y : inout i2c_pins_t) ;

    end package ;
end package ;

package body io is

    package body tri is
        procedure write(signal x : std_ulogic ; signal y : view driver of tri_t) is
        begin
            if( y.en = '1' ) then
                y.o <= x ;
            else
                y.o <= 'U' ;
            end if ;
        end procedure ;

        procedure read(signal x : view driver of tri_t ; signal y : out std_ulogic) is
        begin
            if( x.en = '0' ) then
                y <= x.i ;
            else
                y <= x.o ;
            end if ;
        end procedure ;

        procedure assign(signal x : view driver of tri_t ; signal pin : inout std_logic) is
        begin
            if( x.en = '0' ) then
                pin <= 'Z' ;
                x.o <= pin ;
            else
                pin <= x.o ;
            end if ;
        end procedure ;
    end package body ;

    package body diffpair is
        procedure assign(signal value : in std_ulogic ; signal x : out diffpair_t) is
        begin
            x.p <= value ;
            x.n <= not value ;
        end procedure ;

        procedure assign(signal value : in std_ulogic_vector ; signal x : out diffpairs_t) is
            variable temp : diffpair_t ;
        begin
            assert x'length = value'length report "assign: Truncating assignment" severity warning ;
            for idx in value'range loop
                -- Can't use recursively
                --assign(value(idx), x(idx)) ;
                x(idx).p <= value(idx) ;
                x(idx).n <= value(idx) ;
            end loop ;
        end procedure ;

        procedure assign(signal x : diffpair_t ; signal value : out std_ulogic) is
        begin
            if x.p = not x.n then
                value <= x.p;
            else
                value <= 'X' ;
            end if ;
        end procedure ;

        procedure assign(signal x : in diffpairs_t ; signal value : out std_ulogic_vector) is
        begin
            assert x'length = value'length report "assign: Truncating assignment" severity warning ;
            -- TODO: Define an overlap() function which returns the overlapping range of two vectors?
            for idx in value'range loop
                -- Can't use recursively
                --assign(x(idx), value(idx)) ;
                if x(idx).p = not x(idx).n then
                    value(idx) <= x(idx).p ;
                else
                    value(idx) <= 'X' ;
                end if ;
            end loop ;
        end procedure ;

        procedure connect(signal x : in diffpairs_t ; signal y : out diffpairs_t) is
        begin
            y <= x ;
        end procedure ;

    end package body ;

    package body jtag is
        -- Can't use view here for some reason to constrain the in/out
        procedure assign(signal x : inout jtag_t ; signal y : inout jtag_t) is
        begin
            y.tck <= x.tck ;
            y.trst <= x.trst ;
            y.tms <= x.tms ;
            y.tdi <= x.tdi ;
            x.tdo <= y.tdo ;
        end procedure ;
    end package body ;

    package body i2c is
        procedure assign(signal x : inout i2c_t ; signal y : inout i2c_pins_t) is
        begin
            -- incompatible mode views?
            tri.assign(x.scl, y.scl) ;
            tri.assign(x.sda, y.sda) ;
        end procedure ;
    end package body ;

end package body ;
