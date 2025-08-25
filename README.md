Charity Matching DAO Smart Contract

Overview

The Charity Matching DAO Smart Contract is built on the Stacks blockchain using the Clarity language.
It enables a decentralized donation system where user contributions to approved charities are matched from a DAO-managed treasury based on a configurable ratio.
This ensures greater impact for charitable giving while maintaining transparency and on-chain accountability.

✨ Features

DAO Treasury Management

Owner can fund the treasury (add-to-treasury) and withdraw in emergencies (emergency-withdraw).

Treasury balance is always tracked on-chain.

Charity Approval System

Only approved charities can receive donations.

Owner can add or remove charities dynamically.

Donation Matching

Donations are matched with treasury funds at a configurable matching ratio (default 1:1).

Per-donation match amounts are capped by max-match-per-donation.

Contract ensures treasury has enough funds before matching.

Transparency & Tracking

All donations, matches, and recipient totals are recorded on-chain.

History is stored per donor, per charity, per block.

Donor and charity totals can be queried at any time.

🔧 Contract Functions
Read-Only Functions

get-treasury-balance → Returns DAO treasury balance.

get-matching-ratio → Returns current matching ratio.

get-total-matched → Returns total matched STX across all donations.

is-charity-approved (charity) → Checks if a charity is approved.

get-charity-total (charity) → Returns total STX received by a charity (donations + matches).

get-donor-total (donor) → Returns total STX donated by a user.

calculate-match-amount (donation-amount) → Calculates match based on current ratio.

get-donation (donor charity block-num) → Retrieves specific donation history.

Public Functions

Treasury Management (Owner Only):

add-to-treasury (amount) → Fund DAO treasury.

emergency-withdraw (amount) → Withdraw STX in emergencies.

Charity Management (Owner Only):

approve-charity (charity) → Approve a charity.

remove-charity (charity) → Remove charity approval.

Donation & Matching:

donate-with-match (charity amount) → Donate to charity with automatic DAO matching.

Configurable Parameters (Owner Only):

set-matching-ratio (new-ratio) → Adjust donation-to-match ratio.

set-max-match (new-max) → Set maximum STX match per donation.

⚙️ Example Flow

DAO Owner funds treasury with add-to-treasury.

DAO Owner approves a charity with approve-charity.

A donor calls donate-with-match charity amount.

Donation is sent directly to the charity.

DAO treasury matches part/all of the donation based on ratio.

State variables are updated, ensuring full transparency.

Donors and charities can check totals and history anytime via read-only queries.

🔒 Security Considerations

Only the contract owner can:

Fund/withdraw treasury

Approve/remove charities

Change ratio & max match

Matching funds are only released if:

The charity is approved

The treasury has sufficient balance

Emergency withdraw is restricted to the owner.

✅ Use Cases

DAO-governed charity matching campaigns.

Transparent donor impact tracking.

Incentivized philanthropy (donors get amplified effect).

Proof-of-donation for governance or recognition programs.

📌 Future Enhancements

DAO governance for charity approvals (instead of single owner).

NFT donation badges for contributors.

Multi-token support beyond STX.

Scheduled or milestone-based matching pools.