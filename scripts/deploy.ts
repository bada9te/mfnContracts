import { ethers, upgrades } from "hardhat";


async function main() {
    const [ deployer ] = await ethers.getSigners();
    const mfn = await ethers.getContractFactory("MusicFromNothing");

    const contract = await upgrades.deployProxy(mfn, [deployer.address, "MusicFromNothing", "MFN"], { initializer: 'initialize', kind: 'uups' });

    await contract.waitForDeployment();
    console.log("Deployed to:", await contract.getAddress());
}

main().catch(console.error);