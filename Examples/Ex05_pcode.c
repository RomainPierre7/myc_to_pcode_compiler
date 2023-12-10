// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//int type x declaration with an offset of 0 at depth 0
LOADI(0)

void pcode_main(){
LOADI(3)
STOREP(0) //storing x value
LOADI(1)
LOADP(0) //loading x value
ADDI
return;
}
