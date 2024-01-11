import { NetworkUserConfig, HardhatUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();



const arbitrumGoerli: NetworkUserConfig ={
  url: "https://arb-goerli.g.alchemy.com/v2/oKxs-03sij-U_N0iOlrSsZFr29-IqbuF",
  chainId: 421613,
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
    arbitrumGoerli,
   
  },

}
export default config;
