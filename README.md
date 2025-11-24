# ModMerits 🎖️

A decentralized tipping service for community moderators and Discord server managers built on the Stacks blockchain using Clarity smart contracts.

## Overview

ModMerits enables community members to reward their favorite moderators and server managers with STX tokens directly on-chain. All transactions are transparent, secure, and permanently recorded on the Stacks blockchain.

## Features

- ✅ **Moderator Registration** - Link Discord accounts to Stacks addresses
- 💰 **Direct Tipping** - Send STX tips with custom messages
- 📊 **Tip Tracking** - Complete history of all tips received
- 🔐 **Account Management** - Activate/deactivate moderator accounts
- 💵 **Platform Fee** - 5% fee (adjustable by contract owner, max 20%)
- 🔍 **Transparency** - All transactions verifiable on-chain

## Smart Contract Functions

### Public Functions

#### `register-moderator`
Register as a moderator to receive tips.

```clarity
(register-moderator (discord-id (string-ascii 100)))
```

**Parameters:**
- `discord-id` - Your Discord username or ID (max 100 characters)

**Returns:** `(ok true)` on success

**Example:**
```clarity
(contract-call? .ModMerits register-moderator "DiscordUser#1234")
```

---

#### `send-tip`
Send a tip to a registered moderator.

```clarity
(send-tip (moderator principal) (amount uint) (message (string-utf8 280)))
```

**Parameters:**
- `moderator` - Stacks address of the moderator
- `amount` - Tip amount in microSTX (1 STX = 1,000,000 microSTX)
- `message` - Optional message (max 280 characters, like a tweet!)

**Returns:** `(ok tip-amount)` - The actual amount received by moderator after fees

**Example:**
```clarity
(contract-call? .ModMerits send-tip 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u1000000 u"Great moderation!")
```

---

#### `deactivate-account`
Temporarily deactivate your moderator account to stop receiving tips.

```clarity
(deactivate-account)
```

**Returns:** `(ok true)` on success

---

#### `reactivate-account`
Reactivate your moderator account to resume receiving tips.

```clarity
(reactivate-account)
```

**Returns:** `(ok true)` on success

---

#### `set-platform-fee` (Owner Only)
Update the platform fee percentage.

```clarity
(set-platform-fee (new-fee uint))
```

**Parameters:**
- `new-fee` - New fee percentage (max 20)

**Returns:** `(ok true)` on success

---

### Read-Only Functions

#### `get-moderator-info`
Retrieve information about a registered moderator.

```clarity
(get-moderator-info (moderator principal))
```

**Returns:**
```clarity
{
  discord-id: (string-ascii 100),
  total-tips-received: uint,
  is-active: bool
}
```

---

#### `get-platform-fee`
Get the current platform fee percentage.

```clarity
(get-platform-fee)
```

**Returns:** `uint` - Current fee percentage

---

#### `get-tip-details`
Retrieve details of a specific tip transaction.

```clarity
(get-tip-details (tipper principal) (moderator principal) (tip-id uint))
```

**Returns:**
```clarity
{
  amount: uint,
  timestamp: uint,
  message: (string-utf8 280)
}
```

---

#### `is-moderator-registered`
Check if an address is a registered moderator.

```clarity
(is-moderator-registered (moderator principal))
```

**Returns:** `bool` - true if registered, false otherwise

---

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Action requires contract owner |
| u101 | `err-invalid-amount` | Invalid tip amount or fee |
| u102 | `err-moderator-not-found` | Moderator not registered or inactive |
| u103 | `err-already-registered` | Address already registered |
| u104 | `err-transfer-failed` | STX transfer failed |

---

## Usage Examples

### For Moderators

**1. Register as a moderator:**
```clarity
(contract-call? .ModMerits register-moderator "YourDiscord#0001")
```

**2. Check your stats:**
```clarity
(contract-call? .ModMerits get-moderator-info tx-sender)
```

**3. Take a break (deactivate):**
```clarity
(contract-call? .ModMerits deactivate-account)
```

### For Tippers

**1. Check if moderator is registered:**
```clarity
(contract-call? .ModMerits is-moderator-registered 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

**2. Send a 5 STX tip:**
```clarity
(contract-call? .ModMerits send-tip 
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 
  u5000000 
  u"Thanks for keeping the community safe!")
```

---

## Fee Structure

- **Platform Fee:** 5% (default, adjustable by owner)
- **Example:** Send 10 STX tip
  - Moderator receives: 9.5 STX
  - Platform fee: 0.5 STX

---

## Deployment

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with testnet/mainnet STX

### Deploy Steps

1. **Clone and navigate to project:**
```bash
git clone <your-repo>
cd modmerits
```

2. **Test locally:**
```bash
clarinet test
```

3. **Deploy to testnet:**
```bash
clarinet deploy --testnet
```

4. **Deploy to mainnet:**
```bash
clarinet deploy --mainnet
```

---

## Security Considerations

- ✅ All STX transfers use native `stx-transfer?` function
- ✅ Input validation on all public functions
- ✅ Protection against reentrancy attacks
- ✅ Only moderators can manage their own accounts
- ✅ Platform fee capped at 20% maximum
- ✅ No external contract calls

---

## Integration Ideas

### Discord Bot Integration
Create a Discord bot that:
- Helps moderators register their Stacks address
- Allows users to tip with commands like `/tip @moderator 5 STX`
- Shows leaderboards of top-tipped moderators
- Notifies moderators when they receive tips

### Web Dashboard
Build a web interface to:
- Browse all registered moderators
- View tip history and statistics
- Send tips with a friendly UI
- Track your favorite moderators

---

## Roadmap

- [ ] Multi-moderator tips (tip multiple mods at once)
- [ ] Subscription-based recurring tips
- [ ] NFT badges for top tippers
- [ ] Integration with other community platforms (Reddit, Telegram)
- [ ] Withdrawal scheduling features
- [ ] Enhanced analytics dashboard

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**⚠️ Disclaimer:** This is a smart contract deployed on the Stacks blockchain. Always verify contract addresses and test with small amounts first. The developers are not responsible for lost funds due to user error.