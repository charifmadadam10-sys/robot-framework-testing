*** Settings ***
Library          SeleniumLibrary
Library          Dialogs
Test Setup       Open SauceDemo
Test Teardown    Pause Execution    Click OK to continue testing

*** Test Cases ***
Login Success
#Keyword       Locator         Value
    Input Text    id:user-name    standard_user
    Input Password    id:password    secret_sauce
    Click Button    id:login-button
    Page Should Contain   Products

Login Failed
    Input Text    id:user-name    standard_user
    Input Password    id:password    wrong_password
    Click Button    id:login-button
    Page Should Contain    Username and password do not match

*** Keywords ***
Open SauceDemo
    Open Browser    https://www.saucedemo.com/    chrome
