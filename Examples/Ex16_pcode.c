// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//x arg with int type and offset of -1

void pcode_fact(){
//start of conditional 0
LOADP(bp+-1) //loading x value in current block
LOADI(1)
LTI
IFN(LABEL_0)
//the condition 0 is true
LOADI(1)
return;
GOTO(END_LABEL_0)
LABEL_0:
//the condition 0 is false
LOADP(bp+-1) //loading x value in current block
LOADP(bp+-1) //loading x value in current block
LOADI(1)
SUBI
SAVEBP
CALL(pcode_fact)
RESTOREBP
ENDCALL(1) //unloading 1 args of function fact
MULTI
return;
END_LABEL_0:
//end of conditional 0
}

void pcode_main(){
LOADI(5)
SAVEBP
CALL(pcode_fact)
RESTOREBP
ENDCALL(1) //unloading 1 args of function fact
return;
}
