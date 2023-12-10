// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//x arg with float type and offset of -1

void pcode_castToFloat(){
LOADP(bp+-1) //loading x value in current block
return;
}

void pcode_main(){
LOADI(1)
I2F //converting previous arg
SAVEBP
CALL(pcode_castToFloat)
RESTOREBP
ENDCALL(1) //unloading 1 args of function castToFloat
return;
}
