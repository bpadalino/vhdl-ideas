package i2c_bfm is
    type transaction_t is record
        address : bit_vector(6 downto 0) ;
        data    : bit_vector ;
    end record ;

    type transactor_t is protected
        impure function write(x : transaction_t) return natural ;
        impure function read(x : transaction_t) return natural ;
        procedure drive(signal x : view controller of i2c_t) ;
        procedure drive(signal x : view peripheral of i2c_t) ;
    end record ;

end package ;
