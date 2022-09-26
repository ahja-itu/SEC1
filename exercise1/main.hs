import Text.Printf
import Debug.Trace

debug = flip trace

-- Defining some constants used in the assignment
g = 666  -- The primitive root
p = 6661 -- The chosen prime number

-- Defining some helping functions
bruteforceSecretKey :: Integer -> Integer -> Integer -> Integer
bruteforceSecretKey base prime pk = bruteforceSecretKey' 0 where 
  bruteforceSecretKey' current =
    if (base ^ current) `mod` prime == pk 
      then current
      else bruteforceSecretKey' (succ current)
      
createKey :: Integer -> Integer -> Integer -> Integer
createKey base prime exponent = ((base ^ exponent) `mod` prime)-- `debug` ("crateKey(base: " ++ (show base) ++ ", prime: ")

encryptMsg :: Integer -> Integer -> Integer
encryptMsg sharedKey msg = sharedKey * msg

decryptMsg :: Integer -> Integer -> Integer
decryptMsg sharedKey msg = msg `div` sharedKey

-- Using the `tests` function to verify a working example from the video
-- https://www.youtube.com/watch?v=pyirxbHuvOw
tests = do
  let g = 5
  let p = 89
  let m = 35

  let bSK = 8
  let aSK = 13
  printf "[TESTS]: Initializing with values: g = %s, p = %s, m = %s\n" (show g) (show p) (show m)

  let bPK = createKey g p bSK
  let aPK = createKey g p aSK

  let bPKCheck = if bPK == 4 then "OK" else "FAILED"
  let aPKCheck = if aPK == 40 then "OK" else "FAILED"

  printf "[TESTS]: Alice PK check: expected 40, was %s. Check: %s\n" (show aPK) aPKCheck
  printf "[TESTS]: Bob PK check: expected 4, was %s. Check: %s\n" (show bPK) bPKCheck

  let bSharedKey = createKey aPK p bSK
  let aSharedKey = createKey bPK p aSK

  let sharedKeyCheck = if aSharedKey == bSharedKey then "OK" else "FAILED"
  printf "[TESTS]: Shared key equality check. %s == %s.. %s\n" (show aSharedKey) (show bSharedKey) sharedKeyCheck

  -- Alice encrypts the message:
  aEncryptedMsg = encryptMsg aSharedKey msg
  bEncryptMsg = encryptMsg bSharedKey msg

  let encryptedMsgCheck = if aEncryptedMsg == bEncryptMsg then "OK" else "FAILED"
  printf "[TESTS]: Encrypted msg equality check: %s\n" encryptedMsgCheck





  return ()



main :: IO Integer
main = do





  tests
  -----------------------------------------------------------------------------
  -- Assignment 1
  -----------------------------------------------------------------------------

  -- Alice wants to send Bob a confidential message and so this assignment 
  -- starts with Bob providing Alice with a public key.
  let bobPK = 2227

  -- Alice generates her own SK and PK to in order to generate the shared key
  let aliceSK = 414
  let alicePK = createKey g p aliceSK
  printf "Alice generates her SK/PK pair: (%s, %s)\n" (show aliceSK) (show alicePK)

  let sharedKey = createKey bobPK p aliceSK
  printf "Alice generates the shared key: %s\n" (show sharedKey)

  let message = 2000
  let messageEncrypted = encryptMsg sharedKey message
  printf "Alice encrypts the message \"%s\": %s\n" (show message) (show messageEncrypted)

  -- Alice now sends the pair C = (alicePK, messageEncrypted) to Bob
  printf "*** Alice sends the message to Bob ***\n"
  let (c1, c2) = (alicePK, messageEncrypted)


  -----------------------------------------------------------------------------
  -- Assignment 2
  -----------------------------------------------------------------------------

  -- Eve have not intercepted the encrypted message and will now attempt
  -- to find the secret key of Bob to reconstruct Alice message

  -- Eve can find Bob's secret key by making a brute force attack on his
  -- public key
  let bobSKBroken = bruteforceSecretKey g p bobPK
  -- Eve also needs to find out the secret key of alice
  let aliceSKBroken = bruteforceSecretKey g p c1
  -- Now Eve can proceed to decrypt the message
  let messageDecrypted = decryptMsg bobSKBroken 
  -- printf "Eve decrypts the intercepted message to: %s\n" (show messageDecrypted)

  return 0
