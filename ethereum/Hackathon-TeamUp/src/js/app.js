App = {
  web3Provider: null,
  contracts: {},
  ideaHashLabel: null,
  ideaCodes: null,
  

  init: function() {
    // Load pets.
    $.getJSON('../ideas.json', function(data) {
      var ideasRow = $('#ideasRow');
      var ideaTemplate = $('#ideaTemplate');
      App.ideaHashLabel = $('#idea-hash');
      //App.ideaHashLabel = commonArea.find('.idea-hash');
      console.log(data.length);
      App.ideaHashLabel.html('<b>change to another</b>');
      
      for (i = 0; i < data.length; i ++) {
        ideaTemplate.find('.panel-title').text(data[i].leader + ' - Table ' + data[i].table);
        ideaTemplate.find('img').attr('src', data[i].picture);
        ideaTemplate.find('.idea-industry').text(data[i].industry);
        ideaTemplate.find('.idea-tagline').text(data[i].tagline);
        ideaTemplate.find('.idea-location').text(data[i].location);
        ideaTemplate.find('.idea-votes').text(data[i].votes);
        ideaTemplate.find('.idea-leader').text(data[i].leader);
        ideaTemplate.find('.idea-designer').text(data[i].designer);
        ideaTemplate.find('.idea-frontenddev').text(data[i].frontenddev);
        ideaTemplate.find('.idea-backenddev').text(data[i].backenddev);
        ideaTemplate.find('.btn-vote').attr('data-id', data[i].id);

        ideasRow.append(ideaTemplate.html());
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
    if(typeof web3 != 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
/*
    //get contract artifact file. (deployed address & ABI)
    $.getJSON('Adoption.json', function(data) {

      //create an instance of contract
      var AdoptionArtifact = data;
      App.contracts.Adoption = TruffleContract(AdoptionArtifact);

      //assoicate web3providr for this contract
      App.contracts.Adoption.setProvider(App.web3Provider);
      return App.markAdopted;      
    });
*/

    //get contract artifact file. (deployed address & ABI)
    $.getJSON('TeamUp.json', function(data) {

      //create an instance of contract
      var TeamUpArctifact = data;
      App.contracts.TeamUp = TruffleContract(TeamUpArctifact);

      //assoicate web3providr for this contract
      App.contracts.TeamUp.setProvider(App.web3Provider);
      //return App.markAdopted;      
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-vote', App.handleVote);
    $(document).on('click', '.btn-post', App.handlePostIdea);
  },

  markAdopted: function(adopters, account) {
    var adoptionInstance;

    //access deployed contract then call getAdopters() in late binding way
    App.contracts.Adoption.deployed().then(function(instance) {
      adoptionInstance = instance;
      //call(), read data from blockchain without spending ether
      return adoptionInstance.getAdopters.call();
      console.log("after getAdopters");
      
    }).then(function(adopters) {
      console.log(adopters.length);

      for (i=0; i<adopters.length; i++) {
        console.log("inside disable"); 
        if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);          
        }
      }
    }).catch(function(err) {
      console.log("error in markAdopted:" + err.Message);
    });
  },

  markPosted: function(ideaCodes, account) {
    var teamupInstance;

    console.log("enter markPosted");
    //access deployed contract then call getIdeas() in late binding way
    App.contracts.TeamUp.deployed().then(function(instance) {
      teamupInstance = instance;
      //call(), read data from blockchain without spending ether
      return teamupInstance.getIdeaCodes.call();
      
    }).then(function(ideaCodes) {
      //$('#idea-hash').text(ideaCodes[ideaCodes.length-1]);
      console.log("hello"+ideaCodes[ideaCodes.length-1]);
      $('#ideaTemplate').find('.panel-title').text("hello"+ideaCodes[ideaCodes.length-1]);

    }).catch(function(err) {
      console.log("error in markPosted:" + err.Message);
    });

    console.log("end of markPosted");
  },

  /*
  handleVote: function(event) {
    console.log("begin vote");

    var teamupInstance;

    //use web3 get user accounts
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
    var account = accounts[0]; //make sure MM shows current account. 

      App.contracts.TeamUp.deployed().then(function(instance) {
        teamupInstance = instance;
        console.log("read to call vote");
        return teamupInstance.hackerToVote("test1", "test2", {from: account});
      
      }).then(function(result) {
        return App.markPosted();
      }).then(function(err) {
        console.log(err.Message);
        console.log("have error in handlePostIdea()")
      });
    }); //end of web3
  },
  */

  handlePostIdea: function(event) {
    console.log("begin post idea");

    var teamupInstance;

    //use web3 get user accounts
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0]; //make sure MM shows current account. 

      App.contracts.TeamUp.deployed().then(function(instance) {
        teamupInstance = instance;
        console.log("read to call post idea");
        return teamupInstance.postIdea("test1", "test2", {from: account});
      
      }).then(function(result) {
        return App.markPosted();
      }).then(function(err) {
        console.log(err.Message);
        console.log("have error in handlePostIdea()")
      });
    }); //end of web3
  },

  handleAdopt: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));
    console.log(petId);

    var adoptionInstance;

    //use web3 get user accounts
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      var account = accounts[0];

      App.contracts.Adoption.deployed().then(function(instance) {
        adoptionInstance = instance;    
        
        //interact function by sending a transaction
        return adoptionInstance.adopt(petId, {from: account});
      }).then(function(result) {
        return App.markAdopted();
      }).catch(function(err) {
        console.log(err.Message);
      });
    });
  },//end of function
}; //end of App =

$(function() {
  $(window).load(function() {
    App.init();
  });
});
