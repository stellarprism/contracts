const PlanetToken = artifacts.require("PlanetToken");

module.exports = async function (deployer) {
  const token = await PlanetToken.at(PlanetToken.address);

  const owner = await token.owner();

  const solarSystem = [
    "QmVaGHYVXq55n1McZCWTfDjbQaFpiUdw5LeejwLnHVYtSz", // earth
    "QmRWsVfVxrwXn4Bqc9QRDRZTwHKvz4G8n8qJJBbhd7yyEy", // jupiter
    "QmRRXRbsVJQVtWAHm75qDgciDkgtiYsD41MfEQztedHMdi", // mars
    "QmbscytscBwiYVwPCKTs9uZUid9j3yNkcNqtg3dYY5Wug6", // mercury
    "QmbM2HzGHLdtT29q3RfekuX2epsYDjqu3SQbTc1HbMQoKo", // neptun
    "QmWjQnuFMJWn6GhK6yMTWyJDGQZH7nty7oSnHGGqf5TCSm", // saturn
    "Qmf4QVFE5yrDrLveS9LsBu9PxHGBDYzfaRhein4qy61Zp9", // sun
    "QmbjjCwrGxKMrzmwwtdifQn73SQB3fmxBM8zDfXFur94dj", // uranus
    "QmTvFAQH6g6SX1ZwG7vbcvCmLcgd3dYdNH4vi5ruuRWyQL", // venus
  ];

  for (const planet of solarSystem) {
    await token.safeMint(owner, planet);
  }
};
