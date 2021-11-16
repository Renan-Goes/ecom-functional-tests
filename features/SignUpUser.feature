Feature: Create a new user

    Background:
        * url 'http://localhost:8081'
        * header Content-Type = 'application/json'
        * header Accept = 'application/json'
        * def random = function(max){ return Math.floor(Math.random() * max) + 1 }
        * def signUpJson = read('..\\data\\signUp.json')
        * signUpJson.email = 'test-karate' + random(10000) + '@test.com'
        * signUpJson.userName = 'test-karate' + random(10000)

    Scenario: Creates a new user and return an error if it already exists
        Given path 'auth/signup'
        And request signUpJson
        When method post
        Then status 201
        * print signUpJson
        * print response
        And match response.user.name == signUpJson.userName
        And match response.user.email == signUpJson.email

        Given path 'auth/signup'
        And request signUpJson
        When method post
        Then status 400
        * print signUpJson
        * print response
        And match response.status == 400
        And match response.details == "User already exists."