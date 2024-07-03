// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

/***

run from base project directory with:
 forge test --match-contract MulDivSignFoundry

***/

import "../src//common.sol" as Common;

import { Base_Test } from "./Base.t.sol";

contract MulDivSignFoundry is Base_Test {

    function test_mulDivSigned(int256 x, int256 y, int256 denominator) pure external  {
        vm.assume(denominator != type(int256).min && denominator != 0) ;
        // to avoid overflow in the test */
        vm.assume( x > type(int128).min && x < type(int128).max ) ;
        vm.assume(y > type(int128).min && y < type(int128).max ) ;
        int256 actual = Common.mulDivSigned(x, y, denominator);
        int256 expected = (x * y ) / denominator ;
        assertEq(actual, expected);    
    }

}
