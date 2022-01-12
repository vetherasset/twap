// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.9;

import "../interfaces/chainlink/IAggregatorV3.sol";

contract Oracle is IAggregatorV3 {
    uint8 public decimals;

    uint80 public roundId;
    int public answer;
    uint public startedAt;
    uint public updatedAt;
    uint80 public answeredInRound;

    constructor(uint8 _decimals) {
        decimals = _decimals;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int,
            uint,
            uint,
            uint80
        )
    {
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    // test helpers
    function _setAnswer_(int _answer) external {
        answer = _answer;
    }
}
