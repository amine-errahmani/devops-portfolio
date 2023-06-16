netsh winhttp set proxy proxy.infra:3128 'localhost;*.infra;10.*.*.*'
setx HTTP_PROXY http://proxy.infra:3128
setx HTTPS_PROXY http://proxy.infra:3128 