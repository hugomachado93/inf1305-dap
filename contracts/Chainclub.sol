pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

/*contract DateTimeAPI {
    function isLeapYear(uint16 year) public view returns (bool);
    function getYear(uint timestamp) public view returns (uint16);
    function getMonth(uint timestamp) public view returns (uint8);
    function getDay(uint timestamp) public view returns (uint8);
    function getHour(uint timestamp) public view returns (uint8);
    function getMinute(uint timestamp) public view returns (uint8);
    function getSecond(uint timestamp) public view returns (uint8);
    function getWeekday(uint timestamp) public view returns (uint8);
    function toTimestamp(uint16 year, uint8 month, uint8 day) public view returns (uint timestamp);
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public view returns (uint timestamp);
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public view returns (uint timestamp);
    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public view returns (uint timestamp);
    function currentTimeIsBeforeEndTime(uint currentTime, uint endTime) public pure returns (bool);
}*/

contract Chainclub {
    
    //address deployedDateTimeContractAddress = 0x58d94A58A3D1e0eA5E54C24258c4E1dD55dA0FE8; // The DateTime class/contract address
    //DateTimeAPI dateTime = DateTimeAPI(deployedDateTimeContractAddress); // Creates an interface to the DateTime class

    struct Member {
        uint index;
        string cpf;
        string firstName;
        string lastName;
        address wallet;
        uint8 access; // 0 == membro, 1 == admin
    }
    
    struct Poll {
        uint index;
        uint starterIndex; // 0 se a votação foi criada pela administração
        string subject;
        uint8 accessNeededToVote;
        uint endInVotesCount;
    }
    
    struct Vote {
        address ownerAddress;
        string stringParameter;
        uint numberParameter;
    }
    
    // Enums
    uint8 constant CREATED_BY_ADMIN = 0;
    uint8 constant CREATED_BY_MEMBER = 1;

    // Checks if the poll is not ended by votes count
    modifier isNotEndedByVotes(uint pollIndex) { 
        require(pollVotes[pollIndex].length < polls[pollIndex].endInVotesCount); 
        _; 
    }
    
    // Checks if the member did not vote in this poll
    modifier didNotVote(address memberAddress, uint pollIndex) {
        require(!alreadyVoted(memberAddress, pollIndex));
        _;
    }
    
    // Checks if the poll subject is not empty
    modifier isNotEmpty(string memory pollSubject) { 
        require(!stringsAreEqual(pollSubject, "")); 
        _; 
    }
    
    uint adminsCount; // guarda a quantidade de admins
    Member[] members; // guarda todos membros (incluindo admins)
    Poll[] polls; // guarda todas polls criadas
    mapping (uint => Vote[]) pollVotes; // guarda os votos de uma poll

    /// Create a new chainclub contract with $(administratorsCount) admins and starts polls between the admins to decide important things.
    //"2",[["0","15226939710","Gustavo","Contreiras","0x6247d71202ed3e1547acbd8979ad375a88a5c632","1"],["1","15226939711","Felipe","Gonçalves","0x5632d71202ed3e1547acdb8979ad375a88a5c731","1"]]
    constructor(uint8 administratorsCount, Member[] memory admins) public {
        adminsCount = administratorsCount;

        for (uint i = 0; i < adminsCount; i++) {
            members.push(admins[i]);
        }
        
        startPoll(0, 0, "Decide the maximum number of members of our chainclub.", adminsCount, 1);
        startPoll(1, 0, "Decide the membership price.", adminsCount, 1);
    }
    
    function startPoll (
    uint index, uint starterIndex, string memory pollSubject, uint durationInVotes, uint8 accessNeededToVote) 
    public isNotEmpty(pollSubject) {
        polls.push(Poll(index, starterIndex, pollSubject, accessNeededToVote, durationInVotes));
    }
    
    function voteOnPoll (uint pollIndex, string memory stringParameter, uint numberParameter) 
    public isNotEndedByVotes(pollIndex) didNotVote(msg.sender, pollIndex) {
        pollVotes[pollIndex].push(Vote(msg.sender, stringParameter, numberParameter));
    }
    
    /// Entering the chainclub
    function buyMembership () public {
        
    }
    
    /// Leaving the chainclub
    function sellMembership () public {
        
    }
    
    //////////////// SIMPLE GETTERS ////////////////
    
    function getPoll (uint pollIndex) public view returns (Poll memory) {
        return polls[pollIndex];
    }
    
    // Não funciona e deve ser feito no browser
    /*function getPollVote (uint pollIndex, uint voteIndex) public view returns (Vote memory) {
        Vote[] storage votes = pollVotes[pollIndex];
        Vote storage vote = votes[voteIndex];
        return vote;
    }*/
    
    function getPollVotes (uint pollIndex) public view returns (Vote[] memory) {
        return pollVotes[pollIndex];
    }
    
    function getPolls () public view returns (Poll[] memory) {
        return polls;
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
    
    // Não funciona e deve ser feito no browser
    /*function getMemberVote (address memberAddress, uint pollIndex) public view returns (Vote memory) {
        for (uint i = 0; i < pollVotes[pollIndex].length; i++) {
            if (pollVotes[pollIndex][i].ownerAddress == memberAddress) {
                return pollVotes[pollIndex][i];
            }
        }
        return Vote(msg.sender,"",0);
    }*/
    
    // Não funciona e deve ser feito no browser
    /*function getMemberVote (uint memberIndex, uint pollIndex) public view returns (Vote memory) {
        address memberAddress = getMember(memberIndex).wallet;
        for (uint i = 0; i < pollVotes[pollIndex].length; i++) {
            if (pollVotes[pollIndex][i].ownerAddress == memberAddress) {
                return pollVotes[pollIndex][i];
            }
        }
        return Vote(msg.sender,"",0);
    }*/
    
    function getMembers () public view returns (Member[] memory) {
        return members;
    }
    
    function getAdmins () public view returns (Member[] memory) {
        Member[] memory admins = new Member[](adminsCount);
        for (uint i = 0; i < members.length; i++) {
            if (members[i].access == 1) {
                admins[i] = members[i];
            }
        }
        return admins;
    }
    
    function getAdminsCount () public view returns (uint) {
        return adminsCount;
    }
    
    //////////////// PRIVATE FUNCTIONS ////////////////
    
    function stringsAreEqual (string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
    
    function alreadyVoted (address memberAddress, uint pollIndex) private view returns (bool) {
        for (uint i = 0; i < pollVotes[pollIndex].length; i++) {
            if (memberAddress == pollVotes[pollIndex][i].ownerAddress) {
                return true;
            }
        }
        return false;
    }
}