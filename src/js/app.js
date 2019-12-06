App = {
  web3Provider: null,
  contracts: {},
  polls: [],
  account: "0x0",

  init: async function() {
    return await App.initWeb3();
  },

  initWeb3: function() {
    console.log(web3)
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

      console.log(App.contracts)
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
        console.log(instance)
        return instance;
      })
      .then(async function(chainclubInstance) {        

        var count = 0
        var end = false
        while(1) {
          const subject = await chainclubInstance.getBooleanPollSubject(count)
          .then(res => {
            return res
          })
          .catch(err => {
            end = true
          });

          if(end) {
            break
          }

          console.log(subject)

          const num_votes = await chainclubInstance.getBooleanPollVotesCount(count)
          .then(res => {
            return res.c[0]
          });

          console.log(num_votes)

          count++;

          poll = {
            subject: subject,
            num_votes: num_votes,
            type: 'boolean'
          }

          App.polls.push(poll)
        }

        count = 0
        end = false
        while(1) {
          const subject = await chainclubInstance.getQuantityPollSubject(count)
          .then(res => {
            return res
          })
          .catch(err => {
            end = true
          });

          if(end) {
            break
          }

          console.log(subject)

          const num_votes = await chainclubInstance.getQuantityPollVotesCount(count)
          .then(res => {
            return res.c[0]
          });

          console.log(num_votes)

          count++;

          poll = {
            subject: subject,
            num_votes: num_votes,
            type: 'quantity'
          }

          App.polls.push(poll)
        }

        count = 0
        end = false
        while(1) {
          const subject = await chainclubInstance.getOptionsPollSubject(count)
          .then(res => {
            return res
          })
          .catch(err => {
            end = true
          });

          if(end) {
            break
          }

          console.log(subject)

          const num_votes = await chainclubInstance.getOptionsPollVotesCount(count)
          .then(res => {
            return res.c[0]
          });

          console.log(num_votes)

          count++;

          poll = {
            subject: subject,
            num_votes: num_votes,
            type: 'options'
          }

          App.polls.push(poll)
        }
        console.log(App.polls)
      });
  },

  booleanpoll: function() {
    var booleanpoll = $("#boolen-poll").val();

    App.contracts.Chainclub.deployed().then(function(instance){
      instance.startBooleanPoll(booleanpoll, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  quantitypoll: function() {
    var booleanpoll = $("#quantity-poll").val();

    App.contracts.Chainclub.deployed().then(function(instance){
      instance.startQuantityPoll(booleanpoll, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  }

};

window.setMessage = function() {
  let message = $("#new_message").val();
  App.contracts.Chainclub.deployed()
    .then(function(instance) {
      return instance.startQuantityPoll( message );
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
