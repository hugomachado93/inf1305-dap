pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract Chainclub {
    
    struct Member {
        address payable wallet;
        string name;
        bool paidLastMonth;
        bool isSellingMembership;
    }
    
    struct BooleanPoll {    
        uint pollIndex;
        string subject;     // Ex: Vamos investir em algo para o clube?
    }
    
    struct OptionsPoll {    
        uint pollIndex; 
        string subject;     // Ex: No que vamos investir?
        string[] options;   // "Piscina de ondas", "Pista de corrida", "Torre de bung jump"
    }
    
    struct QuantityPoll {
        uint pollIndex;
        string subject;     // Ex: Quantos reais gastaremos no nosso novo investimento?
        uint bottomLimit;
        uint topLimit;
    }
    
    struct BooleanVote {
        address owner;
        bool yesOrNo;
    }
    
    struct OptionVote {
        address owner;
        uint optionIndex;
    }

    struct QuantityVote {
        address owner;
        uint quantity;      
    }
    
    modifier didNotVoteOnBooleanPoll(address memberAddress, uint pollIndex) {
        require(!alreadyVotedOnBooleanPoll(memberAddress, pollIndex)); _;
    }
    
    modifier didNotVoteOnQuantityPoll(address memberAddress, uint pollIndex) {
        require(!alreadyVotedOnQuantityPoll(memberAddress, pollIndex)); _;
    }
    
    modifier didNotVoteOnOptionsPoll(address memberAddress, uint pollIndex) {
        require(!alreadyVotedOnOptionsPoll(memberAddress, pollIndex)); _;
    }
    
    modifier isNotEmpty(string memory pollSubject) { 
        require(!stringsAreEqual(pollSubject, "")); _; 
    }
    
    modifier moneyIsEnough(uint value) { 
        require(value >= MEMBERSHIP_PRICE_IN_WEI); _; 
    }
    
    modifier isMember(address addr) {
        bool boolean = false; 
        for (uint i = 0; i < members.length; i++) {
            if (members[i].wallet == msg.sender) {
                boolean = true;
            }
        }
        require(boolean); _;
    }
    
    modifier isOnLimit(uint pollIndex, uint quantity) {
        require (quantityPolls[pollIndex].bottomLimit <= quantity && quantityPolls[pollIndex].topLimit >= quantity); _;
    }
    
    // Enums
    uint16 constant MAX_MEMBERS = 1000;
    uint constant MEMBERSHIP_PRICE_IN_WEI = 1000000000;
    
    address payable contractOwner;
    
    Member[] members; // guarda todos membros 
    QuantityPoll[] quantityPolls;   // guarda todas enquetes de quantidade
    OptionsPoll[] optionsPolls;     // guarda todas enquetes de opções
    BooleanPoll[] booleanPolls;     // guarda todas enquetes de sim / nao
    mapping (uint => QuantityVote[]) quantityPollsVotes;    // dá o índice da enquete e recebe um array de votos
    mapping (uint => OptionVote[]) optionsPollsVotes;       // dá o índice da enquete e recebe um array de votos
    mapping (uint => BooleanVote[]) booleanPollsVotes;      // dá o índice da enquete e recebe um array de votos

    constructor(string memory yourFullName) public {
        contractOwner = msg.sender;
        members.push(
            Member(
                msg.sender, yourFullName, true, false
            )
        );
    }
    
    function startBooleanPoll (string memory pollSubject) 
    public isNotEmpty(pollSubject) {
        booleanPolls.push(
            BooleanPoll(
                booleanPolls.length, pollSubject
            )
        );
    }
    
    function startQuantityPoll (string memory pollSubject, uint bottomLimit, uint topLimit) 
    public isNotEmpty(pollSubject) {
        quantityPolls.push(
            QuantityPoll(
                quantityPolls.length, pollSubject, bottomLimit, topLimit
            )
        );
    }
    
    function startOptionsPoll (string memory pollSubject, string[] memory options) 
    public isNotEmpty(pollSubject) {
        optionsPolls.push(
            OptionsPoll(
                optionsPolls.length, pollSubject, options
            )
        );
    }
    
    function voteOnBooleanPool(uint pollIndex, bool boolean) 
    public isMember(msg.sender) didNotVoteOnBooleanPoll(msg.sender, pollIndex) {
        booleanPollsVotes[pollIndex].push(
            BooleanVote(
                msg.sender, boolean
            )
        );
    }
    
    function voteOnQuantityPool(uint pollIndex, uint quantity) 
    public isMember(msg.sender) isOnLimit(pollIndex, quantity) didNotVoteOnQuantityPoll(msg.sender, pollIndex) {
        quantityPollsVotes[pollIndex].push(
            QuantityVote(
                msg.sender, quantity
            )
        );
    }
    
    function voteOnOptionPool(uint pollIndex, uint option) 
    public isMember(msg.sender) didNotVoteOnOptionsPoll(msg.sender, pollIndex) {
        optionsPollsVotes[pollIndex].push(
            OptionVote(
                msg.sender, option
            )
        );
    }
    
    function buyMembership(string memory buyerName) payable 
    public moneyIsEnough(msg.value) {
        
        // Dinheiro vai pro fundador
        if (members.length < MAX_MEMBERS) {
            contractOwner.transfer(msg.value);
        }
        
        // Procura membro que esteja vendendo
        else { 
            for (uint i = 0; i < members.length; i++) {
                
                if (members[i].isSellingMembership && members[i].wallet != msg.sender) {
                    members[i] = Member(
                        msg.sender, buyerName, true, false
                    );
                    
                    // Dinheiro vai pro membro que ta vendendo
                    members[i].wallet.transfer(msg.value);
                }
            }
        }
    }
    
    function sellMembership () public {
        for (uint i = 0; i < members.length; i++) {
            if (members[i].wallet == msg.sender) {
                members[i].isSellingMembership = true;
            }
        }
        
    }
    
    //////////////// SIMPLE GETTERS ////////////////

    function getQuantityPollBottomLimit (uint pollIndex) public view returns (uint) {
        return quantityPolls[pollIndex].bottomLimit;
    }

    function getQuantityPollTopLimit (uint pollIndex) public view returns (uint) {
        return quantityPolls[pollIndex].topLimit;
    }
    
    function getBooleanPoll (uint pollIndex) public view returns (BooleanPoll memory) {
        return booleanPolls[pollIndex];
    }
    
    function getQuantityPoll (uint pollIndex) public view returns (QuantityPoll memory) {
        return quantityPolls[pollIndex];
    }
    
    function getOptionsPoll (uint pollIndex) public view returns (OptionsPoll memory) {
        return optionsPolls[pollIndex];
    }
    
    function getBooleanPollVotes (uint pollIndex) public view returns (BooleanVote[] memory) {
        return booleanPollsVotes[pollIndex];
    }
    
    function getQuantityPollVotes (uint pollIndex) public view returns (QuantityVote[] memory) {
        return quantityPollsVotes[pollIndex];
    }
    
    function getOptionsPollVotes (uint pollIndex) public view returns (OptionVote[] memory) {
        return optionsPollsVotes[pollIndex];
    }
    
    function getMember (uint memberIndex) public view returns (Member memory) {
        return members[memberIndex];
    }
    
    function getMember (address memberAddress) public view returns (Member memory) {
        for (uint i = 0; i < members.length; i++) {
            if (members[i].wallet == memberAddress) {
                return members[i];
            }
        }
    }
    
    function getMembers () public view returns (Member[] memory) {
        return members;
    }
    
    function getMembershipPrice() public pure returns (uint) {
        return MEMBERSHIP_PRICE_IN_WEI;
    }
    
    ///// FUNCOES QUE BUGAM NO REMIX IDE SEM ENABLE OPTIMIZATION //////
    
    function getBooleanPollSubject (uint pollIndex) public view returns (string memory) {
        return booleanPolls[pollIndex].subject;
    }
    
    function getQuantityPollSubject (uint pollIndex) public view returns (string memory) {
        return quantityPolls[pollIndex].subject;
    }
    
    function getOptionsPollSubject (uint pollIndex) public view returns (string memory) {
        return optionsPolls[pollIndex].subject;
    }
    
    function getBooleanPollVotesCount (uint pollIndex) public view returns (uint) {
        return booleanPollsVotes[pollIndex].length;
    }
    
    function getQuantityPollVotesCount (uint pollIndex) public view returns (uint) {
        return quantityPollsVotes[pollIndex].length;
    }
    
    function getOptionsPollVotesCount (uint pollIndex) public view returns (uint) {
        return optionsPollsVotes[pollIndex].length;
    }
    
    //////////////// PRIVATE FUNCTIONS ////////////////
    
    function stringsAreEqual (string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
    
    function alreadyVotedOnBooleanPoll (address memberAddress, uint pollIndex) private view returns (bool) {
        for (uint i = 0; i < booleanPollsVotes[pollIndex].length; i++) {
            if (memberAddress == booleanPollsVotes[pollIndex][i].owner) {
                return true;
            }
        }
        return false;
    }
    
    function alreadyVotedOnQuantityPoll (address memberAddress, uint pollIndex) private view returns (bool) {
        for (uint i = 0; i < quantityPollsVotes[pollIndex].length; i++) {
            if (memberAddress == quantityPollsVotes[pollIndex][i].owner) {
                return true;
            }
        }
        return false;
    }
    
    function alreadyVotedOnOptionsPoll (address memberAddress, uint pollIndex) private view returns (bool) {
        for (uint i = 0; i < optionsPollsVotes[pollIndex].length; i++) {
            if (memberAddress == optionsPollsVotes[pollIndex][i].owner) {
                return true;
            }
        }
        return false;
    }
}