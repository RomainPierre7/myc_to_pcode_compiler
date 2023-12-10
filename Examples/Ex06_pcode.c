// PCode Header
#include "PCode.h"

int main() {
pcode_main();
return stack[sp-1].int_value;
}

//int type x declaration with an offset of 0 at depth 0
LOADI(0)
//float type y declaration with an offset of 1 at depth 0
LOADF(0.0)

void pcode_main(){
LOADI(3)
STOREP(0) //storing x value
LOADF(2.000000)
STOREP(1) //storing y value
LOADI(1)
LOADP(1) //loading y value
LOADP(0) //loading x value
I2F //converting second arg to float
MULTF
I2F2 //converting first arg to float
ADDF
return;
}
