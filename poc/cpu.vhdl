package cpu is

    type clock_names_t is (FCLK0, FCLK1, FCLK2, FCLK3) ;

    type clock_domain_t is record
        clock   :   bit ;
        reset   :   bit ;
    end record ;

    type clock_domains_t is array(clock_names_t) of clock_domain_t ;

    type clock_rates_t is array(clock_names_t) of real ;

    --type aximm_masters_t is (LP0, LP1, HP0, HP1, HP2) ;
    --type aximm_slaves_t is (ACP, HP0, HP1) ;

    --type aximm_masters_t is (aximm_masters_t) of axi4mm.aximm_t ;
    --type aximm_slaves_t is (aximm_slaves_t) of axi4mm.aximm_t ;

    --type axil_masters_t is (LP0, HP0) ;

    --type axil_masters_t is (axil_masters_t) of axi4l.axil_t ;

    type memory_t is protected
        procedure write(r : natural'range'record ; data : bit_vector) ;
        impure function read(r : natural'range'record) return rv_t of bit_vector ;
        impure function equal(variable x : inout memory_t) return boolean ;
    end protected ;

    type interrupt_t is protected
      generic (
        NUM_INTERRUPTS : positive := 1 ;
      ) ;
        -- Waiting Procedure
        procedure wait_on(x : natural) ;

        -- Triggering Procedure
        procedure trigger(x : natural) ;
    end protected ;

    type controller is protected
      generic (
        NUM_INTERRUPTS : positive := 1
      ) ;
        private variable memory : memory_t ;
        alias write is memory.write[natural'range'record, bit_vector] ;
        alias read is memory.read[natural'range'record return bit_vector] ;
        alias equal is memory.equal[memory_t return boolean] ;

        private variable interrupt : interrupt_t generic map ( NUM_INTERRUPTS => NUM_INTERRUPTS ) ;
        alias wait_on is interrupt.wait_on[natural] ;
        alias trigger is interrupt.trigger[natural] ;

        -- interrupt aliases here

        -- private variable axi4mm_bfm
        -- axi4mm_bfm aliases here

        -- private variable axi4l_bfm
        -- axi4l_bfm aliases here
        procedure por(x : bit) ;
        impure function get_clocks return clock_rates_t ;
        procedure set_clock(target : clock_names_t ; freq : real) ;
        procedure generate_clock(clock : clock_names_t ; signal x : inout clock_domain_t) ;
    end protected ;

end package ;

package body cpu is

    type interrupt_t is protected body
        variable num : natural := NUM_INTERRUPTS ;
        procedure wait_on(x : natural) is
        begin

        end procedure ;

        procedure trigger(x : natural) is
        begin

        end procedure ;
    end protected body ;

    type memory_t is protected body
        procedure write(r : natural'range'record ; data : bit_vector) is
        begin
        end procedure ;

        impure function read(r : natural'range'record) return rv_t of bit_vector is
            variable rv : rv_t ;
        begin
            return rv ;
        end function ;

        impure function equal(variable x : inout memory_t) return boolean is
        begin
            return false ;
        end function ;
    end protected body ;

    type controller is protected body
        variable clock_rates : clock_rates_t ;
        variable reset : bit ;
        procedure por(x : bit) is
        begin
            reset := x ;
        end procedure ;

        procedure set_clock(target : clock_names_t ; freq : real) is
        begin
            clock_rates(target) := freq ;
        end procedure ;

        impure function get_clocks return clock_rates_t is
        begin
            return clock_rates ;
        end function ;

        procedure generate_clock(clock : clock_names_t ; signal x : inout clock_domain_t) is
        begin
            if reset = '1' then
                x.reset <= '1' ;
            else
                x.reset <= '0' ;
            end if ;
            x.clock <= not x.clock after (1.0/2.0*clock_rates(clock)) * 1 sec ;
        end procedure ;

    end protected body ;

end package body ;

entity cpusim is
  port (
    variable controller      : inout work.cpu.controller ;
    clock_domains   : out   work.cpu.clock_domains_t ;
    interrupts      : in    bit_vector(7 downto 0) ;
    --axi_masters     : view (master) of cpu.aximm_masters_t ;
    --axi_slaves      : view (slave)  of cpu.aximm_slaves_t ;
    --axi_lites       : view (master) of cpu.axil_masters_t ;
  ) ;
end entity ;

architecture arch of cpusim is

begin

    -- Generate clocks
    gen_clocks : for idx in clock_domains'range generate
        controller.generate_clock(idx, clock_domains(idx)) ;
    end generate ;

end architecture ;

entity test is
end entity ;

architecture arch of test is

    shared variable memory : work.cpu.memory_t ;

    signal interrupts : bit_vector(7 downto 0) ;

    shared variable controller : work.cpu.controller generic map (NUM_INTERRUPTS => interrupts'length) ;

    signal clock_domains : work.cpu.clock_domains_t ;

    --signal axi_masters  : cpu.aximm_masters_t ;
    --signal axi_slaves   : cpu.aximm_slaves_t ;
    --signal axil_masters : cpu.axil_masters_t ;

    use work.cpu.clock_names_t ;

begin

    -- Main CPU
    U_cpu : entity work.cpusim
      port map (
        controller      =>  controller,
        clock_domains   =>  clock_domains,
        interrupts      =>  interrupts
        --axi_masters     =>  axi_masters,
        --axi_slaves      =>  axi_slaves,
        --axil_masters    =>  axil_masters
      ) ;

    -- Peripherals and/or bus functional models

    -- testbench
    tb : process
    begin
        controller.por('1') ;
        controller.set_clock(FCLK0, 100.0e6) ;
        controller.set_clock(FCLK1, 33.3e6) ;
        controller.set_clock(FCLK2, 26.0e6) ;
        controller.set_clock(FCLK3, 491.52e6) ;
        wait for 1000 ns ;
        controller.por('0') ;
        wait for 1000 ns ;
        wait until rising_edge(clock_domains(FCLK0).clock) and clock_domains(FCLK0).reset = '1' ;
        report "Done with simulation" ;
        std.env.stop ;
    end process ;

end architecture ;
