Feature: Deletes an user

    Background:
        * url 'http://localhost:8081'
        * header Content-Type = 'application/json'
        * header Accept = 'application/json'
        * def random = function(max){ return Math.floor(Math.random() * max) + 1 }
        * def signUpJson = read('..\\data\\signUp.json')
        * signUpJson.email = 'test-karate' + random(10000) + '@test.com'
        * signUpJson.userName = 'test-karate' + random(10000)
        * def signInJson = {email: "", password: ""}
        * signInJson.email = signUpJson.email
        * signInJson.password = signUpJson.password
        * def fakeUserJson = { email: test, password: password }

    Scenario: Creates an user and subsequently deletes it
        
        Given path 'auth/signup'
        And request signUpJson
        When method post
        Then status 201
        * print signUpJson
        * print response
        And match response.user.name == signUpJson.userName
        And match response.user.email == signUpJson.email
        * print signInJson

        Given path 'auth/signin'
        And request signInJson
        When method post
        Then status 200
        * print signInJson
        * print response

        And match response.user.email == signInJson.email
        And match response.token == "#notnull"
        * def token = response.token

        Given path 'auth/deleteaccount'
        And header Authorization = 'Bearer ' + token
        When method delete
        Then status 200
        * print response
        And match response.title == "OK"
        And match response.status == 200

        Given path 'auth/deleteaccount'
        When method delete
        Then status 403
        * print response
        And match response.status == 403