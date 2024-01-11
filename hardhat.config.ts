import { NetworkUserConfig, HardhatUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();



const arbitrumSepolia: NetworkUserConfig ={
  url: "https://arb-sepolia.g.alchemy.com/v2/dzO82H1hVgK_Vz6VUEla-yU_krdhRs73",
  chainId: 421614,
  accounts: [process.env.PRIVATE_KEY!],
};



const config: HardhatUserConfig = {
 

  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100,
      },
      viaIR: true,
    },
  },
  networks: {
    arbitrumSepolia,
   
  },

}
export default config;
