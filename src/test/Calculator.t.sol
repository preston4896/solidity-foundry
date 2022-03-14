// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../Calculator.sol";
import "./console.sol";

contract CalculatorTest is DSTest {
    Calculator calculator;

    function setUp() public {
        calculator = new Calculator(0);
    }

    function testView() public view {
        require(calculator.getNumber() == 0);
    }

    function testCalculator() public {
        // 0 + 2 = 2
        require(calculator.add(2) == 2);
        // 2 - 1 = 1
        require(calculator.sub(1) == 1);
        // 1 * 10 = 10
        require(calculator.mult(10) == 10);
        // 10 / 2 = 5
        require(calculator.div(2) == 5);
    }

    function testAddWithFuzzing(uint256 a) public {
        require(calculator.add(a) == a);
    }

    function testSubWithFuzzing(uint256 a) public {
        uint256 initial = calculator.add(type(uint256).max);
        require(calculator.sub(a) == initial - a);
    }

    function testMultWithFuzzing(uint256 a) public {
        require(calculator.mult(a) == 0);
    }

    function testDivWithFuzzing(uint256 a) public {
        uint256 initial = calculator.add(a);
        require(calculator.getNumber() == initial);
        require(calculator.div(2) == a / 2);
    }
}
