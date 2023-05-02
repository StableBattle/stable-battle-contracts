import deployPopulateEvents from "../scripts/deployPopulateEvents";

deployPopulateEvents().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});