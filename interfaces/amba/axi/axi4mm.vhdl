library ieee ;
   use ieee.std_logic_1164.std_ulogic ;
   use ieee.std_logic_1164.std_ulogic_vector ;

use work.axi4.burst_t ;
use work.axi4.resp_t ;
use work.axi4.lock_t ;
use work.axi4.prot_t ;
use work.axi4.cache_t ;

package axi4mm is

    type burst_lengths_t is array(positive range 2**0 to 2**8) of std_ulogic_vector(7 downto 0) ;

    function burst_lengths return burst_lengths_t ;

    constant LEN : burst_lengths_t := burst_lengths ;

    type address_t is record
        addr    :   std_ulogic_vector(31 downto 0) ;
        prot    :   prot_t ;
        size    :   std_ulogic_vector(2 downto 0) ;
        burst   :   burst_t ;
        cache   :   cache_t ;
        id      :   std_ulogic_vector ;
        len     :   std_ulogic_vector(7 downto 0) ;
        lock    :   lock_t ;
        qos     :   std_ulogic_vector ;
        region  :   std_ulogic_vector ;
        user    :   std_ulogic_vector ;
        valid   :   std_ulogic ;
        ready   :   std_ulogic ;
    end record ;

    --function to_string(x : address_t) return string ;

    view address_master of address_t is
        addr      :   out ;
        prot      :   out ;
        size      :   out ;
        burst     :   out ;
        cache     :   out ;
        id        :   out ;
        len       :   out ;
        lock      :   out ;
        qos       :   out ;
        region    :   out ;
        user      :   out ;
        valid     :   out ;
        ready     :   in ;
    end view ;

    alias address_slave is address_master'converse ;

    type bresp_t is record
        resp       :   resp_t ;
        valid      :   std_ulogic ;
        ready      :   std_ulogic ;
        id         :   std_ulogic_vector ;
        user       :   std_ulogic_vector ;
    end record ;

    --function to_string(x : bresp_t) return string ;

    view bresp_master of bresp_t is
        resp       :   in ;
        valid      :   in ;
        ready      :   out ;
        id         :   in ;
        user       :   in ;
    end view ;

    alias bresp_slave is bresp_master'converse ;

    type wdata_t is record
        data       :   std_ulogic_vector ;
        stb        :   std_ulogic_vector ;
        valid      :   std_ulogic ;
        last       :   std_ulogic ;
        user       :   std_ulogic_vector ;
        ready      :   std_ulogic ;
    end record ;

    --function to_string(x : wdata_t) return string ;

    view wdata_master of wdata_t is
        data       :   out ;
        stb        :   out ;
        valid      :   out ;
        last       :   out ;
        user       :   out ;
        ready      :   in ;
    end view ;

    alias wdata_slave is wdata_master'converse ;

    type rdata_t is record
        data       :   std_ulogic_vector ;
        valid      :   std_ulogic ;
        last       :   std_ulogic ;
        id         :   std_ulogic_vector ;
        user       :   std_ulogic_vector ;
        ready      :   std_ulogic ;
    end record ;

    --function to_string(x : rdata_t) return string ;

    view rdata_master of rdata_t is
        data        :   in ;
        valid       :   in ;
        last        :   in ;
        id          :   in ;
        user        :   in ;
        ready       :   out ;
    end view ;

    alias rdata_slave is rdata_master'converse ;

    type aximm_t is record
        aw  :   address_t ;
        b   :   bresp_t ;
        w   :   wdata_t ;
        ar  :   address_t ;
        r   :   rdata_t ;
    end record ;

    type aximm_array_t is array(natural range <>) of aximm_t ;

    view master of aximm_t is
        aw  :   view address_master ;
        ar  :   view address_master ;
        b   :   view bresp_master ;
        w   :   view wdata_master ;
        r   :   view rdata_master ;
    end view ;

    alias slave is master'converse ;

    -- Bus configuration record used for making new fixed configurations
    type config_t is record
        DATA_BYTES  :   positive ;
        USER_BYTES  :   natural ;
        USE_ID      :   boolean ;
        USE_QOS     :   boolean ;
        USE_REGION  :   boolean ;
    end record ;

    -- Default AXI Configuration
    constant DEFAULT_CONFIG : config_t := (
        DATA_BYTES  =>  16,
        USER_BYTES  =>  0,
        USE_ID      =>  false,
        USE_QOS     =>  false,
        USE_REGION  =>  false
    ) ;

    -- Generic package for fixing a bus configuration
    package make is
      generic (
        READ_CONFIG     :   config_t := DEFAULT_CONFIG ;
        WRITE_CONFIG    :   config_t := DEFAULT_CONFIG ;
      ) ;

        constant WID_WIDTH : natural := 0 when WRITE_CONFIG.USE_ID = false else 4 ;
        constant RID_WIDTH : natural := 0 when READ_CONFIG.USE_ID = false else 4 ;

        subtype WID_RANGE is natural range WID_WIDTH-1 downto 0 ;
        subtype RID_RANGE is natural range RID_WIDTH-1 downto 0 ;

        constant WQOS_WIDTH : natural := 0 when WRITE_CONFIG.USE_QOS = false else 4 ;
        constant RQOS_WIDTH : natural := 0 when READ_CONFIG.USE_QOS = false else 4 ;

        subtype WQOS_RANGE is natural range WQOS_WIDTH-1 downto 0 ;
        subtype RQOS_RANGE is natural range RQOS_WIDTH-1 downto 0 ;

        constant WREGION_WIDTH : natural := 0 when WRITE_CONFIG.USE_REGION = false else 4 ;
        constant RREGION_WIDTH : natural := 0 when READ_CONFIG.USE_REGION = false else 4 ;

        subtype WREGION_RANGE is natural range WREGION_WIDTH-1 downto 0 ;
        subtype RREGIOn_RANGE is natural range RREGION_WIDTH-1 downto 0 ;

        constant WDATA_WIDTH : natural := WRITE_CONFIG.DATA_BYTES*8 ;
        constant WSTB_WIDTH  : natural := WRITE_CONFIG.DATA_BYTES ;
        constant WUSER_WIDTH : natural := WRITE_CONFIG.USER_BYTES*8 ;

        subtype WDATA_RANGE is natural range WDATA_WIDTH-1 downto 0 ;
        subtype WSTB_RANGE  is natural range WSTB_WIDTH-1 downto 0 ;
        subtype WUSER_RANGE is natural range WUSER_WIDTH-1 downto 0 ;

        constant RDATA_WIDTH : natural := READ_CONFIG.DATA_BYTES*8 ;
        constant RUSER_WIDTH : natural := WRITE_CONFIG.USER_BYTES*8 ;

        subtype RDATA_RANGE is natural range RDATA_WIDTH-1 downto 0 ;
        subtype RUSER_RANGE is natural range RUSER_WIDTH-1 downto 0 ;

        subtype aximm_t is aximm_t(
            aw ( id(WID_RANGE), qos(WQOS_RANGE), region(WREGION_RANGE), user(WUSER_RANGE)),
            b  ( id(WID_RANGE), user(WUSER_RANGE) ),
            w  ( data(WDATA_RANGE), stb(WSTB_RANGE), user(WUSER_RANGE) ),
            ar ( id(RID_RANGE), qos(RQOS_RANGE), region(RREGION_RANGE), user(RUSER_RANGE) ),
            r  ( id(RID_RANGE), data(RDATA_RANGE), user(RUSER_RANGE) )
        ) ;

    end package ;

end package ;
