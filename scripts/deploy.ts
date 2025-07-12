import { ethers, network } from "hardhat";
import { BytesLike } from "ethers";
import path from "path";
import { writeFileSync } from "fs";
import {
  getSelectors,
  deployContract,
  networkConfig,
  verifyContract,
} from "./utils";

async function main() {
  const existingSelectors: BytesLike[] = [];
  const [deployer] = await ethers.getSigners();
  console.log("Network name: " + network.name);
  console.log(`Network: ${network.name}`);
  console.log("Deploying contracts with account:", deployer.address);

  if (!(network.name in networkConfig)) {
    throw new Error(`Network ${network.name} not supported`);
  }

  const deployParams = {
    talent_token: networkConfig[network.name].TALENT_TOKEN,
    usdc_token: networkConfig[network.name].USDC_TOKEN,
    weth: networkConfig[network.name].WETH,
    swaprouter: networkConfig[network.name].SWAP_ROUTER, // SwapRouter on Base
    quoter: networkConfig[network.name].QUOTE_ROUTER, // Quoter on Base
    usdc_pool_fee: 3000, // 0.3% for USDC pool
    talent_pool_fee: 10000, // 1% for TALENT pool
    max_slippage: 500, // 5% slippage
    token_entry_price: ethers.parseUnits("15", 6), // 15 USDC (6 decimals)
    vote_price: ethers.parseUnits("0.5", 6), // 0.5 USDC (6 decimals)
    vote_reward: ethers.parseUnits("250", 18), // 0.1 USDC (6 decimals)
    winner_percentage: 5000,
    second_percentage: 3000,
    third_percentage: 2000,
    show_percentage: 500,
  };

  console.log(deployParams);
  console.log("\nDeploying libraries...");

  // Deploy main facets
  console.log("\nDeploying main facets...");
  const { contract: abortShowFacet, contractName: abortShowFacetName } =
    await deployContract("AbortShowFacet");
  const { contract: airdropFacet, contractName: airdropFacetName } =
    await deployContract("AirdropFacet");
  const { contract: castVoteFacet, contractName: castVoteFacetName } =
    await deployContract("CastVoteFacet");
  const { contract: dataFacet, contractName: dataFacetName } =
    await deployContract("DataFacet");
  const { contract: finalizeFacet, contractName: finalizeFacetName } =
    await deployContract("FinalizeFacet");
  const {
    contract: removeSubmissionFacet,
    contractName: removeSubmissionFacetName,
  } = await deployContract("RemoveSubmissionFacet");
  const { contract: startShowFacet, contractName: startShowFacetName } =
    await deployContract("StartShowFacet");
  const { contract: submitEntryFacet, contractName: submitEntryFacetName } =
    await deployContract("SubmitEntryFacet");
  const { contract: utilitiesFacet, contractName: utilitiesFacetName } =
    await deployContract("UtilitiesFacet");

  const abortShowFacetAddress = await abortShowFacet.getAddress();
  const airdropFacetAddress = await airdropFacet.getAddress();
  const castVoteFacetAddress = await castVoteFacet.getAddress();
  const dataFacetAddress = await dataFacet.getAddress();
  const finalizeFacetAddress = await finalizeFacet.getAddress();
  const removeSubmissionFacetAddress = await removeSubmissionFacet.getAddress();
  const startShowFacetAddress = await startShowFacet.getAddress();
  const submitEntryFacetAddress = await submitEntryFacet.getAddress();
  const utilitiesFacetAddress = await utilitiesFacet.getAddress();

  // Deploy main factory diamond
  // console.log("\nDeploying IndxrFactoryDiamond...");
  const TalentDiamond = await ethers.getContractFactory("TalentDiamond");
  const talentDiamond = await TalentDiamond.deploy(deployParams);
  await talentDiamond.waitForDeployment();

  const talentDiamondAddress = await talentDiamond.getAddress();
  console.log("TalentDiamond deployed to:", talentDiamondAddress);

  const abortShowFacetSelectors = await getSelectors(
    abortShowFacet,
    abortShowFacetName,
    existingSelectors
  );
  const airdropFacetSelectors = await getSelectors(
    airdropFacet,
    airdropFacetName,
    existingSelectors
  );
  const castVoteSelectors = await getSelectors(
    castVoteFacet,
    castVoteFacetName,
    existingSelectors
  );
  const dataFacetSelectors = await getSelectors(
    dataFacet,
    dataFacetName,
    existingSelectors
  );
  const finalizeFacetSelectors = await getSelectors(
    finalizeFacet,
    finalizeFacetName,
    existingSelectors
  );
  const startShowFacetSelectors = await getSelectors(
    startShowFacet,
    startShowFacetName,
    existingSelectors
  );
  const removeSubmissionFacetSelectors = await getSelectors(
    removeSubmissionFacet,
    removeSubmissionFacetName,
    existingSelectors
  );
  const submitEntryFacetSelectors = await getSelectors(
    submitEntryFacet,
    submitEntryFacetName,
    existingSelectors
  );
  const utilitiesFacetSelectors = await getSelectors(
    utilitiesFacet,
    utilitiesFacetName,
    existingSelectors
  );

  // Prepare diamond cut for main facets
  const mainFacetCuts = [
    {
      target: abortShowFacetAddress,
      action: 0,
      selectors: abortShowFacetSelectors,
    },
    {
      target: airdropFacetAddress,
      action: 0,
      selectors: airdropFacetSelectors,
    },
    {
      target: castVoteFacetAddress,
      action: 0,
      selectors: castVoteSelectors,
    },
    {
      target: dataFacetAddress,
      action: 0,
      selectors: dataFacetSelectors,
    },
    {
      target: finalizeFacetAddress,
      action: 0,
      selectors: finalizeFacetSelectors,
    },
    {
      target: removeSubmissionFacetAddress,
      action: 0,
      selectors: removeSubmissionFacetSelectors,
    },
    {
      target: startShowFacetAddress,
      action: 0,
      selectors: startShowFacetSelectors,
    },
    {
      target: submitEntryFacetAddress,
      action: 0,
      selectors: submitEntryFacetSelectors,
    },
    {
      target: utilitiesFacetAddress,
      action: 0,
      selectors: utilitiesFacetSelectors,
    },
  ];

  //Perform diamond cut for main facets
  console.log("\nPerforming diamond cut for main facets...");

  await verifyContract(abortShowFacetAddress);
  await verifyContract(airdropFacetAddress);
  await verifyContract(castVoteFacetAddress);
  await verifyContract(dataFacetAddress);
  await verifyContract(finalizeFacetAddress);
  await verifyContract(removeSubmissionFacetAddress);
  await verifyContract(startShowFacetAddress);
  await verifyContract(submitEntryFacetAddress);
  await verifyContract(utilitiesFacetAddress);

  // Verify TalentDiamond with constructor arguments
  await verifyContract(talentDiamondAddress, [deployParams]);

  await talentDiamond.diamondCut(mainFacetCuts, ethers.ZeroAddress, "0x");
  const owner = await talentDiamond.owner();
  console.log("Owner: ", owner);

  const diamondInfo = {
    talentDiamond: talentDiamondAddress,
    facets: {
      abortShowFacet: abortShowFacetAddress,
      airdropFacet: airdropFacetAddress,
      castVoteFacet: castVoteFacetAddress,
      dataFacet: dataFacetAddress,
      finalizeFacet: finalizeFacetAddress,
      removeSubmissionFacet: removeSubmissionFacetAddress,
      startShowFacet: startShowFacetAddress,
      submitEntryFacet: submitEntryFacetAddress,
      utilitiesFacet: utilitiesFacetAddress,
    },
  };

  const dirname = path.join(__dirname, "..", "deployedContracts");
  writeFileSync(
    path.join(dirname, `${network.name}-indxr_addresses.json`),
    JSON.stringify(diamondInfo)
  );
  console.log("\nDeployment complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
