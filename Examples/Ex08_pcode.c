// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//float type x declaration with an offset of 0 at depth 0
LOADF(0.0)
//float type y declaration with an offset of 1 at depth 0
LOADF(0.0)
//int type z declaration with an offset of 2 at depth 0
LOADI(0)

void pcode_main(){
//start of conditional 0
LOADP(0) //loading x value
LOADF(0.000000)
GTF
IFN(LABEL_0)
//the condition 0 is true
SAVEBP //entering block
//start of conditional 1
LOADP(1) //loading y value
LOADF(0.000000)
GTF
IFN(LABEL_1)
//the condition 1 is true
LOADI(1)
STOREP(2) //storing z value
GOTO(END_LABEL_1)
LABEL_1:
//the condition 1 is false
LOADI(2)
STOREP(2) //storing z value
END_LABEL_1:
//end of conditional 1
RESTOREBP //exiting block
GOTO(END_LABEL_0)
LABEL_0:
//the condition 0 is false
SAVEBP //entering block
//start of conditional 2
LOADP(1) //loading y value
LOADF(0.000000)
GTF
IFN(LABEL_2)
//the condition 2 is true
LOADI(3)
STOREP(2) //storing z value
GOTO(END_LABEL_2)
LABEL_2:
//the condition 2 is false
LOADI(4)
STOREP(2) //storing z value
END_LABEL_2:
//end of conditional 2
RESTOREBP //exiting block
END_LABEL_0:
//end of conditional 0
LOADP(2) //loading z value
return;
}
