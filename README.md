# SOFIE foodchain smart contracts

The following project contains the smart contracts used for the SOFIE foodchain pilot.

## Installation

To install the necessary node packages execute:

```bash
npm install
```

## Compiling the smart contracts

To compile the smart contracts, execute:

```bash
npm run compile
```

## Running the unit tests

To run the smart contract unit test(s), execute:

```bash
npm run test
```

## Running a development blockhain

To run a development blockhain via ``ganache-cli`` and deploy the smart contracts,
in one terminal window, execute:

```bash
npm run dev-blockchain
```

In the other terminal, run:

```bash
npm run deploy-local
```

You should see a summary as output containing information about the deployment.

## Deploying to staging

Staging settings are define in ``truffle-config.js`` file in object ``networks.staging``.

If the node is locked, unlock it and deploy by running:

```bash
ACCOUNT_PASSWORD=<password> npm run deploy-staging
```
where ``<password>`` is the account password of the node

## Deploying via docker image

You can build a docker image to use to deploy the contract. To build
the image run:

```bash
docker build -t fsc-consortium-smart-contracts-deployer .
```

Afterwards, you can use it to deploy contracts and extract the smart
contract addresses. Please see `Dockerfile` for more details.
