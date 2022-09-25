import hre from "hardhat";

export default async function verify(address : string, args?: any[]) {
  if (!!args) {
    try {
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: args
      });
    } catch (err : any) { 
      if (err.message.includes("Reason: Already Verified")) {
        console.log("Contract is already verified!");
      } else console.log(err);
    }
  } else {
    try {
      await hre.run("verify:verify", {
        address: address
      });
    } catch (err : any) { 
      if (err.message.includes("Reason: Already Verified")) {
        console.log("Contract is already verified!");
      } else console.log(err);
    }
  }
}