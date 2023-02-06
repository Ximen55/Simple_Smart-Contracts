//版本狀態
pragma solidity >=0.4.22 <0.6.0;
//主合約
contract FirstBlockChainGame{
    //資產：擁有者 / 發佈人
    address owner;
    //資產：候選人的名稱
    string candidateName_1;
    string candidateName_2;
    //資產：候選人的總投票數
    uint totalVoteCount_1;
    uint totalVoteCount_2;
    //資產：投1號候選人的人對應票數
    mapping (address => uint) VoteTicketsMap_1;
    //資產：投1號候選人的人的列表
    address[] VoteAddressArray_1;
    //資產：投2號候選人的人對應票數
    mapping (address => uint) VoteTicketsMap_2;
    //資產：投2號候選人的人的列表
    address[] VoteAddressArray_2;
    
    //資產：帳號所擁有的票數
    mapping (address => uint) Tickets;
    //資產：帳號是否註冊
    mapping (address => bool) IsRegistered;
    //資產：註冊帳號列表
    address[] registeredMembers;
    
    //建構子，需要輸入投票候選人的名稱
    constructor (string memory _candidate_1, string memory _candidate_2) public {
        //設定擁有者 / 發佈人
        owner = msg.sender;
        //更新候選人名稱到資產當中
        candidateName_1 = _candidate_1;
        candidateName_2 = _candidate_2;
        //初始化票數
        totalVoteCount_1 = 0;
        totalVoteCount_2 = 0;
    }
    //新票數的事件
    event eventNewVoteResult(
        uint VoteCount_1,
        uint VoteCount_2
    );
    //
    event eventNewtickets(
        uint buytickets_1
    );

    //條件：已經註冊的人才能執行
    modifier HadRegistered{
        require(IsRegistered[msg.sender] == true);
        _;
    }
    
    //條件：只有擁有者可以執行
    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function GetOwner() public view returns(address){
        return owner;
    }
    
    //拿取呼叫者的票數
    function GetMyTickets() public HadRegistered view returns(uint){
        return Tickets[msg.sender];
    }
    //拿取呼叫者是否已經註冊
    function GetIsRegistered() public view returns(bool){
        return IsRegistered[msg.sender];
    }
    //拿取候選人的名稱
    function GetCandidatesName() public view returns(string memory,string memory){
        return (candidateName_1, candidateName_2);
    }
    //拿取目前投票數
    function GetVoteResult() public view returns(uint,uint){
        return (totalVoteCount_1,totalVoteCount_2);
    }
    //拿取投票人 (1與2號候選人) 的列表
    function GetVoteList() public view returns(address[] memory, address[] memory){
        return (VoteAddressArray_1, VoteAddressArray_2);
    }
    //註冊功能
    function Register() public {
        //沒註冊過才能執行
        require(IsRegistered[msg.sender] == false);
        //更新註冊資產，將帳號變為已註冊
        IsRegistered[msg.sender] = true;
        //推送帳號到註冊人員名單當中
        registeredMembers.push(msg.sender);
        //給予500張票券
        Tickets[msg.sender] = 500;
    }
    
    //買票&轉帳功能
    function Buytickets(uint _buyNumber) public payable HadRegistered{
        require(Tickets[msg.sender] >= _buyNumber);
        //增加投票人所擁有的票數
        Tickets[msg.sender] += _buyNumber*100;
        //發送新買家擁有票數事件
        emit eventNewtickets(Tickets[msg.sender]);
    }
    //投票功能，需要有註冊過才能執行，需要填入候選人的編號，以要投票的票數。
    function Vote(uint _candidateNumber, uint _voteNumber) public HadRegistered{
        //投的候選人需要為1號或2號，並且擁有票數要大於投票票數。
        require((_candidateNumber==1 || _candidateNumber==2) && (Tickets[msg.sender] >= _voteNumber));
        //投1號候選人
        if(_candidateNumber == 1){
            //檢查是否已經投過候選人，避免推送多次帳號到列表當中。
            if(VoteTicketsMap_1[msg.sender]==0){
                VoteAddressArray_1.push(msg.sender);
            }
            //增加總票數
            totalVoteCount_1 += _voteNumber;
            //記錄誰投了多少票
            VoteTicketsMap_1[msg.sender] += _voteNumber;
        }
        //投2號候選人
        if(_candidateNumber == 2){
            //檢查是否已經投過候選人，避免推送多次帳號到列表當中。
            if(VoteTicketsMap_2[msg.sender]==0){
                VoteAddressArray_2.push(msg.sender);
            }
            //增加總票數
            totalVoteCount_2 += _voteNumber;
             //記錄誰投了多少票
            VoteTicketsMap_2[msg.sender] += _voteNumber;
        }
        //扣除投票人所擁有的票數
        Tickets[msg.sender] -= _voteNumber;
        //發送新票數事件
        emit eventNewVoteResult(totalVoteCount_1,totalVoteCount_2);
    }
    //結束投票：只有 擁有者 / 發佈人 可以結束投票。刪除目前投票資料，並返回勝利者票券。並更新新的候選人名稱。
    function EndVoteAndCreateNewVote(string memory _candidate_1, string memory _candidate_2) public OnlyOwner{
        //總票數
        uint totalVoteCount = totalVoteCount_1 + totalVoteCount_2;
        //檢查誰獲勝
        if(totalVoteCount_1>totalVoteCount_2){
            //使用迴圈，讓每個獲勝的人都返回票券
            for(uint i = 0; i<VoteAddressArray_1.length;i++){
                address targetAddress = VoteAddressArray_1[i];
                //需要注意不要讓數值有小於1的狀態，否則會強制變為0。返回公式計算的票券
                Tickets[targetAddress] += (totalVoteCount*9/10) * VoteTicketsMap_1[targetAddress] / totalVoteCount_1 ;
            }
        }else{
            //使用迴圈，讓每個獲勝的人都返回票券
            for(uint i = 0; i<VoteAddressArray_2.length;i++){
                address targetAddress = VoteAddressArray_2[i];
                 //需要注意不要讓數值有小於1的狀態，否則會強制變為0。返回公式計算的票券
                Tickets[targetAddress] += (totalVoteCount*9/10) * VoteTicketsMap_2[targetAddress] / totalVoteCount_2 ;
            }
        }
        //重置票數
        totalVoteCount_1 = 0;
        totalVoteCount_2 = 0;
        
        //刪除資料，使用迴圈，透過列表將每個對應刪除。
        for(uint i = 0; i<VoteAddressArray_1.length;i++){
            delete VoteTicketsMap_1[VoteAddressArray_1[i]];
        }
        //刪除列表
        delete VoteAddressArray_1;

        //刪除資料，使用迴圈，透過列表將每個對應刪除。
        for(uint i = 0; i<VoteAddressArray_2.length;i++){
            delete VoteTicketsMap_2[VoteAddressArray_2[i]];
        }
        //刪除列表
        delete VoteAddressArray_2;
        
        //更新成新候選人的名稱
        candidateName_1 = _candidate_1;
        candidateName_2 = _candidate_2;
        
        emit eventNewVoteResult(totalVoteCount_1,totalVoteCount_2);
    }        
}