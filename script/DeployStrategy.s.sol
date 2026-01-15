// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "lib/yieldnest-flex-strategy/script/DeployFlexStrategy.s.sol";
import {L1Contracts} from "@yieldnest-vault-script/Contracts.sol";
import {IContracts} from "@yieldnest-vault-script/Contracts.sol";
import {IActors} from "@yieldnest-vault-script/Actors.sol";
import {console} from "forge-std/console.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyUtils} from "lib/yieldnest-flex-strategy/lib/yieldnest-vault/script/ProxyUtils.sol";
import {MainnetStrategyActors} from "@script/Actors.sol";

contract DeployStrategy is DeployFlexStrategy {
    address public YNUSDX = 0x3DB228FE836D99Ccb25Ec4dfdC80ED6d2CDdCB4b;

    function _setup() public virtual override {
        MainnetStrategyActors _actors = new MainnetStrategyActors();
        if (block.chainid == 1) {
            minDelay = 1 days;
            actors = IActors(_actors);
            contracts = IContracts(new L1Contracts());
        }
        address[] memory _allocators = new address[](1);
        _allocators[0] = YNUSDX;

        setDeploymentParameters(
            BaseScript.DeploymentParameters({
                name: "YieldNest USDC Flex Strategy - ynUSDx - ARB1",
                symbol_: "ynFlex-USDC-ynUSDx-ARB1",
                accountTokenName: "YieldNest Flex Strategy - ynUSDx - ARB1 Accounting Token",
                accountTokenSymbol: "ynFlexUSDC-ynUSDx-ARB1-Tok",
                decimals: 6, // 6 decimals for USDC
                paused: true,
                targetApy: 0.12 ether, // 12% rewards per year
                lowerBound: 0.0001 ether, // Ability to mark 0.01% of TVL as losses
                minRewardableAssets: 1000e6, // min 1000 USDC
                accountingProcessor: _actors.PROCESSOR(),
                baseAsset: IVault(YNUSDX).asset(),
                allocators: _allocators,
                safe: _actors.SAFE(),
                alwaysComputeTotalAssets: true,
                useRewardsSweeper: false
            })
        );
    }
}
