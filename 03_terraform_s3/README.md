# AWS Avengers

Esse pasta tem como objetivo criar algo um pouco mais avançado no terraform utilizando alguns recursos da aws: \
-> S3 \
-> S3 log \
-> S3 lifecyle \
-> S3 replication \
-> S3 bucket notification \
-> SQS \
-> Lambda com python

## Arquitetura proposta

Abaixo o desenho final de onde queremos chegar com esse projeto fazendo s3 além do basico:

![alt text](https://github.com/guilhermegandolfi/aws_avengers/blob/001_terraform/03_terraform_s3/arquitetura/Imagem.png)


```bash
pip install foobar
```

## Comandos terraform utilizados

```bash
# Sempre que for inicializar um projeto terraform em uma pasta vazia
terraform init

# Utilizado para incluir identação no código
terraform fmt

# Usado para efetuar um check do que esta sendo aplicado e desenvolvido com a infraestrutura atual
terraform plan 

# Utilizado para aplicar o que está sendo desenvolvido
terraform apply

```

## License

[MIT](https://choosealicense.com/licenses/mit/)