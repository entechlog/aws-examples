# https://stackoverflow.com/questions/55265203/terraform-delete-all-resources-except-one
# list all resources
terraform state list

# destroy the whole stack except above excluded resource(s)
terraform destroy
