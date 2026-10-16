*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}           https://www.saucedemo.com/
${BROWSER}       chrome
${USERNAME}      standard_user
${PASSWORD}      secret_sauce

*** Test Cases ***
Buy One Product Successfully
    Open Browser    ${URL}    ${BROWSER}

    # Login
    Input Text        id:user-name    ${USERNAME}
    Input Password    id:password     ${PASSWORD}
    Click Button      id:login-button

    # Verify login success
    Page Should Contain    Products

    # Add 1 product to cart
    Click Button    id:add-to-cart-sauce-labs-backpack

    # Verify cart badge
    Element Should Contain    class:shopping_cart_badge    1

    # Open cart
    Click Element    class:shopping_cart_link

    # Verify product in cart
    Page Should Contain    Sauce Labs Backpack

    # Checkout
    Click Button    id:checkout

    # Enter customer information
    Input Text    id:first-name    Testname
    Input Text    id:last-name     Testsurname
    Input Text    id:postal-code   90110

    Click Button    id:continue

    # Verify checkout overview
    Page Should Contain    Checkout: Overview
    Page Should Contain    Sauce Labs Backpack

    # Complete order
    Click Button    id:finish

    # Verify order success
    Page Should Contain    Thank you for your order!

    Sleep    5s
    Close Browser

