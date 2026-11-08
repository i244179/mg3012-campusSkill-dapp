// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title  CampusSkill - On-Chain Learning Milestone Registry
 * @notice Students use their own wallets to publish personal learning
 *         milestones to Ethereum and later mark them as completed.
 *         Every milestone, its creator and its timestamps are stored
 *         permanently on-chain.
 * @dev    MG3012 Blockchain Technology for Business - Assignment 2 (Mini dApp).
 *         Academic project: milestones are self-reported by students and are
 *         NOT certificates issued or verified by any university.
 *
 *         Public application interface (exactly four functions):
 *           1. createMilestone(string title, string description)  -> write
 *           2. completeMilestone(uint256 milestoneId)             -> write
 *           3. getMilestone(uint256 milestoneId)                  -> read
 *           4. getMilestoneCount()                                -> read
 *
 *         State variables and limits are intentionally `private`/`internal`
 *         so that the compiler does not generate extra public getter
 *         functions. The ABI therefore contains exactly these four functions.
 */
contract CampusSkill {
    // ------------------------------------------------------------------
    // Data types
    // ------------------------------------------------------------------

    /// @notice A single learning milestone recorded by a student.
    struct Milestone {
        uint256 id;           // Sequential ID, starting at 1
        string title;         // Short title, e.g. "Completed Solidity Fundamentals"
        string description;   // What was learned or built
        address creator;      // Wallet that created (and owns) the milestone
        uint256 createdAt;    // Block timestamp at creation (Unix seconds)
        bool completed;       // True once the creator marks it as completed
        uint256 completedAt;  // Block timestamp at completion (0 while pending)
    }

    // ------------------------------------------------------------------
    // Input limits (measured in UTF-8 bytes, which is how Solidity sees strings)
    // ------------------------------------------------------------------

    uint256 internal constant MAX_TITLE_LENGTH = 80;
    uint256 internal constant MAX_DESCRIPTION_LENGTH = 280;

    // ------------------------------------------------------------------
    // Storage
    // ------------------------------------------------------------------

    /// @dev Milestone ID => milestone. IDs run from 1 to milestoneCount.
    mapping(uint256 => Milestone) private milestones;

    /// @dev Total number of milestones ever created (also the latest ID).
    uint256 private milestoneCount;

    // ------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------

    /// @notice Emitted when a student publishes a new milestone.
    event MilestoneCreated(
        uint256 indexed id,
        address indexed creator,
        string title,
        uint256 createdAt
    );

    /// @notice Emitted when a creator marks their milestone as completed.
    event MilestoneCompleted(
        uint256 indexed id,
        address indexed creator,
        uint256 completedAt
    );

    // ------------------------------------------------------------------
    // Custom errors (cheaper than revert strings and decoded by ethers.js)
    // ------------------------------------------------------------------

    error EmptyTitle();
    error TitleTooLong(uint256 length, uint256 maxLength);
    error EmptyDescription();
    error DescriptionTooLong(uint256 length, uint256 maxLength);
    error MilestoneNotFound(uint256 milestoneId);
    error NotMilestoneCreator(uint256 milestoneId, address caller);
    error MilestoneAlreadyCompleted(uint256 milestoneId);

    // ------------------------------------------------------------------
    // Modifiers
    // ------------------------------------------------------------------

    /// @dev Rejects IDs outside the range 1..milestoneCount.
    modifier milestoneExists(uint256 milestoneId) {
        if (milestoneId == 0 || milestoneId > milestoneCount) {
            revert MilestoneNotFound(milestoneId);
        }
        _;
    }

    // ------------------------------------------------------------------
    // 1. WRITE - create a milestone
    // ------------------------------------------------------------------

    /**
     * @notice Publish a new learning milestone owned by the caller.
     * @param  title        Milestone title (1-80 bytes).
     * @param  description  Milestone description (1-280 bytes).
     * @return milestoneId  The sequential ID assigned to the new milestone.
     */
    function createMilestone(string memory title, string memory description)
        external
        returns (uint256 milestoneId)
    {
        uint256 titleLength = bytes(title).length;
        uint256 descriptionLength = bytes(description).length;

        if (titleLength == 0) revert EmptyTitle();
        if (titleLength > MAX_TITLE_LENGTH) {
            revert TitleTooLong(titleLength, MAX_TITLE_LENGTH);
        }
        if (descriptionLength == 0) revert EmptyDescription();
        if (descriptionLength > MAX_DESCRIPTION_LENGTH) {
            revert DescriptionTooLong(descriptionLength, MAX_DESCRIPTION_LENGTH);
        }

        milestoneCount += 1;
        milestoneId = milestoneCount;

        milestones[milestoneId] = Milestone({
            id: milestoneId,
            title: title,
            description: description,
            creator: msg.sender,
            createdAt: block.timestamp,
            completed: false,
            completedAt: 0
        });

        emit MilestoneCreated(milestoneId, msg.sender, title, block.timestamp);
    }

    // ------------------------------------------------------------------
    // 2. WRITE - complete a milestone (creator only, once)
    // ------------------------------------------------------------------

    /**
     * @notice Mark one of your own milestones as completed.
     * @dev    Only the original creator may complete a milestone, and only once.
     *         The milestone stays recorded; only its status and completion
     *         timestamp change.
     * @param  milestoneId  ID of the milestone to complete.
     */
    function completeMilestone(uint256 milestoneId)
        external
        milestoneExists(milestoneId)
    {
        Milestone storage milestone = milestones[milestoneId];

        if (milestone.creator != msg.sender) {
            revert NotMilestoneCreator(milestoneId, msg.sender);
        }
        if (milestone.completed) {
            revert MilestoneAlreadyCompleted(milestoneId);
        }

        milestone.completed = true;
        milestone.completedAt = block.timestamp;

        emit MilestoneCompleted(milestoneId, msg.sender, block.timestamp);
    }

    // ------------------------------------------------------------------
    // 3. READ - fetch a single milestone
    // ------------------------------------------------------------------

    /**
     * @notice Return the full record of one milestone.
     * @param  milestoneId  ID of the milestone (1..getMilestoneCount()).
     * @return The Milestone struct (id, title, description, creator,
     *         createdAt, completed, completedAt).
     */
    function getMilestone(uint256 milestoneId)
        external
        view
        milestoneExists(milestoneId)
        returns (Milestone memory)
    {
        return milestones[milestoneId];
    }

    // ------------------------------------------------------------------
    // 4. READ - total number of milestones
    // ------------------------------------------------------------------

    /**
     * @notice Return how many milestones have been created in total.
     * @dev    Because IDs are sequential, valid IDs are 1..count.
     */
    function getMilestoneCount() external view returns (uint256) {
        return milestoneCount;
    }
}
