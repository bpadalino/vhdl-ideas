library work ;
use work.axi4mm.aximm_t ;
use work.axi4l.axil32_t ;
use work.axi4s.axis_t ;
use work.memory.memory_t ;
use work.axi4mm_bfm.transaction_t ;
use work.mpsoc.mpsoc_api_t ;
use work.log.log ;

entity mpsoc_sim is
end entity ;

architecture arch of mpsoc_sim

    -- Shared API
    shared variable mpsoc_api : mpsoc_api_t ;

    -- Large memory pool
    shared variable memory : memory_t ;

    -- Clocks and reset
    signal pl_clock0    : bit ;
    signal pl_resetn0   : bit ;
    signal pl_reset0    : bit ;

    -- CPU AXI4-Lite Interface
    signal mpsoc_axil_m : axil32_t ;
    signal gpio_axil_m  : axil32_t ;
    signal modem_axil_m : axil32_t ;

    -- CPU AXI4-MM Interface
    subtype nil is natural range 1 to 0 ;
    subtype mpsoc_aximm_t is aximm_t (
        aw ( id(nil), qos(nil), region(nil), user(nil) ),
        w  ( id(nil), user(nil) ),
        b  ( data(127 downto 0), stb(128/8-1 downto 0), user(nil) ),
        ar ( id(nil), qos(nil), region(nil), user(nil) ),
        r  ( id(nil), data(127 downto 0), user(nil) )
    ) ;
    signal modem_aximm_tx_m : mpsoc_aximm_t ;
    signal modem_aximm_rx_m : mpsoc_aximm_t ;
    signal mpsoc_aximm_s    : mpsoc_aximm_t ;

    -- Interrupts
    signal interrupts : bit_vector(15 downto 0) ;

    -- TODO: Tidy this up into a data structure?
    constant GPIO_BASE_ADDRESS  : natural := x"4000_0000" ;
    constant GPIO_ADDRESS_SPACE : natural := x"1000" ;

    constant MODEM_BASE_ADDRESS  : natural := x"4100_0000" ;
    constant MODEM_ADDRESS_SPACE : natural := x"2000" ;

    constant MODEM_TX_WORKER_REG : natural := MODEM_BASE_ADDRESS + x"10" ;
    constant MODEM_RX_WORKER_REG : natural := MODEM_BASE_ADDRESS + x"20" ;

    signal complete : boolean := false ;

    signal tx_complete : boolean := false ;
    signal rx_complete : boolean := false ;

