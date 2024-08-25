import { ethers, upgrades, network } from "hardhat";


async function main() {
    console.log("[USDC] Selecting...", network.name);
    let USDCAddress = "0x";
    switch (network.name) {
        case "bsc_test":  USDCAddress = "0x16227D60f7a0e586C66B005219dfc887D13C9531"; break;

        case "bsc":       USDCAddress = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d"; break;
        case "arbitrum":  USDCAddress = "0xaf88d065e77c8cc2239327c5edb3a432268e5831"; break;
        case "avalanche": USDCAddress = "0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"; break;
        case "base":      USDCAddress = "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"; break;
        case "polygon":   USDCAddress = "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359"; break;
        default: break;
    }
    if (USDCAddress === "0x") {
        throw new Error("Unknown network!");
    }
    console.log("[USDC] Selected:", USDCAddress);
    const [ deployer ] = await ethers.getSigners();
    const mfn = await ethers.getContractFactory("MusicFromNothing");
    
    const contract = await upgrades.deployProxy(mfn, [deployer.address, USDCAddress], { initializer: 'initialize', kind: 'uups' });
    await contract.waitForDeployment();
    console.log("[DONE] Deployed to:", await contract.getAddress());
}

main().catch(console.error);
