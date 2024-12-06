// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BettingContract is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Bet {
        address initiator;
        uint8 choice;
        uint amount;
        bool resolved;
        uint8 result;
    }

    mapping(uint => Bet) public bets;
    Counters.Counter private _betIds;
    address public botAccount;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private _tokenExists;

    event BetCreated(
        uint betId,
        address indexed initiator,
        uint8 choice,
        uint amount
    );
    event BetResolved(uint betId, uint8 result);
    event WinningsDistributed(uint betId, address winner);

    constructor(
        address _botAccount
    ) ERC721("BettingToken", "BET") Ownable(msg.sender) {
        botAccount = _botAccount;
    }

    modifier onlyBot() {
        require(
            msg.sender == botAccount,
            "Only bot account can call this function"
        );
        _;
    }

    function createBet(uint8 choice) external payable {
        require(choice == 0 || choice == 1, "Invalid choice");
        require(msg.value > 0, "Amount must be greater than zero");

        _betIds.increment();
        uint betId = _betIds.current();

        bets[betId] = Bet({
            initiator: msg.sender,
            choice: choice,
            amount: msg.value,
            resolved: false,
            result: 0
        });

        emit BetCreated(betId, msg.sender, choice, msg.value);
    }

    function resolveBet(
        uint _betId,
        uint8 result,
        string memory ipfsHash
    ) external onlyBot {
        require(result == 0 || result == 1, "Invalid result");
        Bet storage bet = bets[_betId];
        require(!bet.resolved, "Bet already resolved");

        bet.resolved = true;
        bet.result = result;

        emit BetResolved(_betId, result);

        if (bet.result == 1) {
            // if won
            distributeWinnings(_betId, ipfsHash);
        }
    }

    function distributeWinnings(uint _betId, string memory ipfsHash) internal {
        Bet storage bet = bets[_betId];
        require(bet.resolved, "Bet not resolved yet");
        require(bytes(ipfsHash).length > 0, "IPFS hash is required");

        address winner = bet.initiator;
        if (winner != address(0)) {
            payable(winner).transfer(bet.amount);
            uint256 tokenId = _mintNFT(winner);
            _setTokenURI(tokenId, ipfsHash);
        }

        emit WinningsDistributed(_betId, winner);
    }

    function _mintNFT(address to) internal returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        _tokenExists[newItemId] = true;
        return newItemId;
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        require(
            _tokenExists[tokenId],
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _tokenExists[tokenId],
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId];
    }

    function getFirstPendingBet() external view onlyBot returns (uint) {
        for (uint i = 1; i <= _betIds.current(); i++) {
            if (!bets[i].resolved) {
                return i;
            }
        }
        return 0;
    }
}
