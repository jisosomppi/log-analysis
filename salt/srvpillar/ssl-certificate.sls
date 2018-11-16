ssl:
  user: root
  group: root
  cert:
    filename: 'public.20160505.crt'
    mode: 444
    contents: |
      -----BEGIN CERTIFICATE-----
      BASE64
      -----END CERTIFICATE-----
  key:
    filename: 'public.20160505.key'
    mode: 400
    contents: |
      -----BEGIN PRIVATE KEY-----
      BASE64
      -----END PRIVATE KEY-----
