// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//y arg with int type and offset of -1
//x arg with int type and offset of -2

void pcode_plus(){
LOADP(bp+-2) //loading x value in current block
LOADP(bp+-1) //loading y value in current block
ADDI
return;
}

void pcode_main(){
LOADI(5)
LOADI(6)
SAVEBP
CALL(pcode_plus)
RESTOREBP
ENDCALL(2) //unloading 2 args of function plus
return;
}
