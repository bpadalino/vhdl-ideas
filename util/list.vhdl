-- Ordered List
package list is
    -- type could be value_mirror to hold a bunch of different records?
    -- generic package or generic protected type?
    -- generic protected type makes more sense
    type list is protected
      generic(
        type t ;
        type array_t is array(natural range <>) of t ;
        function "<"(l, r : t) return boolean is <>
      ) ;
        procedure prepend(x : array_t) ;
        procedure prepend(x : t) ;
        procedure append(x : array_t) ;
        procedure append(x : t) ;
        procedure insert(x : t ; index : natural) ;
        procedure insert(x : array_t ; index : natural) ;
        procedure clear ;
        procedure remove(index : natural := 0) ;
        impure function size return natural ;
        impure function get(index : natural := 0) return rv_t of t ;
        impure function iterate(from : natural := 0) return natural'range'record ;
        procedure copy(variable target : inout list) ;
    end protected ;

end package ;

package body list is

    -- Double linked list
    type list is protected body
        type item_t ;

        type item_ptr is access item_t ;

        type item_t is record
            data      : t ;
            prev_item : item_ptr ;
            next_item : item_ptr ;
        end record ;

        variable root   : item_ptr := null ;
        variable last   : item_ptr := null ;
        variable length : natural := 0 ;

        procedure update_last is
            variable item : item_ptr := root ;
        begin
            while item.next_item /= null loop
                item := item.next_item ;
            end loop ;
            last := item ;
        end procedure ;

        procedure prepend(x : t) is
        begin
            insert(x, 0) ;
        end procedure ;

        procedure prepend(x : array_t) is
        begin
        end procedure ;

        procedure append(x : t) is
        begin
            insert(x, length) ;
        end procedure ;

        procedure append(x : array_t) is
        begin
        end procedure ;

        procedure insert(x : t ; index : natural) is
            variable item : item_ptr := new item_t ;
            variable iter : item_ptr := root ;
            variable prev : item_ptr := null ;
        begin
            -- Check position is within the list parameters
            assert index <= length severity error ;

            -- Create the item
            item.data := x ;

            -- Iterate to the position
            for idx in 1 to index loop
                prev := iter ;
                iter := prev.next_item ;
            end loop ;

            -- Insert the item
            prev.next_item := item ;
            item.prev_item := prev ;

            iter.prev_item := item;
            item.next_item := iter ;

            update_last ;
            length := length + 1 ;
        end procedure ;

        procedure insert(x : array_t ; index : natural) is
        begin

        end procedure ;

        procedure clear is
        begin
            root := null ;
            last := null ;
            length := 0 ;
        end procedure ;

        procedure remove(index : natural := 0) is
            variable iter : item_ptr := root ;
        begin
            for idx in 1 to index loop
                iter := iter.next_item ;
            end loop ;
            iter.prev_item.next_item := iter.next_item ;
            iter.next_item.prev_item := iter.prev_item ;
        end procedure ;

        impure function size return natural is
        begin
            return length ;
        end function ;

        impure function get(index : natural := 0) return rv_t of t is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        impure function iterate(from : natural := 0) return natural'range'record is
            subtype rv_t is natural range 0 to length-1 ;
        begin
            return rv_t'range'record ;
        end function ;

        procedure copy(variable target : inout list) is
            variable iter : item_ptr := root ;
        begin
            while iter /= null loop
                list.append(iter.data) ;
                iter := iter.next_item ;
            end loop ;
        end procedure ;

    end protected body ;

end package body ;

