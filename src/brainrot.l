%{
#include <stdio.h>
#include "brainrot.tokens.h"
int line = 1;
%}

%%
"+"		{ return INCVAL; }
"-"		{ return DECVAL; }
">"		{ return INCPTR; }
"<"		{ return DECPTR; }
","		{ return INPUT; }
"."		{ return OUTPUT; }
"["		{ return WHILESTART; }
"]"		{ return WHILEEND; }
\n		{ line++; }
.		;
%%
