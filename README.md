# ecom-functional-tests
Karate tests for the ecom API.

## How to run
First run the ecom API, you can use the command "docker-compose up" in the root directory of the ecom project, which can be found here: https://github.com/Renan-Goes/ecom/tree/tests

Run the command: "java -jar karate.jar features" from the root of the project directory to run all tests, in order to run a specific test, you only have to add the full path, e.g:
"java -jar karate.jar features/SignUpUser.feature".

## The tests run are:
### Signing up an user successfully
### Failing to sign up an user because the email/username already exists
### Signin up a created user successfully
### Failing to sign in an user because the credentials are incorrect
### Successfully delete a created user
### Fail to delete an user because it does not exist or the token is invalid
### Successfully create a new product
### Fail to add a product because the price is invalid (0.0)
### Successfully update a product
### Fail to update a product because its ID is invalid
### Fail to update the productId of a product because its not allowed
### Successfully deletes a product
### Fails to delete a product because its ID is invalid
### Successfully buying a producted added by another user
### Failing to buy a product because it belong to the user trying to buy it
### Fails to buy a product because its ID is invalid
