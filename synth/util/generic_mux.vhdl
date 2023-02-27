entity generic_mux is
  generic (
    type elements_t is array(type is (<>)) of type is private ;
    procedure assign(signal x : elements_t'element ;  signal y : elements_t'element) ;
  ) ;
  port (
    sel     : in  elements_t'index ;
    inputs  : in  elements_t ;
    output  : out elements_t'element
  ) ;
end entity ;

architecture arch of generic_mux is

    signal insel : output'subtype ;

begin

    insel <= inputs(sel) ;

    assign(insel, output) ;

end architecture ;
