App = {
  web3Provider: null,
  contracts: {},

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
    //Projeto Inicia aqui
    App.contracts.Chainclub.deployed()
      .then(function(instance) {
        _instance = instance;
        return instance;
      })
      .then(function(chainclubInstance) {
        var count = chainclubInstance.getPollCount();
        makeUL(count, chainclubInstance);
      });
  }
};

var _instance = null;

window.setMessage = function() {
  console.log(_instance);
  let message = $("#new_message").val();
  _instance.startPoll(2, 2, message, 5, 0);

  _instance
    .send({
      from: window.coinbase
    })
    .then(function(res) {
      console.log(res);
    });
};
function makeUL(count, chainclubInstance) {
  console.log("makeUL");
  // Create the list element:
  var list = document.createElement("ul");
  var fetchPosts = new Promise(function(resolve, rejected) {
    var posts = [];
    for (var i = 0; i < count; i++) {
      var contentsPromise = chainclubInstance.getPollSubject(i).call();
      var votesPromise = chainclubInstance.getPollVotes(i).call();
      var post = Promise.all([votesPromise, contentsPromise, i]).then(function([
        votes,
        content,
        index
      ]) {
        return {
          votes,
          content,
          index
        };
      });
      posts.push(post);
    }
    Promise.all(posts).then(posts => resolve(posts));
  });
  fetchPosts
    .then(posts => {
      return posts.sort(compare);
    })
    .then(function(posts) {
      for (var i = 0; i < count; i++) {
        var item = document.createElement("li");
        item.appendChild(document.createTextNode(posts[i].content));
        (button = document.createElement("input")),
          (br = document.createElement("br"));
        button.type = "button";
        button.value = posts[i].votes;
        button.myParam = posts[i].index;
        button.addEventListener("click", vote, false);
        item.appendChild(button);
        list.appendChild(item);
      }
    });
  return list;
}

function vote(index) {
  window.Chainclub.methods
    .payMessager(index.target.myParam, "test", 1)
    .send({
      from: window.coinbase
    })
    .then(function(res) {
      console.log(index.target.myParam);
      alert("You voted on this poll");
    });
}
function compare(a, b) {
  return b.votes - a.votes;
}
$(function() {
  $(window).load(function() {
    App.init();
  });
});
