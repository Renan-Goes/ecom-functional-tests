Feature: Creates new product, updates one of its fields and then deletes it

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
        * def signInJson = {email: "", password: ""}
        * signInJson.email = signUpJson.email
        * signInJson.password = signUpJson.password
        
        Given path 'auth/signup'
        And request signUpJson
        When method post
        Then status 201
        And match response.user.name == signUpJson.userName
        And match response.user.email == signUpJson.email

        Given path 'auth/signin'
        And request signInJson
        When method post
        Then status 200
        And match response.user.email == signInJson.email
        And match response.token == "#notnull"
        * def token = response.token

        * def productJson = read('../data/product.json')

        * def productUpdateJson = read('../data/productUpdate.json')

    Scenario: Creates a new product, updates, updates it and deletes it, return error if invalid
        
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
        
        # should not add the product because price is invalid
        Given path 'addproduct'
        And header Authorization = 'Bearer ' + token
        And request 
        """
            {
                "name": "product",
                "price": 0.0,
                "description": ""
            }
        """
        When method post
        Then status 400
        * print productJson
        * print response

        # update the product's description
        Given path 'updateproduct/' + productId
        And header Authorization = 'Bearer ' + token
        And request productUpdateJson
        When method patch
        Then status 200
        * print productUpdateJson
        * print response
        And match response.product.productId == productId
        And match response.product.description == productUpdateJson.values.description

        # should not update the product because the id is invalid
        Given path 'updateproduct/005'
        And header Authorization = 'Bearer ' + token
        And request productUpdateJson
        When method patch
        Then status 404
        * print productUpdateJson
        * print response

        # should not update because productId cannot be updated
        Given path 'updateproduct/' + productId
        And header Authorization = 'Bearer ' + token
        And request 
        """{
                "values":
                {
                    "productId": "01"
                }
            }
        """
        When method patch
        Then status 401
        * print productUpdateJson
        * print response

        # should delete the product
        Given path 'products/' + productId
        And header Authorization = 'Bearer ' + token
        When method delete
        Then status 200
        * print response
        And match response.details == "Product successfully removed."

        #should not delete the product because the id is invalid
        Given path 'products/006'
        And header Authorization = 'Bearer ' + token
        When method delete
        Then status 404
        * print response
