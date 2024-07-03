// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;


import  "src/common.sol" as Common;

contract Wrapper   {
    function mulDivSigned(int256 x, int256 y, int256 denominator) external pure returns (int256 result)  {
        return Common.mulDivSigned(x, y, denominator);
    }

}
