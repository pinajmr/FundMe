from brownie import FundMe
from scripts.helpful_scripts import get_account
from scripts.deploy import deploy_fund_me

def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee() + 100 # Add more
    print(f"The current entry fee is {entrance_fee}")
    print("Funding")
    fund_me.fund({"from":account, "value":entrance_fee})

def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from":account})


def main():
    fund()
    withdraw()