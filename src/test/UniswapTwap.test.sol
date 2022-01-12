// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.9;

import "ds-test/test.sol";
import "./IHevm.sol";
import "./Vader.sol";
import "./Pair.sol";
import "./Oracle.sol";
import "../UniswapTwap.sol";

uint constant UPDATE_PERIOD = 8 * 3600;

// Vader / ETH pair
uint constant RESERVE_0 = 66499238503559455756102747;
uint constant RESERVE_1 = 1516294737994407350424;
uint32 constant BLOCK_TIMESTAMP_LAST = 1641965524;
uint constant PRICE_0_CUMULATIVE = 290997132847692725730920201640628870;
uint constant PRICE_1_CUMULATIVE = 2175364172539067783223801824880287210285448442;

contract User {
    UniswapTwap private twap;

    constructor(UniswapTwap _twap) {
        twap = _twap;
    }

    function setOracle(IAggregatorV3 _oracle) external {
        twap.setOracle(_oracle);
    }

    function setUpdatePeriod(uint _updatePeriod) external {
        twap.setUpdatePeriod(_updatePeriod);
    }

    function setMaxPriceDiff(uint _maxPriceDiff) external {
        twap.setMaxPriceDiff(_maxPriceDiff);
    }

    function setKeeper(address _keeper) external {
        twap.setKeeper(_keeper);
    }

    function forceUpdateVaderPrice() external {
        twap.forceUpdateVaderPrice();
    }
}

contract UniswapTwapTest is DSTest {
    IHevm private hevm;

    Vader private vader;
    Oracle private oracle;
    Pair private pair;
    UniswapTwap private twap;

    User private user;
    User private keeper;

    uint private deployedAt;

    function setUp() public {
        hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(BLOCK_TIMESTAMP_LAST + 1);

        vader = new Vader();

        pair = new Pair(address(vader), address(222));
        // numbers from mainnet Vader / ETH pair
        pair._setReserves_(RESERVE_0, RESERVE_1, BLOCK_TIMESTAMP_LAST);
        pair._setPriceCumulative_(PRICE_0_CUMULATIVE, PRICE_1_CUMULATIVE);

        oracle = new Oracle(8);
        oracle._setAnswer_(3100 * 10**8);

        twap = new UniswapTwap(address(vader), pair, oracle, UPDATE_PERIOD);

        // users to test access control
        user = new User(twap);
        keeper = new User(twap);

        deployedAt = block.timestamp;
    }

    function test_constructor() public {
        assertEq(twap.vader(), address(vader));
        assertEq(address(twap.oracle()), address(oracle));
        assertEq(address(twap.pair()), address(pair));
        assertEq(twap.maxPriceDiff(), 1e5);

        (
            uint priceCumulative,
            ,
            uint lastMeasurement,
            uint updatePeriod,
            bool isFirst
        ) = twap.pairData();

        assertEq(priceCumulative, PRICE_0_CUMULATIVE);
        assertEq(lastMeasurement, deployedAt);
        assertEq(updatePeriod, UPDATE_PERIOD);
        assertTrue(isFirst);

        assertEq(twap.maxUpdateWindow(), updatePeriod);
    }

    function test_getVaderPrice() public {
        hevm.warp(block.timestamp + UPDATE_PERIOD + 1);
        twap.syncVaderPrice();

        assertGt(twap.getVaderEthPriceAverage(), 0);

        // test TWAP - spot price difference is small
        uint maxPriceDiff = 100;
        twap.setMaxPriceDiff(maxPriceDiff);

        uint twapPrice = twap.getVaderEthPriceAverage();
        uint spotPrice = twap.getVaderEthSpotPrice();

        assertGt(twapPrice, 0);
        assertGt(spotPrice, 0);
        assertLt((abs(twapPrice, spotPrice) * 1e5) / twapPrice, maxPriceDiff);

        twap.syncVaderPrice();

        // prices extracted from making the test fail
        twapPrice = twap.getVaderEthPriceAverage();
        spotPrice = twap.getVaderEthSpotPrice();
        assertEq(twapPrice, 22802477433001);
        assertEq(spotPrice, 22801685735292);
        // approximately 2 * 1e-5
        assertEq((twapPrice * 1e5) / 1e18, 2);
        assertEq((spotPrice * 1e5) / 1e18, 2);

        uint vaderUsdPrice = twap.getVaderPrice();
        assertEq(vaderUsdPrice, 70687680042303100);
        // approximately $0.07
        assertEq((vaderUsdPrice * 100) / 1e18, 7);
    }

    function test_setKeeper() public {
        twap.setKeeper(address(keeper));
        assertEq(twap.keeper(), address(keeper));
    }

    function testFail_setKeeper() public {
        user.setKeeper(address(keeper));
    }

    function test_setOracle() public {
        twap.setOracle(oracle);
    }

    function testFail_setOracle() public {
        user.setOracle(oracle);
    }

    function test_setUpdatePeriod() public {
        twap.setUpdatePeriod(111);
        (, , , uint updatePeriod, ) = twap.pairData();
        assertEq(updatePeriod, 111);
    }

    function testFail_setUpdatePeriod() public {
        user.setUpdatePeriod(111);
    }

    function testFail_setUpdatePeriod_max() public {
        twap.setUpdatePeriod(30 days + 1);
    }

    function test_setMaxPriceDiff() public {
        twap.setMaxPriceDiff(1);
        assertEq(twap.maxPriceDiff(), 1);
    }

    function testFail_setMaxPriceDiff() public {
        user.setMaxPriceDiff(1);
    }

    function testFail_setMaxPriceDiff_max() public {
        twap.setMaxPriceDiff(1e5 + 1);
    }

    function test_forceUpdateVaderPrice() public {
        twap.forceUpdateVaderPrice();
    }

    function test_forceUpdateVaderPrice_keeper() public {
        twap.setKeeper(address(keeper));
        keeper.forceUpdateVaderPrice();
    }

    function testFail_forceUpdateVaderPrice() public {
        user.forceUpdateVaderPrice();
    }
}
