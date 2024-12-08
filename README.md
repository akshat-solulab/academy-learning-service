# BetChain Learning Service

A decentralized autonomous service that manages betting games comparing token holder counts between Arbitrum and Base networks using [Olas](https://olas.network/) framework and [Open Autonomy](https://github.com/valory-xyz/open-autonomy).

## 🎯 Overview

This agent service facilitates a decentralized betting game where:

- Users can place bets on which chain has more token holders - Arbitrum or Base
- Agent service automatically:
    - Fetches current holder counts from Blockscout APIs 
    - Determines winners based on actual holder numbers
    - Calculates prizes proportional to holder count differences
    - Executes prize payments and bet resolution transactions using Safe multisig

## 🏗️ Architecture

Key Components:
- [`DataPullBehaviour`](packages/valory/skills/learning_abci/behaviours.py) - Data fetching
- [`DecisionMakingBehaviour`](packages/valory/skills/learning_abci/behaviours.py) - Winner determination 
- [`TxPreparationBehaviour`](packages/valory/skills/learning_abci/behaviours.py) - Transaction handling
- [`BetChain`](packages/valory/contracts/betchain/contract.py) - Smart contract interface
- [`LearningAbciApp`](packages/valory/skills/learning_abci/rounds.py) - ABCI state machine

## 📋 Prerequisites

- Python `>=3.10`
- Tendermint `==0.34.19`
- IPFS node `==0.6.0`
- Poetry
- Docker Engine & Docker Compose

## 🚀 Quick Start

```bash
# Clone repository
git clone git@github.com:valory-xyz/academy-learning-agent.git
cd academy-learning-agent

# Setup environment
poetry shell
poetry install
autonomy packages sync --update-packages

# Generate keys
autonomy generate-key ethereum -n 4


## ⚙️ Configuration

1. Setup environment:
```bash
cp sample.env .env
```

2. Configure variables:
```properties
ALL_PARTICIPANTS=["0xB953...74"]
GNOSIS_LEDGER_RPC=https://...
TRANSFER_TARGET_ADDRESS=0x...
SAFE_CONTRACT_ADDRESS=0x...
SAFE_CONTRACT_ADDRESS_SINGLE=0x...
BETCHAIN_CONTRACT_ADDRESS=0x...
```

## 🏃 Running

Single Agent:
```bash
bash run_agent.sh
```

Full Service (4 Agents):
```bash
bash run_service.sh
```

Monitor logs:
```bash
docker logs -f learningservice_abci_0
```

## 📜 License

Apache License 2.0

