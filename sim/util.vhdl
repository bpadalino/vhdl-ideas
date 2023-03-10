library std ;
    use std.reflection.all ;
    use std.textio.all ;

package util is

    impure function to_string(variable value : value_mirror) return string ;

    -- Good functions to have for any data type
    --function pack(x : sometype) return rv_t of std_ulogic_vector ;
    --function unpack(x : std_ulogic_vector) return rv_t of sometype ;

    procedure tee(file f : text ; s : string) ;

    type log is protected
      generic (
        fname : string ;
        id    : string ;
      ) ;
        procedure warn(x : string) ;
        procedure info(x : string) ;
        procedure err( x : string) ;
    end protected ;

end package ;

package body util is

    type log is protected body
        file f : text ;
        procedure warn(x : string) is
            constant color_warning : string := work.colors.ansi.YELLOW & id & "/WARNING" & work.colors.ansi.RESET ;
        begin
            tee(f, "[" & color_warning & "]" & x) ;
        end procedure ;

        procedure info(x : string) is
            constant color_info : string := work.colors.ansi.GREEN & id & "/INFO" & work.colors.ansi.RESET ;
        begin
            tee(f, "[" & color_info & "   ]" & x) ;
        end procedure ;

        procedure err(x : string) is
            constant color_error : string := work.colors.ansi.RED & id & "/ERROR" & work.colors.ansi.RESET ;
        begin
            tee(f, "[" & color_error & "  ]" & x) ;
        end procedure ;
    end protected body ;

    procedure tee(file f : text ; s : string) is
        variable l : line ;
    begin
        write(l, s) ;
        writeline(output, l) ;
        writeline(f, l) ;
    end procedure ;

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
            return "" ;
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
            return "" ;
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
