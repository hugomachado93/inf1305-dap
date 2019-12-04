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
    constructor(uint8 administratorsCount, Member[] memory admins) public {
        adminsCount = administratorsCount;

        for (uint i = 0; i < adminsCount; i++) {
            members.push(admins[i]);
        }
        
        startPoll(0, 0, "Decide the maximum number of members of our chainclub.", adminsCount, 1);
        startPoll(1, 0, "Decide the membership price.", adminsCount, 1);
    }

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
    
    function startPoll (uint index, uint starterIndex, string memory pollSubject, uint durationInVotes, 
    uint8 accessNeededToVote) public isNotEmpty(pollSubject) 
    {
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
    function getPollSubject(uint index)
        public view returns (string memory) {
        return polls[index].subject;
    }
    
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
    function getPollCount()
        public view returns (uint) {
        return polls.length;
    }
}