import { ethers, upgrades } from "hardhat";


async function main() {
    const [ deployer ] = await ethers.getSigners();

    const token = await ethers.getContractFactory("MFNToken");
    const tokenContract = await upgrades.deployProxy(token, [deployer.address, "MFNToken", "MFNT"], { initializer: 'initialize', kind: 'uups' });
    await tokenContract.waitForDeployment();
    console.log("[TOKEN] Deployed to:", await tokenContract.getAddress());

    const mfn = await ethers.getContractFactory("MusicFromNothing");
    const contract = await upgrades.deployProxy(mfn, [deployer.address, await tokenContract.getAddress(), 1000], { initializer: 'initialize', kind: 'uups' });
    await contract.waitForDeployment();
    console.log("[LOGIC] Deployed to:", await contract.getAddress());
}

main().catch(console.error);