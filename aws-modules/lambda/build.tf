# -------------------------------------------------------------------------
# Copy Lambda function files to a target directory
# -------------------------------------------------------------------------
resource "null_resource" "external_function_copy_files" {
  provisioner "local-exec" {
    command = "rm -rf ${var.source_dir}/target && mkdir -p ${var.source_dir}/target && cp ${var.source_dir}/${lower(var.function_name)}.py ${var.source_dir}/target/ && cp ${var.source_dir}/requirements.txt ${var.source_dir}/target/"
  }

  triggers = {
    #    build_number          = timestamp()
    dependencies_versions = filemd5("${var.source_dir}/requirements.txt")
    source_versions       = filemd5("${var.source_dir}/${lower(var.function_name)}.py")
  }
}

# -------------------------------------------------------------------------
# Install Lambda function dependencies
# -------------------------------------------------------------------------
resource "null_resource" "external_function_install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${var.source_dir}/target/requirements.txt -t ${var.source_dir}/target"
  }

  triggers = {
    #    build_number          = timestamp()
    dependencies_versions = filemd5("${var.source_dir}/requirements.txt")
    source_versions       = filemd5("${var.source_dir}/${lower(var.function_name)}.py")
  }

  depends_on = [null_resource.external_function_copy_files]
}

# -------------------------------------------------------------------------
# Archive the Lambda function (including dependencies)
# -------------------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.source_dir}/target/"
  output_path = "${var.source_dir}/lambda_payload.zip"
  excludes    = ["__pycache__", "venv"]
  depends_on  = [null_resource.external_function_install_dependencies]
}
