const PlanetToken = artifacts.require('PlanetToken')

module.exports = async function (deployer) {
  await deployer.deploy(PlanetToken)
}
