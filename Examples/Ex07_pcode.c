// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//float type x declaration with an offset of 0 at depth 0
LOADF(0.0)
//int type y declaration with an offset of 1 at depth 0
LOADI(0)

void pcode_main(){
//start of conditional 0
LOADP(0) //loading x value
LOADF(0.000000)
GTF
IFN(LABEL_0)
//the condition 0 is true
LOADI(1)
STOREP(1) //storing y value
GOTO(END_LABEL_0)
LABEL_0:
//the condition 0 is false
LOADI(0)
STOREP(1) //storing y value
END_LABEL_0:
//end of conditional 0
LOADP(1) //loading y value
return;
}
