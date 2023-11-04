# ✨ Ethereum Airdrop Contract Magic with Foundry ✨

## 🚀 Project Overview

Dive into the enchanting world of Ethereum smart contracts with our captivating Airdrop contract. Now with the addition of ERC721 tokens, this spellbook not only handles ETH and ERC20 tokens but also allows you to distribute NFTs with a wizard's flourish. Crafted in the mystical forges of Foundry, this magic code empowers you to bestow tokens and NFTs alike across the blockchain, all within an efficient, secure, and user-friendly interface.

## 🌟 Mystical Features

- **Batch Airdrop Alchemy:** Cast your tokens far and wide, reaching multiple beneficiaries in a singular, gas-saving incantation.

- **ERC20 Compatibility Charm:** Ensures your tokens, no matter their origin, glide seamlessly into the recipients' vaults.

- **Gas-Efficiency Enchantment:** Minimizes the ether spent in the airdrop process, saving you from draining your mana pool.

- **Robust Error Warding:** Shields your transactions from the dark arts of failed transfers and blockchain mishaps.

- **Spell of Simplicity:** With incantations designed for ease, you'll perform airdrops as easily as waving a wand.

- **ERC721 Token Enchantment:** Broaden your airdrop capabilities to include the transfer of NFTs, ensuring your magical creatures and artifacts reach their new guardians without a hitch.

## 📚 Grimoire of Prerequisites

Before you embark on your journey, ensure your alchemist's kit contains:

- The latest Foundry toolchain, with forge and cast spells ready for casting.
- An Ethereum grail (wallet) filled with enough ethers for your airdrop crusade and contract summoning.

## 🧙‍♂️ Conjuring the Contract

Summon the Airdrop contract into your realm by following these mystical steps:

```bash
git clone https://github.com/ChaituKReddy/airdrop
cd ethereum-airdrop-foundry
forge install
```

## 🔮 Crystal Ball Configuration

Gaze into the crystal ball to configure your environmental talismans:

```bash
export RPC_URL="your-ethereum-rpc-url"
export PRIVATE_KEY="your-private-key"
```

## 🪄 Usage and Incantations

Before any grand spellcasting, cleanse your workspace of past enchantments:

```bash
forge clean
```

Weave your smart contract into existence:

```bash
forge build
```

Invoke the spirits to test your contract's fortitude:

```bash
forge test
```

Raise your contract from the depths of the Ethereum network:

```bash
forge script script/Airdrop.s.sol --private-key $PRIVATE_KEY --rpc-url $RPC_URL --broadcast
```

Perform the grand airdrop ritual with precision and care:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [CONTRACT_ADDRESS] "airdropNative(address[],uint256[])" [RECIPIENTS] [AMOUNTS]
```

For ERC20 potions, secure the contract's handling rights:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [TOKEN_ADDRESS] "approve(address,uint256)" [CONTRACT_ADDRESS] [AMOUNT]
```

Finally, release the airdrop spell:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [CONTRACT_ADDRESS] "airdropERC20(address,address[],uint256[])" [TOKEN_ADDRESS] [RECIPIENTS] [AMOUNTS]
```

To perform the new ERC721 token airdrop ritual:

Before casting the airdrop spell, invoke the following incantation to approve the Airdrop contract to transfer your NFTs:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [NFT_CONTRACT_ADDRESS] "setApprovalForAll(address,bool)" [AIRDROP_CONTRACT_ADDRESS] true
```

For a galaxy of NFTs to multiple wards:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [CONTRACT_ADDRESS] "airdropERC721(address,address[],uint256[])" [TOKEN_ADDRESS] [RECIPIENTS] [TOKEN_IDS]
```

For a single relic or a trove to one ward:

```bash
cast send --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY [CONTRACT_ADDRESS] "airdropERC721(address,address,uint256[])" [TOKEN_ADDRESS] [RECIPIENT] [TOKEN_IDS]
```

## 🛠️ Scrolls of Upgrading

To enhance your Airdrop contract with new spells and enchantments:

1. Craft new incantations and inscribe them onto your contract.
2. Rebuild your contract's essence with forge build.
3. Redeploy with the arcane knowledge of your new spells.

## 🤝 Circle of Conjurers

Join our circle and contribute your own spells and charms! Fork the repository, carve your runes, and propose your enhancements through a pull request.

## 📜 License Scroll

This tome of knowledge is shared under the MIT License. Consult the LICENSE scroll for divinations.
