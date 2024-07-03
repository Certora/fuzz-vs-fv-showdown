

/***


to run:
from folder prb-math: 

certoraRun test/Wrapper.sol --verify Wrapper:test/MulDivSign.certora.spec 

https://prover.certora.com/output/40726/37fd8698a5ae4837afc0ba4745bc015a?anonymousKey=736b80546317c3e44b7f5c6f0c10f0e7d36e0355


***/

methods {
    function mulDivSigned(int256, int256, int256) external returns (int256) envfree;
}


rule verify(int256 x, int256 y, int256 denominator) {

    require denominator != 0 ;
    mathint mathameticalResult = x*y / denominator; 

    int256 actualResult = mulDivSigned(x,y,denominator);
    assert to_mathint(actualResult) == mathameticalResult; 
}