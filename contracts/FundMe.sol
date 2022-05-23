//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

// Smart contract that lets anyone deposit ETH into the contract
// Only the owner of the contract can withdraw the ETH

// Get the latest ETH/USD price from chainlink price feed
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // safe  math library check uint256 for integer overflows
    using SafeMathChainlink for uint256;

    //mapping to store which address depositeded how much ETH
    mapping(address => uint256) public addressToAmountFunded;
    // array of addresses who deposited
    address[] public funders;
    // address of the owner( who deployed the contract)
    address public owner;

    AggregatorV3Interface public priceFeed;

    constructor(address _priceFee) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFee);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function fund() public payable {
        // 18 digit number to be compared with donated amount
        uint256 minimUSD = 50 * 10**18;
        // is the donated amount less than 50USD?
        require(
            getConversionRate(msg.value) >= minimUSD,
            "You need to spend more ETH!"
        );
        // if not, add to mapping and funders array
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }

    function getPrice() public view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        // ETH/USD rate in 18 Digit
        return uint256(price * 10000000000);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        // return (minimumUSD * precision) / price;
        // We fixed a rounding error found in the video by adding one!
        return ((minimumUSD * precision) / price) + 1;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);

        // iterate through all the mappings and make them 0
        // since all the deposited amount has been withdrawn
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);
    }
}
