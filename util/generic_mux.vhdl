entity generic_mux is
  generic (
    type elements_t is array(type is (<>)) of type is private ;
    -- Input array element might not be the same type as the output, so we need to know that here for the assign procedure
    --type output_t is private ;
    --procedure assign(constant x : in elements_t'element ;  signal y : out elements_t'element) is <> ;
  ) ;
  port (
    sel     : in  elements_t'index ;
    inputs  : in  elements_t ;
    output  : out elements_t'element
  ) ;
end entity ;

architecture arch of generic_mux is

begin

    output <= inputs(sel) ;

    --assign(inputs(sel), output) ;

end architecture ;
