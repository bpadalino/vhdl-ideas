package xilinx is

    -- RFSoC RF Data Converter IP
    package rfdc is
        alias axis_array_t is work.axi4s.axis_array_t ;

        type rfdc is record
            adc : axis_array_t ;
            dac : axis_array_t ;
        end record ;

        package make is
          generic (
            NUM_ADC :   positive := 1 ;
            NUM_DAC :   positive := 1 ;
          ) ;

            subtype nil is natural range 1 to 0 ;

            subtype axis32_t is work.axi4s.axis_t (
                data(31 downto 0),dest(nil),id(nil),keep(nil),strb(nil),user(nil)
            ) ;

            subtype rfdc is rfdc(
                adc(0 to NUM_ADC-1)(data(31 downto 0),dest(nil),id(nil),keep(nil),strb(nil),user(nil)),
                dac(0 to NUM_DAC-1)(data(31 downto 0),dest(nil),id(nil),keep(nil),strb(nil),user(nil))
            ) ;

        end package ;

    end package ;

end package ;
