//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Calculator {
    uint256 _number;

    constructor(uint256 number_) {
        _number = number_;
    }

    function add(uint256 x) public returns (uint256) {
        _number += x;
        return _number;
    }

    function sub(uint256 x) public returns (uint256) {
        _number -= x;
        return _number;
    }

    function mult(uint256 x) public returns (uint256) {
        _number *= x;
        return _number;
    }

    function div(uint256 x) public returns (uint256) {
        _number /= x;
        return _number;
    }

    function getNumber() public view returns (uint256) {
        return _number;
    }
}
