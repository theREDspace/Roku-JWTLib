# Roku-JWTLib
BrightScript Library to create, read and validate JSON Web Tokens

#### Functions

###### readJWT

Read a JWT and returns the body
```
  @param jwtData, JWT parts in string
  @param key, Secret key string used to sign the JWT
  @return AssocArray JWT Body
```
**Usage :** 
``` 
  jwtBody = readJWT("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21tYW5kIjoiUGxheWVyIEpvaW5lZCIsImlhdCI6MTUzODU3NTI1Mywib3B0aW9ucyI6eyJuYW1lIjoiVGVzdCJ9fQ.mVwXgC_FEbkgcaB8lIN9vJBwYJt7rtWxaepEBdFuy2M", "This is a key") 
```

###### writeJWT
Write a JWT using Algorithm, Body and key
```
  @param String algorithm, Algorithm to use for signing
  @param AssocArray body, Data to add as JWT body
  @param String key, Secret key string used to sign the JWT
  @return String JWT returned
```
**Usage :**
``` 
  JWTString = writeJWT("SHA256", {"User": "Username", "id": 123}, "Secret Key")
```

###### validateJWT
Validates the Hash or Certificate for the jwt
```
  @param algorithm, Algorithm from the JWT header JSON
  @param jwtHeader, JWT Header in base64 string
  @param jwtBody, JWT Body in base64 string
  @param jwtSig, JWT Signature in base64url string
  @param key, Secret Key string used to sign JWT
  @return Bool if JWT is valid
```
**Usage :**
``` 
  valid = validateJWT("HS256", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", "eyJjb21tYW5kIjoiUGxheWVyIEpvaW5lZCIsImlhdCI6MTUzODU3NTI1Mywib3B0aW9ucyI6eyJuYW1lIjoiVGVzdCJ9fQ", "mVwXgC_FEbkgcaB8lIN9vJBwYJt7rtWxaepEBdFuy2M")
```

###### base64ToBase64Url
Convert base64 to base64url
```
  @param base64, base64 to convert to base64url
  @return Converted base64url
```
**Usage :**
``` 
  base64Url = base64ToBase64Url("mVwXgC_FEbkgcaB8lIN9vJBwYJt7rtWxaepEBdFuy2M")
```

###### base64UrlToBase64
Convert base64url to base64
```
  @param base64url, base64URL to convert to base64
  @return Converted base64
```
**Usage :**
``` 
  base64 = base64ToBase64Url("mVwXgC_FEbkgcaB8lIN9vJBwYJt7rtWxaepEBdFuy2M")
```