begin

    complete <= tx_complete and rx_complete ;

    -- Active high
    pl_reset0 <= not pl_resetn0 ;

    -- CPU Interface
    -- TODO: This becomes much more standard/compact
    U_cpu : entity work.mpsoc_model
      port map (
        -- MPSoC Controller
        api                 => mpsoc_api,
        memory              => memory,

        -- Clock
        pl_clk0             =>  pl_clock0,
        pl_resetn0          =>  pl_resetn0,

        -- AXI4-Lite Interface
        m_axi_hpm1_fpd_clock => pl_clock0,
        m_axi_hpm1_fpd       => mpsoc_axil_m,

        -- AXI4-MM Interface
        s_axi_hpc0_fpd_clock => pl_clock0,
        s_axi_hpc0_fpd       => mpsoc_aximm_s,

        interrupts           => interrupts
      ) ;

    -- AXI4-Lite Fanout
    U_axil_fanout : entity work.axil_fanout(sim)
      generic map (
        ADDRESS_MAP => (0 => (GPIO_BASE_ADDRESS, GPIO_ADDRESS_SPACE), 1 => (MODEM_BASE_ADDRESS, MODEM_ADDRESS_SPACE))
      ) port map (
        clock       =>  pl_clock0,
        reset       =>  pl_reset0,

        input       => mpsoc_axil_m,
        outputs     => (gpio_axil_m, modem_axi_m)
      ) ;

    -- AXI4-MM Fanin
    U_aximm_fanin : entity work.aximm_fanin(sim)
      port map (
        clock   =>  pl_clock0,
        reset   =>  pl_reset0,

        inputs  => (modem_tx_aximm_m, modem_rx_aximm_m)
        output  => (mpsoc_aximm_s)
      ) ;

    -- GPIO Peripheral
    U_gpio : entity work.axi_gpio(sim)
      port map (
        clock   =>  pl_clock0,
        reset   =>  pl_resetn0,

        s_axi   =>  gpio_axi
        gpio    =>  gpio
      ) ;

    -- Modem Peripheral
    U_modem : entity work.axi_modem(sim)
      port map (
        clock           =>  pl_clock0,
        reset           =>  pl_reset0,

        s_axi           =>  modem_axil_m,

        axis_adc        =>  modem_adc,
        axis_dac        =>  modem_dac,

        m_aximm_tx      =>  modem_aximm_tx_m,
        m_aximm_rx      =>  modem_aximm_rx_m,

        interrupt_tx    =>  interrupts(0),
        interrupt_rx    =>  interrupts(1)
      ) ;

    tb : process
        variable reg : std_logic_vector(31 downto 0) ;
        variable resp : resp_t ;
        variable tx_result : tx_request_t ;
        variable rx_result : rx_request_t ;
    begin
        -- POR
        mpsoc_api.por('1') ;

        -- Setup clock to be 100 MHz
        mpsoc_api.set_clock_frequency(100e6) ;
        wait for 100 ns ;

        -- POR Release
        mpsoc_api.por('0') ;
        for i in 1 to 100 loop
            wait until rising_edge(pl_clock0) and pl_resetn0 = '1' ;
        end loop ;

        -- Wait until the other processes are done
        wait until complete = '1' ;

        -- Check memory here for completed values
        tx_result := memory.read(TX_REQUEST_BASE_ADDRESS, ) ;

        rx_result := memory.read(RX_REQUEST_BASE_ADDRESS, ) ;

        wait for 1000 ns ;
        log("Simulation completed") ;
        std.env.stop ;
    end process ;

    tx : process
        variable tx_request : tx_request_t ;
        variable reg : std_ulogic_vector(31 downto 0) ;
        variable resp : resp_t ;
    begin
        -- Read some peripheral registers
        resp := mpsoc_api.read(x"4100_0000", reg) ;
        if resp /= OKAY then
            log("TX Could not read register") ;
        end if ;

        -- Write the TX request
        memory.write(TX_REQUEST_BASE_ADDRESS, pack(tx_request)) ;

        -- Kick off a transmit operation
        resp := mpsoc_api.write(MODEM_TX_WORKER_REG, cast(TX_REQUEST_BASE_ADDRESS)) ;
        if resp /= OKAY then
            log("TX Request error") ;
        end if ;

        -- Wait for tx interrupt
        mpsoc_api.wait_on_interrupt(0) ;
        mpsoc_api.clear_interrupt(0) ;

        -- Done
        wait ;
    end process ;

    rx : process
        variable rx_request : rx_request_t ;
        variable reg : std_ulogic_vector(31 downto 0) ;
        variable resp : resp_t ;
    begin
        resp := mpsoc_api.read(x"4100_0000", reg) ;
        if resp /= OKAY then
            log("RX could not read register") ;
        end if ;

        -- Write the RX request
        memory.write(RX_REQUEST_BASE_ADDRESS, pack(rx_request)) ;

        -- Kick off a receive operation
        resp := mpsoc_api.write(MODEM_RX_WORKER_REG, cast(RX_REQUEST_BASE_ADDRESS)) ;
        if resp /= OKAY then
            log("RX Request error") ;
        end if ;

        -- Wait for rx interrupt
        mpsoc_api.wait_on_interrupt(1) ;
        mpsoc_api.clear_interrupt(1) ;

        -- Done
        wait ;
    end process ;

end architecture ;
