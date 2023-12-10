// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}


void pcode_main(){
//int type x declaration with an offset of 1 at depth 1
LOADI(0)
//int type y declaration with an offset of 2 at depth 1
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
LOADP(bp+1) //loading x value in current block
STOREP(stack[bp]+2) //storing y value in current block
RESTOREBP //exiting block
LOADP(bp+1) //loading x value in current block
STOREP(bp+2) //storing y value in current block
LOADP(bp+2) //loading y value in current block
return;
}
