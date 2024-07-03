

From prb-math library https://github.com/PaulRBerg/prb-math .

Where there was a discrepancy between what the code does and it's definition. 
function Common.mulDivSigned() does not round down as expected. 
This is due to the fact that Solidity rounds towards zero, so testing with a Solidity fuzzer and the naive property does not catch this misunderstanding. An advanced fuzzer test does catch this behavior 


fuzzer test: 

forge test --match-contract MulDivSignFoundry     
forge test --match-contract MulDivSignAdvancedFoundry


formal verification:  
run from folder prb-math:

certoraRun test/Wrapper.sol --verify Wrapper:test/MulDivSign.certora.spec  

result of Certora Prover demonstrate that 
The source code was modified (fixed documentation)  due to this formal verification finding: 
https://prover.certora.com/output/40726/f49175a31fee4c3ba5f84ae6b930a882?anonymousKey=4b232b7f08def3d92f66729f2317a57b90c86f1b

This finding highlights two key observations: 
1. There is an advantage of checking your code with a different engine/language than the one being tested. The Certora Prover uses CVL - a mathematical form - to define properties. Currently, all Solidity fuzzers are base on Solidity compiler 
2. Write your tests in multiple ways - this might catch problems in the compiler and also in assumptions that might have been made 

The probability of a catch for a fuzzer:
there are three variables (x,y,denominator) the bug occurs when the result is negative and there is rounding to an integer, Approximately: 30%
Indeed enough 10 runs to catch this, 
