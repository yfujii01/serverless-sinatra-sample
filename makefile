help:			# ヘルプ(タスク一覧)
	@echo Usage: make [タスク]
	@echo タスク一覧
	@grep -E '^([a-z0-9_]*):' makefile

create_s3_backet:	# S3バケットを作成する
	aws s3 mb s3://${S3_BUCKET_NAME}

remove_s3_backet:	# S3バケットを削除する
	aws s3 rb s3://${S3_BUCKET_NAME} --force

check_s3_backet:	# S3バケットの存在を確認する
	aws s3 ls s3://${S3_BUCKET_NAME}

deploy:			# デプロイする
	# パッケージのインストール
	bundle install --deployment

	# S3にアップロード
	sam package --template-file template.yaml \
	--output-template-file packaged-template.yaml \
	--s3-bucket ${S3_BUCKET_NAME}

	# 確認
	aws s3 ls s3://${S3_BUCKET_NAME}

	# デプロイ
	sam deploy --template-file packaged-template.yaml \
	--stack-name ${STACK_NAME} \
	--capabilities CAPABILITY_IAM

undeploy:		# デプロイしたものを削除する
	# lambdaなど削除
	aws cloudformation delete-stack \
	--stack-name ${STACK_NAME} \
	--region ${REGION}

ls_endpoint:		# エンドポイント一覧の表示
	aws cloudformation describe-stacks \
		--stack-name ${STACK_NAME} \
		--query 'Stacks[].Outputs'

test:			# テスト実行
	bundle exec rspec

start_local:		# ローカル実行
	# dockerが必要
	sam local start-api
