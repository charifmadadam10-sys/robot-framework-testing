*** Settings ***
Library    SeleniumLibrary
Library    Dialogs

*** Variables ***
${URL}         https://www.saucedemo.com/
${USERNAME}    standard_user
${PASSWORD}    secret_sauce

*** Test Cases ***
Login With Valid User
    Open SauceDemo
    Login    ${USERNAME}    ${PASSWORD}
    Verify Login Success
    Pause Execution    Click OK to continue testing

*** Keywords ***
Open SauceDemo
    Open Browser    ${URL}    chrome

Login
    [Arguments]    ${username}    ${password}
    Input Text      id:user-name    ${username}
    Input Password  id:password     ${password}
    Click Button    id:login-button

Verify Login Success
    Page Should Contain    Products
