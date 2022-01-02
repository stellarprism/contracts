const PlanetToken = artifacts.require("PlanetToken");
const Marketplace = artifacts.require("Marketplace");

module.exports = async function (deployer) {
  await deployer.deploy(Marketplace, PlanetToken.address, 5);
};
