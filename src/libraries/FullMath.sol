// SPDX-License-Identifier: CC-BY-4.0
pragma solidity 0.8.9;

// taken from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
// license is CC-BY-4.0
library FullMath {
    function fullMul(uint x, uint y) internal pure returns (uint l, uint h) {
        uint mm = mulmod(x, y, type(uint).max);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }

    function fullDiv(
        uint l,
        uint h,
        uint d
    ) private pure returns (uint) {
        uint pow2 = d & uint(-int(d));
        d /= pow2;
        l /= pow2;
        l += h * (uint(-int(pow2)) / pow2 + 1);
        uint r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }

    function mulDiv(
        uint x,
        uint y,
        uint d
    ) internal pure returns (uint) {
        (uint l, uint h) = fullMul(x, y);

        uint mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;

        if (h == 0) return l / d;

        require(h < d, "FullMath: FULLDIV_OVERFLOW");
        return fullDiv(l, h, d);
    }
}
