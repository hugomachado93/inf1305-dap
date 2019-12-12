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

          const num_votes = await chainclubInstance.getQuantityPollVotesCount(count)
          .then(res => {
            return res.c[0]
          });

          const bottom_limit = await chainclubInstance.getQuantityPollBottomLimit(count)
          .then(res => {
            return res.c[0]
          });

          const top_limit = await chainclubInstance.getQuantityPollTopLimit(count)
          .then(res => {
            return res.c[0]
          });

          count++;

          poll = {
            subject: subject,
            num_votes: num_votes,
            type: 'quantity',
            bottom_limit: bottom_limit,
            top_limit: top_limit
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

          const num_votes = await chainclubInstance.getOptionsPollVotesCount(count)
          .then(res => {
            return res.c[0]
          });

          const allOptions = await chainclubInstance.getOptionsPollReturnOptions(count)
          .then(res => {
            return res
          });

          console.log("aqui" + allOptions);

          count++;

          poll = {
            subject: subject,
            num_votes: num_votes,
            type: 'options',
            options: allOptions
          }

          App.polls.push(poll)
        }

        console.log(App.polls)

        for(var i = 0; i < App.polls.length; i++) {
          if(App.polls[i].type == 'boolean') {
            $("#polls-list").append(`<li>${App.polls[i].subject} (${App.polls[i].num_votes} votes)  <form onsubmit="App.voteBoleanPollYes(${i}); return false"> <button type="submit" class="btn btn-primary">Yes</button></form>  <form onsubmit="App.voteBoleanPollNo(${i}); return false"> <button type="submit" class="btn btn-primary">No</button></form></li>`)
            console.log("quantity " + App.polls[i].num_votes)
          }

          else if(App.polls[i].type == 'quantity') {
            
            var nVotes;
            if(App.polls[i].num_votes != "undefined") {
              console.log("aqui " + i)
              nVotes = App.polls[i].num_votes;
            } else {
              nVotes = 0;
            }

            if(i == -1){
              i = 0;
            }

            $("#polls-list").append(`
            <li>${App.polls[i].subject} (${nVotes} votes)
              <form onsubmit="App.voteQuantityPoll(${i}, ${$("#myVal").val()}); return false">
                <div class="range-field">
                  <input type="range" name="myVal" id="myVal" min="${App.polls[i].bottom_limit}" max="${App.polls[i].top_limit}" value="${App.polls[i].bottom_limit}" oninput="this.form.myValInput.value=this.value" />
                  <input type="number" name="myValInput" min="${App.polls[i].bottom_limit}" max="${App.polls[i].top_limit}" value="${App.polls[i].bottom_limit}" oninput="this.form.myVal.value=this.value" />
                  <button type="submit" class="btn btn-primary">confirm</button>
                </div>
              </form>
            </li>`)
            console.log("quantity " + App.polls[i].num_votes);

          }else if(App.polls[i].type == 'options') {
            var optionsArray = App.polls[i].options.split(';')
            $("#polls-list").append(`<li>${App.polls[i].subject} (${App.polls[i].num_votes} votes) </li>`)
            for(var j=0;j<optionsArray.length;j++) {
              $("#polls-list").append(`<li>${optionsArray[j]} <form onsubmit="App.voteOptionsPoll(${i}, ${j}); return false"> <button type="submit" id="option-vote" class="btn btn-primary">Vote</button></form></li>`)
            }
          }
        }

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
    var superiorlimit = $("#superior-limit").val();
    var inferiorlimtit = $("#inferior-limit").val();

    App.contracts.Chainclub.deployed().then(function(instance){
      instance.startQuantityPoll(booleanpoll,inferiorlimtit,superiorlimit, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  optionspoll: function() {
    var optionsPoll = $("#options-poll").val();
    var options = $("#options").val();
    console.log(optionsPoll, options)
    App.contracts.Chainclub.deployed().then(function(instance){
      instance.startOptionsPoll(optionsPoll, options, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  voteBoleanPollYes: function(index) {
    App.contracts.Chainclub.deployed().then(function(instance){
      instance.voteOnBooleanPool(index,true, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  voteBoleanPollNo: function(index) {
    App.contracts.Chainclub.deployed().then(function(instance){
      instance.voteOnBooleanPool(index,false, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  voteQuantityPoll: function(index, quantity) {
    App.contracts.Chainclub.deployed().then(function(instance){
      instance.voteOnQuantityPool(index,quantity, {from: App.account}).then(function(result){
        console.log(result);
      });
    });
  },

  voteOptionsPoll: function(index, option) {
    App.contracts.Chainclub.deployed().then(function(instance){
      instance.voteOnOptionPool(index,option, {from: App.account}).then(function(result){
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
