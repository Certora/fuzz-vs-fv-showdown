A comparison of Solidity fuzzing techniques to formal verification techniques.


The tools used for fuzzing are [Foundry](https://book.getfoundry.sh/)and [Echidna](https://secure-contracts.com/program-analysis/echidna/index.html). For formal verification, the tool of choice is Certora Prover.[https://docs.certora.com/]


This challenge set is based on existing benchmarks. In addition, and a few more examples aim to demonstrate the techniques and highlight the differences between them and their shared properties.


Slides of a talk Given at ethcc(7) can be found [here](https://docs.google.com/presentation/d/1hTESS6QsveNN2_YG9Q297NJGb5XiwvXl05xgRr5S2kY/edit#slide=id.p)


## Results for Prb-math ##
Within the  prb-math repository at https://github.com/PaulRBerg/prb-math,
An example illustrates a discrepancy between the intended behavior of the code and its actual implementation.
Specifically, the Common.mulDivSigned() function does not round down as expected.
This discrepancy arises because Solidity rounds towards zero, which means testing with a Solidity fuzzer and a naive property fails to identify this misunderstanding. However, adjusting the assertion to reflect a deeper understanding of the issue enables the fuzzer test to detect this behavior accurately.




run from folder prb-math:
fuzzer test:


`forge test --match-contract MulDivSignFoundry`    
`forge test --match-contract MulDivSignAdvancedFoundry`




formal verification: 


`certoraRun test/Wrapper.sol --verify Wrapper:test/MulDivSign.certora.spec `


The result of the Certora Prover demonstrates that the expected value is less than the actual one.
The source code was modified (fixed documentation)  due to this formal verification finding:
https://prover.certora.com/output/40726/f49175a31fee4c3ba5f84ae6b930a882?anonymousKey=4b232b7f08def3d92f66729f2317a57b90c86f1b


This finding highlights two key observations:
1. There is a distinct advantage in validating code using a different engine/language than the one being tested. For instance, the Certora Prover utilizes CVL - a mathematical form - to define properties whereas most existing Solidity fuzzers are reliant on the Solidity compiler. 
2.  Writing tests in multiple ways can uncover issues both in the compiler itself and in underlying assumptions. This approach helps in identifying discrepancies that might otherwise go unnoticed.


The probability of a catch for a fuzzer:
There are three variables (x,y,denominator). The bug occurs when the result is negative and there is rounding to an integer.




| x | y | denominator | catch |
| --| --| ---------- | -------|
| + | + | + | no |
| + | + | - | yes |
| + | - | + | yes |
| + | - | - | no |
| - | + | + | yes |
| - | + | - | no |
| - | - | + | no |
| - | - | - | yes |


The probability of catching this behavior was 4 out of 8 (1 to 2 odds), which proved sufficient with 3 runs.





## Results of solidity-fuzzing-comparison ##


### Challenge #1 Naive Receiver  ###


This example is based on damn-vulnerable https://github.com/OpenZeppelin/damn-vulnerable-defi.
Fuzzers attempt to detect a property where the Ethereum balance of a specific receiver does not change. However, this property is weak since there are valid scenarios where such changes are expected. Running time: 2h for Echidna.
For the slightly better property, the reciever's balance does not reduce to 0, not found by fuzzers.


As demonstrated by the Certora Prover the property (receiverHasAssets_invariant) breaks immediately after the constructor.
To address this, the Certora Prover requires a more robust property, such as the noChangeToOtherUser rule,  and finds a violation swiftly You can view the violation found for receiverHasAssets_rule:https://prover.certora.com/output/40726/2a3306dfe1f345d180542e8760d0fbfa/?anonymousKey=cd948532525e7575020473552ff6b24fe10a1a00
Note that it found another violation, which is simply calling the `receiveEther` function directly with a `fee` amount and `msg.value` amount that sums to the current balance.
Note that on a fixed version of the code, only noChangeToOtherUser is verified, demonstrating that it is a correct property;
https://prover.certora.com/output/40726/4aae2d02e03d4b99a9a18bdda7084d39?anonymousKey=831594d3dc0a3cf3aef95752593dc6e1adf5171c


This highlights two key observations:
1. Properties should be written to ensure correct general behavior.
2. There can be multiple violations of a property so the code should be fixed and rechecked.
3. No change to other is a complicated rule to write with a fuzzer


### Challenge #2 Unstoppable  ###


### Challenge #3 Proposal ###
The Certora Prover default behavior is over-approximation and asserts on dynamic loops; https://docs.certora.com/en/latest/docs/prover/cli/options.html#optimistic-loop. 
See [result](https://prover.certora.com/output/40726/829c057e2446485bbc132b1764ae6a73?anonymousKey=ded92f50e2961fbe70e848e80c40c6fabace58eb) run after resolving external call. The prover asserts about "Unwinding condition in a loop".

Adding only `--optimistic_loop`, the code is verified due to assuming only one loop (which implies one voter), see [report]
(https://prover.certora.com/output/40726/672527e8e1f94b9bb0abe20ec9c1056f/?anonymousKey=bca2cd9a23ec9b0cb27791b6f4a8939b9a99cdf5). 

The Certora Prover needs at least 2 iterations to detect a [violation](https://prover.certora.com/output/40726/48fbfffb48974d1a89c4595239f4e83a?anonymousKey=f8f12fac85dbf80fb348e771c6d7f7c8ab75cc2a).
The issue is that the reward per voter should be computed using the totalVotersFor.

Fixing the issue and rerunning with 2 iterations, the code is [verified](https://prover.certora.com/output/40726/626246a27635490b85e4ad9fb78aaf1b?anonymousKey=22e598e5006b8d2bbc67155d4b4ef8d187c61e0a). However, this again is an under-approximation. 

Adding another loop iteration, identifies another [issue](https://prover.certora.com/output/40726/4e19880047f9437f85e4abe110f7e6ea?anonymousKey=51a29ced27f221bd0b43cbe42978e3fcf0864a9f), which there is one than one dust to give away to the last voter. 
Now we can fix the code and get a complete [verification](https://prover.certora.com/output/40726/7f5bc4d479044dd7a7704ba862315885?anonymousKey=1ef5a2ea874ac79327c390ece206b56e30709421) .


This example highlights that setup should be carefully checked, especially when using unsafe assumptions (in all tools).




### Challenge #6 Rarely False  ###
The Certora Prover easily finds  https://prover.certora.com/output/40726/6b68aa093d7f42088381e9a553879ad4?anonymousKey=1ac51616393f2d83495ec22a9daaa205e1346ae6
For Echidna 10 hours is not enough, (2 ** 30)  iterations.


To catch this bug, the fuzzer needs to randomly create a number that, when summed up with 1234, all 80 lower bits are 0.
probability of catch -   1 to 2^80


On the other hand, the Certora Prover solves it mathematically in seconds.
This highlights that catching rare behavior can take a significant amount of iterations. 


## Results of fuzz-vs-fv ##


### fund-eq-of-dai-certora


certora run : 36s https://prover.certora.com/output/40726/cd7686ca79a64bd0bfbf67918174587b/?anonymousKey=fd25e812595b5c6db37b207d85cb594f89f5dbad


On the basic setting, the Fuzzer ran for 13 hours and made over 125 million calls.
Why did it take so long?
The issue arises when two specific functions are called, out of the 17 functions, and there is a strong correlation between the arguments:


The two functions;


```
grab(bytes32 index, address u, address v, address w, int256 dink, int256 dart)
init(bytes32 index)
```


The exact arguments have to be:


```
   grab(x, *, *, *,  0 , != 0  )
   init(x)
```
Thus, the first argument has to be the same, the dink has to be zero and the dart non-zero. The addresses don't matter.


So the chances are:
1/17 selecting grab() sighash
1/ 2^256 selecting dink to be zero
1/1 selecting non-zero value
1/17 selecting init()
1/2^256 selecting the same x as for grab


1 to ( 17 * 17 * 2^512)
Luckily the fuzzers choose 0 and small numbers at a higher probability so significantly less iterations are needed, 125 M approximately 2^26.






# comet
Writing the same property as defined by Certora spec:
Certoaa Spec: https://github.com/Certora/comet/tree/certora



