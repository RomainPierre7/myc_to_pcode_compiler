// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//int type x declaration with an offset of 0 at depth 0
LOADI(0)
//int type y declaration with an offset of 1 at depth 0
LOADI(0)
//int type z declaration with an offset of 2 at depth 0
LOADI(0)

void pcode_main(){
LOADI(3)
STOREP(0) //storing x value
LOADI(5)
STOREP(1) //storing y value
LOADI(0)
STOREP(2) //storing z value
LOOP_0: //loading condition while loop 0
LOADP(0) //loading x value
LOADI(0)
GTI
IFN(END_LOOP_0)
//start of while loop 0
SAVEBP //entering block
LOADP(2) //loading z value
LOADP(1) //loading y value
ADDI
STOREP(2) //storing z value
LOADP(0) //loading x value
LOADI(1)
SUBI
STOREP(0) //storing x value
RESTOREBP //exiting block
GOTO(LOOP_0)
//end of while loop 0
END_LOOP_0:
LOADP(2) //loading z value
return;
}
