// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//x arg with int type and offset of -1

void pcode_plusUn(){
LOADP(bp+-1) //loading x value in current block
LOADI(1)
ADDI
return;
}

void pcode_main(){
LOADI(1)
SAVEBP
CALL(pcode_plusUn)
RESTOREBP
ENDCALL(1) //unloading 1 args of function plusUn
return;
}
