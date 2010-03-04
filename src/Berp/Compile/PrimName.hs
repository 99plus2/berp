module Berp.Compile.PrimName where

import Language.Haskell.Exts.Syntax as Hask
-- import Language.Python.Version3.Syntax.AST as Py
import Language.Python.Common.AST as Py
import Prelude hiding (read, init)
import Language.Haskell.Exts.Build
import Berp.Compile.Utils

preludeModuleName, berpModuleName :: ModuleName
berpModuleName = ModuleName "Berp.Base"
preludeModuleName = ModuleName "Prelude"

prim :: String -> Exp
-- prim = qvar berpModuleName . name 
prim = var . name 

for :: Exp
for = prim "for"

break :: Exp
break = prim "break"

continue :: Exp
continue = prim "continue"

raise :: Exp
raise = prim "raise"

raiseFrom :: Exp
raiseFrom = prim "raiseFrom"

reRaise :: Exp
reRaise = prim "reRaise"

exceptDefault :: Exp
exceptDefault = prim "exceptDefault"

except :: Exp
except = prim "except"

exceptAs :: Exp
exceptAs = prim "exceptAs"

stmt :: Exp
stmt = prim "stmt"

list :: Exp
list = prim "list"

try :: Exp
try = prim "try"

tryElse :: Exp
tryElse = prim "tryElse"

tryFinally :: Exp
tryFinally = prim "tryFinally"

tryElseFinally :: Exp
tryElseFinally = prim "tryElseFinally"

subscript :: Exp
subscript = prim "subs"

pure :: Exp
pure = prim "pure"

primOp :: String -> QOp
primOp = op . sym 

assignOp :: QOp
assignOp = primOp "=:"

setAttr :: Exp
setAttr = prim "setattr"

while :: Exp
while = prim "while"

global :: Exp
global = prim "global"

globalRef :: Exp
globalRef = prim "globalRef"

variable :: Exp
variable = prim "var"

globalVariable :: Exp
globalVariable = prim "globalVar"

tuple :: Exp
tuple = prim "tuple"

whileElse :: Exp
whileElse = prim "whileElse"

start :: Exp
start = prim "start"

initName :: Name
initName = name "init"

init :: Exp
init = var initName 

ret :: Exp
ret = prim "return"

ite :: Exp
ite = prim "ifThenElse"

ifThen :: Exp
ifThen = prim "ifThen"

def :: Exp
def = prim "def"

klass :: Exp
klass = prim "klass"

lambda :: Exp
lambda = prim "lambda"

call :: Exp
call = prim "call"

apply :: QOp 
apply = primOp "@@"

read :: Exp
read = prim "read"

integer :: Integer -> Exp
integer i = app (prim "integer") (intE i)

bool :: Bool -> Exp
bool b = if b then true else false 

true,false :: Exp
true = prim "true"
false = prim "false"

none :: Exp
none = prim "none"

pass :: Exp
pass = prim "pass"

string :: String -> Exp
string s = app (prim "string") (strE s)

opExp :: Py.OpSpan -> Hask.QOp
opExp (And {}) = op $ name "and"
opExp (Or {}) = op $ name "or"
opExp (Exponent {}) = primOp "**"
opExp (LessThan {}) = primOp "<"
opExp (GreaterThan {}) = primOp ">"
opExp (Equality {}) = primOp "=="
opExp (GreaterThanEquals {}) = primOp ">=" -- not sure if this is official
opExp (LessThanEquals {}) = primOp "<="
opExp (NotEquals {}) = primOp "!="
opExp (BinaryOr {}) = primOp "||"
opExp (Xor {}) = primOp "^"
opExp (BinaryAnd {}) = primOp "&"
opExp (ShiftLeft {}) = primOp "<<"
opExp (ShiftRight {}) = primOp ">>"
opExp (Multiply {}) = primOp "*"
opExp (Plus {}) = primOp "+"
opExp (Minus {}) = primOp "-"
opExp (Divide {}) = primOp "/"
opExp (FloorDivide {}) = primOp "//"
opExp (Invert {}) = primOp "~" 
opExp (Modulo {}) = primOp "%"
opExp (Dot {}) = primOp "."
opExp other = unsupported $ "opExp: " ++ show other
