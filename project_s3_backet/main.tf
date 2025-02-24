module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "linorg-backet"  
  acl    = "public-read"       

  control_object_ownership = true  
  object_ownership         = "ObjectWriter"  

  versioning = {
    enabled = true  
  }

   block_public_acls = false
   ignore_public_acls = false
}

resource "aws_s3_object" "example" {
  bucket = "linorg-backet"
  key    = "example.txt"
  content = "This is a public file"
  acl    = "public-read"
}



