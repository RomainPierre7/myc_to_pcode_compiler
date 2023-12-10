// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}


void pcode_main(){
//int type x declaration with an offset of 1 at depth 1
LOADI(0)
LOADI(3)
STOREP(bp+1) //storing x value in current block
SAVEBP //entering block
//int type x declaration with an offset of 1 at depth 2
LOADI(0)
LOADI(4)
STOREP(bp+1) //storing x value in current block
SAVEBP //entering block
//int type x declaration with an offset of 1 at depth 3
LOADI(0)
LOADI(5)
STOREP(bp+1) //storing x value in current block
RESTOREBP //exiting block
RESTOREBP //exiting block
LOADI(1)
return;
}
