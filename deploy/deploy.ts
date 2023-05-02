import deployStableBattle from "../scripts/deployStableBattle";

deployStableBattle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});