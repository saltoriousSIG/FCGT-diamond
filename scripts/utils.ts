import {
  BaseContract,
  ContractTransactionResponse,
  BytesLike,
  Interface,
  Contract,
} from "ethers";
import { ethers, run as hre } from "hardhat";

export async function getSelectors(
  contract:
    | Contract
    | (BaseContract & {
        deploymentTransaction(): ContractTransactionResponse;
      }),
  contractName: string,
  existingSelectors: Array<BytesLike>
): Promise<BytesLike[]> {
  let abi = "";
  const file = await import(
    `../artifacts/contracts/facets/${contractName}.sol/${contractName}.json`
  );
  abi = file.abi;
  const contract_interface = new Interface(abi);
  const selectors = contract.interface.fragments
    .filter((fragment: any) => fragment.type === "function")
    .map((fragment: any) => {
      console.log(fragment.name, "before check");
      if (fragment.name === "owner" || fragment.name === "transferOwnership") {
        return "";
      }
      console.log(fragment.name, "after check");
      if (contract_interface.getFunction(fragment.name)) {
        return contract_interface.getFunction(fragment.name)
          ?.selector as BytesLike;
      }
      return "";
    })
    .filter((f: any) => f && !existingSelectors.includes(f));
  selectors.map((s: BytesLike) => existingSelectors.push(s));
  return selectors;
}

export async function deployContract(
  contractName: string,
  libraries?: { libraries: Record<string, any> }
) {
  console.log(`Deploying ${contractName}...`);
  const Contract = await ethers.getContractFactory(contractName, libraries);
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  console.log(`${contractName} deployed to:`, await contract.getAddress());
  return {
    contract,
    contractName,
  };
}

export async function verifyContract(
  contractAddress: string,
  constructorArgs: any[] = []
) {
  console.log(`Verifying contract at ${contractAddress}...`);
  try {
    await hre("verify:verify", {
      address: contractAddress,
      constructorArguments: constructorArgs,
    });
    console.log(`✅ Contract verified at ${contractAddress}`);
  } catch (error: any) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log(`✅ Contract already verified at ${contractAddress}`);
    } else {
      console.log(
        `❌ Failed to verify contract at ${contractAddress}:`,
        error.message
      );
    }
  }
}

export const networkConfig: Record<string, any> = {
  base_sepolia: {
    WETH: "0x4200000000000000000000000000000000000006",
    SWAP_ROUTER: "0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4",
    QUOTE_ROUTER: "0xC5290058841028F1614F3A6F0F5816cAd0df5E27",
    TALENT_TOKEN: "0x46CfBf5Be5ca5AB74e060bd66dB9b7bA288E7B07",
    USDC_TOKEN: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  },
  base: {
    WETH: "0x4200000000000000000000000000000000000006",
    SWAP_ROUTER: "0x2626664c2603336E57B271c5C0b26F421741e481",
    QUOTE_ROUTER: "0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a",
    TALENT_TOKEN: "0x46CfBf5Be5ca5AB74e060bd66dB9b7bA288E7B07",
    USDC_TOKEN: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  },
} as const;
