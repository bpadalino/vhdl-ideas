entity generic_demux is
  generic (
    type elements_t is array(type is (<>)) of type is private ;
    function "="(l, r : in elements_t'index) return boolean ;
    procedure assign(x : in elements_t'element ;  signal y : out elements_t'element) ;
    DEFAULT_VALUE : elements_t'element ;
  ) ;
  port (
    sel     : in  elements_t'index ;
    input   : in  elements_t'element ;
    outputs : out elements_t
  ) ;
end entity ;

architecture arch of generic_demux is

begin

    gen_idx : for idx in sel'range generate
        process(sel, input)
        begin
            if sel = idx then
                assign(input, outputs(idx)) ;
            else
                assign(DEFAULT_VALUE, outputs(idx)) ;
            end if ;
        end process ;
    end generate ;

end architecture ;
