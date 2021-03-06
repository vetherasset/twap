# twap

```shell
npm i

# config .sethrc
cp .sethrc.copy .sethrc

# list accounts
ethsign ls

# import account
ethsign import

# delete imported key
rm $HOME/.ethereum/keystore/my-key

# lint
npm run lint

# solhint
npm run solhint

# compile
dapp build
# test
dapp test -v

# ---- Kovan ----
VADER=0xcCb3AeF7Baa506e2D05193e38e88459F68AC1a8F
PAIR=0xd9c8de60D39b2F421B3e59598f14aA108406EDF0
ORACLE=0x9326BFA02ADD2366b30bacB125260Af641031331
UPDATE_PERIOD=1

TWAP=0x1bf8b6fde5c942867dd9d3dcea506de706fe98b4

# ---- Mainnet ----
VADER=0x2602278EE1882889B946eb11DC0E810075650983
PAIR=0x452c60e1E3Ae0965Cd27dB1c7b3A525d197Ca0Aa
ORACLE=0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
UPDATE_PERIOD=1

TWAP=0x6a81be7f5c868f34f109d5b5f38ed67f3395f7b0

# deploy
dapp create src/UniswapTwap.sol:UniswapTwap $VADER $PAIR $ORACLE $UPDATE_PERIOD --verify

# verify
export ETHERSCAN_API_KEY=...
TWAP=0xF0733C42640a93D7216c45fec99B2Ba839Afff94
dapp verify-contract src/UniswapTwap.sol:UniswapTwap $TWAP $VADER $PAIR $ORACLE $UPDATE_PERIOD

# flatten
hevm flatten --source-file src/UniswapTwap.sol > tmp/flat.sol

# slither
pip3 install slither-analyzer
slither tmp/flat.sol
slither tmp/flat.sol --print human-summary
slither tmp/flat.sol --print vars-and-auth
```
