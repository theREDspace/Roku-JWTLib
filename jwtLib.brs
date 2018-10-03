' readJWT
' Read a JWT and returns the body
' 
' @param jwtData, JWT parts in string
' @param key, Secret key string used to sign the JWT
' @return AssocArray JWT Body
function readJWT(jwtData, key)
  jwtDataSplit = jwtData.split(".")
  
  if jwtDataSplit.count() < 3 then
    ?"Invalid JWT, Missing section"
    return Invalid
  end if
  
  jwtHeader = CreateObject("roByteArray")
  jwtHeader.FromBase64String(base64UrlToBase64(jwtDataSplit[0]))
  header = parseJSON(jwtHeader.ToAsciiString())
  if header = Invalid then
    ?"Header is Invalid JSON"
    return Invalid
  end if
  
  jwtBody = CreateObject("roByteArray")
  jwtBody.FromBase64String(base64UrlToBase64(jwtDataSplit[1]))
  body = parseJSON(jwtBody.ToAsciiString())
  ?body
  if body = Invalid then
    ?"Body is Invalid JSON"
    return Invalid
  end if
  
  if validateJWT(header.alg, jwtDataSplit[0], jwtDataSplit[1], base64UrlToBase64(jwtDataSplit[2]), key) = true then
    ?"Valid JWT"; body
    
    if body.exp <> Invalid then 'Validate expiry if it exists
      expires = createObject("roDateTime")
      expires.fromSeconds(body.exp)
      ? expires; createObject("roDateTime")
      if expires.AsSeconds() < createObject("roDateTime").AsSeconds() then
        ?"Token Expired"
        return Invalid
      else 'Valid Token
        return body
      end if
    else
      return body
    end if    
  else
    ?"Invalid JWT"
    return Invalid
  end if
end function

' writeJWT
' Write a JWT using Algorithm, Body and key
' 
' @param String algorithm, Algorithm to use for signing
' @param AssocArray body, Data to add as JWT body
' @param String key, Secret key string used to sign the JWT
' @return String JWT returned
function writeJWT(algorithm, body, key)
  if algorithm = "SHA256" then
    digest = "HS256"
  else if algorithm = "SHA384" then
    digest = "HS384"
  else if algorithm = "SHA512" then
    digest = "HS512"
  else
    ?"Unknown Algorithm"; algorithm
    return false
  end if
  
  hmac = CreateObject("roHMAC")
  
  header = FormatJSON({
    "alg": digest,
    "typ": "JWT"
  })
  
  jwtHeader = CreateObject("roByteArray")
  jwtHeader.FromAsciiString(header)
  jwtBody = CreateObject("roByteArray")
  jwtBody.FromAsciiString(FormatJSON(body))
  
  jwtHeaderUrl = base64ToBase64Url(jwtHeader.ToBase64String())
  jwtBodyUrl = base64ToBase64Url(jwtBody.ToBase64String())
  
  signature_key = CreateObject("roByteArray")
  signature_key.fromAsciiString(key)
  
  message = CreateObject("roByteArray")
  message.fromAsciiString(jwtHeaderUrl + "." + jwtBodyUrl)
  
  if hmac.setup(algorithm, signature_key) = 0 then
    result = hmac.process(message)
    resultUrl = base64ToBase64Url(result.ToBase64String())
    
    return jwtHeaderUrl + "." + jwtBodyUrl + "." + resultUrl
  else
    ?"HMAC Setup failed"
    return Invalid
  end if
end function

' validateJWT
' Validates the Hash or Certificate for the jwt
' 
' @param algorithm, Algorithm from the JWT header JSON
' @param jwtHeader, JWT Header in base64 string
' @param jwtBody, JWT Body in base64 string
' @param jwtSig, JWT Signature in base64 string
' @param key, Secret Key string used to sign JWT
' @return Bool if JWT is valid
function validateJWT(algorithm, jwtHeader, jwtBody, jwtSig, key)
  if algorithm = "HS256" then
    digest = "SHA256"
  else if algorithm = "HS384" then
    digest = "SHA384"
  else if algorithm = "HS512" then
    digest = "SHA512"
  else
    ?"Unknown Algorithm"; algorithm
    return false
  end if
  
  hmac = CreateObject("roHMAC")
  
  signature_key = CreateObject("roByteArray")
  signature_key.fromAsciiString(key)
  if hmac.setup(digest, signature_key) = 0 then
    message = CreateObject("roByteArray")
    message.fromAsciiString(jwtHeader + "." + jwtBody)
    result = hmac.process(message)
    sig = CreateObject("roByteArray")
    sig.FromBase64String(jwtSig)
    
    index = 0
    for each sigVal in sig
      if sigVal <> result[index] then
        return false
      end if
      index++
    end for

    return true
  else
    ?"HMAC setup failed!"
    return false
  end If
end function

' base64ToBase64Url
' Convert base64 to base64url
' 
' @param base64, base64 to convert to base64url
' @return Converted base64url
function base64ToBase64Url (base64)
  return base64.replace("+", "-").replace("/", "_").replace("=", "") ' + to -, / to _ and remove optional padding
end function

' base64UrlToBase64
' Convert base64url to base64
' 
' @param base64url, base64URL to convert to base64
' @return Converted base64
function base64UrlToBase64 (base64url)
  base64 = base64Url.replace("-", "+").replace("_","/")
  length = base64.len() mod 4
  
  ' Add required padding, optional in base64url
  if length < 3 then
    base64 = base64 + "=="
  else if length < 4 then
    base64 = base64 + "="
  end if
  
  return base64
end function