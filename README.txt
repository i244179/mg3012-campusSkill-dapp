CampusSkill - Screenshot Guide (MG3012 Assignment 2)
====================================================

STATUS: All screenshots captured on 8 Nov 2026 from the live app on Ethereum
Sepolia (contract 0xD7B366017de69acC7AC1003d7Ccd1eCEc791E81d).

  01-wallet-connection.png            REQUIRED - wallet connected on Sepolia
  02-milestone-creation.png           REQUIRED - milestone #1 created, tx confirmed
  03-completed-milestone.png          REQUIRED - milestone #1 completed, tx confirmed
  04-remix-connected-to-metamask.png  extra - Remix deploy via MetaMask
  05-contract-deployed-on-sepolia.png extra - deployed CampusSkill contract
  06-create-metamask-confirm.png      extra - MetaMask confirm for createMilestone
  07-create-transaction-confirmed.png extra - create tx confirmed
  08-complete-metamask-confirm.png    extra - MetaMask confirm for completeMilestone

The guide below explains how these were captured.

Required file names (use exactly these names, PNG format):

  01-wallet-connection.png
  02-milestone-creation.png
  03-completed-milestone.png

Before you start
----------------
1. The contract is deployed on Sepolia and CONFIG.CONTRACT_ADDRESS in
   index.html contains the real address.
2. The app is running through a local web server, for example:
       cd CampusSkill
       python -m http.server 8000
   then open http://localhost:8000 in Chrome / Brave / Edge with MetaMask.
   (MetaMask does not inject into file:// pages.)
3. MetaMask is on the Sepolia network and holds some Sepolia test ETH.
4. Use a desktop browser window at least 1280 px wide so the whole
   dashboard (timeline + side panel) is visible.

Screenshot 1 - 01-wallet-connection.png
---------------------------------------
Shows: the CampusSkill interface, a successfully connected wallet,
the wallet address and the Sepolia network.
  - Click "Connect MetaMask" and approve the connection in MetaMask.
  - Wait until the header shows "Network: Sepolia" (green dot) and
    "Wallet: 0x....." and the button reads "Connected".
  - Optional but recommended: open the MetaMask popup so it is visible
    next to the page, showing the same account on Sepolia.
  - Capture the full browser window.

Screenshot 2 - 02-milestone-creation.png
----------------------------------------
Shows: a created milestone with its title and description, its
transaction status and the transaction hash / confirmation.
  - Fill in "Milestone title" and "Description"
    (example: "Completed Solidity Fundamentals").
  - Click "Publish milestone" and confirm in MetaMask.
  - Wait until the Transaction status card shows
    "Create milestone: confirmed in block ..." with all three steps ticked
    and the transaction hash + "View on Sepolia Etherscan" link.
  - Make sure the new milestone card (Pending, with "You" chip) is visible
    in the Learning timeline in the same screenshot.

Screenshot 3 - 03-completed-milestone.png
-----------------------------------------
Shows: the SAME milestone with Completed status, its completion
timestamp and the transaction confirmation.
  - On the milestone from Screenshot 2, click "Mark as completed" and
    confirm in MetaMask.
  - Wait for "Complete #N: confirmed in block ..." in the Transaction
    status card.
  - The milestone card must show the green "Completed" chip and a date
    under "Completed".
  - Capture the card and the Transaction status panel together.

Optional extra evidence (recommended)
-------------------------------------
The assignment text also mentions screenshots of contract deployment.
If you want to include it, add a fourth image such as
  04-remix-deployment.png
showing Remix "Deployed Contracts" with CampusSkill, or the contract
page on https://sepolia.etherscan.io.

How to capture
--------------
Windows:  Win + Shift + S  (Snipping Tool), then save as PNG.
macOS:    Cmd + Shift + 4  (or Cmd + Shift + 5 for a window).
Hide or blur nothing that the marker needs to see (address, hash, network).
Never show your MetaMask Secret Recovery Phrase or private key.

After adding the three images, delete this README.txt only if your
instructor wants the folder to contain images only (keeping it is harmless),
then regenerate the ZIP as described in the main README.md
(section "Screenshots" / "Submission ZIP").
