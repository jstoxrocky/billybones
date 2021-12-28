import { ethers } from "hardhat";

async function main() {
    const contractAddress = '0x18ADfC01A9f92217d99efe8b441A9f11f50Fb346';
    const billyBones = await ethers.getContractAt('BillyBones', contractAddress)
    const price = ethers.utils.parseEther("0.001");
    await billyBones.mint({ value: price });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
