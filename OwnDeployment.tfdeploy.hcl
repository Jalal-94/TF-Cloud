store "varset" "AWS_Creds" {
 name = "AWS Credentials"
 category = "env"

}


deployment "prod" {
    inputs = {
      
    
  users_list = ["bob","alice"]
  region = "us-east-2"
  environment = "prof"
  aws_access_key = store.varset.AWS_Creds.AWS_ACCESS_KEY.AWS_ACCESS_KEY_ID
  aws_secret_key = store.varset.AWS_Creds.AWS_SECRET_ACCESS_KEY

}

#destroy = true
}


deployment "dev" {

    inputs = {
      
    
  
 users_list = ["charlie","cherk"]
 region = "us-east-2"
 environment = "dev"
 aws_access_key = store.varset.AWS_Creds.AWS_ACCESS_KEY_ID
 aws_secret_key = store.varset.AWS_Creds.AWS_SECRET_ACCESS_KEY
}
#destroy = true
}
