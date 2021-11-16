Feature: Creates a new product from one user and another user buys it

    Background:
        * url 'http://localhost:8081'
        * header Content-Type = 'application/json'
        * header Accept = 'application/json'
        * def signUpJson = read('..\\data\\signUp.json')
        * def signInJson = read('..\\data\\signIn.json')

        * def random = function(max){ return Math.floor(Math.random() * max) + 1 }
        * def signUpJson = read('..\\data\\signUp.json')
        * signUpJson.email = 'test-karate' + random(10000) + '@test.com'
        * signUpJson.userName = 'test-karate' + random(10000)

        * def secondSignUpJson = read('..\\data\\signUp.json')
        * secondSignUpJson.email = 'test-karate' + random(10000) + '@test.com'
        * secondSignUpJson.userName = 'test-karate' + random(10000)

        * def signInJson = {email: "", password: ""}
        * signInJson.email = signUpJson.email
        * signInJson.password = signUpJson.password

        * def secondSignInJson = {email: "", password: ""}
        * secondSignInJson.email = secondSignUpJson.email
        * secondSignInJson.password = secondSignUpJson.password

        Given path 'auth/signup'
        And request signUpJson
        When method post
        Then status 201
        And match response.user.name == signUpJson.userName
        And match response.user.email == signUpJson.email
        
        Given path 'auth/signup'
        And request secondSignUpJson
        When method post
        Then status 201
        And match response.user.name == secondSignUpJson.userName
        And match response.user.email == secondSignUpJson.email

        Given path 'auth/signin'
        And request signInJson
        When method post
        Then status 200
        And match response.user.email == signInJson.email
        And match response.token == "#notnull"
        * def token = response.token

        * def productJson = read('../data/product.json')

        * def productUpdateJson = read('../data/productUpdate.json')

    Scenario: Creates a products, logs as another user and buys the product
        
        # adds the product
        Given path 'addproduct'
        And header Authorization = 'Bearer ' + token
        And request productJson
        When method post
        Then status 201
        * print productJson
        * print response
        And match response.product.name == productJson.name
        And match response.product.description == productJson.description
        * def productId = response.product.productId

        # # should not buy the product because an user cannot buy its own product
        Given path 'buy'
        And header Authorization = 'Bearer ' + token
        * def requestBody = {listOfProductIds:[a]}
        * requestBody.listOfProductIds[0] = productId
        And request requestBody
        When method post
        Then status 400
        * print response
        And match response.details == "You're trying to buy your own product."

        # buys the product from the other user
        Given path 'auth/signin'
        And request secondSignInJson
        When method post
        Then status 200
        And match response.user.email == secondSignInJson.email
        And match response.token == "#notnull"
        * def token2 = response.token

        Given path 'buy'
        And header Authorization = 'Bearer ' + token2
        * def requestBody2 = {listOfProductIds:[a]}
        * requestBody2.listOfProductIds[0] = productId
        * print requestBody2
        And request requestBody2
        When method post
        Then status 200
        * print response
        And match response.productsBought[0].product.productId == productId
        
        # should not buy the product because Id is invalid
        Given path 'auth/signin'
        And request secondSignInJson
        When method post
        Then status 200
        And match response.user.email == secondSignInJson.email
        And match response.token == "#notnull"
        * def token2 = response.token

        Given path 'buy'
        And header Authorization = 'Bearer ' + token2
        * def requestBody3 = {listOfProductIds:[a]}
        * requestBody3.listOfProductIds[0] = "007"
        And request requestBody3
        When method post
        Then status 400
        * print response
        
