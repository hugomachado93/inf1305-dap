App = {
  web3Provider: null,
  contracts: {},
  account: "0x0",
  init: async function() {
    return await App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== "undefined") {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider(
        "http://localhost:7545"
      );
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Chainclub.json", function(Chainclub) {
      App.contracts.Chainclub = TruffleContract(Chainclub);
      App.contracts.Chainclub.setProvider(App.web3Provider);
      return App.render();
    });
  },

  render: function() {
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });
    //Projeto Inicia aqui
    App.contracts.Chainclub.deployed()
      .then(function(instance) {
        return instance;
      })
      .then(function(chainclubInstance) {
        var count = chainclubInstance.getPollCount();
        console.log(count);
      });
  }
};

window.setMessage = function() {
  let message = $("#new_message").val();
  App.contracts.Chainclub.deployed()
    .then(function(instance) {
      return instance.startPoll(1, 1, message, 1, 1, { from: App.account });
    })
    .then(function(result) {
      console.log("done");
    })
    .catch(function(err) {
      console.log(err);
    });
};
$(function() {
  $(window).load(function() {
    App.init();
  });
});
