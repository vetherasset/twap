// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.9;

import "../interfaces/uniswap/IUniswapV2Pair.sol";

contract Pair is IUniswapV2Pair {
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;
    uint32 public blockTimestampLast;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        )
    {
        return (uint112(reserve0), uint112(reserve1), blockTimestampLast);
    }

    // test helpers
    function _setReserves_(
        uint _reserve0,
        uint _reserve1,
        uint32 _blockTimestampLast
    ) external {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = _blockTimestampLast;
    }

    function _setPriceCumulative_(uint _p0, uint _p1) external {
        price0CumulativeLast = _p0;
        price1CumulativeLast = _p1;
    }
}
