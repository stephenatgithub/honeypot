// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Honeypot.sol";

contract HoneypotTest is Test {
    HoneyPot public honeyPot;
    Bank public bank;

    function setUp() public {
        honeyPot = new HoneyPot();
        bank = new Bank(address(honeyPot));
    }

    function testDeposit() public {
        bank.deposit{value: 2 ether}();
        assertEq(address(bank).balance, 2 ether);
    }

    function testWithdraw() public {
        bank.deposit{value: 1 ether}();
        assertEq(address(bank).balance, 1 ether);

        address alice = address(1);
        vm.startPrank(alice);
        vm.deal(alice, 5 ether);

        bank.deposit{value: 2 ether}();
        assertEq(address(bank).balance, 3 ether);

        bank.withdraw(2 ether);
        assertEq(address(bank).balance, 1 ether);
    }

    function testAttack() public {
        bank.deposit{value: 2 ether}();
        assertEq(address(bank).balance, 2 ether);

        address alice = address(1);
        vm.startPrank(alice);
        vm.deal(alice, 5 ether);
        
        Attack a = new Attack(address(bank));
        a.attack{value: 1 ether}();
        assertEq(address(bank).balance, 0);
    }
}
