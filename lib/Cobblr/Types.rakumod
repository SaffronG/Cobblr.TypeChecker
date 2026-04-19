unit module Cobblr::Types;

role Type { }

class TInt does Type {
    method gist { "Int" }
}

class TFloat does Type {
    method gist { "Float" }
}

class TBool does Type {
    method gist { "Bool" }
}

class TIntVec does Type {
    method gist { "IntVec" }
}

class TCustom does Type {
    method gist { "Custom" }
}
