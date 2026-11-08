# CampusSkill: On-Chain Learning Milestone Registry

> A decentralized application (dApp) on **Ethereum Sepolia** where students publish personal learning milestones from their own wallets and mark them as completed on-chain.

| | |
|---|---|
| **Course** | MG3012 Blockchain Technology for Business, Assignment 2 (Mini dApp) |
| **Program** | BS Financial Technology, 5th semester (Fall 2026), FAST-NUCES Islamabad |
| **Student** | Maheen (24i-4179) |
| **Network** | Ethereum Sepolia testnet, chain ID `11155111` (`0xaa36a7`) |
| **Contract address** | `0xD7B366017de69acC7AC1003d7Ccd1eCEc791E81d` |
| **Etherscan** | https://sepolia.etherscan.io/address/0xD7B366017de69acC7AC1003d7Ccd1eCEc791E81d |
| **GitHub repository** | https://github.com/i244179/mg3012-campusSkill-dapp |

---

## Table of contents
1. [Introduction](#1-introduction)
2. [Problem statement](#2-problem-statement)
3. [Proposed solution](#3-proposed-solution)
4. [Project objectives](#4-project-objectives)
5. [Key features](#5-key-features)
6. [Technology stack](#6-technology-stack)
7. [Architecture overview](#7-architecture-overview)
8. [Folder structure](#8-folder-structure)
9. [Smart contract explanation](#9-smart-contract-explanation)
10. [The four contract functions](#10-the-four-contract-functions)
11. [Events and access control](#11-events-and-access-control)
12. [Sepolia configuration](#12-sepolia-configuration)
13. [MetaMask setup](#13-metamask-setup)
14. [Deployment instructions (Remix IDE)](#14-deployment-instructions-remix-ide)
15. [Contract address](#15-contract-address)
16. [ABI configuration](#16-abi-configuration)
17. [Frontend setup](#17-frontend-setup)
18. [Application usage](#18-application-usage)
19. [Transaction workflow](#19-transaction-workflow)
20. [Testing methodology](#20-testing-methodology)
21. [Screenshots](#21-screenshots)
22. [Etherscan verification (bonus)](#22-etherscan-verification-bonus)
23. [Known limitations](#23-known-limitations)
24. [Future improvements](#24-future-improvements)
25. [Academic disclaimer](#25-academic-disclaimer)

---

## 1. Introduction
CampusSkill is a small, complete dApp built for MG3012 Assignment 2. It combines a Solidity smart contract deployed to Sepolia with a single-page HTML/CSS/JavaScript frontend that talks to the contract through **MetaMask** and **ethers.js v6**.

A *milestone* is a short, self-reported learning achievement, for example *"Completed Solidity Fundamentals"* or *"Built a Decentralized Application"*. Each milestone is written to the blockchain by the student's wallet and can later be marked as completed by that same wallet.

## 2. Problem statement
Students often track learning progress in notebooks, spreadsheets or private apps. Those records:
- can be edited or back-dated without any trace,
- belong to whoever runs the app or server, not to the student,
- are hard to share as a single, checkable timeline.

## 3. Proposed solution
CampusSkill stores each milestone in a public smart contract:
- the **creator** is the wallet that sent the transaction (`msg.sender`), so ownership is proven by a cryptographic signature;
- the **creation time** and **completion time** come from the block timestamp, so they cannot be back-dated;
- only the creator can mark a milestone as completed, and only once;
- milestones are never deleted, so the timeline is permanent and anyone can read it.

There is **no backend and no database**. The Sepolia blockchain is the only data store, and the browser reads from it directly.

## 4. Project objectives
1. Design and deploy a secure Solidity contract with clear read and write functions.
2. Demonstrate wallet-based identity and access control (creator-only completion).
3. Build a professional, responsive single-page frontend using plain HTML, CSS and JavaScript.
4. Integrate MetaMask and ethers.js v6 for wallet connection, network checks, reads and transactions.
5. Show the full transaction lifecycle (signature → submitted → mined) with Etherscan links.
6. Document setup, deployment and testing so that anyone can reproduce the project.

## 5. Key features
- **MetaMask connection** with wallet address, connection indicator and network indicator in the header.
- **Sepolia detection and one-click network switch** (`wallet_switchEthereumChain`, falling back to `wallet_addEthereumChain`).
- **Read-only mode without a wallet**: milestones load from a public Sepolia RPC even before you connect.
- **Dashboard statistics**: total, completed and pending milestones, all computed from on-chain data.
- **Personal progress ring** showing the connected wallet's completion rate.
- **Create milestone form** with live UTF-8 byte counters and validation that mirrors the contract limits (80 / 280 bytes).
- **Learning timeline** of milestone cards (ID, title, description, creator, creation date, completion date, status) with distinct pending and completed styles.
- **Filters** (All / Mine / Pending / Completed) and **sort order** (newest or oldest first). This is the extra UI feature for the bonus.
- **Transaction panel**: three-step progress, transaction hash, Sepolia Etherscan link, block number, gas used, and a list of this session's transactions.
- **Clear error messages** for: missing MetaMask, rejected requests, insufficient Sepolia ETH, wrong network, unconfigured or wrong contract address, RPC failures, invalid input and every custom contract error.
- **Safe rendering**: blockchain text is inserted with `textContent` only, never `innerHTML`.
- **Accessible**: semantic HTML5, labelled form fields, live regions, visible focus styles, reduced-motion support.

## 6. Technology stack
| Component | Technology |
|---|---|
| Smart contract | Solidity `^0.8.20` (tested with solc 0.8.20) |
| Development environment | Remix IDE |
| Blockchain | Ethereum Sepolia testnet |
| Wallet | MetaMask |
| Frontend | HTML5 (single page) |
| Styling | CSS3 (`style.css`) |
| Frontend programming | Vanilla JavaScript (native ES module) |
| Blockchain library | ethers.js **v6.13.4**, pinned, from `https://cdn.jsdelivr.net/npm/ethers@6.13.4/dist/ethers.min.js` |
| Repository | GitHub |

No React, Node.js server, build tool or database is used.

## 7. Architecture overview
```
┌───────────────────────────── Browser ─────────────────────────────┐
│ index.html + style.css + assets/campus-learning.svg               │
│   <script type="module">                                           │
│     ethers.BrowserProvider(window.ethereum) ──► signer ──► writes │
│     ethers.JsonRpcProvider(public Sepolia RPC) ──────────► reads  │
└───────────────┬───────────────────────────────────┬───────────────┘
                │ EIP-1193 requests                  │ JSON-RPC (read-only)
        ┌───────▼────────┐                   ┌───────▼─────────┐
        │   MetaMask     │  signed tx        │ Sepolia RPC node │
        │ (keys, signing)├──────────────────►│                  │
        └────────────────┘                   └───────┬──────────┘
                                                     │
                                        ┌────────────▼────────────┐
                                        │ CampusSkill contract     │
                                        │ (Ethereum Sepolia)       │
                                        └─────────────────────────┘
```
- **Reads** (`getMilestoneCount`, `getMilestone`) are free `eth_call`s. Before a wallet is connected they go through a public Sepolia RPC (`CONFIG.READ_RPC_URLS`). Once MetaMask is connected to Sepolia they go through MetaMask.
- **Writes** (`createMilestone`, `completeMilestone`) are signed by MetaMask and cost Sepolia test ETH for gas.
- Private keys never leave MetaMask. The page contains no keys, seed phrases or passwords.

## 8. Folder structure
```
CampusSkill/
├── SmartContract.sol          # Solidity smart contract (contract CampusSkill)
├── index.html                 # Single-page frontend + JavaScript module (ethers.js v6)
├── style.css                  # All styling and responsive layout
├── README.md                  # This documentation
├── .gitignore                 # Excludes OS/editor junk, secrets and ZIP files from Git
├── assets/
│   └── campus-learning.svg    # Original illustration used by the <img> element
└── screenshots/
    ├── README.txt             # How to capture the three required screenshots
    ├── 01-wallet-connection.png    # (to be captured)
    ├── 02-milestone-creation.png   # (to be captured)
    └── 03-completed-milestone.png  # (to be captured)
```

## 9. Smart contract explanation
File: `SmartContract.sol`. Contract name: **`CampusSkill`**. No imports, libraries or inheritance.

**Data model**
```solidity
struct Milestone {
    uint256 id;          // sequential ID starting at 1
    string  title;       // 1–80 bytes
    string  description; // 1–280 bytes
    address creator;     // msg.sender at creation
    uint256 createdAt;   // block.timestamp at creation
    bool    completed;   // false until the creator completes it
    uint256 completedAt; // block.timestamp at completion, 0 while pending
}
mapping(uint256 => Milestone) private milestones;
uint256 private milestoneCount;
```
- IDs are sequential: the first milestone is `1`, and valid IDs are `1 … getMilestoneCount()`.
- Storage variables and limit constants are `private` / `internal` on purpose, so the compiler does **not** generate extra public getters. The ABI contains **exactly four functions**.
- Input limits are measured in **bytes** (`bytes(title).length`) because that is how Solidity measures strings. Emoji and non-Latin characters use 2–4 bytes each, and the frontend counter shows bytes for the same reason.

**Validation (custom errors)**

| Error | When |
|---|---|
| `EmptyTitle()` | title is empty |
| `TitleTooLong(length, maxLength)` | title > 80 bytes |
| `EmptyDescription()` | description is empty |
| `DescriptionTooLong(length, maxLength)` | description > 280 bytes |
| `MilestoneNotFound(milestoneId)` | ID is 0 or greater than the count |
| `NotMilestoneCreator(milestoneId, caller)` | someone other than the creator tries to complete |
| `MilestoneAlreadyCompleted(milestoneId)` | completing an already completed milestone |

Custom errors cost less gas than revert strings. ethers.js decodes them, and the frontend shows them as readable messages.

## 10. The four contract functions
| # | Function | Type | Description |
|---|---|---|---|
| 1 | `createMilestone(string title, string description) returns (uint256)` | **Write** | Validates input, assigns the next ID, stores the milestone with `creator = msg.sender` and `createdAt = block.timestamp`, emits `MilestoneCreated`, and returns the new ID. |
| 2 | `completeMilestone(uint256 milestoneId)` | **Write** | Checks that the ID exists, the caller is the creator and the milestone is not already completed. Sets `completed = true` and `completedAt = block.timestamp`, then emits `MilestoneCompleted`. The record is kept, never deleted. |
| 3 | `getMilestone(uint256 milestoneId) view returns (Milestone)` | **Read** | Returns the full struct for a valid ID; reverts with `MilestoneNotFound` otherwise. |
| 4 | `getMilestoneCount() view returns (uint256)` | **Read** | Returns the number of milestones ever created, which is also the highest valid ID. |

## 11. Events and access control
**Events**
```solidity
event MilestoneCreated(uint256 indexed id, address indexed creator, string title, uint256 createdAt);
event MilestoneCompleted(uint256 indexed id, address indexed creator, uint256 completedAt);
```
`id` and `creator` are indexed, so Etherscan and other tools can filter by milestone or by wallet. The frontend reads `MilestoneCreated` from the transaction receipt to find the new milestone's ID and highlight it.

**Access control**
- Anyone with a wallet can create milestones; they become the creator.
- Only `milestone.creator == msg.sender` can call `completeMilestone`, and any other caller is rejected with `NotMilestoneCreator`.
- Completion is one-way and one-time (`MilestoneAlreadyCompleted`).
- There is no admin or owner role, so nobody (including the deployer) can edit or delete other people's milestones.

## 12. Sepolia configuration
| Setting | Value |
|---|---|
| Network name | Sepolia |
| Chain ID (decimal) | `11155111` |
| Chain ID (hex) | `0xaa36a7` |
| Currency | SepoliaETH (test ETH, no real value) |
| Block explorer | https://sepolia.etherscan.io |
| Read-only RPCs used by the app | `https://ethereum-sepolia-rpc.publicnode.com`, then `https://sepolia.drpc.org` |

All of these values are in the `CONFIG` object at the top of the `<script type="module">` in `index.html`.

## 13. MetaMask setup
1. Install MetaMask from https://metamask.io/download/ (Chrome, Brave, Edge or Firefox).
2. Create a wallet, or import one, and store the Secret Recovery Phrase **offline**. Never paste it anywhere.
3. Enable test networks: MetaMask → network selector → toggle **Show test networks** → choose **Sepolia**.
4. Get free Sepolia ETH from a faucet, for example https://cloud.google.com/application/web3/faucet/ethereum/sepolia. About 0.05 SepoliaETH is enough for deployment and dozens of transactions.

## 14. Deployment instructions (Remix IDE)
1. Open **https://remix.ethereum.org**.
2. In the *File Explorer*, create a new file named **`SmartContract.sol`**.
3. Paste the full contents of `SmartContract.sol` from this repository.
4. Open the **Solidity Compiler** tab and select compiler **0.8.20** (any `0.8.20+` works, but 0.8.20 is what was tested).
5. Click **Compile SmartContract.sol**. There should be a green tick with no errors.
6. Open MetaMask and unlock it.
7. Make sure MetaMask is on **Sepolia**.
8. Make sure the account holds some **Sepolia ETH** (see the faucet above).
9. Open the **Deploy & Run Transactions** tab and set *Environment* to **Injected Provider – MetaMask**. Approve the connection in MetaMask, then check that Remix shows `Custom (11155111) network` / Sepolia and your account.
10. In *Contract*, select **`CampusSkill - SmartContract.sol`** and click **Deploy**. The constructor takes no arguments.
11. **Confirm** the transaction in MetaMask.
12. Wait for confirmation. The Remix terminal shows a green tick and the contract appears under *Deployed Contracts*.
13. **Copy the contract address** with the copy icon next to *CAMPUSSKILL AT 0x…*.
14. *(Optional)* Copy the ABI from the *Solidity Compiler* tab → *ABI* button. It is already in `index.html` and identical (see [§16](#16-abi-configuration)).
15. **Update the frontend**: in `index.html` replace
    ```js
    CONTRACT_ADDRESS: "PASTE_YOUR_DEPLOYED_CONTRACT_ADDRESS_HERE",
    ```
    with your address, for example `CONTRACT_ADDRESS: "0xAbC…123",`. Also add it to the table at the top of this README and to [§15](#15-contract-address).
16. **Run the frontend locally** (see [§17](#17-frontend-setup)).
17. **Connect MetaMask** in the app with the *Connect MetaMask* button.
18. **Test the app**: create a milestone, refresh the page, then complete the milestone (see [§20](#20-testing-methodology)).

You can also test quickly inside Remix: expand the deployed contract, call `createMilestone` with two strings, then call `getMilestoneCount` and `getMilestone(1)`.

## 15. Contract address
```
Network:  Ethereum Sepolia (11155111)
Address:  0xD7B366017de69acC7AC1003d7Ccd1eCEc791E81d
Explorer: https://sepolia.etherscan.io/address/0xD7B366017de69acC7AC1003d7Ccd1eCEc791E81d
Compiler: Solidity 0.8.34 (Remix default), EVM version Osaka, deployed with Remix IDE via MetaMask (Injected Provider)
```
The contract source and ABI are identical to the version tested locally with solc 0.8.20. The `pragma solidity ^0.8.20;` line allows any 0.8.x compiler from 0.8.20 upward.

## 16. ABI configuration
- The ABI in `index.html` (`const CONTRACT_ABI = [...]`) is the **exact JSON ABI produced by the Solidity 0.8.20 compiler** for `CampusSkill`. An automated check confirmed that it is byte-for-byte identical to the compiler output.
- It contains 4 functions, 2 events and 7 custom errors. The errors are included so that ethers.js can decode reverts.
- If you change `SmartContract.sol`, you must recompile it in Remix, copy the new ABI (*Compiler → ABI*), replace `CONTRACT_ABI` and redeploy.

## 17. Frontend setup
The frontend is static and needs no installation or build step.

1. Put the **contract address** into `CONFIG.CONTRACT_ADDRESS` in `index.html` (see §14 step 15).
2. Serve the folder over **http://localhost**. MetaMask does not inject into pages opened as `file://`.
   - **Python** (preinstalled on most systems):
     ```bash
     cd CampusSkill
     python -m http.server 8000      # macOS/Linux may need: python3 -m http.server 8000
     ```
     Then open **http://localhost:8000**.
   - **VS Code**: install the *Live Server* extension → right-click `index.html` → *Open with Live Server*.
   - **GitHub Pages** (optional): repository *Settings → Pages → Deploy from branch → main / root*. This gives you a public HTTPS URL that works with MetaMask.
3. An internet connection is required, because ethers.js, the Manrope font and the Sepolia RPC are loaded online.

## 18. Application usage
1. **Open the app.** Existing milestones load from Sepolia straight away, even without a wallet.
2. **Connect MetaMask** with the button at the top right and approve the request. If MetaMask is on another network, the app asks it to switch to Sepolia.
3. Check the header: **Network: Sepolia** (green) and **Wallet: 0x1234…abcd**.
4. **Publish a milestone**: enter a title (≤ 80 bytes) and description (≤ 280 bytes), click **Publish milestone** and confirm in MetaMask.
5. Watch the **Transaction status** card go from *Confirm in MetaMask* to *Submitted to Sepolia* (hash and Etherscan link appear) to *Confirmed on-chain* (block and gas used).
6. The new milestone appears in the **Learning timeline** with a *Pending* chip and a *You* chip.
7. When you have finished it, click **Mark as completed** on your milestone and confirm. The card turns green and shows the completion date.
8. Use the **All / Mine / Pending / Completed** filters and the **Newest/Oldest first** toggle to explore the timeline.
9. Milestones created by other wallets show *"Only the creator can complete this milestone."*

## 19. Transaction workflow
```
User clicks Publish / Mark as completed
  → validate input (title/description byte limits; creator & status pre-check)
  → ensureReadyToWrite(): config valid → MetaMask present → account connected → on Sepolia → bytecode exists
  → signer = await browserProvider.getSigner()
  → tx = await contract.createMilestone(title, description)      // or completeMilestone(id)
        UI: "Submitted", shows tx.hash + https://sepolia.etherscan.io/tx/<hash>
  → receipt = await tx.wait(1)
        receipt.status === 1 ? continue : error
        UI: "Confirmed in block N", gas used
  → parse MilestoneCreated / MilestoneCompleted from receipt logs
  → reload getMilestoneCount() + getMilestone(1..n) and re-render stats/timeline
```
Success is shown **only after** the receipt confirms the transaction was mined with status 1. If anything fails at any step, the panel marks that step as failed and shows the reason.

**Error handling summary**

| Situation | What the user sees |
|---|---|
| MetaMask not installed | Warning banner + *Install MetaMask* button; read-only mode still works |
| Connection / transaction rejected (code 4001) | "Request rejected: nothing was sent to the blockchain" |
| Pending MetaMask request (−32002) | "MetaMask is waiting for you" |
| Wrong network | Banner "Wrong network: <name>" + *Switch to Sepolia*; write buttons disabled |
| Network switch rejected | "Network switch rejected" |
| Not enough SepoliaETH | "Not enough Sepolia ETH" with faucet advice |
| Placeholder / invalid contract address | "Contract address not configured" banner; writes disabled |
| Address has no contract on Sepolia | "No contract at this address" |
| RPC unreachable | "Cannot reach Sepolia" + *Try again* |
| Contract custom error | Decoded message, e.g. "Not your milestone", "Already completed" |
| Invalid form input | Inline field errors; no transaction is sent |
| Account or network changed in MetaMask | UI updates automatically (`accountsChanged`, `chainChanged`) |

## 20. Testing methodology
Testing was split into **automated tests that were actually run** and **manual tests that need your MetaMask wallet on Sepolia**.

### 20.1 Automated tests (run during development)
**Smart contract**: compiled with **solc 0.8.20** (solc-js) with no errors or warnings. 12 behaviour tests were run on a local Ganache EVM configured with chain ID 11155111:
- ABI has exactly the 4 application functions ✔
- initial count is 0 ✔
- `createMilestone` stores every field, returns ID 1 and emits `MilestoneCreated` with correct args ✔
- `getMilestone` returns the full struct, and `createdAt` equals the block timestamp ✔
- IDs are sequential across different wallets and the count is correct ✔
- non-creator completion reverts with `NotMilestoneCreator` and state is unchanged ✔
- creator completion sets `completed`, `completedAt` equals the block timestamp, and the event is emitted ✔
- second completion reverts with `MilestoneAlreadyCompleted` ✔
- IDs 0 and count+1 revert with `MilestoneNotFound` for read and write ✔
- empty title / description revert ✔
- 81-byte title and 281-byte description revert; exactly 80 / 280 bytes are accepted ✔
- failed calls do not change the count ✔

**Frontend (static)**:
- `index.html` passes **html-validate** with no errors ✔
- the module script parses without syntax errors (`node --check`) ✔
- the ABI in `index.html` is identical to the compiler's ABI ✔
- all 39 `getElementById` references exist in the HTML ✔
- the chain ID is `11155111` / `0xaa36a7`, and all explorer links use `sepolia.etherscan.io` ✔
- `innerHTML` is never used ✔

**Frontend end-to-end (simulation)**: 20 Playwright tests in headless Chromium against a local Ganache chain (chain ID 11155111), with a **mock EIP-1193 wallet** standing in for MetaMask:
- page renders, CSS and SVG load, all required HTML elements are present, no JS errors
- placeholder config and missing MetaMask banners appear
- wrong contract address and unreachable RPC show clear errors
- read-only loading works before connecting
- connect shows the address and Sepolia
- validation blocks empty and over-limit input, including multi-byte characters
- create shows the hash, a Sepolia Etherscan link and confirmation; the card renders and stats update
- the milestone persists after a page reload, and `localStorage` is unused
- complete updates status, timestamp, stats and progress ring
- a non-creator gets no complete button, and account switching updates the UI
- a contract revert from the wallet is decoded ("Already completed")
- a rejected transaction shows "Request rejected"
- insufficient funds shows "Not enough Sepolia ETH"
- wrong network shows a banner and the switch works; a rejected switch shows a message
- filters and sort work
- HTML in on-chain text is shown as plain text (no injection)
- disconnect is handled
- no horizontal scroll at 390 px and 768 px

> These simulations check the app's logic but **are not** a substitute for testing with real MetaMask on Sepolia.

### 20.2 Manual integration tests (to do after real deployment)
| # | Test | Expected result | Result |
|---|---|---|---|
| 1 | Open CampusSkill via `http://localhost:8000` | Dashboard loads, no config banner | ☐ |
| 2 | Connect MetaMask | Approval popup, then wallet shown | ☐ |
| 3 | Verify wallet address | Header matches MetaMask account | ☐ |
| 4 | Verify Sepolia | "Network: Sepolia" with green dot | ☐ |
| 5 | Create a milestone | MetaMask confirmation popup | ☐ |
| 6 | Confirm the transaction | Hash + Etherscan link shown | ☐ |
| 7 | Wait for mining | "Confirmed in block …" | ☐ |
| 8 | Milestone appears | Card with title, description, Pending | ☐ |
| 9 | Refresh the browser (F5) | — | ☐ |
| 10 | Milestone persists | Same card loads from chain | ☐ |
| 11 | Complete the milestone | Confirm in MetaMask, then confirmed | ☐ |
| 12 | Updated status | Green "Completed" chip | ☐ |
| 13 | Completion timestamp | Date shown under "Completed" | ☐ |
| 14 | Switch MetaMask to a second account | No complete button on first account's milestone | ☐ |
| 15 | Unauthorized completion rejected | In Remix, call `completeMilestone(id)` from the second account; reverts `NotMilestoneCreator` | ☐ |
| 16 | Switch MetaMask to another network | "Wrong network" banner, switch button works | ☐ |
| 17 | Reject a transaction in MetaMask | "Request rejected", nothing recorded | ☐ |

## 21. Screenshots
Three genuine screenshots from the live Sepolia app go in `screenshots/`. Step-by-step capture instructions are in [`screenshots/README.txt`](screenshots/README.txt).

| File | Shows |
|---|---|
| `screenshots/01-wallet-connection.png` | CampusSkill with a connected wallet, address and Sepolia network |
| `screenshots/02-milestone-creation.png` | A created milestone (title, description) with transaction status and hash |
| `screenshots/03-completed-milestone.png` | The same milestone marked Completed with completion timestamp and confirmation |

**Additional evidence** (genuine screenshots from the same session):

| File | Shows |
|---|---|
| `screenshots/04-remix-connected-to-metamask.png` | Remix *Deploy & Run* using **Browser Extension → MetaMask** with the Sepolia account |
| `screenshots/05-contract-deployed-on-sepolia.png` | The deployed **CampusSkill** contract (`0xD7B3…1E81d`) on **Sepolia** in Remix |
| `screenshots/06-create-metamask-confirm.png` | MetaMask transaction request for `createMilestone` (Sepolia, interacting with the contract) |
| `screenshots/07-create-transaction-confirmed.png` | Create transaction confirmed in block 12092114, milestone #1 shown as Pending |
| `screenshots/08-complete-metamask-confirm.png` | MetaMask transaction request for `completeMilestone(1)` |

![Wallet connection](screenshots/01-wallet-connection.png)
![Milestone creation](screenshots/02-milestone-creation.png)
![Completed milestone](screenshots/03-completed-milestone.png)

### Submission ZIP
After adding the screenshots and the real contract address, create the ZIP from the folder **that contains** `CampusSkill/`:
- **Windows**: right-click the `CampusSkill` folder → *Send to → Compressed (zipped) folder* → rename it to `CampusSkill-Submission.zip`. Delete any older ZIP inside the folder first.
- **PowerShell**: `Compress-Archive -Path .\CampusSkill -DestinationPath .\CampusSkill-Submission.zip -Force`
- **macOS/Linux**: `zip -r CampusSkill-Submission.zip CampusSkill -x "CampusSkill/*.zip" "*.DS_Store"`

## 22. Etherscan verification (bonus)
Verifying publishes the source code on Etherscan, so anyone can read it and call the functions from the *Contract* tab.

**Option A: Remix plugin (easiest)**
1. In Remix → *Plugin Manager* → activate **Contract Verification** (or *Etherscan – Contract Verification*).
2. Choose *Sepolia*, paste the deployed address, select contract `CampusSkill`, and click **Verify**. Some versions ask for a free Etherscan API key from https://etherscan.io/myapikey.

**Option B: Etherscan website**
1. Open `https://sepolia.etherscan.io/address/<CONTRACT_ADDRESS>` → *Contract* tab → **Verify and Publish**.
2. Compiler type: *Solidity (Single file)*. Compiler version: **exactly the one Remix used**, which for this deployment is `v0.8.34+commit.80d5c536`. License: *MIT*.
3. Paste `SmartContract.sol`. Set *Optimization* to **No** (Remix default) and *EVM version* to **osaka**, which is what Remix used.
4. Submit. A green tick on the *Contract* tab confirms verification. Add the verified link to this README.

## 23. Known limitations
- **Internet dependency**: ethers.js is loaded from the pinned jsDelivr CDN (`ethers@6.13.4`), the font from Google Fonts, and read-only data from public Sepolia RPCs. Offline, the app cannot load (the font falls back to system fonts).
- **Public RPC limits**: free endpoints can rate-limit or go down. The app tries a second RPC and also reads through MetaMask once you connect on Sepolia.
- **Reading cost grows with the number of milestones**: each milestone is one `eth_call` (batched 8 at a time). This is fine for a class project, but a large registry would need pagination or an indexer.
- **Self-reported data**: the contract proves *who* recorded a milestone and *when*, not that the learning actually happened.
- **Immutable records**: milestones cannot be edited or deleted, by design. Avoid personal or sensitive information in titles and descriptions because everything is public.
- **Testnet only**: Sepolia ETH has no value, and the testnet may be reset or deprecated in the future.
- Live updates from *other* users appear after **Refresh** or after your own next transaction. There is no automatic polling.

## 24. Future improvements
- Event-based live updates (`contract.on("MilestoneCreated", …)`) and pagination.
- Optional evidence links (e.g. GitHub repo or IPFS hash) per milestone.
- Instructor/mentor **attestations** with a separate role, clearly separated from self-reported entries.
- Categories, tags and per-wallet public profile pages.
- Hardhat/Foundry test suite in CI and a verified deployment script.
- Deploy to a Layer-2 (e.g. Base or Optimism) to reduce gas costs.

## 25. Academic disclaimer
CampusSkill is an **academic project** for MG3012 Blockchain Technology for Business at FAST-NUCES. It is **not** an official, accredited or university-issued certification or records system. Milestones are self-reported by students and are not checked by any institution. It runs on the Sepolia **test network** only. Do not use it with mainnet funds.

---
*Built with Solidity, HTML, CSS, JavaScript and ethers.js v6.*
