var Chainclub = artifacts.require("Chainclub");

module.exports = function(deployer) {
  deployer.deploy(Chainclub, 2, [
    [
      "1",
      "15226939710",
      "Gustavo",
      "Contreiras",
      "0x6247d71202ed3e1547acbd8979ad375a88a5c632",
      "1"
    ],
    [
      "2",
      "15226939711",
      "Felipe",
      "Gonçalves",
      "0x5632d71202ed3e1547acdb8979ad375a88a5c731",
      "1"
    ]
  ]);
  // Additional contracts can be deployed here
};
