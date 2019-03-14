import ./libs/strutil/src/strutil.nim
import os

#Start of lexical analysis
echo "Initiating compiler"
echo "Starting lexical analysis"

const
    tksymbols
    	'%': tkMod,
    	'+': tkAdd,
    	'-': tkSub,
    	'/': tkDiv,
    	'*': tkMul,

