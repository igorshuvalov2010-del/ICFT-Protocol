// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {InvalidRecipient, InvalidTokenAllocation} from "../../utils/Errors.sol";

/**
 * @title ICFT
 * @notice Fixed-supply ERC-20 token used by the ICFT MVP lending protocol.
 * @dev The contract mints the entire supply once during construction and never mints again.
 * @dev Allocation constants encode the requested tokenomics split used by the MVP deployment flow.
 *
 * @custom:version 1.0.0
 */
contract ICFT is ERC20 {
    /// @notice Total fixed token supply minted once at deployment.
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 ether;

    /// @notice Allocation reserved for Fund A lending liquidity.
    uint256 public constant FUND_A_ALLOCATION = 200_000_000 ether;
    /// @notice Allocation reserved for liquid market and operational liquidity.
    uint256 public constant LIQUIDITY_ALLOCATION = 150_000_000 ether;
    /// @notice Allocation reserved for strategic reserves.
    uint256 public constant STRATEGIC_RESERVE_ALLOCATION = 280_000_000 ether;
    /// @notice Allocation reserved for future investor distribution.
    uint256 public constant FUTURE_INVESTORS_ALLOCATION = 160_000_000 ether;
    /// @notice Allocation reserved for founders.
    uint256 public constant FOUNDER_ALLOCATION = 80_000_000 ether;
    /// @notice Allocation reserved for developers and core contributors.
    uint256 public constant DEVELOPERS_ALLOCATION = 100_000_000 ether;
    /// @notice Allocation reserved for ecosystem grants and growth programs.
    uint256 public constant ECOSYSTEM_GRANTS_ALLOCATION = 30_000_000 ether;

    /**
     * @notice Mints the full fixed supply according to the requested allocation split.
     * @param fundARecipient Recipient of the Fund A allocation.
     * @param liquidityRecipient Recipient of the liquidity allocation.
     * @param strategicReserveRecipient Recipient of the strategic reserve allocation.
     * @param futureInvestorsRecipient Recipient of the future investors allocation.
     * @param founderRecipient Recipient of the founder allocation.
     * @param developersRecipient Recipient of the developers allocation.
     * @param ecosystemRecipient Recipient of the ecosystem grants allocation.
     */
    constructor(
        address fundARecipient,
        address liquidityRecipient,
        address strategicReserveRecipient,
        address futureInvestorsRecipient,
        address founderRecipient,
        address developersRecipient,
        address ecosystemRecipient
    ) ERC20("ICFT", "ICFT") {
        if (
            fundARecipient == address(0) ||
            liquidityRecipient == address(0) ||
            strategicReserveRecipient == address(0) ||
            futureInvestorsRecipient == address(0) ||
            founderRecipient == address(0) ||
            developersRecipient == address(0) ||
            ecosystemRecipient == address(0)
        ) revert InvalidRecipient();

        // Mint the full tokenomics split in a single deterministic construction flow.
        _mint(fundARecipient, FUND_A_ALLOCATION);
        _mint(liquidityRecipient, LIQUIDITY_ALLOCATION);
        _mint(strategicReserveRecipient, STRATEGIC_RESERVE_ALLOCATION);
        _mint(futureInvestorsRecipient, FUTURE_INVESTORS_ALLOCATION);
        _mint(founderRecipient, FOUNDER_ALLOCATION);
        _mint(developersRecipient, DEVELOPERS_ALLOCATION);
        _mint(ecosystemRecipient, ECOSYSTEM_GRANTS_ALLOCATION);

        // Enforce that the static allocation constants fully reconstruct the intended total supply.
        if (totalSupply() != TOTAL_SUPPLY) revert InvalidTokenAllocation();
    }
}
