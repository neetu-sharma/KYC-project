pragma solidity ^0.5.9;
import './admininterface.sol';

contract KYC is admininterface {
    
	// Customer Details Struct. It defines a custom type to be used to store values for every customer.
	struct CustomerDetail {
		string Usernameofthecustomer ;
		string Customerdata;
		bool kycStatus;
		uint256 Downvotes;
		uint256 Upvotes;
		address Bank;
	}
	// Bank Details Struct. It defines a custom type to be used to store values for every bank.
	struct Bank_Detail {
		string Name;
		address ethAddress;
		uint256 complaintsReported;
		uint256 KYCcount;
		bool isAllowedToVote;
		string regNumber;
	}
		// KYC Request Struct. It defines a custom type to be used to store values for every KYC request.
	struct  KYCRequest {
		string Username;
		address Bankaddress;
		string Customerdata;
	}

	// KYCRequests state variable of the type 'mapping' will be like a hash-map of all KYCRequests collected from each user.
	mapping (string => KYCRequest) public KYCRequests;
	// CustomerDetails state variable of the type 'mapping' will be like a hash-map of CustomerDetails to add customers by bank .
	mapping (string => CustomerDetail) public CustomerDetails;
	// Bank_Details state variable of the type 'mapping' will be like a hash-map of Bank_Details to add banks by admin.
    mapping (address => Bank_Detail) public Bank_Details;
    
	// Define events we wish to emit for varoius functionalities
	event AddBank(address indexed adminkyc, string _Name, address _ethAddress, string _regNumber);
    event ReportBank(address indexed otherbank, address _ethAddress);
    event ModifyBankisallowedtovote(address indexed adminkyc, address _ethAddress);
    event RemoveBank(address indexed adminkyc, address _ethAddress);
    event AddRequest(address indexed banker, string _Username, string _Customerdata);
	event AddCustomer(address indexed banker, string _Usernameofthecustomer, string _Customerdata);
	event UpvoteCustomer(address indexed banker, string _Usernameofthecustomer);
	event DownvoteCustomer(address indexed banker, string _Usernameofthecustomer);
	event ModifyCustomer(address indexed banker, string _Usernameofthecustomer, string _newCustomerdata);
	event RemoveRequest(address indexed banker, string _Username);
    
    //Add Bank function is used by the admin to add a bank to the KYC Contract. 
    function addBank(string calldata _Name, address _ethAddress, string calldata _regNumber) verifyadmin(msg.sender) external returns(bool) {
        Bank_Details[_ethAddress].Name =_Name;
        Bank_Details[_ethAddress].ethAddress = _ethAddress;
        Bank_Details[_ethAddress].regNumber =_regNumber;
        Bank_Details[_ethAddress].complaintsReported = 0; // Initially complaints reported against bank are 0.
        Bank_Details[_ethAddress].isAllowedToVote = true; // By considering bank is genuine initially
        Bank_Details[_ethAddress].KYCcount =0;            // Initial KYC count is 0.
        emit AddBank(msg.sender, Bank_Details[_ethAddress].Name, Bank_Details[_ethAddress].ethAddress, Bank_Details[_ethAddress].regNumber);
		return true;	    
	}
	//View Bank Details function is used to fetch the bank details.
	function ViewBankDetails(address _ethAddress) external view returns(string memory, address, string memory, uint256, uint256, bool) {
        return (Bank_Details[_ethAddress].Name, 
                Bank_Details[_ethAddress].ethAddress,
                Bank_Details[_ethAddress].regNumber, 
                Bank_Details[_ethAddress].complaintsReported,
                Bank_Details[_ethAddress].KYCcount,
                Bank_Details[_ethAddress].isAllowedToVote);
    }
    //Report Bank function is used to report a complaint against any bank in the network.  
	function reportBank(address _ethAddress) external returns(uint) {
        Bank_Details[_ethAddress].complaintsReported +=1; // Against upvoting the incorrect customer data.
		emit ReportBank(msg.sender, Bank_Details[_ethAddress].ethAddress);
		return (Bank_Details[_ethAddress].complaintsReported);
    }
    
    //Get Bank Complaints function is used to fetch bank complaints from the smart contract. 
    function getBankComplaints(address _ethAddress) verifyadmin(msg.sender) external view returns(uint256 complaintsReported) {
        return Bank_Details[_ethAddress].complaintsReported;
    }
    
    //Modify Bank function is used by the admin to change the status of isAllowedToVote of any of the banks at any point in time.
	function modifyBankisallowedtovote(address _ethAddress) verifyadmin(msg.sender) external returns(bool) {
        require(Bank_Details[_ethAddress].complaintsReported > 1, "valid bank not corrupted"); // Assuming 5 banks in KYC process, complaint reportes should not be more than 1 to satisfy 1/3 condition.
        Bank_Details[_ethAddress].isAllowedToVote= false; 
        emit ModifyBankisallowedtovote(msg.sender, Bank_Details[_ethAddress].ethAddress);
        return true;
	}
	
    //Remove Bank function is used by the admin to remove a bank from the KYC Contract. 
	function removeBank(address _ethAddress) verifyadmin(msg.sender) external returns(bool) {
	    delete Bank_Details[_ethAddress];
        emit RemoveBank(msg.sender, Bank_Details[_ethAddress].ethAddress);
		return true;
	}
	
    //Add Request function is used to add the KYC request to the KYCrequests list. 
	function addRequest(string calldata _Username, string calldata _Customerdata) external returns(bool) {
	    require(KYCRequests[_Username].Bankaddress == address(0), "customer is already present in the KYCRequests list");
	//Set values for the KYCRequest struct 
	    KYCRequests[_Username].Username = _Username;
		KYCRequests[_Username].Customerdata = _Customerdata;
        KYCRequests[_Username].Bankaddress = msg.sender;
		emit AddRequest(msg.sender, KYCRequests[_Username].Username, KYCRequests[_Username].Customerdata);
		return true;
	}

    //Add Customer function will add a customer to the customer list. 
	function addCustomer(string calldata _Usernameofthecustomer, string calldata _Customerdata) external returns(bool) {
    	require(CustomerDetails[_Usernameofthecustomer].Bank == address(0), "Customer is already present in the CustomerDetails list");
    // Set values for the CustomerDetails struct
	    CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer = _Usernameofthecustomer;
		CustomerDetails[_Usernameofthecustomer].Customerdata = _Customerdata;
		CustomerDetails[_Usernameofthecustomer].kycStatus = false;  // initially kycStatus is false and after checking condition modify it
		CustomerDetails[_Usernameofthecustomer].Downvotes = 0;      // initial downvotes 
		CustomerDetails[_Usernameofthecustomer].Upvotes = 0;        // initial upvotes
		CustomerDetails[_Usernameofthecustomer].Bank = msg.sender;
        emit AddCustomer(msg.sender, CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer, CustomerDetails[_Usernameofthecustomer].Customerdata);
		return true;
	}

    //Remove Request function will remove the request from the requests list.
    function removeRequest(string calldata _Username) external returns(bool) {
	    require(KYCRequests[_Username].Bankaddress != address(0), "Customer is not present in the database");
		delete KYCRequests[_Username].Username;
		emit RemoveRequest(msg.sender, KYCRequests[_Username].Username);
		return true;
	}

    //View Customer function allows a bank to view the details of a customer.
	function viewCustomer(string calldata _Usernameofthecustomer) external view returns(string memory, string memory, bool, uint256,uint256, address) {
		return (CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer,
		CustomerDetails[_Usernameofthecustomer].Customerdata,
		CustomerDetails[_Usernameofthecustomer].kycStatus,
		CustomerDetails[_Usernameofthecustomer].Downvotes,
		CustomerDetails[_Usernameofthecustomer].Upvotes,
		CustomerDetails[_Usernameofthecustomer].Bank);
	}

    //Upvote Customers function allows a bank to cast an upvote for a customer. 
    function upvoteCustomer(string calldata _Usernameofthecustomer) external returns(uint256) {
	    CustomerDetails[_Usernameofthecustomer].Upvotes+=1;
		emit UpvoteCustomer(msg.sender, CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer);
		return CustomerDetails[_Usernameofthecustomer].Upvotes;
    }
    
    //Downvote Customers function allows a bank to cast a downvote for a customer. 
	function downvoteCustomer(string calldata _Usernameofthecustomer) external returns(uint256) {
	    CustomerDetails[_Usernameofthecustomer].Downvotes+=1;
	    emit DownvoteCustomer(msg.sender, CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer);
		return CustomerDetails[_Usernameofthecustomer].Downvotes;
    }
    
    //Modify Customer function allows a bank to modify a customer's data.
    function modifyCustomer(string calldata _Usernameofthecustomer, string calldata _newCustomerdata) external returns(bool) {
		require(CustomerDetails[_Usernameofthecustomer].Bank != address(0), "Customer is not present in the CustomerDetails list");
		CustomerDetails[_Usernameofthecustomer].Customerdata = _newCustomerdata;
		require((CustomerDetails[_Usernameofthecustomer].Upvotes > CustomerDetails[_Usernameofthecustomer].Downvotes), "Reject Customerdata as no. of downvotes are greater than upvotes");
		require(CustomerDetails[_Usernameofthecustomer].Downvotes < 2, "Reject Customerdata as no. of downvotes are greater than 1/3 of the total no. of banks, which is 5 here");
		CustomerDetails[_Usernameofthecustomer].Upvotes = 0;
		CustomerDetails[_Usernameofthecustomer].Downvotes = 0;
		CustomerDetails[_Usernameofthecustomer].kycStatus = true;
        emit ModifyCustomer(msg.sender, CustomerDetails[_Usernameofthecustomer].Usernameofthecustomer, CustomerDetails[_Usernameofthecustomer].Customerdata);
		return true;
	}

}
 


