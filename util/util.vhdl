use std.reflection.all ;

library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

package util is

    -- binary file interaction

    package sim is
        impure function to_string(variable value : value_mirror) return string ;

        ---- Not doable - can't hold a file inside of a protected type
        --type file_t is protected
        --    procedure rewind ;
        --    procedure close ;
        --    procedure seek(offset : integer ; origin : file_origin_kind := FILE_ORIGIN_BEGIN) ;
        --    procedure read(value : out string) ;
        --    procedure write(value : string) ;
        --    procedure flush ;
        --    impure function fopen(fname : string ; mode : file_open_kind := READ_MODE) return file_open_status ;
        --    impure function state return file_open_state ;
        --    impure function size return integer ;
        --    impure function mode return file_open_kind ;
        --    impure function position(origin : file_origin_kind := FILE_ORIGIN_BEGIN) return integer ;
        --    impure function canseek return boolean ;
        --    impure function endfile return boolean ;
        --end protected ;

        -- Good functions to have for any data type
        --function pack(x : sometype) return rv_t of std_ulogic_vector ;
        --function unpack(x : std_ulogic_vector) return rv_t of sometype ;

        --procedure transact(x : transaction_list ; i : view blah) ;

        --procedure cast(x : sometype) return rv_t of std_logic_vector ;

        -- Generic compare function, pass in whatever comparison operator
        function compare
          generic(
            type t ;
            function "<"(l, r : t) return boolean is <> ;
            function "="(l, r : t) return boolean is <> ;
          ) parameter(op : string ; l, r : t) return boolean ;

    end package ;

    package synth is
        --function nullrange generic(type t is (<>)) return t'range'record ;

        function to_signed(x : string ; base : positive := 10) return rv_t of signed ;

        function to_unsigned(x : string ; base : positive := 10) return rv_t of unsigned ;

        function modpow(base : unsigned ; exp : unsigned ; modulus : unsigned) return rv_t of unsigned ;

        function maximum
          generic (
            type t ;
            function "<"(l, r : t) return boolean is <> ;
          ) parameter (l, r : t) return t ;

        function minimum
          generic (
            type t ;
            function "<"(l, r : t) return boolean is <> ;
          ) parameter (l, r : t) return t ;

        -- Convenient
        alias "+" is "&"[string, string return string] ;

        --function overlap
        --  generic (
        --    type array_t is array(type is (<>)) of type is private ;
        --    function maximum(l, r : array_t'index) return boolean is <> ;
        --    function minimum(l, r : array_t'index) return boolean is <> ;
        --  ) parameter (
        --    l, r : array_t ;
        --  ) return array_t'index'range'record ;

    end package ;

end package ;

package body util is

    package body sim is

        function compare
          generic (
            type t ;
            function "<"(l, r : t) return boolean is <> ;
            function "="(l, r : t) return boolean is <> ;
          ) parameter(op : string ; l, r : t) return boolean is
        begin
            case op is
                when "<"    => return l < r ;
                when "<="   => return (l < r) or (l = r) ;
                when "="    => return l = r ;
                when "/="   => return not (l = r) ;
                when ">="   => return not(l < r) ;
                when ">"    => return (not(l < r)) and (not(l = r)) ;
                when others => return false ;
            end case ;
        end function ;

        -- can create a string for any value
        impure function to_string(variable value : VALUE_MIRROR) return STRING is
            -- string-ify array elements
            impure function to_string(variable value : ARRAY_VALUE_MIRROR; field_idx, length : INDEX; prefix : STRING) return STRING is
                variable index : index_vector(1 to length);
            begin
                index := (1 => field_idx);
                block
                    variable element : value_mirror := value.get(index) ;
                    constant element_str : STRING := to_string(element);
                 begin
                    if field_idx < length - 1 then
                        return to_string(value, field_idx + 1, length, prefix & element_str & ", ");
                    elsif field_idx = length - 1 then
                        return prefix & element_str;
                    end if;
                end block;
            end function;

            -- string-ify arrays
            impure function to_string(variable value : ARRAY_VALUE_MIRROR) return STRING is
                variable array_type : ARRAY_SUBTYPE_MIRROR;
                variable sm : SUBTYPE_MIRROR ;
                variable length : INDEX;
            begin
                array_type := value.get_subtype_mirror;
                length := array_type.length(1);

                if array_type.dimensions /= 1 then
                    -- not supported in this example
                    report "only 1D arrays are supported" severity FAILURE;
                    return INDEX'image(array_type.dimensions) & "D array";
                end if;
                return "(" & to_string(value, 0, length, "") & ")";
            end function;

            -- string-ify record elements
            impure function to_string(variable value : RECORD_VALUE_MIRROR; element_idx : INDEX; prefix : STRING) return STRING is
                variable record_type : RECORD_SUBTYPE_MIRROR;
            begin
                record_type := value.get_subtype_mirror;
                block
                    variable element : value_mirror := value.get(element_idx) ;
                    constant element_str : STRING := record_type.element_name(element_idx) & " => " & to_string(element);
                begin
                    if element_idx < record_type.length - 1 then
                        return to_string(value, element_idx + 1, prefix & element_str & ", ");
                    elsif element_idx = record_type.length - 1 then
                        return prefix & element_str;
                    end if;
                end block;
            end function;

            -- string-ify records
            impure function to_string(variable value : RECORD_VALUE_MIRROR) return STRING is
            begin
                return "(" & to_string(value, 0, "") & ")";
            end function;

            impure function to_string(variable x : enumeration_value_mirror) return string is
            begin
                return x.image ;
            end function ;

            constant class : VALUE_CLASS := value.get_value_class;
        begin
            case class is
                when CLASS_ENUMERATION =>
                    block
                        variable enum : enumeration_value_mirror := value.to_enumeration ;
                        variable senum : string := to_string(enum) ;
                    begin
                        return senum;
                    end block ;
                when CLASS_INTEGER =>
                    block
                        variable int : integer_value_mirror := value.to_integer ;
                        variable sint : string := to_string(int.value) ;
                    begin
                        return sint;
                    end block ;
                when CLASS_FLOATING =>
                    block
                        variable float : floating_value_mirror := value.to_floating ;
                    begin
                        return to_string(float.value);
                    end block ;
                when CLASS_PHYSICAL =>
                    block
                        variable phy : physical_value_mirror := value.to_physical ;
                    begin
                        return phy.image;
                    end block ;
                when CLASS_RECORD =>
                    block
                        variable rec : record_value_mirror := value.to_record ;
                    begin
                        return to_string(rec);
                    end block ;
                when CLASS_ARRAY =>
                    block
                        variable arr : array_value_mirror := value.to_array ;
                    begin
                        return to_string(arr);
                    end block ;
                when CLASS_ACCESS =>
                    block
                        variable acc : access_value_mirror := value.to_access ;
                        variable acc_subtype : access_subtype_mirror := acc.get_subtype_mirror ;
                    begin
                        return "access type: " & acc_subtype.simple_name;
                    end block ;
                when CLASS_FILE =>
                    return "file type";
                when CLASS_PROTECTED =>
                    return "protected type";
            end case;
        end function;

    end package body ;

    package body synth is

        --function nullrange generic(type t is (<>)) return t'range'record is
        --    subtype rv is t range t'high to t'low ;
        --begin
        --    return rv'range'record ;
        --end function ;

        -- part of a bigint?
        function to_integer(x : character) return rv_t of integer is
            constant rv : natural := character'pos(x) - character'pos('0') when character'pos(x) < 58 else
                                     character'pos(x) - character'pos('A') + 10 when character'pos(x) < 71 else
                                     character'pos(x) - character'pos('a') + 10 ;
        begin
            return rv ;
        end function ;

        function modpow(base : unsigned ; exp : unsigned ; modulus : unsigned) return rv_t of unsigned is
            variable lbase : base'subtype := base ;
            variable lexp : exp'subtype := exp ;
            variable rv : rv_t ;
        begin
            if modulus = 1 then
                return to_unsigned(0, rv'length) ;
            end if ;
            rv := to_unsigned(1, rv'length) ;
            lbase := lbase mod modulus ;
            while lexp > 0 loop
                if lexp(0) = '1' then
                    rv := (rv * lbase) mod modulus ;
                end if ;
                lexp := shift_right(lexp, 1) ;
                lbase := (lbase * lbase) mod modulus ;
            end loop ;
            return rv ;
        end function ;

        function from_string(x : string) return rv_t of signed ;
        function from_hstring(x : string) return rv_t of signed ;
        function from_ostring(x : string) return rv_t of signed ;
        function from_bstring(x : string) return rv_t of signed ;

        function to_signed(x : string ; base : positive := 10) return rv_t of signed is
            variable rv : rv_t := (others =>'0') ;
            constant negate : boolean := true when x(1) = '-' else false ;
            variable idx    : positive := 2 when negate = true else 1 ;
        begin
            assert base = 10 or base = 8 or base = 2 or base = 16
                report "to_signed: Unsupported base (" & to_string(base) & ")"
                severity failure ;
            while idx < x'length loop
                rv := rv * base ;
                rv := rv + to_integer(x(idx)) ;
            end loop ;
            case base is
                when  2 => assert x = to_bstring(rv) report "Conversion Error" severity warning ;
                when  8 => assert x = to_ostring(rv) report "Conversion Error" severity warning ;
                when 10 => assert x = to_string(rv)  report "Conversion Error" severity warning ;
                when 16 => assert x = to_hstring(rv) report "Conversion Error" severity warning ;
                when others => report "Invalid base" severity failure ;
            end case ;
            return rv when negate = false else -rv ;
        end function ;

        function to_unsigned(x : string ; base : positive := 10) return rv_t of unsigned is
            variable rv : rv_t := (others =>'0') ;
        begin
            for idx in x'range loop
                rv := rv * base ;
                rv := rv + to_integer(x(idx)) ;
            end loop ;
            case base is
                when  2 => assert x = to_bstring(rv) report "Conversion Error" severity warning ;
                when  8 => assert x = to_ostring(rv) report "Conversion Error" severity warning ;
                when 10 => assert x = to_string(rv)  report "Conversion Error" severity warning ;
                when 16 => assert x = to_hstring(rv) report "Conversion Error" severity warning ;
                when others => report "Invalid base" severity failure ;
            end case ;
            return rv ;
        end function ;

        function maximum
          generic (
            type t ;
            function "<"(l, r : t) return boolean is <> ;
          ) parameter(l, r : t) return t
        is
        begin
            return l when (r < l) else r ;
        end function ;

        function minimum
          generic (
            type t ;
            function "<"(l, r : t) return boolean is <> ;
          ) parameter(l, r : t) return t
        is
        begin
            return l when (l < r) else r ;
        end function ;

    end package body ;

end package body ;
