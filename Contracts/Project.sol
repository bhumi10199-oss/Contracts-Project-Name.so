// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedSavings {
    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Deposit) public deposits;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit(uint256 _lockTimeInSeconds) external payable {
        require(msg.value > 0, "No ETH sent");
        require(deposits[msg.sender].amount == 0, "Existing deposit found");

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            unlockTime: block.timestamp + _lockTimeInSeconds
        });

        emit Deposited(msg.sender, msg.value, block.timestamp + _lockTimeInSeconds);
    }

    function withdraw() external {
        Deposit memory userDeposit = deposits[msg.sender];
        require(userDeposit.amount > 0, "No deposit found");
        require(block.timestamp >= userDeposit.unlockTime, "Funds are still locked");

        uint256 amount = userDeposit.amount;
        deposits[msg.sender].amount = 0;

        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function checkLockTime(address user) external view returns (uint256) {
        return deposits[user].unlockTime;
    }
}
