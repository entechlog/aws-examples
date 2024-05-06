
resource "null_resource" "copy_files" {
  provisioner "local-exec" {
    command = "rm -rf ${path.module}/uploads/lambda/api2s3/target && mkdir -p ${path.module}/uploads/lambda/api2s3/target && cp ${path.module}/uploads/lambda/api2s3/get_pair_candles.py ${path.module}/uploads/lambda/api2s3/target/ && cp ${path.module}/uploads/lambda/api2s3/requirements.txt ${path.module}/uploads/lambda/api2s3/target/"
  }

  triggers = {
    requirements_file = filemd5("${path.module}/uploads/lambda/api2s3/requirements.txt")
    source_file       = filemd5("${path.module}/uploads/lambda/api2s3/get_pair_candles.py")
  }
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/uploads/lambda/api2s3/target/requirements.txt -t ${path.module}/uploads/lambda/api2s3/target"
  }

  triggers = {
    requirements_file = filemd5("${path.module}/uploads/lambda/api2s3/requirements.txt")
    source_file       = filemd5("${path.module}/uploads/lambda/api2s3/get_pair_candles.py")
  }

  depends_on = [null_resource.copy_files]
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/uploads/lambda/api2s3/target/"
  output_path = "${path.module}/uploads/lambda/api2s3.zip"
  excludes    = ["${path.module}/uploads/lambda/.gitkeep", "__pycache__", "venv"]

  depends_on = [null_resource.install_dependencies]
}

# -------------------------------------------------------------------------
# Resource block for Lambda function
# -------------------------------------------------------------------------
resource "aws_lambda_function" "lambda_function" {
  function_name    = "${local.resource_name_prefix}-get-pair-candles"
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  role        = aws_iam_role.lambda_execution_role.arn
  handler     = "get_pair_candles.lambda_handler"
  runtime     = "python3.9"
  timeout     = 360
  memory_size = 2048

  depends_on = [data.archive_file.lambda_function]
}
