App = {
  web3Provider: null,
  contracts: {},

  init: async function() {

    return await App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }     
    return App.initContract();
  },
  
  initContract : function() {
    $.getJSON("Dao.json", function(dao){
      App.contracts.Dao = TruffleContract(dao);
      App.contracts.Dao.setProvider(App.web3Provider);

      return App.render();

    });
  },

  render : function() {
    //Projeto Inicia aquo
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
