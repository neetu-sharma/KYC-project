# KYC-project

Instructions Phase-3
Step1: Create a new directory to create truffle project using command 
             mkdir mytruffleproject 
Step 2: Go inside the directory using command	
             cd mytruffleproject/
Step 3: Initiate truffle project using command 
             truffle init
After initiating command,  truffle automatically generate folders -contracts, migrations, test and truffle_ config.js file inside mytruffleproject folder.
Step 4: Add kyc.sol and admininterface.sol contract inside contract folder and 2_initial_kyc.js inside migrations folder. 
Step 5: Make changes inside truffle_config.js file as follows-
          Within Development object,  host : “127.0.0.1”, port: 30303 and network_id : “2019”
           create geth object,  host : “127.0.0.1”, port: 30303 and network_id : “2019”
           Add version inside compilers:{ 
                                             Solc: {
                                                  Version: “0.5.9”
Step 6: To compile smart contract, run command
              truffle compile
 In truffle project folder, there are 3 contracts exists. So after compilation a new folder named build is created inside my truffle project folder. This folder has 3 json files- admininterface.json, migrations.json and kyc.json.
Step 7: Them migrate contract on top of blockchain. For this, open a new terminal and go to the ethereumprivatenetwork directory to start the geth environment using command
             geth --datadir ./datadir --networkid 2019 --rpc --rpcport 30303 --allow-insecure-unlock console
Step 8: Then open eth accounts using command 
             eth.account
Step 9: Unlock account using command
            personal.unlockAccount(‘Address of 1st Account’, ‘password of the account’, 0) 
Step 10: Then mine contract using command
           miner.start()
Step 11: Then go to first terminal to connect truffle with geth environment and to get truffle console. Run command
                truffle console --network geth
Step 12: Inside truffle (geth) console , Run command
                Let kyc await kyc.deployed()
Step 13: After executing this, we get the values of smart contract kyc. Then use the command
                 Kyc
Then press tab twice to get the fuctions inside smart contract.
Step 14: Finally run various commands to test kyc contract functionality in the order mentioned below
Kyc.addBank()
Kyc.viewBank()
Kyc.addRequest()
Kyc.addCustomer()
Kyc.viewCustomer()
Kyc.upvoteCustomer()
Kyc.DownvoteCustomer()
Kyc.modifyCustomer()
Kyc.removeCustomer()
Kyc.reportBank()
Kyc.getBankcomplaint()
Kyc.modifyBank()
Kyc.removeBank()







