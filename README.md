# Stages

* I. Management of simple arithmetic expressions with constants (3 points)

* II. Type management/verification/conversions (3 points)

* III. Management of global variables (3 points)

* IV. Branching management (3 points)

* V. Management of sub-blocks (3 points)

* VI. Function call management (3 points)

* VII. Type addition (2 points)

# Achievements

* Stage 1 : Done. Nothing particular.

* Stage 2 : Done.Nothing particular.

* Stage 3 : Done. Offset processed by ascending in the three. ```glob_decl_list decl decl_list var_decl vlist ``` are declared as ```offset_value```. Global offsets start at 0, block offsets start at 1 to let the 0 to the block pointer.

* Stage 4 : Done. ```char* getLabel(int i)``` and ```char* getLoop(int i)``` functions added to return a label with i as an identifier. In use, i is the label/loop counter (which are globals) and the return is a global ```char* buffer[100]``` to avoid leak memory. ```if```, ```elsop``` and ```while``` are declared as ```label_value```. ```if``` and ```while``` increment the corresponding global counter and ```elsop``` collect the label number from ```if``` to be accessible to ```else```. The others token which need the label number collect it from one of the three mentioned earlier.

* Stage 5 : Done. Adding of the block pointer use with the global depth / variable depth difference.

* Stage 6 : Done. ```params``` is used to note the negative offset of each arg when defining the function. ```arglist``` is used to count the number of arguments and ```ENDCALL(i)``` the right i. ```app``` collects the function type to allow computing with function (e.g. recursive). Globals ```int arg_count``` and ```int arg_type[MAX_ARG]``` are used to note the arguments number of a function and their types and then, fill them into an attribute. So ```int arg_count``` and ```int type_array[MAX_ARG]``` are 2 new fields of the ```attribute structure```. This allow the check/conversion type when the function is called.
* 
# Usage

```make``` : Compile ```lang```, the myc to pcode compiler. ```lang``` takes in input the myc code (```./lang < code.c```).

```./run ExXX``` (with XX a number) : Compile the XX example from myc to pcode in the ExXX_pcode.c file. The result is also print on the standard output.
